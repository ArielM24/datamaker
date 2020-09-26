import 'package:DataMaker/src/gui/dataDetailView.dart';
import 'package:DataMaker/src/pokemon/pokemon.dart';
import 'package:flutter/material.dart';

class dataSearch extends SearchDelegate {
  List suggestions = [];

  @override
  List<Widget> buildActions(BuildContext context) {
    // TODO: implement buildActions
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
    // TODO: implement buildLeading
    return IconButton(
        icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow,
          progress: transitionAnimation,
        ),
        onPressed: () {
          close(context, null);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
    return dataDetailView();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: implement buildSuggestions
    List results = (query.isEmpty)
        ? []
        : dataContainer.pkmData
            .where((pkm) =>
                (pkm.name.toLowerCase().startsWith(query.toLowerCase())) ||
                pkm.types.contains(query.toUpperCase()) ||
                (pkm.evolutions.indexWhere((evolution) =>
                        evolution.contains(query.toUpperCase())) >
                    -1))
            .toList();
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, i) {
        dataContainer.search(results[i].name);
        return Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomRight,
                  end: Alignment.bottomCenter,
                  colors: dataContainer.selection().getColors())),
          child: ListTile(
            leading: Icon(Icons.data_usage),
            title: Text(results[i].name),
            trailing: SizedBox(
                width: 120,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: results[i].getTypesImages())),
            onTap: () {
              dataContainer.search(results[i].name);
              showResults(context);
            },
          ),
        );
      },
    );
  }
}
