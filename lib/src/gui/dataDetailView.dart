import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:DataMaker/src/pokemon/pokemon.dart';
import 'package:flutter/material.dart';
import 'package:DataMaker/src/pokemon/dataContainer.dart';

class DataDetailView extends StatefulWidget {
  DataDetailView({Key key}) : super(key: key);

  @override
  createState() => _DataDetailViewState();
}

class _DataDetailViewState extends State<DataDetailView> {
  Pokemon pkm = DataContainer.selection();
  double evHeigth;
  int _currentIndex = 0;
  var _pages = [];

  @override
  Widget build(BuildContext context) {
    evHeigth = (90 * pkm.evolutions.length).toDouble();
    _pages = [_dataPage(), _evolPage(), _movesPage()];
    return WillPopScope(
      onWillPop: () => _onBackPressed(context),
      child: Scaffold(
        appBar: AppBar(
            title: Text("${DataContainer.selection().name}"),
            backgroundColor: DataContainer.selection().getColors()[0],
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => _onBackPressed(context),
            )),
        body: _pages.elementAt(_currentIndex),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          fixedColor: Colors.white,
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.leaderboard), label: "Data"),
            BottomNavigationBarItem(icon: Icon(Icons.upgrade), label: "Evol"),
            BottomNavigationBarItem(
                icon: Icon(Icons.data_usage), label: "Moves"),
          ],
          onTap: (int index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }

  Future<bool> _onBackPressed(BuildContext context) async {
    if (DataContainer.searching > 0) {
      DataContainer.searching--;
      if (DataContainer.searching == 1) {
        DataContainer.search(DataContainer.predecesor);
        DataContainer.predecesor = "";
        DataContainer.searching--;
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => DataDetailView()));
      } else if (DataContainer.searching > 1) {
        Navigator.pop(context);
      } else if (DataContainer.hasSearched) {
        DataContainer.hasSearched = false;
        Navigator.pop(context);
      }
    } else {
      Navigator.pop(context);
    }
    return true;
  }

  Widget _dataPage() {
    print(pkm.getTypeChart());
    return ListView(
      children: _iconList() +
          _typesList() +
          _habilitiesList() +
          _typesChartList() +
          _statsList() +
          _extraList(),
    );
  }

  List<Widget> _iconList() {
    return [
      _makeRoundedContainer(Text("#Número ${pkm.number}")),
      _makeRoundedContainer(SizedBox(
          width: 128,
          child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    alignment: Alignment.centerLeft,
                    fit: BoxFit.fitHeight,
                    image: MemoryImage(pkm.getIconBytes()),
                  ),
                ),
              )))),
      _makeRoundedContainer(Text("Nombre interno: ${pkm.internalName}"))
    ];
  }

  List<Widget> _typesList() {
    return [
      _makeRoundedContainer(Column(
        children: <Widget>[Text("Tipo(s):")] +
            _makeListString(pkm.types) +
            <Widget>[
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: pkm.getTypesImages())
            ],
      )),
    ];
  }

  List<Widget> _habilitiesList() {
    return [
      _makeRoundedContainer(Column(children: <Widget>[
        Text("Habilidades:"),
        _makeHabilitiesList(pkm.abilities + [pkm.hiddenAbi])
      ])),
    ];
  }

  List<Widget> _statsList() {
    return [
      _makeRoundedContainer(Text("Stats base")),
      _makeRoundedContainer(Table(
        border: TableBorder.all(color: Colors.white),
        children: [
          TableRow(children: [
            Text("HP"),
            Text("ATK"),
            Text("DEF"),
            Text("SP"),
            Text("SATK"),
            Text("SDEF"),
          ]),
          TableRow(children: _makeListString(pkm.stats)),
        ],
      )),
      _makeRoundedContainer(Text("Total stats: ${pkm.totalStats()}")),
    ];
  }

  List<Widget> _typesChartList() {
    List rows = <TableRow>[];

    pkm.getTypeChart().forEach((element) {
      List w = <Widget>[];
      element.forEach((t) {
        w.add(Text(
          "$t",
          textScaleFactor: 0.8,
        ));
      });
      rows.add(TableRow(children: w));
    });
    return [
      _makeRoundedContainer(Text("Daño recibido")),
      _makeRoundedContainer(Table(
        border: TableBorder.all(color: Colors.white),
        children: rows,
      ))
    ];
  }

  List<Widget> _extraList() {
    return [
      _makeRoundedContainer(Text("Datos extra")),
      _makeRoundedContainer(Column(
        children: [
          Text("Apariciones:\n${pkm.locations}"),
          Text("Felicidad base: ${pkm.happines}"),
          Text("Compatibilidad: ${pkm.compability}"),
          Text("Peso: ${pkm.weight} Kg"),
          Text("Pasos para eclosionar: ${pkm.stepsToHatch}"),
          Text("Evs que suelta:"),
          Table(
            border: TableBorder.all(color: Colors.white),
            children: [
              TableRow(children: [
                Text("HP"),
                Text("ATK"),
                Text("DEF"),
                Text("SP"),
                Text("SATK"),
                Text("SDEF"),
              ]),
              TableRow(children: _makeListString(pkm.evs)),
            ],
          ),
          Text("Pokédex: ${pkm.pokedex}"),
        ],
      ))
    ];
  }

  Widget _evolPage() {
    return ListView(
      children: [
        _makeRoundedContainer(Text("#Número ${pkm.number}")),
        _makeRoundedContainer(SizedBox(
            width: 128,
            child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      alignment: Alignment.centerLeft,
                      fit: BoxFit.fitHeight,
                      image: MemoryImage(pkm.getIconBytes()),
                    ),
                  ),
                )))),
        _makeRoundedContainer(Text("Evoluciones")),
        Column(
          children: _makeEvolutionsList(),
        ),
      ],
    );
  }

  Widget _movesPage() {
    return ListView(
      children: [
        _makeRoundedContainer(Text("#Número ${pkm.number}")),
        _makeRoundedContainer(SizedBox(
            width: 128,
            child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      alignment: Alignment.centerLeft,
                      fit: BoxFit.fitHeight,
                      image: MemoryImage(pkm.getIconBytes()),
                    ),
                  ),
                )))),
        _makeRoundedContainer(Column(
          children: [
            Text("Movimientos:"),
            Table(
                columnWidths: {
                  0: FlexColumnWidth(3),
                  1: FlexColumnWidth(2),
                  2: FlexColumnWidth(15)
                },
                border: TableBorder.all(
                  color: Colors.white,
                ),
                children: _movesRows(pkm.moves)),
            Text("TMs"),
            Table(
              columnWidths: {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(10),
              },
              border: TableBorder.all(color: Colors.white),
              children: _movesRows(pkm.tmMoves.map((e) => [e]).toList()),
            ),
            Text("Huevo:"),
            Table(
                columnWidths: {
                  0: FlexColumnWidth(3),
                  1: FlexColumnWidth(10),
                },
                border: TableBorder.all(color: Colors.white),
                children: _movesRows(pkm.eggMoves.map((e) => [e]).toList())),
          ],
        )),
      ],
    );
  }

  List<TableRow> _movesRows(List moves) {
    var rows = <TableRow>[];
    if (moves.isNotEmpty) {
      if (moves[0].length == 2) {
        rows.add(
            TableRow(children: [Text("Info"), Text("Nivel"), Text("Nombre")]));
      } else if (moves[0].length == 1) {
        rows.add(TableRow(children: [Text("Info"), Text("Nombre")]));
      }
    }
    moves.forEach((move) {
      int index = move.length > 1 ? 1 : 0;
      rows.add(TableRow(
          children: <Widget>[
                RaisedButton(
                  onPressed: () => _showMoveData(move[index]),
                  child: Icon(Icons.more_horiz),
                )
              ] +
              _makeListString(move)
                  .map((e) => GestureDetector(
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child: Center(child: e),
                      ),
                      onTap: () => _showMoveData(move[index])))
                  .toList()));
    });
    return rows;
  }

  _showMoveData(String move) {
    showAlertDialog(
        context: context, message: _moveStr(DataContainer.pkmMoves[move]));
  }

  String _moveStr(List move) {
    return "${move[1]}\n"
        "Potencia: ${move[2] == '0' ? '-' : move[2]}\n"
        "Tipo: ${move[3]}\n"
        "Categoría: ${move[4]}\n"
        "Presición: ${move[5] == '0' ? '-' : move[5]}\n"
        "PPs: ${move[6]}\n"
        "Probabilidad de efecto: ${move[7] == '0' ? '-' : move[7]}\n"
        "Descripción: ${move[8]}\n";
  }

  List<Widget> _makeListString(List str) {
    var l = <Widget>[];
    str.forEach((element) {
      l.add(Text("$element"));
    });
    return l;
  }

  Widget _makeRoundedContainer(Widget wd) {
    return Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.bottomRight,
                end: Alignment.bottomCenter,
                colors: pkm.getColors()),
            borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.all(5),
        margin: const EdgeInsets.all(5),
        alignment: Alignment.center,
        child: wd);
  }

  Widget _makeHabilitiesList(List habilities) {
    List<TableRow> rows = [];
    habilities.forEach((element) {
      rows.add(TableRow(children: [
        GestureDetector(
          child: Padding(
            padding: const EdgeInsets.only(top: 5, bottom: 5),
            child: Center(child: Text(element)),
          ),
          onTap: () {
            showAlertDialog(
                context: context,
                message: "${abilityStr(DataContainer.pkmAbilities[element])}");
          },
        )
      ]));
    });
    rows.insert(
        rows.length - 1, TableRow(children: [Center(child: Text("Oculta:"))]));
    return Table(
      border: TableBorder.all(color: Colors.white),
      children: rows,
    );
  }

  String abilityStr(List ability) {
    return "${ability[1]}\n"
        "Descripción: ${ability[2]}";
  }

  List<Widget> _makeEvolutionsList() {
    var tiles = <Widget>[];
    var evolutions = pkm.getEvolutiveLine();
    for (int i = 0; i < evolutions.length; i++) {
      String name = _normalizeName(evolutions[i][0]);
      tiles.add(
        GestureDetector(
            child: _makeRoundedContainer(
              Row(
                children: [
                  SizedBox(
                    width: 210,
                    child: ListTile(
                        title: Text(evolutions[i][0]),
                        subtitle:
                            Text("${evolutions[i][1]} ${evolutions[i][2]}"),
                        onTap: () => _navigateEvol(context, name)),
                  ),
                  _iconEvol(name),
                ],
              ),
            ),
            onTap: () => _navigateEvol(context, name)),
      );
    }
    return tiles;
  }

  String _normalizeName(String name) {
    if (name == "PORYGONZ") {
      name = "Porygon-Z";
    } else {
      name = "${name[0]}${name.substring(1).toLowerCase()}";
    }
    return name;
  }

  Widget _iconEvol(String name) {
    return SizedBox(
      width: 48,
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.fitHeight,
                  alignment: Alignment.centerLeft,
                  image: MemoryImage(
                      DataContainer.getPokemon(name).getIconBytes()))),
        ),
      ),
    );
  }

  _navigateEvol(BuildContext context, String name) {
    if (DataContainer.searching > 0) {
      DataContainer.searching++;
    }
    DataContainer.search(name);
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => DataDetailView()));
  }
}
