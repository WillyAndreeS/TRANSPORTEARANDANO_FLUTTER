// ignore_for_file: prefer_if_null_operators

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:transporte_arandanov2/screens/mapbottompillhome.dart';
import 'package:transporte_arandanov2/screens/second_page.dart';
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

  final mycontrollertransp = TextEditingController();

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
          Uri.parse("${url_base}WSPowerBI/controller/transportearandano.php?accion=viajes&idtransp=$idtransp"),
          headers: {"Accept": "application/json"});
      setState(() {
        var extraerData = json.decode(response.body);
        data = extraerData["datos"];
      });
      print("NAME: $data");
    } else {
      print("CONTENIDO A BUSCAr: ${mycontrollertransp!.text}");
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
          Uri.parse("${url_base}WSPowerBI/controller/transportearandano.php?accion=viajestotal&nombre=${mycontrollertransp!.text}"),
          headers: {"Accept": "application/json"});
      setState(() {
      //  data!.removeLast();
        /*if (data != null) {

        }*/
        var extraerData = json.decode(response.body);
        data = extraerData["datos"];
        print("DATA: "+ data.toString());
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
    mycontrollertransp.text = "";
    recibirDatos();

  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // ignore: avoid_unnecessary_containers
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[

          placa == 'ADM'
              ?
          Container(
              margin: const EdgeInsets.only(left: 15),
              child:ClipRRect(
          borderRadius: BorderRadius.circular(4),
      child: Stack(

        children: <Widget>[
          Positioned.fill(
            child: Container(

              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[
                    Color(0xFF00AB74),
                    Color(0xFF00AB74),
                    Color(0xFF00AB74),
                  ],
                ),
              ),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.all(16.0),
              primary: Colors.white,
              textStyle: const TextStyle(fontSize: 14),
            ),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) => const CustomDialogsBuscar(
                      title: "GENERAR RUTA",
                      description:
                      'Selecciona el módulo en el que iniciarás el recojo de fruta',
                      imagen: "assets/images/distance.png"));
            },
            child: const Text('Crear Viaje'),
          ),
        ],
      ),
    )):Container(),
          SizedBox(height: 15,),
          placa == 'ADM'
              ?
          Container(
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
                        return null;
                      },
                      controller: mycontrollertransp,
                   //   onEditingComplete: recibirDatos,
                      decoration: InputDecoration(
                        hintText: 'Buscar',
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.only(left: 15.0, top: 15.0),
                        suffixIcon: IconButton(
                          onPressed: () {
                            print("QUE FUE: "+mycontrollertransp.text);
                            data!.clear();
                            recibirDatos();
                          },
                          icon: const Icon(Icons.search),
                          iconSize: 35.0,
                        ),
                      ),
                    /*  onChanged: (val) {
                        setState(() {
                          buscarTransp = val;
                        });
                      }*/))
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

class CustomDialogsBuscar extends StatefulWidget {
  final String? title, description, imagen;
  const CustomDialogsBuscar(
      {Key? key, this.title, this.description, this.imagen})
      : super(key: key);

  @override
  _CustomDialogsBuscarState createState() => _CustomDialogsBuscarState();
}

class _CustomDialogsBuscarState extends State<CustomDialogsBuscar> {
  int capacidadVehiculo = 900;
  // ignore: non_constant_identifier_names
  int cantidad_jabas = 0;
  List? data;
  var result;
  var resultviaje;
  double? latitudes, longitudes;
  String? aliasinicial;
  List? dataestado;
  String? dropdownValue;
  var dataacopio;
  int maxLength = 8;
  String text = "";
  int total = 0;
  String? actividad;
  String? moduloselect;
  var resultdetail;
  final myController = TextEditingController();
  var ddData = [];
  var ddacopios = [];
  int? cantidad_jabas_actual;
  int capacidad = 900;
  //String? idtransp;

  _guardarModulo(String modulo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("modulo", modulo);
  }

  Future<void> recibirDatos(
      String modulo,
      ) async {
    var extraerData;
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
                      Text("Buscando acopios")
                    ]),
                  )));
        });
    print("MODULO ENVIADO: $modulo");
    var response = await http.get(
        Uri.parse("${url_base}WSPowerBI/controller/transportearandano.php?accion=puntoiniciomanual1&modulo=$modulo"),
        headers: {"Accept": "application/json"});
    setState(() {
      extraerData = json.decode(response.body);
      data = extraerData["datos"];
      dataacopio = json.encode(extraerData["datos"]);
      if(data!.isEmpty){
        showDialog(
            context: context,
            builder: (context) =>
            const CustomDialogsActividad(
                title: "MENSAJE",
                description:
                'No hay acopios disponibles \n en este modulo',
                imagen:
                "assets/images/warning.png"));
        Navigator.pop(context);
      }else {
        print("ddata$dataacopio");
        aliasinicial = data![0]["ALIAS"];
        for (var i = 0; i < data!.length; i++) {
          cantidad_jabas = int.parse(data![i]["CANTIDAD_JABAS"]);
          latitudes = double.parse(data![i]["LATITUD"]);
          longitudes = double.parse(data![i]["LONGITUD"]);

          if (total <= capacidadVehiculo && cantidad_jabas > 0) {
            print("CANT JABAS$cantidad_jabas");
            var objeto = {"ALIAS": data![i]["ALIAS"]};
            total += cantidad_jabas;
            ddData.add(objeto);
          }
        }
        Navigator.pop(context);
      }
    });
    Navigator.pop(context);
  }

  Future<void> atualizarAcopios(String pacopios, int tipo) async {
    var response = await http.get(
        Uri.parse("${url_base}acp/index.php/transportearandano/setAcopios?accion=estado&alias=$pacopios&tipo=$tipo"),
        headers: {"Accept": "application/json"});
    if (mounted) {
      setState(() {
        var extraerData = json.decode(response.body);
        result = extraerData["state"];
        //  print("RESULTADO: " + result.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      elevation: 0,
      backgroundColor: Colors.white,
      child: dialogContents(context),
    );
  }

  dialogContents(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
          margin: const EdgeInsets.only(top: 20),
          decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(50),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: Offset(0.0, 10.0),
                )
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset(
                widget.imagen!,
                width: 64,
                height: 64,
              ),
              const SizedBox(height: 20.0),
              Text(
                widget.title!,
                style: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Divider(),
              const SizedBox(height: 10.0),
              Text(
                widget.description!,
                style: const TextStyle(fontSize: 15.0),
                //textAlign: TextAlign.justify,
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: <Widget>[
                  Flexible(
                    child: TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Debe ingresar el número de DNI';
                        } else if (value.length != 8) {
                          return 'El numero de DNI debe ser 8 dígitos';
                        }
                      },
                      onChanged: (String newVal) {
                        if (newVal.length <= maxLength) {
                          text = newVal;
                        } else {
                          myController.value = TextEditingValue(
                              text: text,
                              selection: TextSelection(
                                  baseOffset: maxLength,
                                  extentOffset: maxLength,
                                  affinity: TextAffinity.downstream,
                                  isDirectional: false),
                              composing:
                              TextRange(start: 0, end: maxLength));
                              myController.text = text;
                        }
                      },
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      cursorColor: kPrimaryColor,
                      controller: myController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: 'DNI',
                        //labelStyle: TextStyle(color: Colors.grey),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: const BorderSide(
                            color: kPrimaryColor,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: const BorderSide(
                            color: Colors.grey,
                            width: 2.0,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              DropdownButton<String>(
                value: dropdownValue,
                icon: const Icon(Icons.arrow_downward),
                iconSize: 24,
                elevation: 16,
                hint: const Text('Selecciona el módulo'),
                style: const TextStyle(color: Colors.deepPurple),
                underline: Container(
                  height: 2,
                  color: Colors.deepPurpleAccent,
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownValue = newValue;
                  });
                },
                items: <String>[
                  "MODULO 01",
                  "MODULO 02",
                  "MODULO 03",
                  "MODULO 04",
                  "MODULO 05",
                  "MODULO 06",
                  "MODULO 07",
                  "MODULO 08",
                  "MODULO 09",
                  "MODULO 10",
                  "MODULO 11",
                  "MODULO 12",
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                      value: value, child: Text(value));
                }).toList(),
              ),
              const SizedBox(height: 24.0),
              Row(
                children: <Widget>[
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      decoration: BoxDecoration(
                          color: kPrimaryColor,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10.0,
                              offset: Offset(0.0, 10.0),
                            )
                          ]),
                      child: TextButton(
                          onPressed: () async {
                            String? actividad;
                            print(
                                "VALOR DROPDOWN: $dropdownValue");
                            // ignore: unnecessary_null_comparison
                            if (dropdownValue == null) {
                              showDialog(
                                  context: context,
                                  builder: (context) =>
                                  const CustomDialogsActividad(
                                      title: "MENSAJE",
                                      description:
                                      'Debes Seleccionar un módulo de destino',
                                      imagen: "assets/images/warning.png"));
                            } else {
                                moduloselect = dropdownValue.toString().substring(7);
                                //_guardarModulo(moduloselect!);
                                await recibirDatos(moduloselect!);
                              //  setState(() {
                                  print("ESTADO NULL: $data");
                                  if(data!.isEmpty) {
                                    showDialog(
                                        context: context,
                                        builder: (context) =>
                                        const CustomDialogsActividad(
                                            title: "MENSAJE",
                                            description:
                                            'No hay acopios disponibles \n en este modulo',
                                            imagen:
                                            "assets/images/warning.png"));
                                    // Navigator.pop(context);
                                  }else{
                                    String idtransp = myController.text;
                                    print("TRANSPORTISTAAAA: $idtransp");
                                    var response = await http.post(
                                        Uri.parse("${url_base}acp/index.php/transportearandano/setViaje"),
                                        body: {
                                          // "accion": "viaje",
                                          "idtransp": idtransp,
                                          "tbox": "0",
                                          "tdistance": "0.00",
                                          "estado": "0",
                                          "ruta": "-",
                                          "vehiculo": placa.toString(),
                                        });
                                  //  if (mounted) {
                                   //   setState(() {
                                        print("RESPONSE BODY: ${response.body}");

                                        var extraerData = json.decode(response.body);
                                        resultviaje = extraerData["state"];
                                        print("RESULTADO DE INSERCIÓN: ${extraerData["state"]}");
                                //      });
                                //    }
                                    for (var i = 0; i < data!.length; i++) {
                                       if (total <= capacidad! && cantidad_jabas! > 0) {
                                        cantidad_jabas_actual = int.parse(data![i]["CANTIDAD_JABAS"]);
                                        total += cantidad_jabas!;
                                        if (total > 0) {
                                          var objeto = {"ALIAS": data![i]["ALIAS"]};
                                          ddData.add(objeto);
                                          var acopiosViaje = {
                                            // Le agregas la fecha
                                            "ALIAS": data![i]["ALIAS"],
                                            "CANTIDAD_JABAS": data![i]["CANTIDAD_JABAS"],
                                            "LATITUD": data![i]["LATITUD"],
                                            "LONGITUD": data![i]["LONGITUD"],
                                            "SALDO":
                                            capacidad! >= cantidad_jabas! ? cantidad_jabas : capacidad
                                          };
                                          ddacopios.add(acopiosViaje);
                                        }
                                      }
                                    }
                                    for (var i = 0; i < ddacopios.length; i++) {
                                      var responsedetail = await http.get(
                                          Uri.parse("${"${url_base +
                                              "acp/index.php/transportearandano/setViajeDetail?accion=viajedetail&idviajes=" +
                                              resultviaje +
                                              "&alias=" +
                                              ddacopios[i]["ALIAS"] +
                                              "&latitud=" +
                                              ddacopios[i]["LATITUD"] +
                                              "&longitud=" +
                                              ddacopios[i]["LONGITUD"]}&cantjabas=" +
                                              ddacopios[i]["CANTIDAD_JABAS"]}&jabascargadas=0"),
                                          headers: {"Accept": "application/json"});
                                      if (mounted) {
                                        setState(() {
                                          var extraerData = json.decode(responsedetail.body);
                                          resultdetail = extraerData["state"];
                                          print("RESULTADO DE DETALLE: $resultdetail");
                                        });
                                      }
                                      atualizarAcopios(ddacopios[i]["ALIAS"], 0);
                                    }


                                  }
                                Navigator.pop(context);
                                //});
                            }
                          },
                          child: const Text(
                            "Confirmar",
                            style: TextStyle(color: Colors.white),
                          )),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      decoration: BoxDecoration(
                          color: kDarkSecondaryColor,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10.0,
                              offset: Offset(0.0, 10.0),
                            )
                          ]),
                      child: TextButton(
                        //color: kArandano,
                          onPressed: () {
                            for (var i = 0; i < ddData.length; i++) {
                              atualizarAcopios(ddData[i]["ALIAS"], 1);
                            }
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Cancelar",
                            style: TextStyle(color: Colors.white),
                          )),
                    ),
                  ),
                ],
              )
            ],
          ),
        )
      ],
    );
  }
}


class CustomDialogsActividad extends StatelessWidget {
  final String? title, description, buttontext, imagen;
  final Image? image;

  const CustomDialogsActividad(
      {Key? key,
        this.title,
        this.description,
        this.buttontext,
        this.image,
        this.imagen})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: dialogContents(context),
    );
  }

  dialogContents(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Stack(
      children: <Widget>[
        Container(
          padding:
          const EdgeInsets.only(top: 50, bottom: 16, left: 16, right: 16),
          margin: const EdgeInsets.only(top: 16),
          decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(50),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: Offset(0.0, 10.0),
                )
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: 40.0),
              Text(
                title!,
                style: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Divider(),
              const SizedBox(height: 10.0),
              Text(
                description!,
                style: const TextStyle(fontSize: 15.0),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 12.0),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "OK",
                    style: TextStyle(
                        fontWeight: FontWeight.w700, color: Colors.grey),
                  ),
                ),
              )
            ],
          ),
        ),
        Positioned(
          top: 0,
          left: size.width / 3.5,
          //right: 16,
          child: CircleAvatar(
            backgroundColor: Colors.white,
            radius: 50,
            backgroundImage: AssetImage(imagen!),
          ),
        )
      ],
    );
  }
}