// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:transporte_arandanov2/constants.dart';
import 'package:transporte_arandanov2/database/database.dart';
import 'package:transporte_arandanov2/model/consumidores_model.dart';
import 'package:transporte_arandanov2/model/user_model.dart';
import 'package:transporte_arandanov2/model/variedades_model.dart';
import 'package:transporte_arandanov2/screens/intro_slider/home_slider.dart';
import 'package:transporte_arandanov2/screens/second_page.dart';
import 'package:path/path.dart' as pat;

String? _nombre;
var idtransp = "0";
int? estadoSincronizacion = 0;
int? estadoIntro;
int? codigoInternet = 1;

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        body: Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/arandano2.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(
                top: kDefaultPadding / 4,
                bottom: kDefaultPadding / 2,
              ),
              width: size.width * 0.9,
              height: size.height * 0.1,
              decoration: BoxDecoration(
                  //color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  image: const DecorationImage(
                    image: AssetImage("assets/images/logo_actionbar_nuevo.png"),
                    fit: BoxFit.cover,
                  )),
            ),
            const FeaturePlantCard(),
          ],
        ),
      ),
    ));
  }
}

class FeaturePlantCard extends StatefulWidget {
  const FeaturePlantCard({
    Key? key,
    // this.image,
    this.press,
  }) : super(key: key);
  // final String image;
  final VoidCallback? press;

  @override
  State<FeaturePlantCard> createState() => FeaturePlantCardState();
}

class FeaturePlantCardState extends State<FeaturePlantCard> {
  List? data;
  List? datavariedades;
  List? dataconsumidores;
  int capacidadVehiculo = 0;
  String? placa;
  String? tipouser;
  final myController = TextEditingController();
  List? datavehiculos;

  Future<void> recibirDatos() async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var response = await http.get(
            Uri.parse(url_base +
                "WSPowerBI/controller/transportearandano.php" +
                "?accion=user"),
            headers: {"Accept": "application/json"});
        if (mounted) {
          setState(() {
            var extraerData = json.decode(response.body);
            data = extraerData["datos"];
          });
        }
        print('connected');
      }
    } on SocketException catch (_) {
      codigoInternet = 0;
      Widget okButton = FloatingActionButton(
        child: const Text("OK"),
        onPressed: () {
          Navigator.pop(context);
        },
      );
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return Center(
                child: AlertDialog(
                    content: const Text('Revisa tu conexión a internet'),
                    actions: [okButton]));
          });
      print('not connected');
    }
    Navigator.pop(context);
    //print("NAME: " + data[0]['TRANSPNAME']);
  }

  Future<void> recibirDatosBarras() async {
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
                      Text("Obteniendo consumidores")
                    ]),
                  )));
        });
    var response = await http.get(
        Uri.parse(url_base +
            "WSPowerBI/controller/transportearandano.php" +
            "?accion=detallebarrastotal"),
        headers: {"Accept": "application/json"});
    if (mounted) {
      setState(() {
        var extraerData = json.decode(response.body);
        dataconsumidores = extraerData["datos"];
      });
    }
    Navigator.pop(context);
  }

  Future<void> recibirDatosVariedades() async {
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
                      Text("Obteniendo variedades")
                    ]),
                  )));
        });
    var response = await http.get(
        Uri.parse(url_base +
            "WSPowerBI/controller/transportearandano.php" +
            "?accion=variedadtotal"),
        headers: {"Accept": "application/json"});
    if (mounted) {
      setState(() {
        var extraerData = json.decode(response.body);
        datavariedades = extraerData["datos"];
      });
    }
    Navigator.pop(context);
  }

  Future<void> enviarBackup(String backup) async {
    try {
      final resulte = await InternetAddress.lookup('google.com');
      String results;
      if (resulte.isNotEmpty && resulte[0].rawAddress.isNotEmpty) {
        var response = await http.post(
            Uri.parse(url_base + "acp/index.php/transportearandano/setBackup"),
            body: {"backup": backup});
        //if (mounted) {
        setState(() {
          var extraerData = json.decode(response.body);
          results = extraerData["state"].toString();
          print("STATE: " + results);
          if (results.toString().contains("true")) {
            print("backup subido correctamente");
          }
        });
      }
    } on Exception catch (e) {
      print('Error causador por: $e');
    }
  }

  _guardarSesion() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("name", _nombre.toString());
    prefs.setString("id", idtransp);
    prefs.setInt("capacidad_vehiculo", capacidadVehiculo);
    prefs.setString("placa", placa.toString());
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    int maxLength = 8;
    String text = "";
    /*Size? size;
    if (mounted) {
      //size = MediaQuery.of(context).size;
    }*/
    return GestureDetector(
        //onTap: press,
        child: Column(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(
            top: kDefaultPadding / 2,
            bottom: kDefaultPadding / 2,
          ),
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height / 3,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    alignment: Alignment.topCenter,
                    margin: const EdgeInsets.only(left: 100),
                    padding: const EdgeInsets.only(right: 20),
                    child: const Text(
                      "Iniciar Sesión",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  Container(
                      alignment: Alignment.center,
                      child: PrimaryButtonIcon(
                        icon: Icons.sync_rounded,
                        press: () async {
                          /* String texto =
                              await DatabaseProvider.db.generateBackup();
                          enviarBackup(texto);*/

                          await recibirDatos();
                          await recibirDatosBarras();
                          await recibirDatosVariedades();
                          if (data != null) {
                            // ignore: prefer_typing_uninitialized_variables
                            var response;
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
                                            child:
                                                Column(children: const <Widget>[
                                              CircularProgressIndicator(),
                                              SizedBox(height: 5),
                                              Text(
                                                  "Guardando datos en BD Local")
                                            ]),
                                          )));
                                });
                            /*await DatabaseProvider.db
                                .getDatabaseInstanaceDelete();*/
                            /*var databasesPath = await getDatabasesPath();
                            String path =
                                pat.join(databasesPath, 'transportes.db');
                            await deleteDatabase(path);*/
                           await DatabaseProvider.db.deleteAllUser();
                            await DatabaseProvider.db.deleteAllAcopios();
                            await DatabaseProvider.db.deleteAllConsumidores();
                            await DatabaseProvider.db.deleteAllVariedades();
                            for (int i = 0; i < data!.length; i++) {
                              response = await DatabaseProvider.db
                                  .addUserToDatabase(User(
                                id: int.parse(data![i]["DNI"]),
                                name: data![i]["NAME"],
                                dni: data![i]['DNI'],
                                capacidad:
                                    int.parse(data![i]['CAPACIDAD_VEHICULO']),
                                placa: data![i]['PLACA'],
                              ));

                              print("sincronización: " + response.toString());
                            }
                            for (int i = 0; i < dataconsumidores!.length; i++) {
                              response = await DatabaseProvider.db
                                  .addConsumidoresToDatabase(Consumidores(
                                idlugar:
                                    int.parse(dataconsumidores![i]["IDLUGAR"]),
                                consumidor: dataconsumidores![i]["CONS"],
                              ));

                              print("sincronización BARRAS: " +
                                  response.toString());
                            }
                            for (int i = 0; i < datavariedades!.length; i++) {
                              response = await DatabaseProvider.db
                                  .addVariedadesToDatabase(Variedades(
                                idconsumidor: datavariedades![i]
                                    ["IDCONSUMIDOR"],
                                descripcion: datavariedades![i]["DESCRIPCION"],
                              ));

                              print("sincronización: " + response.toString());
                            }
                            Navigator.pop(context);
                            Widget okButton = FloatingActionButton(
                              child: const Text("OK"),
                              onPressed: () {
                                estadoSincronizacion = 1;
                                Navigator.pop(context);
                              },
                            );
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Center(
                                      child: AlertDialog(
                                          content: const Text(
                                              'Sincronización correcta'),
                                          actions: [okButton]));
                                });
                          } else {
                            Widget okButton = FloatingActionButton(
                              child: const Text("OK"),
                              onPressed: () {
                                estadoSincronizacion = 0;
                                Navigator.pop(context);
                              },
                            );
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Center(
                                      child: AlertDialog(
                                          content: const Text(
                                              'Error al cargar datos'),
                                          actions: [okButton]));
                                });
                            print("no llegaron datos");
                          }
                        },
                      ))
                ],
              ),
              const Center(
                child: Text(
                  "ARANDANO - ACP",
                  style: TextStyle(fontSize: 10),
                ),
              ),
              const SizedBox(height: 12),
              Form(
                child: Container(
                  margin: const EdgeInsets.only(
                    left: kDefaultPadding / 2,
                    right: kDefaultPadding / 2,
                  ),
                  child: Row(
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
                ),
              ),
              const SizedBox(height: 15),
              GestureDetector(
                child: const PrimaryButton(
                  btnText: "INGRESAR",
                  colors: kPrimaryColor,
                ),
                onTap: () {
                  if (estadoSincronizacion == 1) {
                    if (myController.text.length == 8) {
                      String dni = myController.text;
                      DatabaseProvider.db
                          .getUserWithLoginAndPass(dni)
                          .then((List<User> users) {
                        if (users.isNotEmpty) {
                          _nombre = users[0].name;
                          idtransp = users[0].id.toString();
                          capacidadVehiculo = users[0].capacidad!;
                          placa = users[0].placa!;
                          _guardarSesion();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SecondPage(),
                            ),
                          );
                        } else {
                          showDialog(
                              context: context,
                              builder: (context) => const CustomDialogsBuscar(
                                    title: "Credenciales incorrectas",
                                    description:
                                        "Verifica tu DNI y vuelve a intentarlo",
                                    imagen: "assets/images/dni.png",
                                  ));
                          print(
                              '[LoginPage] _authenticateUser: Invalid credentials');
                        }
                      });
                    } else {
                      showDialog(
                          context: context,
                          builder: (context) => const CustomDialogsBuscar(
                                title: "Credenciales incorrectas",
                                description: "Error al digitar el DNI",
                                imagen: "assets/images/dni.png",
                              ));
                      print(
                          '[LoginPage] _authenticateUser: Invalid credentials');
                    }
                  } else {
                    Widget okButton = FloatingActionButton(
                      child: const Text("OK"),
                      onPressed: () {
                        estadoSincronizacion = 1;
                        Navigator.pop(context);
                      },
                    );
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Center(
                              child: AlertDialog(
                                  content: const Text(
                                      'Aun no has realizado la sincronización'),
                                  actions: [okButton]));
                        });
                  }
                },
              ),
              const SizedBox(
                height: 10,
              ),
              GestureDetector(
                child: const PrimaryButton(
                  btnText: "Ver Tutorial",
                  colors: Colors.grey,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HomeIntro(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    ));
  }
}

class PrimaryButton extends StatefulWidget {
  final String? btnText;
  final Color? colors;

  const PrimaryButton({Key? key, this.btnText, this.colors}) : super(key: key);

  @override
  _PrimaryButtonState createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: widget.colors, borderRadius: BorderRadius.circular(50)),
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.only(
        left: kDefaultPadding / 2,
        right: kDefaultPadding / 2,
      ),
      child: Center(
        child: Text(
          widget.btnText!,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}

class PrimaryButtonIcon extends StatefulWidget {
  final IconData? icon;
  final VoidCallback? press;
  const PrimaryButtonIcon({Key? key, this.icon, this.press}) : super(key: key);

  @override
  _PrimaryButtonIconState createState() => _PrimaryButtonIconState();
}

class _PrimaryButtonIconState extends State<PrimaryButtonIcon> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
            color: Colors.teal[700], borderRadius: BorderRadius.circular(50)),
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(
          left: kDefaultPadding / 2,
          right: kDefaultPadding / 2,
        ),
        child: Center(child: Icon(widget.icon, size: 25, color: Colors.white)),
      ),
      onTap: widget.press!,
    );
  }
}

class CustomDialogsBuscar extends StatelessWidget {
  final String? title, description, buttontext, imagen, nombre;
  final Image? image;

  const CustomDialogsBuscar(
      {Key? key,
      this.title,
      this.description,
      this.buttontext,
      this.image,
      this.imagen,
      this.nombre})
      : super(key: key);
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
          padding: const EdgeInsets.only(bottom: 20, left: 20),
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
                imagen!,
                width: 64,
                height: 64,
              ),
              const SizedBox(height: 20.0),
              Text(
                title!,
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Divider(),
              const SizedBox(height: 10.0),
              Text(
                description!,
                style: const TextStyle(fontSize: 16.0),
                textAlign: TextAlign.justify,
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
                      child: FloatingActionButton(
                          //color: kArandano,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "OK",
                            style: TextStyle(color: Colors.white),
                          )),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}
