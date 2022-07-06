import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:transporte_arandanov2/constants.dart';
import 'package:transporte_arandanov2/screens/ruteo_sinterminar.dart';
import 'package:transporte_arandanov2/screens/second_page.dart';
import 'package:transporte_arandanov2/screens/viaje_detalle.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class MapBottomPillHome extends StatefulWidget {
  String? numeroViaje;
  int? cantjabas;
  double? distance;
  int? tiempo;
  String? finicio;
  String? ffin;
  int? idviajes;
  int? estado;
  String? ruta;
  String? nombre;
  String? placa;
  MapBottomPillHome(
      {Key? key,
      this.numeroViaje,
      this.cantjabas,
      this.distance,
      this.tiempo,
      this.finicio,
      this.ffin,
      this.idviajes,
      this.estado,
      this.ruta,
      this.nombre,
      this.placa})
      : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  State<MapBottomPillHome> createState() => MapBottomPillHomeState(
      numeroViaje: numeroViaje,
      cantjabas: cantjabas,
      distance: distance,
      tiempo: tiempo,
      finicio: finicio,
      ffin: ffin,
      idviajes: idviajes,
      estado: estado,
      ruta: ruta,
      nombre: nombre,
      placa: placa);
}

class MapBottomPillHomeState extends State<MapBottomPillHome> {
  String? numeroViaje;
  int? cantjabas;
  double? distance;
  int? tiempo;
  String? finicio;
  String? ffin;
  int? idviajes;
  int? estado;
  String? ruta;
  String? placa;
  String? nombre;

  MapBottomPillHomeState(
      {this.numeroViaje,
      this.cantjabas,
      this.distance,
      this.tiempo,
      this.finicio,
      this.ffin,
      this.idviajes,
      this.estado,
      this.ruta,
      this.nombre,
      this.placa});

  @override
  Widget build(BuildContext context) {
    String tipo = ' MIN';
    return Container(
      child: estado == 1
          ? GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyViajeDetail(
                        numeroViaje: numeroViaje,
                        cantjabas: cantjabas,
                        distance: distance,
                        finicio: finicio,
                        ffin: ffin,
                        idviajes: idviajes,
                        ruta: ruta),
                  ),
                );
              },
              child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: Offset.zero)
                      ]),
                  child: Column(
                    children: [
                      Container(
                          color: Colors.white,
                          child: Row(
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  ClipOval(
                                    child: Image.asset(
                                        'assets/images/r_007.png',
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    estado == 0
                                        ? Text(
                                            placa == 'ADM'
                                                ? "VIAJE ST ${numeroViaje!}"
                                                : "VIAJE ST ${numeroViaje!}",
                                            style: TextStyle(
                                                color: Colors.grey[700],
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15))
                                        : Text("VIAJE ${numeroViaje!}",
                                            style: TextStyle(
                                                color: Colors.grey[700],
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15)),
                                    const SizedBox(height: 2),
                                    Text('JABAS CARGADAS: $cantjabas'),
                                    const SizedBox(height: 2),
                                    Text(
                                        'T. de recorrido: $tiempo$tipo',
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 14))
                                  ],
                                ),
                              ),
                              const Icon(Icons.history,
                                  color: kPrimaryColor, size: 50)
                            ],
                          )),
                    ],
                  )))
          : Container(
              //color: Colors.black,
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.green[200],
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: Offset.zero)
                  ]),
              child: Column(
                children: [
                  Container(
                      color: Colors.green[200],
                      child: Row(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              ClipOval(
                                child: Image.asset('assets/images/r_007.png',
                                    width: 60, height: 60, fit: BoxFit.cover),
                              ),
                            ],
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                estado == 0
                                    ? Text("VIAJE ST ${numeroViaje!}",
                                        style: TextStyle(
                                            color: Colors.grey[700],
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15))
                                    : Text("VIAJE ${numeroViaje!}",
                                        style: TextStyle(
                                            color: Colors.grey[700],
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15)),
                                const SizedBox(height: 2),
                                Text('JABAS: $cantjabas'),
                                const SizedBox(height: 2),
                                Text(
                                    'T. de recorrido: $tiempo$tipo',
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 14))
                              ],
                            ),
                          ),
                          Column(
                            children: <Widget>[
                              IconButton(
                               // padding: const EdgeInsets.all(2),
                                icon: const Icon(Icons.location_pin,
                                    color: Colors.white, size: 30),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => GMap(
                                          //nombre: nombre ?? 'USUARIO',
                                          ruta: ruta!,
                                          idviajes: idviajes!),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                               // padding: const EdgeInsets.all(2),
                                icon: const Icon(Icons.history,
                                    color: Colors.white, size: 30),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MyViajeDetail(
                                          numeroViaje: numeroViaje,
                                          cantjabas: cantjabas,
                                          distance: distance,
                                          finicio: finicio,
                                          ffin: ffin,
                                          idviajes: idviajes,
                                          ruta: ruta),
                                    ),
                                  );
                                },
                              ),
                              placa == 'ADM' ?
                              IconButton(
                                //padding: const EdgeInsets.all(2),
                                icon: const Icon(Icons.close,
                                    color: Colors.white, size: 30),
                                onPressed: () async{
                                    var response = await http.get(
                                    Uri.parse("${url_base}acp/index.php/transportearandano/setTravelUpdate?accion=estadoViaje&idviajes=$idviajes&tipo=1"),
                                    headers: {"Accept": "application/json"});
                                    //  if (mounted) {
                                    setState(() {
                                      var extraerData = json.decode(response.body);
                                      String results =
                                      extraerData["state"].toString();
                                      print("RESULTADO ESTADO VIAJE: $results");
                                      if (results == "true") {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const SecondPage(),
                                          ),
                                        );
                                      }
                                    });
                                },
                              ): Container(),
                            ],
                          )
                        ],
                      )),
                ],
              )),
    );
  }
}
