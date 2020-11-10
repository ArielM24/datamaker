import 'package:datamaker/src/gui/dataDetailView.dart';
import 'package:datamaker/src/gui/dataSearch.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:datamaker/src/pokemon/dataContainer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'dart:io';

class DataView extends StatefulWidget {
  final String path;
  DataView(this.path, {Key key}) : super(key: key);
  @override
  createState() => _DataView(path);
}

class _DataView extends State<DataView> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String path;
  int index = 1;
  String name;
  var scrollControler = ScrollController();
  _DataView(this.path);
  @override
  void initState() {
    super.initState();
    _setData();
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows) {
      name = path.split("\\").last;
    } else {
      name = path.split("/").last;
    }
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(
            "$name",
            overflow: TextOverflow.fade,
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: IconButton(
                icon: Icon(Icons.menu),
                onPressed: () {
                  _scaffoldKey.currentState.openDrawer();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    showSearch(context: context, delegate: DataSearch());
                  }),
            )
          ],
        ),
        body: Center(
            child: DraggableScrollbar.arrows(
          controller: scrollControler,
          labelTextBuilder: (double offset) {
            num n = offset * (DataContainer.pkmData.length / 50000);
            if (n < 1) n = 1;
            return Text(
              "${n.toInt()}",
              style: TextStyle(color: Colors.black87),
            );
          },
          child: ListView.builder(
              controller: scrollControler,
              itemCount: index,
              itemBuilder: (context, int i) {
                return makeList(context, i);
              }),
        )),
        drawer: _makeDrawer());
  }

  Widget _makeDrawer() {
    return Drawer(
        child: ListView(
      children: [
        DrawerHeader(
          child: Center(child: Text("$name\nSearch stats")),
        ),
        ListTile(
          title: RaisedButton(
              color: Colors.blue,
              child: Text("Number"),
              onPressed: _statSearch),
        ),
        ListTile(
          title: RaisedButton(
              color: Colors.blue,
              child: Text("Range"),
              onPressed: _rangeSearch),
        ),
      ],
    ));
  }

  _statSearch() async {
    var stat = await showTextInputDialog(
        context: context,
        textFields: [DialogTextField()],
        message: "Total stats");
    if (stat != null) {
      _showResults(stat);
    }
  }

  _rangeSearch() async {
    var stat = await showTextInputDialog(
        context: context,
        textFields: [DialogTextField(), DialogTextField(), DialogTextField()],
        message: "Total stats, range (-total, +total)");
    if (stat != null) {
      _showResults(stat);
    }
  }

  _showResults(List stat) {
    int n, inf = 0, sup = 0;
    n = int.parse(stat[0]);
    if (stat.length > 2) {
      inf = int.parse(stat[1]);
      sup = int.parse(stat[2]);
    }
    var res = DataContainer.searchStats(n, inf, sup);
    List<AlertDialogAction> acts = [];
    bool first = true;
    res.forEach((element) {
      acts.add(AlertDialogAction(label: element, isDefaultAction: first));
      first = false;
    });
    showConfirmationDialog(
      context: context,
      message: "${res.length} Results",
      title: "Results",
      actions: acts,
    );
  }

  Widget makeList(BuildContext context, int i) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.bottomRight,
                end: Alignment.bottomCenter,
                colors: DataContainer.pkmData[i].getColors())),
        child: Column(
          children: [
            ListTile(
              leading: SizedBox(
                width: 120,
                child: Row(
                  children: [
                    Text(
                      "${DataContainer.pkmData[i].number}",
                      style: GoogleFonts.lobster(),
                    ),
                    SizedBox(width: 30),
                    SizedBox(
                      width: 48,
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  fit: BoxFit.fitHeight,
                                  alignment: Alignment.centerLeft,
                                  image: MemoryImage(DataContainer.pkmData[i]
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
                  children: DataContainer.pkmData[i].getTypesImages(),
                ),
              ),
              title: Text(
                "${DataContainer.pkmData[i].name}",
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
    DataContainer.selected = index;
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => DataDetailView()));
  }

  _setData() {
    index = DataContainer.pkmData.length;
  }
}
