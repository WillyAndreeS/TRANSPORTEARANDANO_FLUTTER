// ignore_for_file: prefer_if_null_operators

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:transporte_arandanov2/screens/mapbottompillhome.dart';
import '../../constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

//var idtransp = "0";
int capacidadVehiculo = 0;
int idVehiculo = 0;
bool updateValue = false;
String? placa;
String? name;

// ignore: must_be_immutable
class MyStatelessWidget extends StatefulWidget {
  String? transportista;
  MyStatelessWidget({Key? key, this.transportista}) : super(key: key);

  @override
  State<MyStatelessWidget> createState() => MyStatelessWidgetState();
}

class MyStatelessWidgetState extends State<MyStatelessWidget> {
  List? data;
  String buscarTransp = " ";
  TextEditingController? mycontrollertransp;
  Future<void> recibirDatos() async {
    // ignore: prefer_typing_uninitialized_variables
    var idtransp;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      idtransp = prefs.get("id") ?? 0;
      placa = (prefs.get("placa") ?? "-") as String?;
    });

    if (placa != 'ADM') {
      var response = await http.get(
          Uri.parse(url_base +
              "WSPowerBI/controller/transportearandano.php?accion=viajes&idtransp=" +
              idtransp.toString()),
          headers: {"Accept": "application/json"});
      setState(() {
        var extraerData = json.decode(response.body);
        data = extraerData["datos"];
      });
      print("NAME: " + data.toString());
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            Size size = MediaQuery.of(context).size;
            return Center(
                child: AlertDialog(
                    backgroundColor: Colors.transparent,
                    content: Container(
                      color: Colors.white,
                      height: size.height / 7,
                      padding: const EdgeInsets.all(20),
                      child: Column(children: const <Widget>[
                        CircularProgressIndicator(),
                        SizedBox(height: 5),
                        Text("cargando viajes")
                      ]),
                    )));
          });
      var response = await http.get(
          Uri.parse(url_base +
              "WSPowerBI/controller/transportearandano.php?accion=viajestotal&nombre=" +
              buscarTransp),
          headers: {"Accept": "application/json"});
      setState(() {
        if (data != null) {
          data!.clear();
        }
        var extraerData = json.decode(response.body);
        data = extraerData["datos"];
      });
      Navigator.pop(context);
    }
  }

  _estadoSesion() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = (prefs.get("name") ?? "Usuario") as String?;
      placa = (prefs.get("placa") ?? "-") as String?;
    });
  }

  @override
  void initState() {
    super.initState();
    _estadoSesion();
    recibirDatos();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // ignore: avoid_unnecessary_containers
    return Container(
      child: Column(
        children: <Widget>[
          placa == 'ADM'
              ? Container(
                  height: 50.0,
                  margin: const EdgeInsets.only(left: 15, right: 15),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(0.0, 1.0),
                        blurRadius: 1.0,
                      ),
                    ],
                  ),
                  child: TextFormField(
                      //  keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Debe ingresar el nombre del conductor';
                        }
                      },
                      controller: mycontrollertransp,
                      onEditingComplete: recibirDatos,
                      decoration: InputDecoration(
                        hintText: 'Buscar',
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.only(left: 15.0, top: 15.0),
                        suffixIcon: IconButton(
                          onPressed: () {
                            recibirDatos();
                          },
                          icon: const Icon(Icons.search),
                          iconSize: 35.0,
                        ),
                      ),
                      onChanged: (val) {
                        setState(() {
                          buscarTransp = val;
                        });
                      }))
              : Container(
                  margin: const EdgeInsets.only(top: 20, left: 20),
                  child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "VIAJES DE HOY",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      )),
                ),
          const SizedBox(
            height: 15,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SizedBox(
              height: size.height / 1.5,
              child: data == null
                  ? const Center(
                      child: Text("No ha realizado viajes hoy",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                    )
                  : data!.isEmpty
                      ? Container(
                          margin: EdgeInsets.only(
                            top: size.height / 5,
                            bottom: kDefaultPadding / 4,
                          ),
                          child: Column(
                            children: <Widget>[
                              Container(
                                margin: const EdgeInsets.only(
                                  top: kDefaultPadding / 4,
                                  bottom: kDefaultPadding,
                                ),
                                width: size.width * 0.9,
                                height: size.height * 0.1,
                                child: const DecoratedBox(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(
                                          'assets/images/logo_color_h.png'),
                                      // ...
                                    ),
                                    // ...
                                  ),
                                ),
                              ),
                              const Text("No ha realizado viajes hoy",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: data == null ? 0 : data!.length,
                          itemBuilder: (BuildContext context, i) {
                            if (data!.isEmpty) {
                              return const Center(
                                  child: Text("No ha realizado viajes hoy",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black)));
                            } else {
                              return Container(
                                  child: placa == 'ADM'
                                      ? MapBottomPillHome(
                                          numeroViaje: data![i]["NAMETRANSP"] == null
                                              ? '001'
                                              : data![i]["NAMETRANSP"] +
                                                  ' ' +
                                                  (data!.length - i).toString(),
                                          // ignore: unnecessary_null_comparison
                                          cantjabas:
                                              // ignore:  unnecessary_null_comparison
                                              int.parse(data![i]["TBOX"]) == null
                                                  ? 0
                                                  : int.parse(data![i]["TBOX"]),
                                          // ignore: unnecessary_null_comparison
                                          distance:
                                              // ignore: unnecessary_null_comparison
                                              double.parse(data![i]["TDISTANCE"]) == null
                                                  ? 0
                                                  : double.parse(
                                                      data![i]["TDISTANCE"]),
                                          // ignore: unnecessary_null_comparison
                                          tiempo: int.parse(data![i]["TTIME"]) == null
                                              ? 1
                                              : int.parse(data![i]["TTIME"]),
                                          finicio: data![i]["TFINICIO"] ??
                                              '00/00/00  00:00:00',
                                          ffin: data![i]["TFFIN"] ??
                                              '00/00/00  00:00:00',
                                          // ignore: unnecessary_null_comparison
                                          idviajes: int.parse(data![i]["IDVIAJES"]) == null
                                              ? 0
                                              : int.parse(data![i]["IDVIAJES"]),
                                          // ignore: unnecessary_null_comparison
                                          estado: int.parse(data![i]["ESTADO"]) == null
                                              ? 1
                                              : int.parse(data![i]["ESTADO"]),
                                          ruta: data![i]["RUTA"] == null
                                              ? "ruta"
                                              : data![i]["RUTA"],
                                          nombre: name ?? "USUARIO",
                                          placa: placa ?? "-")
                                      // ignore:  unnecessary_null_comparison
                                      : MapBottomPillHome(
                                          numeroViaje: data![i]["TNAME"] == null
                                              ? '001'
                                              : data![i]["TNAME"] +
                                                  ' ' +
                                                  (data!.length - i).toString(),
                                          // ignore: unnecessary_null_comparison
                                          cantjabas: int.parse(data![i]["TBOX"]) == null ? 0 : int.parse(data![i]["TBOX"]),
                                          // ignore: unnecessary_null_comparison
                                          distance: double.parse(data![i]["TDISTANCE"]) == null ? 0 : double.parse(data![i]["TDISTANCE"]),
                                          // ignore: unnecessary_null_comparison
                                          tiempo: int.parse(data![i]["TTIME"]) == null ? 1 : int.parse(data![i]["TTIME"]),
                                          finicio: data![i]["TFINICIO"] == null ? '00/00/00  00:00:00' : data![i]["TFINICIO"],
                                          ffin: data![i]["TFFIN"] == null ? '00/00/00  00:00:00' : data![i]["TFFIN"],
                                          // ignore: unnecessary_null_comparison
                                          idviajes: int.parse(data![i]["IDVIAJES"]) == null ? 0 : int.parse(data![i]["IDVIAJES"]),
                                          // ignore: unnecessary_null_comparison
                                          estado: int.parse(data![i]["ESTADO"]) == null ? 1 : int.parse(data![i]["ESTADO"]),
                                          ruta: data![i]["RUTA"] == null ? "ruta" : data![i]["RUTA"],
                                          nombre: name == null ? "USUARIO" : name,
                                          placa: placa == null ? "-" : placa));
                              //  MapBottomPillHome();
                            }
                          },
                        ),
              //    ],
            ),
          ),
        ],
      ),
    );
  }
}

class FeaturePlantCard extends StatelessWidget {
  const FeaturePlantCard({
    Key? key,
    // this.image,
    this.press,
  }) : super(key: key);
  // final String image;
  final VoidCallback? press;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
        onTap: press,
        child: Column(
          children: <Widget>[
            Container(
                margin: const EdgeInsets.only(
                  top: kDefaultPadding / 4,
                  bottom: kDefaultPadding / 4,
                ),
                width: size.width * 0.9,
                height: size.height / 7,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10.0,
                        offset: Offset(0.0, 10.0),
                      )
                    ]),
                child: Container(
                  width: 10,
                  alignment: Alignment.centerLeft,
                  color: kPrimaryColor,
                )),
          ],
        ));
  }
}
