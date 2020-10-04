import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:DataMaker/src/pokemon/pokemon.dart';
import 'package:flutter/material.dart';

class dataDetailView extends StatefulWidget {
  dataDetailView({Key key}) : super(key: key);

  @override
  createState() => _dataDetailViewState();
}

class _dataDetailViewState extends State<dataDetailView> {
  Pokemon pkm = dataContainer.selection();
  double evHeigth;

  @override
  Widget build(BuildContext context) {
    evHeigth = (90 * pkm.evolutions.length).toDouble();
    return Scaffold(
        appBar: AppBar(
            title: Text("${dataContainer.selection().name}"),
            backgroundColor: dataContainer.selection().getColors()[0],
            centerTitle: true,
            leading: IconButton(
              icon: Image.asset("assets/pokemon-go.png"),
              onPressed: () {
                Navigator.pop(context);
              },
            )),
        body: ListView(children: [
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
            children: <Widget>[Text("Tipo(s):")] +
                _makeListString(pkm.types) +
                <Widget>[
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: pkm.getTypesImages())
                ],
          )),
          _makeRoundedContainer(Column(
              children: <Widget>[Text("Habilidades:")] +
                  _makeListString(pkm.abilities +
                      [
                        "${(pkm.hiddenAbi != '') ? 'Oculta: ${pkm.hiddenAbi}' : ''}"
                      ]))),
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
          _makeRoundedContainer(Column(
            children: [
              Text("Movimientos:"),
              Table(
                  border: TableBorder.all(
                    color: Colors.white,
                  ),
                  children: _movesRows(pkm.moves)),
              Text("TMs"),
              Table(
                border: TableBorder.all(color: Colors.white),
                children: [],
              ),
              Text("Huevo:"),
              Table(
                  border: TableBorder.all(color: Colors.white),
                  children: _movesRows(pkm.eggMoves.map((e) => [e]).toList())),
            ],
          )),
          _makeRoundedContainer(Text("Evoluciones")),
          Column(
            children: _makeEvolutionsList(),
          ),
          _makeRoundedContainer(Text("Datos extra")),
          _makeRoundedContainer(Column(
            children: [
              Text("Felicidad base: ${pkm.happines}"),
              Text("Compatibilidad: ${pkm.compability}"),
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
        ]));
  }

  List<TableRow> _movesRows(List moves) {
    var rows = <TableRow>[];

    moves.forEach((move) {
      int index = move.length > 1 ? 1 : 0;
      rows.add(TableRow(
          children: _makeListString(move)
              .map((e) => GestureDetector(
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: e,
                    ),
                    onTap: () {
                      showAlertDialog(
                          context: context,
                          message:
                              _moveStr(dataContainer.pkmMoves[move[index]]));
                    },
                  ))
              .toList()));
    });
    return rows;
  }

  String _moveStr(List move) {
    String str = "${move[1]}\n"
        "Potencia: ${move[2] == '0' ? '-' : move[2]}\n"
        "Tipo: ${move[3]}\n"
        "Categoría: ${move[4]}\n"
        "Presición: ${move[5] == '0' ? '-' : move[5]}\n"
        "PPs: ${move[6]}\n"
        "Probabilidad de efecto: ${move[7] == '0' ? '-' : move[7]}\n"
        "Descripción: ${move[8]}\n";

    return str;
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

  List<Widget> _makeEvolutionsList() {
    var tiles = <Widget>[];
    for (int i = 0; i < pkm.evolutions.length; i++) {
      tiles.add(_makeRoundedContainer(
        ListTile(
          title: Text(pkm.evolutions[i][0]),
          subtitle: Text("${pkm.evolutions[i][1]} ${pkm.evolutions[i][2]}"),
          onTap: () {
            String name = pkm.evolutions[i][0];
            if (name == "PORYGONZ") {
              name = "Porygon-Z";
              dataContainer.search(name);
            } else {
              dataContainer
                  .search("${name[0]}${name.substring(1).toLowerCase()}");
            }
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => dataDetailView()));
          },
        ),
      ));
    }
    return tiles;
  }
}
