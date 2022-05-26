// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:transporte_arandanov2/constants.dart';
import 'package:flutter_mobile_vision_2/flutter_mobile_vision_2.dart'
    as barcode;
import 'package:transporte_arandanov2/database/database.dart';
import 'package:transporte_arandanov2/model/consumidores_model.dart';
import 'package:transporte_arandanov2/model/jabas_model.dart';
import 'package:transporte_arandanov2/model/variedades_model.dart';
import 'package:transporte_arandanov2/screens/ruteo_sinterminar.dart';

class RegistroViaje extends StatefulWidget {
  final String? title,
      description,
      buttontext,
      imagen,
      cantidad,
      alias,
      idviajes,
      tipoacopio,
      latitud,
      idacopio,
      longitud;
  final Image? image;

  const RegistroViaje(
      {Key? key,
      this.title,
      this.description,
      this.buttontext,
      this.image,
      this.imagen,
      this.cantidad,
      this.alias,
      this.idviajes,
      this.tipoacopio,
      this.latitud,
      this.idacopio,
      this.longitud})
      : super(key: key);

  @override
  _RegistroViajeState createState() => _RegistroViajeState();
}

class _RegistroViajeState extends State<RegistroViaje> {
  String? _value = "Código de válvula";
  String? dropdownValue;
  String? dropdownValueBarra;
  String? dropdownValueV;
  String? dropdownValueS;
  String? dropdownValueM;
  String? dropdownValueT;
  String? dropdownValueCo;
  List variedad = [];
  List databarras = [];
  String? title;
  String? resultacopio;
  String? _mensaje, validacion = "";
  final myControllerPD = TextEditingController();
  final myControllerPJ = TextEditingController();
  final myControllerOB = TextEditingController();
  final myControllerNA = TextEditingController();
  final myControllerDE = TextEditingController();
  final myControllerFC = TextEditingController();
  bool isInitialized = false;
  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();
  final _formKey4 = GlobalKey<FormState>();
  final _formKeys = GlobalKey<FormState>();

  Future<void> atualizarAcopios(String pacopios, int tipo) async {
    // print("ALIAS ESTADO: " + pacopios);
    var response = await http.get(
        Uri.parse("${url_base}acp/index.php/transportearandano/setAcopios?accion=estado&alias=$pacopios&tipo=$tipo"),
        headers: {"Accept": "application/json"});
    if (mounted) {
      setState(() {
        var extraerData = json.decode(response.body);
        String result = extraerData["state"].toString();
        print("RESULTADO: $result");
      });
    }
  }

  Future<void> cargarVariedades(String cadenaconsumidor) async {

    var idac = cadenaconsumidor.split("|");
    var consumidor = idac[0];
    print("CONS: $consumidor");
    DatabaseProvider.db
        .getVariedadWithIdConsumidor(consumidor)
        .then((List<Variedades> variedades) {
      setState(() {
        for (var i = 0; i < variedades.length; i++) {
          var objeto = {
            // Le agregas la fecha
            "IDCONSUMIDOR": variedades[i].idconsumidor,
            "DESCRIPCION": variedades[i].descripcion
          };
          variedad.add(objeto);
          print("DESCRIPCION: " + variedades[i].descripcion!);
        }
      });
    });
  }

  Future<void> recibirDatosBarras(int idlugar) async {
    // ignore: prefer_typing_uninitialized_variables
    databarras.clear();
    DatabaseProvider.db
        .getConsumidorWithIdLugar(idlugar)
        .then((List<Consumidores> consumidores) {
      setState(() {
        for (var i = 0; i < consumidores.length; i++) {
          var objeto = {
            // Le agregas la fecha
            "IDLUGAR": consumidores[i].idlugar,
            "CONS": consumidores[i].consumidor
          };
          databarras.add(objeto);
        }
        //  databarras = consumidores;
      });
    });
  }

  @override
  void initState() {
    barcode.FlutterMobileVision.start().then((value) {});
    setState(() {
      isInitialized = true;
    });
    super.initState();
    //cargarVariedades("");
    //recibirDatosBarras();
  }

  Future _mensajesValidaciones(String sms) async {
    setState(() {
      validacion = sms;
    });
  }

  void scanBarcode() async {
    List<barcode.Barcode> barcodes = [];
    try {
      barcodes = await barcode.FlutterMobileVision.scan(
        waitTap: false,
        showText: true,
        autoFocus: true,
        flash: true,
      );
      if (barcodes.isNotEmpty) {
        for (barcode.Barcode barco in barcodes) {
          print(
              'barcodevalueis ${barco.displayValue} ${barco.getFormatString()} ${barco.getValueFormatString()}');
          // ignore: unnecessary_string_interpolations
          cargarVariedades('${barco.displayValue}');
          setState(() {
            // ignore: unnecessary_string_interpolations
            _value = '${barco.displayValue}';
          });
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: dialogContents(context),
    );
  }

  dialogContents(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Stack(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(top: 30, left: 15, right: 15),
              child: Container(
                padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
                margin: const EdgeInsets.only(top: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      widget.title!,
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Divider(),
                    const Divider(),
                    const SizedBox(height: 20.0),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: <Widget>[
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 5),
                              decoration: BoxDecoration(
                                color: kDarkSecondaryColor,
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: TextButton(
                                  onPressed: () {
                                    print("IDACOPIO: " + widget.idacopio!);
                                    //if(databarras.isNotEmpty){
                                      recibirDatosBarras(
                                          int.parse(widget.idacopio!));
                                   // }

                                  },
                                  child: const Icon(Icons.swipe,
                                      color: Colors.white)),
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          databarras != null
                              ? DropdownButton<String>(
                                  value: dropdownValueBarra,
                                  icon: const Icon(Icons.arrow_downward),
                                  iconSize: 24,
                                  elevation: 16,
                                  hint: const Text(
                                      'Selecciona el codigo de barras'),
                                  style:
                                      const TextStyle(color: Colors.deepPurple),
                                  underline: Container(
                                    height: 2,
                                    color: Colors.deepPurpleAccent,
                                  ),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      dropdownValueBarra = newValue;
                                      _value = dropdownValueBarra;
                                      cargarVariedades(
                                          _value == null ? '' : _value!);
                                    });
                                  },
                                  items: databarras.map((list) {
                                    return DropdownMenuItem(
                                      value: list['CONS'].toString(),
                                      child: Text(list['CONS']),
                                    );
                                  }).toList(),
                                )
                              : const Center(
                                  child: CircularProgressIndicator(),
                                ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(children: <Widget>[
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Container(
                              margin:
                                  const EdgeInsets.only(left: 10, bottom: 5),
                              decoration: BoxDecoration(
                                color: kDarkSecondaryColor,
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: TextButton(
                                  onPressed: () {
                                    scanBarcode();
                                  },
                                  child: const Icon(Icons.camera_alt,
                                      color: Colors.white)),
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              //margin: const EdgeInsets.only(left: 10),
                              width: size.width * 0.6,
                              decoration: BoxDecoration(
                                //color: kArandano,
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(20),
                                border:
                                    Border.all(width: 2, color: Colors.grey),
                              ),
                              child: Text(
                                _value!,
                                style: const TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ])),
                    const Divider(),
                    const SizedBox(height: 15.0),
                    Row(children: <Widget>[
                      const Text("EXPORTABLE: ",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 10),
                      Flexible(
                        // ignore: avoid_unnecessary_containers
                        child: Container(
                          child: Form(
                            key: _formKey,
                            child: TextFormField(
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Debe ingresar la cantidad de jabas';
                                }
                              },
                              keyboardType: TextInputType.number,
                              cursorColor: kPrimaryColor,
                              controller: myControllerPD,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                labelText: 'Cant. de jabas',
                                labelStyle: const TextStyle(color: Colors.grey),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  borderSide: const BorderSide(
                                    color: kPrimaryColor,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  borderSide: const BorderSide(
                                    color: Colors.grey,
                                    width: 2.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 15),
                    Row(children: <Widget>[
                      const Text("NACIONAL:     ",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 10),
                      Flexible(
                        // ignore: avoid_unnecessary_containers
                        child: Container(
                          child: Form(
                            key: _formKey2,
                            child: TextFormField(
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Debe ingresar la cantidad de jabas';
                                }
                              },
                              keyboardType: TextInputType.number,
                              cursorColor: kPrimaryColor,
                              controller: myControllerNA,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                labelText: 'Cant. de jabas',
                                labelStyle: const TextStyle(color: Colors.grey),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  borderSide: const BorderSide(
                                    color: kPrimaryColor,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  borderSide: const BorderSide(
                                    color: Colors.grey,
                                    width: 2.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 15),
                    Row(children: <Widget>[
                      const Text("DESMEDRO:    ",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 10),
                      Flexible(
                        // ignore: avoid_unnecessary_containers
                        child: Container(
                          child: Form(
                            key: _formKey3,
                            child: TextFormField(
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Debe ingresar la cantidad de jabas';
                                }
                              },
                              keyboardType: TextInputType.number,
                              cursorColor: kPrimaryColor,
                              controller: myControllerDE,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                labelText: 'Cant. de jabas',
                                labelStyle: const TextStyle(color: Colors.grey),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  borderSide: const BorderSide(
                                    color: kPrimaryColor,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  borderSide: const BorderSide(
                                    color: Colors.grey,
                                    width: 2.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 15),
                    Row(children: <Widget>[
                      const Text("FRUTA CAIDA:",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 10),
                      Flexible(
                        // ignore: avoid_unnecessary_containers
                        child: Container(
                          child: Form(
                            key: _formKey4,
                            child: TextFormField(
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Debe ingresar la cantidad de jabas';
                                }
                              },
                              keyboardType: TextInputType.number,
                              cursorColor: kPrimaryColor,
                              controller: myControllerFC,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                labelText: 'Cant. de jabas',
                                labelStyle: const TextStyle(color: Colors.grey),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  borderSide: const BorderSide(
                                    color: kPrimaryColor,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  borderSide: const BorderSide(
                                    color: Colors.grey,
                                    width: 2.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 15),
                    variedad != null
                        ? DropdownButton<String>(
                            value: dropdownValue,
                            icon: const Icon(Icons.arrow_downward),
                            iconSize: 24,
                            elevation: 16,
                            hint: const Text('Selecciona la variedad'),
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
                            items: variedad.map((list) {
                              return DropdownMenuItem(
                                value: list['DESCRIPCION'].toString(),
                                child: Text(list['DESCRIPCION']),
                              );
                            }).toList(),
                          )
                        : const Center(
                            child: CircularProgressIndicator(),
                          ),
                    const SizedBox(
                      height: 15,
                    ),
                    DropdownButton<String>(
                      value: dropdownValueCo,
                      icon: const Icon(Icons.arrow_downward),
                      iconSize: 24,
                      elevation: 16,
                      hint: const Text('Selecciona la condición'),
                      style: const TextStyle(color: Colors.deepPurple),
                      underline: Container(
                        height: 2,
                        color: Colors.deepPurpleAccent,
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          dropdownValueCo = newValue;
                        });
                      },
                      items: <String>[
                        "ORGANICO",
                        "CONVENCIONAL",
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                            value: value, child: Text(value));
                      }).toList(),
                    ),
                    const SizedBox(height: 15.0),
                    const Divider(),
                    const SizedBox(height: 15.0),
                    const Center(
                        child: Text("CONSUMIDOR REAL",
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w700,
                            ))),
                    const SizedBox(height: 10.0),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                    child:Row(children: <Widget>[
                      DropdownButton<String>(
                        value: dropdownValueS,
                        icon: const Icon(Icons.arrow_downward),
                        iconSize: 24,
                        elevation: 16,
                        hint: const Text('SECTOR'),
                        style: const TextStyle(color: Colors.deepPurple),
                        underline: Container(
                          height: 2,
                          color: Colors.deepPurpleAccent,
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            dropdownValueS = newValue;
                          });
                        },
                        items: <String>["SEC. 07", "SEC. 08", "SEC. 09"]
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                              value: value, child: Text(value));
                        }).toList(),
                      ),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: dropdownValueM,
                        icon: const Icon(Icons.arrow_downward),
                        iconSize: 24,
                        elevation: 16,
                        hint: const Text('MÓDULO'),
                        style: const TextStyle(color: Colors.deepPurple),
                        underline: Container(
                          height: 2,
                          color: Colors.deepPurpleAccent,
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            dropdownValueM = newValue;
                          });
                        },
                        items: <String>[
                          "MOD 01",
                          "MOD 02",
                          "MOD 03",
                          "MOD 04",
                          "MOD 05",
                          "MOD 06",
                          "MOD 07",
                          "MOD 08",
                          "MOD 09",
                          "MOD 1O",
                          "MOD 11"
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                              value: value, child: Text(value));
                        }).toList(),
                      ),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: dropdownValueT,
                        icon: const Icon(Icons.arrow_downward),
                        iconSize: 24,
                        elevation: 16,
                        hint: const Text('TURNO'),
                        style: const TextStyle(color: Colors.deepPurple),
                        underline: Container(
                          height: 2,
                          color: Colors.deepPurpleAccent,
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            dropdownValueT = newValue;
                          });
                        },
                        items: <String>[
                          "TUR 01",
                          "TUR 02",
                          "TUR 03",
                          "TUR 04",
                          "TUR 05",
                          "TUR 06",
                          "TUR 07",
                          "TUR 08",
                          "TUR 09",
                          "TUR 1O",
                          "TUR 11",
                          "TUR 12",
                          "TUR 13",
                          "TUR 14",
                          "TUR 15",
                          "TUR 16",
                          "TUR 17",
                          "TUR 18",
                          "TUR 19",
                          "TUR 20",
                          "TUR 21",
                          "TUR 22",
                          "TUR 23",
                          "TUR 24",
                          "TUR 25",
                          "TUR 26",
                          "TUR 27",
                          "TUR 28",
                          "TUR 29",
                          "TUR 30"
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                              value: value, child: Text(value));
                        }).toList(),
                      ),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: dropdownValueV,
                        icon: const Icon(Icons.arrow_downward),
                        iconSize: 24,
                        elevation: 16,
                        hint: const Text('VÁLVULA'),
                        style: const TextStyle(color: Colors.deepPurple),
                        underline: Container(
                          height: 2,
                          color: Colors.deepPurpleAccent,
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            dropdownValueV = newValue;
                          });
                        },
                        items: <String>[
                          "VAL 01",
                          "VAL 02",
                          "VAL 03",
                          "VAL 04",
                          "VAL 05",
                          "VAL 06",
                          "VAL 07",
                          "VAL 08",
                          "VAL 09",
                          "VAL 1O",
                          "VAL 11",
                          "VAL 12",
                          "VAL 13",
                          "VAL 14",
                          "VAL 15",
                          "VAL 16",
                          "VAL 17",
                          "VAL 18",
                          "VAL 19",
                          "VAL 20",
                          "VAL 21",
                          "VAL 22",
                          "VAL 23",
                          "VAL 24",
                          "VAL 25",
                          "VAL 26",
                          "VAL 27",
                          "VAL 28",
                          "VAL 29",
                          "VAL 30",
                          "VAL 31",
                          "VAL 32",
                          "VAL 33",
                          "VAL 34",
                          "VAL 35",
                          "VAL 36",
                          "VAL 37",
                          "VAL 38",
                          "VAL 39",
                          "VAL 40",
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                              value: value, child: Text(value));
                        }).toList(),
                      ),
                    ])),
                    const SizedBox(
                      height: 10,
                    ),
                    const Divider(),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(children: <Widget>[
                      Flexible(
                        // ignore: avoid_unnecessary_containers
                        child: Container(
                          child: Form(
                            key: _formKeys,
                            child: TextFormField(
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Debe ingresar la cantidad de jabas';
                                }
                              },
                              keyboardType: TextInputType.multiline,
                              minLines: 1,
                              maxLines: 5,
                              cursorColor: kPrimaryColor,
                              controller: myControllerOB,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                labelText: 'OBSERVACIONES',
                                labelStyle: const TextStyle(color: Colors.grey),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  borderSide: const BorderSide(
                                    color: kPrimaryColor,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  borderSide: const BorderSide(
                                    color: Colors.grey,
                                    width: 2.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 10.0),
                    Text(validacion!,
                        style:
                            const TextStyle(color: Colors.red, fontSize: 12)),
                    const SizedBox(height: 20),
                    Row(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                            decoration: BoxDecoration(
                                color: kArandano,
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
                                  // if (_formKey.currentState.validate()) {
                                  if (_value == "Código de válvula") {
                                    _mensaje = "Debe leer el código de válvula";
                                    _mensajesValidaciones(_mensaje!);
                                  } else {
                                    DateTime now = DateTime.now();
                                    print("datetime: $now");
                                    var response = await DatabaseProvider.db
                                        .addJabasToDatabase(Jabas(
                                            idviaje:
                                                int.parse(widget.idviajes!),
                                            lat: widget.latitud ?? '00.000000',
                                            long:
                                                widget.longitud ?? '00.000000',
                                            alias: widget.alias ?? 'V0',
                                            // ignore: prefer_if_null_operators, unnecessary_null_comparison
                                            nacional:
                                                // ignore: prefer_if_null_operators, unnecessary_null_comparison
                                                int.parse(myControllerNA.text) == null
                                                    ? 0
                                                    : int.parse(
                                                        myControllerNA.text),
                                            exportable:
                                                // ignore: prefer_if_null_operators, unnecessary_null_comparison
                                                int.parse(myControllerPD.text) == null
                                                    ? 0
                                                    : int.parse(
                                                        myControllerPD.text),
                                            // ignore: prefer_if_null_operators, unnecessary_null_comparison
                                            desmedro:
                                                // ignore: prefer_if_null_operators, unnecessary_null_comparison
                                                int.parse(myControllerDE.text) == null
                                                    ? 0
                                                    : int.parse(
                                                        myControllerDE.text),
                                            frutac:
                                            // ignore: prefer_if_null_operators, unnecessary_null_comparison
                                            int.parse(myControllerFC.text) == null
                                                ? 0
                                                : int.parse(
                                                myControllerFC.text),
                                            estado: 0,
                                            // ignore: unnecessary_null_comparison
                                            jabascargadas: 0,
                                            // ignore: prefer_if_null_operators, unnecessary_null_comparison
                                            variedad: dropdownValue.toString() == null
                                                ? ''
                                                : dropdownValue.toString(),
                                            // ignore: prefer_if_null_operators, unnecessary_null_comparison
                                            condicion: dropdownValueCo.toString() ==
                                                    null
                                                ? ''
                                                : dropdownValueCo.toString(),
                                            consumidor: dropdownValueS == null
                                                ? ''
                                                // ignore: unnecessary_null_comparison
                                                : dropdownValueS
                                                                .toString()
                                                                .substring(5) +
                                                            dropdownValueM! ==
                                                        null
                                                    ? ''
                                                    // ignore: unnecessary_null_comparison
                                                    : dropdownValueM.toString().substring(4) + dropdownValueT! == null
                                                        ? ''
                                                        : dropdownValueT.toString().substring(4) + "ARA",
                                            valvula: dropdownValueV == null ? '' : dropdownValueV.toString().substring(4),
                                            // ignore: prefer_if_null_operators, unnecessary_null_comparison
                                            observaciones: myControllerOB.text == null ? '' : myControllerOB.text,
                                            // ignore: prefer_if_null_operators
                                            descripcion: _value == null ? '' : _value,
                                            fllegada: now.toString()));
                                    print("sincronización: $response");
                                    if (response > 0) {
                                      Navigator.pop(context);
                                    } else {
                                      showDialog(
                                          context: context,
                                          builder: (context) =>
                                              const CustomDialogsActividad(
                                                  title: "MENSAJE",
                                                  description:
                                                      'Registro incorrecto vuelve a intentarlo',
                                                  imagen:
                                                      "assets/images/warning.png"));
                                    }
                                  }
                                  // }
                                },
                                child: const Text(
                                  "Registrar",
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
              ),
            ),
          ],
        ));
  }
}

class CustomDialogsBuscar extends StatefulWidget {
  final String? title, description, imagen, idviajes, idlugar;
  const CustomDialogsBuscar(
      {Key? key,
      this.title,
      this.description,
      this.imagen,
      this.idviajes,
      this.idlugar})
      : super(key: key);

  @override
  _CustomDialogsBuscarState createState() => _CustomDialogsBuscarState();
}

class _CustomDialogsBuscarState extends State<CustomDialogsBuscar> {
  String? dropdownValue;
  // ignore: prefer_typing_uninitialized_variables
  var dataacopio;
  List? data;
  Future<void> recibirDatos() async {
    // ignore: prefer_typing_uninitialized_variables
    String codigoviajes = widget.idviajes ?? '0';
    String codigolugar = widget.idlugar ?? '0';
    var extraerData;
    var response = await http.get(
        Uri.parse("${url_base}WSPowerBI/controller/transportearandano.php?accion=detallebarras&idviajes=$codigoviajes&idlugar=$codigolugar"),
        headers: {"Accept": "application/json"});
    setState(() {
      extraerData = json.decode(response.body);
      data = extraerData["datos"];
      dataacopio = json.encode(extraerData["datos"]);
      print("DATAACOPIO: " + dataacopio.toString());
    });
  }

  @override
  void initState() {
    super.initState();
    recibirDatos();
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
              data != null
                  ? DropdownButton<String>(
                      value: dropdownValue,
                      icon: const Icon(Icons.arrow_downward),
                      iconSize: 24,
                      elevation: 16,
                      hint: const Text('Selecciona el codigo de barras'),
                      style: const TextStyle(color: Colors.deepPurple),
                      /*underline: Container(
                        height: 2,
                        color: Colors.deepPurpleAccent,
                      ),*/
                      onChanged: (String? newValue) {
                        setState(() {
                          dropdownValue = newValue;
                        });
                      },
                      items: data!.map((list) {
                        return DropdownMenuItem(
                          value: list['CONS'].toString(),
                          child: Text(list['CONS']),
                        );
                      }).toList(),
                    )
                  : const Center(
                      child: CircularProgressIndicator(),
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
                            print(
                                "VALOR DROPDOWN: " + dropdownValue.toString());
                            // ignore: unnecessary_null_comparison
                            if (dropdownValue == null) {
                              showDialog(
                                  context: context,
                                  builder: (context) =>
                                      const CustomDialogsActividad(
                                          title: "MENSAJE",
                                          description:
                                              'Debes Seleccionar la válvula a cargar',
                                          imagen: "assets/images/warning.png"));
                            } else {}
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
