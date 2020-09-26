import 'package:DataMaker/src/gui/dataDetailView.dart';
import 'package:DataMaker/src/gui/dataSearch.dart';
import 'package:flutter/material.dart';
import 'package:DataMaker/src/pokemon/pokemon.dart';
import 'package:google_fonts/google_fonts.dart';

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
    return Scaffold(
        appBar: AppBar(
          title: Text("${path.split("/").last}"),
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
              leading: Text(
                "${dataContainer.pkmData[i].number}",
                style: GoogleFonts.lobster(),
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

  Widget _makeDetails(Pokemon p) {
    return ExpansionTile(
      title: Text("Tipos: ${p.types}\n"
          "Habilidades : ${p.abilities}\n"
          "Habilidad oculta: ${p.hiddenAbi}\n"
          "Stats base: ${p.stats}\n"
          "Movimientos: ${p.moves}\n"
          "Movimientos huevo: ${p.eggMoves}\n"),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("Felicidad: ${p.happines}\n"
              "Pasos para eclocionar ${p.stepsToHatch}\n"
              "Compatibilidad: ${p.compability}\n"
              "Evs que suelta: ${p.evs}\n"
              "Evoluciones: ${p.evolutions}\n"
              "Pokedex: ${p.pokedex}\n"),
        )
      ],
    );
  }
}
