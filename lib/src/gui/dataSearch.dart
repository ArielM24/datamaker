import 'package:DataMaker/src/gui/dataDetailView.dart';
import 'package:flutter/material.dart';
import 'package:DataMaker/src/pokemon/dataContainer.dart';

class DataSearch extends SearchDelegate {
  int index;
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = "";
          })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow,
          progress: transitionAnimation,
        ),
        onPressed: () {
          if (DataContainer.hasSearched) {
            DataContainer.searching--;
            if (DataContainer.searching == 0) {
              DataContainer.hasSearched = false;
            }
          }
          close(context, null);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    return DataDetailView();
  }

  List _results() {
    return (query.isEmpty)
        ? []
        : DataContainer.pkmData
            .where((pkm) =>
                (pkm.name.toLowerCase().startsWith(query.toLowerCase())) ||
                (pkm.internalName
                    .toLowerCase()
                    .startsWith(query.toLowerCase())) ||
                pkm.types.contains(query.toUpperCase()) ||
                (pkm.evolutions.indexWhere((evolution) =>
                        evolution.contains(query.toUpperCase())) >
                    -1))
            .toList();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List results = _results();
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, i) {
        DataContainer.search(results[i].name);
        return Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomRight,
                  end: Alignment.bottomCenter,
                  colors: DataContainer.selection().getColors())),
          child: ListTile(
            leading: SizedBox(
                width: 120,
                child: Row(
                  children: [
                    Icon(Icons.data_usage),
                    SizedBox(
                      width: 30,
                    ),
                    SizedBox(
                        width: 48,
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  fit: BoxFit.fitHeight,
                                  alignment: Alignment.centerLeft,
                                  image:
                                      MemoryImage(results[i].getIconBytes())),
                            ),
                          ),
                        ))
                  ],
                )),
            title: Text(results[i].name),
            trailing: SizedBox(
                width: 120,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: results[i].getTypesImages())),
            onTap: () {
              if (DataContainer.searching > 0) {
                DataContainer.searching = 0;
                DataContainer.predecesor = results[i].name;
                DataContainer.hasSearched = true;
              } else {
                DataContainer.predecesor = results[i].name;
                DataContainer.hasSearched = true;
              }
              DataContainer.searching++;
              DataContainer.search(results[i].internalName, true);
              showResults(context);
            },
          ),
        );
      },
    );
  }
}
