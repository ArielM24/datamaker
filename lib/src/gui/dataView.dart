import 'package:DataMaker/src/gui/dataDetailView.dart';
import 'package:DataMaker/src/gui/dataSearch.dart';
import 'package:flutter/material.dart';
import 'package:DataMaker/src/pokemon/pokemon.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';


class dataView extends StatefulWidget {
  String path;

  dataView(this.path, {Key key}) : super(key: key);
  @override
  createState() => _dataView(path);
}

class _dataView extends State<dataView> {
  String path;
  int index = 1;
  var scrollControler = ScrollController();
  //List<Pokemon> pkm = [];
  _dataView(this.path);
  @override
  void initState() {
    super.initState();
    _setData();
  }

  @override
  Widget build(BuildContext context) {
    String name;
    if(Platform.isWindows){
      name = path.split("\\").last;
    }else{
      name = path.split("/").last;
    }
    return Scaffold(
        appBar: AppBar(
          title: Text("$name"),
          leading: IconButton(
            icon: Image.asset("assets/pokemon-go.png"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  showSearch(context: context, delegate: dataSearch());
                })
          ],
        ),
        body: Center(
            child: Scrollbar(
          //labelTextBuilder: (double offset) => Text("${offset ~/ 100}"),

          controller: scrollControler,
          child: ListView.builder(
              controller: scrollControler,
              itemCount: index,
              itemBuilder: (context, int i) {
                return makeList(context, i);
              }),
        )));
  }

  Widget makeList(BuildContext context, int i) {
    //dataContainer.selected = i;
    return Card(
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.bottomRight,
                end: Alignment.bottomCenter,
                colors: dataContainer.pkmData[i].getColors())),
        child: Column(
          children: [
            ListTile(
              leading: SizedBox(
                width: 120,
                child: Row(
                  children: [
                    Text(
                      "${dataContainer.pkmData[i].number}",
                      style: GoogleFonts.lobster(),
                    ),
                    SizedBox(width: 30),
                    SizedBox(
                      width: 56,
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  fit: BoxFit.fitHeight,
                                  alignment: Alignment.centerLeft,
                                  image: MemoryImage(dataContainer.pkmData[i]
                                      .getIconBytes()))),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              trailing: SizedBox(
                width: 120,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: dataContainer.pkmData[i].getTypesImages(),
                ),
              ),
              title: Text(
                "${dataContainer.pkmData[i].name}",
              ),
              onTap: () {
                _changeView(context, i);
              },
            ),
          ],
        ),
      ),
      elevation: 5,
    );
  }

  _changeView(BuildContext context, int index) {
    dataContainer.selected = index;
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => dataDetailView()));
  }

  _setData() {
    index = dataContainer.pkmData.length;
  }
}
