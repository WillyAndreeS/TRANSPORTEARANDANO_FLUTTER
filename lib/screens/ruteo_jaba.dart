import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
//import 'package:transporte_arandano/screens/map/mapbottompilljabas.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:transporte_arandanov2/constants.dart';
import 'package:transporte_arandanov2/database/database.dart';
import 'package:transporte_arandanov2/main.dart';
import 'package:transporte_arandanov2/model/acopios_restantes_model.dart';
import 'package:transporte_arandanov2/model/jabas_model.dart';
import 'package:transporte_arandanov2/screens/principal_page.dart';
import 'package:http/http.dart' as http;
import 'package:transporte_arandanov2/screens/pin_pill_info.dart';
import 'package:transporte_arandanov2/screens/registro_viaje_adm.dart';
//import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'dart:math' as math;

import 'package:transporte_arandanov2/screens/second_page.dart';

const double PIN_VISIBLE_POSITION = 20;
const double PIN_INVISIBLE_POSITION = -220;
const LatLng SOURCE_LOCATION = LatLng(-7.0450281, -79.5436953);
const double CAMERA_ZOOM = 15;
const double CAMERA_TILT = 30;
const double CAMERA_BEARING = 80;
Set<Marker> _markers = HashSet<Marker>();
int? cantidad_jabas;
//int capacidad = 500;
int? cantidad_jabas_actual;
String? jabasrecogidas2 = '0';
String? jabascosechadas = '0';
String? modulojabas = '0';
var extraerData1;
List? datapunto;

Future<void> recibirDatosReloadHilo(List params) async {
  try {
    final resulte = await InternetAddress.lookup('google.com');
    if (resulte.isNotEmpty && resulte[0].rawAddress.isNotEmpty) {
      String xml = params[0];
      List dData = params[1];
     // String idviajesrestult = params[2];
      String results;
      HttpOverrides.global = MyHttpOverrides();
      var response = await http.post(
          Uri.parse("${url_base}acp/index.php/transportearandano/setAcopiosDetailNota"),
          body: {"xml": xml});
      var extraerData = json.decode(response.body);
      results = extraerData["state"].toString();

      if (results.toString().contains("TRUE")) {
        if (dData.isNotEmpty) {
          for (var i = 0; i < dData.length; i++) {
            print('Error IDVIAJE por: $dData[i]["IDVIAJES"]');
            DatabaseProvider.db
                .updateJabasViaje(dData[i]["IDVIAJES"], dData[i]["ALIAS"]);
          }
        }
      }
      // mensaje = results.toString();
    }
  } on Exception catch (e) {
    print('Error causador por: $e');
  }
}


Future<void> recibirDatosAcopiosMapeados(List params) async {
  try {
    final resulte = await InternetAddress.lookup('google.com');
    if (resulte.isNotEmpty && resulte[0].rawAddress.isNotEmpty) {
      HttpOverrides.global = MyHttpOverrides();
      //String results;
        var response1 = await http.get(
            Uri.parse("${url_base}WSPowerBI/controller/transportearandano.php?accion=puntoinicioadmin"),
            headers: {"Accept": "application/json"});
        extraerData1 = json.decode(response1.body);
        datapunto = extraerData1["datos"];
        if (datapunto!.isNotEmpty) {
          for (var i = 0; i < datapunto!.length; i++) {
            DatabaseProvider.db
                .insertAcopiosRestantes(
                "00",
                int.parse(datapunto![i]["CANTIDAD_JABAS"]),
                datapunto![i]["ALIAS"],
                datapunto![i]["LATITUD"],
                datapunto![i]["LONGITUD"],
                '-',
                int.parse(datapunto![i]["IDACOPIO"]),
                datapunto![i]["NAME"]);
          }
        }
    }
  } on Exception catch (e) {
    print('Error causador por: $e');
  }
}

final _formKey = GlobalKey<FormState>();

class GMapJabas extends StatefulWidget {
  String? nombre;
  List? data;
  GMapJabas({Key? key, this.nombre, this.data}) : super(key: key);

  @override
  _GMapJabasState createState() => _GMapJabasState();
}

class _GMapJabasState extends State<GMapJabas> {
  Set<Polygon> _polygons = HashSet<Polygon>();
  Set<Polyline> _polylines = HashSet<Polyline>();
  Set<Circle> _circles = HashSet<Circle>();
  bool _showMapStyle = false;
  double pinPillPosition = PIN_VISIBLE_POSITION;
  LatLng? currentLocation;
  LatLng? destinationLocation;
  LatLng? mediaLocation;
  BitmapDescriptor? sourceIcon;
  BitmapDescriptor? initIcon;
  BitmapDescriptor? destinationIcon;
  BitmapDescriptor? mediaIcon;
  bool userBadgeSelected = false;
  bool resetToggle = false;
  String? nombre;
  //_GMapJabasState({this.nombre!});
  GoogleMapController? _mapController;
  BitmapDescriptor? _markerIcon;
  BitmapDescriptor? _markerIcon2;
  List? data1;
  List? areas;

  //var result;
  double? distancia;

  int estado = 0;

  Completer<GoogleMapController> _controller = Completer();
  //Set<Marker> _markerss = Set<Marker>();
  Set<Polyline> _polyliness = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  PolylinePoints? polylinePoints;
  String googleAPIKey = 'AIzaSyAnvIlkNe_V7YW_8bcc-av9bniI-HQneCg';
  BitmapDescriptor? sourceIcones;
  BitmapDescriptor? destinationIcones;
  LocationData? currentLocationes;
  LocationData? destinationLocationes;
  Location? location;
  double pinPillPositiones = -100;
  PinInformation currentlySelectedPin = PinInformation(
      pinPath: '',
      avatarPath: '',
      location: LatLng(0, 0),
      locationName: '',
      labelColor: Colors.grey);
  PinInformation? sourcePinInfo;
  String? jabaspedateadas = '0';
  String? jabasdisponibles = '0';
  String? jabasrecogidas = '0';
  PinInformation? destinationPinInfo;
  FlutterIsolate? isolate2;
  FlutterIsolate? isolate;

  @override
  void initState() {
    super.initState();
    _setMarkerIcon();
    //_setMarkerIcon2();
    setSourceAndDestinationIcons();

    // RecibirAreas();
    location = new Location();
    polylinePoints = PolylinePoints();
    location?.onLocationChanged.listen((LocationData cLoc) {
      currentLocationes = cLoc;
      updatePinOnMap();
    });

    setInitialLocation();
    recibirAcopios();
    CargarJabas();
    cargarCantidades();
  }

  void saveBox(String xml, List dData) async {
    try{
      isolate?.kill();
      isolate = await FlutterIsolate.spawn(recibirDatosReloadHilo, [xml, dData]);
    } on IsolateSpawnException catch(e){
      print(e);
    }
  }

  void saveBoxAcopios() async {
    try{
      isolate2?.kill();
      isolate2 = await FlutterIsolate.spawn(recibirDatosAcopiosMapeados, []);
    } on IsolateSpawnException catch(e){
      print(e);
    }
    // return ReceivePort();
  }
  void showPinsOnMap() {
    estado = 0;
    var pinPosition = LatLng(-7.043901, -79.541921);
    print("--------------------------" + pinPosition.toString());

    /*sourcePinInfo = PinInformation(
        locationName: "Start Location",
        location: SOURCE_LOCATION,
        pinPath: "assets/images/truck5.png",
        avatarPath: "assets/images/avatar.png",
        labelColor: Colors.redAccent);*/

    _markers.add(Marker(
        markerId: MarkerId('sourcePin'),
        position: pinPosition,
        onTap: () {
          setState(() {
            currentlySelectedPin = sourcePinInfo!;
            pinPillPosition = 0;
          });
        },
        icon: sourceIcones!));
  }



  void updatePinOnMap() async {
    /*CameraPosition cPosition = CameraPosition(
      zoom: estado == 0 ? CAMERA_ZOOM : 22,
      tilt: estado == 0 ? CAMERA_TILT : 90,
      bearing: estado == 0 ? CAMERA_BEARING : 58,
      target: LatLng(currentLocationes!.latitude!, currentLocationes!.longitude!),
    );
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));*/
    setState(() {
      var pinPosition =
          LatLng(currentLocationes!.latitude!, currentLocationes!.longitude!);
      // sourcePinInfo.location = pinPosition;

      _markers.removeWhere((m) => m.markerId.value == 'sourcePin');
      print("POSITION" + pinPosition.toString());
      _markers.add(Marker(
          markerId: MarkerId('sourcePin'),
          onTap: () {
            setState(() {
              currentlySelectedPin = sourcePinInfo!;
              pinPillPosition = 0;
            });
          },
          position: pinPosition, // updated position
          icon: sourceIcones!));
    });
  }

  Future<void> CargarJabas() async {
    Timer.periodic(const Duration(minutes: 1), (Timer timer) async {
      saveBoxAcopios();
      print("HOLA MUNDO");

      // -------------------------- acopios restantes------------------
      var cantidadrestada2 = 0;
      DatabaseProvider.db
          .getCantidadAcopiosRestantes("00")
          .then((List<AcopiosRestantes> acopiosrestantes) async {

        for (var i = 0; i < acopiosrestantes.length; i++) {
          int cantidadJabasRestantes = acopiosrestantes[i].cantidadjabas! ;
          print("JABAS ACTUALES: ${acopiosrestantes[i].alias!} jabas: ${acopiosrestantes[i].cantidadjabas}");

              print("JABAS ACTUALES2: ${acopiosrestantes[i].cantidadjabas}");
              var bitmapData;

              _markers.removeWhere(
                      (m) => m.markerId.value == acopiosrestantes[i].alias!);
              if(int.parse(acopiosrestantes[i].cantidadjabas.toString()) > 0) {
                if(acopiosrestantes[i].name! == 'LIBRE') {
                  bitmapData = await _createAvatarBusqueda(
                      80, 90, acopiosrestantes[i].cantidadjabas.toString());
                }else{
                  bitmapData = await _createAvatarRestantes(
                      80, 90, acopiosrestantes[i].cantidadjabas.toString());
                }
                var bitmapDescriptor = BitmapDescriptor.fromBytes(bitmapData);
                _markers.add(
                  Marker(
                      markerId: MarkerId(acopiosrestantes[i].alias!),
                      position: LatLng(
                          double.parse(acopiosrestantes[i].latitud!),
                          double.parse(acopiosrestantes[i].longitud!)),
                      icon: bitmapDescriptor,
                      onTap: () {
                        /*showDialog(
                            context: context,
                            builder: (context) => CustomDialogs(
                                title: "ACOPIO OCUPADO POR: "+acopiosrestantes![i].name.toString(),
                                description: "",
                                imagen: "assets/images/arandano_icon.png",
                                cantidad: acopiosrestantes![i].cantidadjabas.toString(),
                                alias: acopiosrestantes![i].alias.toString()
                            ));*/
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                RegistroViajeAdm(
                                  title: "ACOPIO DE: " + acopiosrestantes![i].name.toString(),
                                  description: acopiosrestantes[i].descripcion!,
                                  imagen: "assets/images/arandano_icon.png",
                                  cantidad: acopiosrestantes[i].cantidadjabas
                                      .toString(),
                                  alias: acopiosrestantes[i].alias!,
                                  latitud: acopiosrestantes[i].latitud!,
                                  longitud: acopiosrestantes[i].longitud!,
                                  idacopio: acopiosrestantes[i].idlugar
                                      .toString(),
                                  // area: data[i]["AREA"],
                               //   idviajes: result.toString(),
                                  tipoacopio: '-',
                                ),
                          ),
                        );
                      }),
                );
              }else if(int.parse(acopiosrestantes[i].cantidadjabas.toString()) == 0){
                var bitmapData;
                bitmapData = await _createAvatarCerrado(
                    80, 90, acopiosrestantes[i].cantidadjabas.toString() );
                var bitmapDescriptor = BitmapDescriptor.fromBytes(bitmapData);
                _markers.add(
                  Marker(
                      markerId: MarkerId(acopiosrestantes[i].alias.toString()),
                      position: LatLng(double.parse(acopiosrestantes![i].latitud.toString()),
                          double.parse(acopiosrestantes![i].longitud.toString())),
                      icon: bitmapDescriptor,
                      onTap: () {
                        /*showDialog(
                            context: context,
                            builder: (context) => CustomDialogs(
                                title: "ACOPIO OCUPADO POR: "+acopiosrestantes![i].name.toString(),
                                description: "",
                                imagen: "assets/images/arandano_icon.png",
                                cantidad: acopiosrestantes![i].cantidadjabas.toString(),
                                alias: acopiosrestantes![i].alias.toString()
                            ));*/
                        Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            RegistroViajeAdm(
                              title: "ACOPIO DE: " + acopiosrestantes![i].name.toString(),
                              description: acopiosrestantes[i].descripcion!,
                              imagen: "assets/images/arandano_icon.png",
                              cantidad: acopiosrestantes[i].cantidadjabas
                                  .toString(),
                              alias: acopiosrestantes[i].alias!,
                              latitud: acopiosrestantes[i].latitud!,
                              longitud: acopiosrestantes[i].longitud!,
                              idacopio: acopiosrestantes[i].idlugar
                                  .toString(),
                              // area: data[i]["AREA"],
                            //  idviajes: result.toString(),
                              tipoacopio: '-',
                            ),
                      ),
                    );
                      }),
                );
              }else if(int.parse(acopiosrestantes[i].cantidadjabas.toString()) < 0){
                var bitmapData;
                bitmapData = await _createAvatarExceso(
                    80, 90, acopiosrestantes![i].cantidadjabas.toString());
                var bitmapDescriptor = BitmapDescriptor.fromBytes(bitmapData);
                _markers.add(
                  Marker(
                      markerId: MarkerId(acopiosrestantes![i].alias.toString()),
                      position: LatLng(double.parse(datapunto![i].latitud.toString()),
                          double.parse(datapunto![i].longitud.toString())),
                      icon: bitmapDescriptor,
                      onTap: () {
                        /*showDialog(
                            context: context,
                            builder: (context) => CustomDialogs(
                                title: "ACOPIO OCUPADO POR: "+acopiosrestantes![i].name.toString(),
                                description: "",
                                imagen: "assets/images/arandano_icon.png",
                                cantidad: acopiosrestantes![i].cantidadjabas.toString(),
                                alias: acopiosrestantes![i].alias.toString()
                            ));*/
                        Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            RegistroViajeAdm(
                              title: "ACOPIO DE: " + acopiosrestantes![i].name.toString(),
                              description: acopiosrestantes[i].descripcion!,
                              imagen: "assets/images/arandano_icon.png",
                              cantidad: acopiosrestantes[i].cantidadjabas
                                  .toString(),
                              alias: acopiosrestantes[i].alias!,
                              latitud: acopiosrestantes[i].latitud!,
                              longitud: acopiosrestantes[i].longitud!,
                              idacopio: acopiosrestantes[i].idlugar
                                  .toString(),
                              // area: data[i]["AREA"],
                             // idviajes: result.toString(),
                              tipoacopio: '-',
                            ),
                      ),
                    );
                      }),
                );
              }
        }
      });
      cargarCantidades();
      try {

        StringBuffer xmlViajesAcopio = StringBuffer();
        var ddData = [];
        var objeto;
        String cabeceraXml =
            "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?><SOLICITUD_DESTINO>";
        String itemXml = "";
        DatabaseProvider.db
            .getJabasTotalViajes()
            .then((List<Jabas> jabas) {
          //  if (jabas.isNotEmpty) {
          for (var i = 0; i < jabas.length; i++) {
            if(jabas[i].jabascargadas != null) {
              itemXml += "<Item IDVIAJES=\"${jabas[i].idviaje}\" LATITUD=\"${jabas[i].lat!}\" LONGITUD=\"${jabas[i].long!}\" ALIAS=\"${jabas[i].alias!}\" CANTJABAS=\"${jabas[i].jabascargadas}\" ESTADO=\"1\" DESCRIPCION=\"${jabas[i].descripcion!}\" JABASCARGADAS=\"${jabas[i].jabascargadas}\" FLLEGADA=\"${jabas[i].fllegada!}\" EXPORTABLE=\"${jabas[i].exportable}\" NACIONAL=\"${jabas[i].nacional}\" DESMEDRO=\"${jabas[i].desmedro}\" FRUTAC=\"${jabas[i].frutac}\" VARIEDAD=\"${jabas[i].variedad}\" CONDICION=\"${jabas[i].condicion}\" CONSUMIDOR=\"${jabas[i].consumidor}\" VALVULA=\"${jabas[i].valvula}\" OBSERVACIONES=\"${jabas[i].observaciones}\" />";
              objeto = {
                // Le agregas la fecha
                "ALIAS": jabas[i].alias,
                "IDVIAJES" : jabas[i].idviaje
              };
              ddData.add(objeto);
            //  reiniciarAcopioIndividual(jabas[i].alias!);

            }
          }
          //  }

          String pieXml = "</SOLICITUD_DESTINO>";
          String xml2 = cabeceraXml + itemXml + pieXml;
          print("XML CARGADO$xml2");
          xmlViajesAcopio.write(xml2);
     //     print('idviaje: ' + result);
          print("ALIAS: $ddData");
          if(itemXml != ""){

            saveBox(xmlViajesAcopio.toString(), ddData);
          }

        });

      } on Exception catch (e) {
        print('Error causador por: $e');
      }
// ------------------------------------------

    });
  }



  /*Future<void> reiniciarAcopioIndividual(String alias) async {
    print("ALIAS ESTADO: $alias");
    var response = await http.get(
        Uri.parse("${"${url_base}acp/index.php/transportearandano/setReinicioAcopiosIndividual?accion=reinicioindividual&idviajes=" +
            result}&alias=$alias"),
        headers: {"Accept": "application/json"});
    if (mounted) {
      setState(() {
        var extraerData = json.decode(response.body);
        String result = extraerData["state"].toString();
        print("RESULTADO ACOPIO: $result");
      });
    }
  }*/


  Future<Uint8List?> _createAvatarAcopiosRestantes(
      int width, int height, String name, Color color) async {
    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = color;

    canvas.drawOval(
      Rect.fromCircle(
        center: Offset(width * 0.5, height * 0.5),
        radius: math.min(width * 0.5, height * 0.5),
      ),
      paint,
    );

    TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
    painter.text = TextSpan(
      text: name,
      style: const TextStyle(
          fontSize: 18.0, color: Colors.white, fontWeight: FontWeight.w700),
    );
    painter.layout();
    painter.paint(
        canvas,
        Offset((width * 0.5) - painter.width * 0.5,
            (height * 0.5) - painter.height * 0.5));

    final img = await pictureRecorder.endRecording().toImage(width, height);
    final data = await img.toByteData(format: ImageByteFormat.png);
    return data?.buffer.asUint8List();
  }

  void setSourceAndDestinationIcons() async {
    BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.0),
            'assets/images/marker_truck.png')
        .then((onValue) {
      sourceIcones = onValue;
    });
  }

  void _setMarkerIcon() async {
    _markerIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), 'assets/images/bag_fruit.png');
  }

  void _setMarkerIcon2() async {
    _markerIcon2 = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), 'assets/images/navigation2.png');
  }

  void _toggleMapStyle() async {
    String style = await DefaultAssetBundle.of(context)
        .loadString('assets/images/marker_truck.png');

    if (_showMapStyle) {
      _mapController!.setMapStyle(style);
    } else {
      _mapController!.setMapStyle(null);
    }
  }

  void setInitialLocation() async {
    currentLocationes = await location!.getLocation();
  }

  Future<Uint8List> _createAvatarRestantes(int width, int height, String name,
      {Color color = Colors.deepPurple}) async {
    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = color;

    canvas.drawOval(
      Rect.fromCircle(
        center: Offset(width * 0.5, height * 0.5),
        radius: math.min(width * 0.5, height * 0.5),
      ),
      paint,
    );

    TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
    painter.text = TextSpan(
      text: name,
      style: const TextStyle(
          fontSize: 25.0, color: Colors.white, fontWeight: FontWeight.w700),
    );
    painter.layout();
    painter.paint(
        canvas,
        Offset((width * 0.5) - painter.width * 0.5,
            (height * 0.5) - painter.height * 0.5));

    final img = await pictureRecorder.endRecording().toImage(width, height);
    final data = await img.toByteData(format: ImageByteFormat.png);
    return data!.buffer.asUint8List();
  }

  Future<Uint8List> _createAvatarCerrado(int width, int height, String name,
      {Color color = Colors.grey}) async {
    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = color;

    canvas.drawOval(
      Rect.fromCircle(
        center: Offset(width * 0.5, height * 0.5),
        radius: math.min(width * 0.5, height * 0.5),
      ),
      paint,
    );

    TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
    painter.text = TextSpan(
      text: name,
      style: const TextStyle(
          fontSize: 25.0, color: Colors.white, fontWeight: FontWeight.w700),
    );
    painter.layout();
    painter.paint(
        canvas,
        Offset((width * 0.5) - painter.width * 0.5,
            (height * 0.5) - painter.height * 0.5));

    final img = await pictureRecorder.endRecording().toImage(width, height);
    final data = await img.toByteData(format: ImageByteFormat.png);
    return data!.buffer.asUint8List();
  }

  Future<Uint8List> _createAvatarExceso(int width, int height, String name,
      {Color color = Colors.red}) async {
    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = color;

    canvas.drawOval(
      Rect.fromCircle(
        center: Offset(width * 0.5, height * 0.5),
        radius: math.min(width * 0.5, height * 0.5),
      ),
      paint,
    );

    TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
    painter.text = TextSpan(
      text: name,
      style: const TextStyle(
          fontSize: 25.0, color: Colors.white, fontWeight: FontWeight.w700),
    );
    painter.layout();
    painter.paint(
        canvas,
        Offset((width * 0.5) - painter.width * 0.5,
            (height * 0.5) - painter.height * 0.5));

    final img = await pictureRecorder.endRecording().toImage(width, height);
    final data = await img.toByteData(format: ImageByteFormat.png);
    return data!.buffer.asUint8List();
  }

  Future<Uint8List> _createAvatarBusqueda(int width, int height, String name,
      {Color color = kPrimaryColor}) async {
    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = color;

    canvas.drawOval(
      Rect.fromCircle(
        center: Offset(width * 0.5, height * 0.5),
        radius: math.min(width * 0.5, height * 0.5),
      ),
      paint,
    );

    TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
    painter.text = TextSpan(
      text: name,
      style: const TextStyle(
          fontSize: 25.0, color: Colors.white, fontWeight: FontWeight.w700),
    );
    painter.layout();
    painter.paint(
        canvas,
        Offset((width * 0.5) - painter.width * 0.5,
            (height * 0.5) - painter.height * 0.5));

    final img = await pictureRecorder.endRecording().toImage(width, height);
    final data = await img.toByteData(format: ImageByteFormat.png);
    return data!.buffer.asUint8List();
  }

  Future<Uint8List?> _createAvatar(int width, int height, String name,
      {Color color = kArandano}) async {
    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = color;

    canvas.drawOval(
      Rect.fromCircle(
        center: Offset(width * 0.5, height * 0.5),
        radius: math.min(width * 0.5, height * 0.5),
      ),
      paint,
    );

    TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
    painter.text = TextSpan(
      text: name,
      style: const TextStyle(
          fontSize: 25.0, color: Colors.white, fontWeight: FontWeight.w700),
    );
    painter.layout();
    painter.paint(
        canvas,
        Offset((width * 0.5) - painter.width * 0.5,
            (height * 0.5) - painter.height * 0.5));

    final img = await pictureRecorder.endRecording().toImage(width, height);
    final data = await img.toByteData(format: ImageByteFormat.png);
    return data?.buffer.asUint8List();
  }

  Future<void> cargarCantidades() async {
    var datajabas;
     /*showDialog(
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
                    child: Column(children:  const <Widget>[
                      CircularProgressIndicator(),
                      SizedBox(height: 5),
                      Text("Verificando jabas")
                    ]),
                  )));
        });*/
    var response1 = await http.get(
        Uri.parse("${url_base}WSPowerBI/controller/transportearandano.php?accion=totalizadojabas"),
        headers: {"Accept": "application/json"});
    if (mounted) {
    setState(() {
      extraerData1 = json.decode(response1.body);
      print("PRUEBA JABAS: ----"+extraerData1.toString());
      datajabas = extraerData1["datos"];
      jabaspedateadas = datajabas![0]["TOTALPEDATEADO"];
      jabasdisponibles = datajabas![0]["CANTIDAD_JABAS"];
      jabasrecogidas = datajabas![0]["CANTIDAD_RECOGIDAS"];
    });
     }

    // Navigator.pop(context);

  }

  Future<void> recibirAcopios() async {

    var extraerDataAcopiosRestantes;
    var cantidadrestada = 0;
    var extraerData1;
    List? datapunto;
    var ddData = [];
    String? aliasnewpoint, consumidornewpoint;
    double? latnewpoint, longnewpoint;
   /* showDialog(
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
                    child: Column(children:  const <Widget>[
                      CircularProgressIndicator(),
                      SizedBox(height: 5),
                      Text("Verificando acopios extra")
                    ]),
                  )));
        });*/
    var response1 = await http.get(
        Uri.parse("${url_base}WSPowerBI/controller/transportearandano.php?accion=puntoinicioadmin"),
        headers: {"Accept": "application/json"});
    //if (mounted) {
      setState(() {
        extraerData1 = json.decode(response1.body);
        print("PRUEBAAAA: ----"+extraerData1.toString());
        datapunto = extraerData1["datos"];

      });
   // }
    for (var i = 0; i < datapunto!.length; i++) {
      int cantidadJabasRestantes = int.parse(
          datapunto![i]["CANTIDAD_JABAS"]);
          if(int.parse(datapunto![i]["CANTIDAD_JABAS"]) > 0) {
            var bitmapData;
            if(datapunto![i]["NAME"] == "LIBRE") {
              bitmapData =
              await _createAvatarBusqueda(
                  80, 90, datapunto![i]["CANTIDAD_JABAS"]);
            }else{
              bitmapData = await _createAvatarRestantes(
                  80, 90, datapunto![i]["CANTIDAD_JABAS"]);
            }
            var bitmapDescriptor = BitmapDescriptor.fromBytes(bitmapData);
            _markers.add(
              Marker(
                  markerId: MarkerId(datapunto![i]["ALIAS"]),
                  position: LatLng(double.parse(datapunto![i]["LATITUD"]),
                      double.parse(datapunto![i]["LONGITUD"])),
                  icon: bitmapDescriptor,
                  onTap: () {
                    /*showDialog(
                        context: context,
                        builder: (context) => CustomDialogs(
                          title: "ACOPIO OCUPADO POR: "+datapunto![i]["NAME"],
                          description: "",
                          imagen: "assets/images/arandano_icon.png",
                          cantidad: datapunto![i]["CANTIDAD_JABAS"],
                          alias: datapunto![i]["ALIAS"]
                        ));*/
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            RegistroViajeAdm(
                              title: "ACOPIO DE: " + datapunto![i]["NAME"],
                              trazabilidad: datapunto![i]["TRAZA"],
                              description: datapunto![i]["DESCRIPCION"],
                              imagen: "assets/images/ar andano_icon.png",
                              cantidad: datapunto![i]["CANTIDAD_JABAS"],
                              alias: datapunto![i]["ALIAS"],
                              latitud: datapunto![i]["LATITUD"],
                              longitud: datapunto![i]["LONGITUD"],
                              idacopio: datapunto![i]["IDACOPIO"],
                              // area: data[i]["AREA"],
                           //   idviajes: result.toString(),
                              tipoacopio: '-',
                            ),
                      ),
                    );
                  }),
            );
          }else if(int.parse(datapunto![i]["CANTIDAD_JABAS"]) == 0){
            var bitmapData;
              bitmapData = await _createAvatarCerrado(
                  80, 90, datapunto![i]["CANTIDAD_JABAS"]);
            var bitmapDescriptor = BitmapDescriptor.fromBytes(bitmapData);
            _markers.add(
              Marker(
                  markerId: MarkerId(datapunto![i]["ALIAS"]),
                  position: LatLng(double.parse(datapunto![i]["LATITUD"]),
                      double.parse(datapunto![i]["LONGITUD"])),
                  icon: bitmapDescriptor,
                  onTap: () {
                    /*showDialog(
                        context: context,
                        builder: (context) => CustomDialogs(
                            title: "ACOPIO OCUPADO POR: "+datapunto![i]["NAME"],
                            description: "",
                            imagen: "assets/images/arandano_icon.png",
                            cantidad: datapunto![i]["CANTIDAD_JABAS"],
                            alias: datapunto![i]["ALIAS"]
                        ));*/
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            RegistroViajeAdm(
                              title: "ACOPIO DE: " + datapunto![i]["NAME"],
                              trazabilidad: datapunto![i]["TRAZA"],
                              description: datapunto![i]["DESCRIPCION"],
                              imagen: "assets/images/ar andano_icon.png",
                              cantidad: datapunto![i]["CANTIDAD_JABAS"],
                              alias: datapunto![i]["ALIAS"],
                              latitud: datapunto![i]["LATITUD"],
                              longitud: datapunto![i]["LONGITUD"],
                              idacopio: datapunto![i]["IDACOPIO"],
                              // area: data[i]["AREA"],
                           //   idviajes: result.toString(),
                              tipoacopio: '-',
                            ),
                      ),
                    );
                  }),
            );
          }else if(int.parse(datapunto![i]["CANTIDAD_JABAS"]) < 0){
            var bitmapData;
            bitmapData = await _createAvatarExceso(
                80, 90, datapunto![i]["CANTIDAD_JABAS"]);
            var bitmapDescriptor = BitmapDescriptor.fromBytes(bitmapData);
            _markers.add(
              Marker(
                  markerId: MarkerId(datapunto![i]["ALIAS"]),
                  position: LatLng(double.parse(datapunto![i]["LATITUD"]),
                      double.parse(datapunto![i]["LONGITUD"])),
                  icon: bitmapDescriptor,
                  onTap: () {
                    /*showDialog(
                        context: context,
                        builder: (context) => CustomDialogs(
                            title: "ACOPIO OCUPADO POR: "+datapunto![i]["NAME"],
                            description: "",
                            imagen: "assets/images/arandano_icon.png",
                            cantidad: datapunto![i]["CANTIDAD_JABAS"],
                            alias: datapunto![i]["ALIAS"]
                        ));*/
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            RegistroViajeAdm(
                              title: "ACOPIO DE: " + datapunto![i]["NAME"],
                              trazabilidad: datapunto![i]["TRAZA"],
                              description: datapunto![i]["DESCRIPCION"],
                              imagen: "assets/images/ar andano_icon.png",
                              cantidad: datapunto![i]["CANTIDAD_JABAS"],
                              alias: datapunto![i]["ALIAS"],
                              latitud: datapunto![i]["LATITUD"],
                              longitud: datapunto![i]["LONGITUD"],
                              idacopio: datapunto![i]["IDACOPIO"],
                              // area: data[i]["AREA"],
                            //  idviajes: result.toString(),
                              tipoacopio: '-',
                            ),
                      ),
                    );
                  }),
            );
          }
    }
   // Navigator.pop(context);

  }

  /*Future<void> RecibirDatos() async {
    var ddData = [];
    String ruta = "";
    mediaIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(devicePixelRatio: 2), 'assets/images/flages.png');
    sourceIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(devicePixelRatio: 2), 'assets/images/bag_fruit.png');

    _markers.add(Marker(
        markerId: MarkerId("V1"),
        position: LatLng(-7.043901, -79.541921),
        icon: mediaIcon!));

    for (var i = 0; i < widget.data!.length; i++) {
      var bitmapData =
          await _createAvatar(80, 90, widget.data![i]["CANTIDAD_JABAS"]);
      var bitmapDescriptor = BitmapDescriptor.fromBytes(bitmapData!);
      if (int.parse(widget.data![i]["CANTIDAD_JABAS"]) > 0) {
        _markers.add(
          Marker(
            markerId: MarkerId(widget.data![i]["ALIAS"]),
            position: LatLng(double.parse(widget.data![i]["LATITUD"]),
                double.parse(widget.data![i]["LONGITUD"])),
            icon: bitmapDescriptor,
          ),
        );
      }
      if (i == 0) {
        var objeto = {
          // Le agregas la fecha
          "ALIAS": widget.data![i]["ALIAS"]
        };
        ddData.add(objeto);
      }
    }

    var inicio = 'V1';
    var fin = json.encode(ddData);
    /*var responses = await http.post(
        "http://190.223.54.4/acp/index.php/optimizacionrutapp/returnShortestPath",
        body: {"puntoInicio": inicio, "destinosAgregados": fin});
    setState(() {
      print("RESPUESTA1: " + responses.body.toString());
      final extraerData =
          new Map<String, dynamic>.from(json.decode(responses.body));
      data1 = extraerData["datos"]["coordenadas"];
      List<LatLng> polylineLatLongs = List<LatLng>();
      ruta = responses.body;
      distancia = extraerData["datos"]["costo"];
      for (var i = 0; i < data1.length; i++) {
        polylineLatLongs.add(LatLng(double.parse(data1[i]["latitud"]),
            double.parse(data1[i]["longitud"])));
        _polylines.add(
          Polyline(
            polylineId: PolylineId("0"),
            points: polylineLatLongs,
            color: Colors.yellowAccent[400],
            width: 8,
          ),
        );
      }
    });*/
  }*/

  void setSourceAndDestinationMarkerIcons(BuildContext context) async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2), 'assets/images/bag_fruit.png');

    initIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2),
        'assets/images/car-placeholder.png');

    mediaIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2), 'assets/images/flages.png');

    destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 1), 'assets/images/bag_fruit.png');
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _controller.complete(controller);
    setState(() {
      _markers.add(
        Marker(
            markerId: MarkerId("sourcePin"),
            position: LatLng(-7.043901, -79.541921),
            icon: _markerIcon!),
      );
      showPinsOnMap();
    });
  }

  void _onMapCreated2(GoogleMapController controller) {
    _mapController = controller;
    _controller.complete(controller);
    setState(() {
      _markers.add(
        Marker(
            markerId: MarkerId("sourcePin"),
            position:
                LatLng(currentLocationes!.latitude!, currentLocationes!.longitude!),
            icon: _markerIcon2!),
      );
    });
  }

  zoomInMarker() {
    estado = 1;
    _mapController!
        .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(currentLocationes!.latitude!, currentLocationes!.longitude!),
      zoom: 25,
      tilt: 90,
      bearing: -30,
    )))
        .then((val) {
      setState(() {
        resetToggle = true;
        _onMapCreated2(_mapController!);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    setSourceAndDestinationMarkerIcons(context);
    CameraPosition initialCameraPosition = const CameraPosition(
        zoom: CAMERA_ZOOM,
        tilt: CAMERA_TILT,
        bearing: CAMERA_BEARING,
        target: SOURCE_LOCATION);
    if (currentLocationes != null) {
      initialCameraPosition = CameraPosition(
          target:
              LatLng(currentLocationes!.latitude!, currentLocationes!.longitude!),
          zoom: CAMERA_ZOOM,
          tilt: CAMERA_TILT,
          bearing: CAMERA_BEARING);
    }

    return Scaffold(
        body: Stack(
      children: <Widget>[
        GoogleMap(
          myLocationEnabled: true,
          compassEnabled: false,
          tiltGesturesEnabled: false,
          //   zoomControlsEnabled: false,
          onMapCreated: _onMapCreated,
          initialCameraPosition: initialCameraPosition,
          onTap: (LatLng loc) {
            pinPillPosition = -200;
          },
          mapType: MapType.satellite,
          markers: _markers,
          polygons: _polygons,
          polylines: _polylines,
          circles: _circles,
          myLocationButtonEnabled: false,
        ),
        Container(
          alignment: Alignment.bottomCenter,
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 80),
        ),
        Align(
            alignment: Alignment.topLeft,
            child: GestureDetector(
              child: Container(
                  margin: const EdgeInsets.only(top: 45, left: 20),
                  child: ClipOval(
                      child: Container(
                          color: kArandano,
                          //margin: EdgeInsets.only(top: 45),
                          padding: const EdgeInsets.all(5),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 32,
                          )))),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SecondPage(),
                  ),
                );
              },
            )),
        /* AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: 0,
            right: 0,
            bottom: this.pinPillPosition,
            child: MapBottomPillJabas(
                nombre: nombre == null ? 'USUARIO' : nombre)),*/
        Positioned(

            top: 50,
            right: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[

                GestureDetector(
                  child: Container(

                    margin: const EdgeInsets.only(top: 10, right: 10),
                    child: ClipOval(
                        child: Container(
                            color: kPanetone,
                            //margin: EdgeInsets.only(top: 45),
                            padding: const EdgeInsets.all(5),
                            child: const Icon(
                              Icons.sync,
                              color: Colors.white,
                              size: 32,
                            ))),
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
                  ),
                  onTap: () async {
                    _markers.removeWhere((m) => m.markerId.value != '');
                    cargarCantidades();
                    recibirAcopios();
                    print('si actualiza');
                  },
                ),

              ],
            )),
        Positioned(

            bottom: 10,
            right: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[

                GestureDetector(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10, right: 10),
                    child: ClipOval(
                        child: Container(
                            color: kAccentColor,
                            //margin: EdgeInsets.only(top: 45),
                            padding: const EdgeInsets.all(15),
                            child: Text(jabaspedateadas!  + " JBS. COS.", style: TextStyle(color: Colors.white)
                            ))),
                    decoration: BoxDecoration(
                        color: kAccentColor,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10.0,
                            offset: Offset(0.0, 10.0),
                          )
                        ]),
                  ),
                  onTap: () async {
                    showDialog(
                        context: context,
                        builder: (context) => CustomDialogsActividad(
                            title: "COSECHA"));
                  },
                ),
                const SizedBox(height: 10,),
                GestureDetector(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10, right: 10),
                    child: ClipOval(
                        child: Container(
                            color: kPrimaryColor,
                            //margin: EdgeInsets.only(top: 45),
                            padding: const EdgeInsets.all(15),
                            child: Text(jabasrecogidas!  + " JBS. REC.", style: TextStyle(color: Colors.white)
                            ))),
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
                  ),
                  onTap: () async {
                  },
                ),
                const SizedBox(height: 10,),
                GestureDetector(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10, right: 10),
                    child: ClipOval(
                        child: Container(
                            color: Colors.red,
                            //margin: EdgeInsets.only(top: 45),
                            padding: const EdgeInsets.all(15),
                            child: Text(jabasdisponibles! +" JBS. DISP.", style: TextStyle(color: Colors.white)
                            ))),
                    decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10.0,
                            offset: Offset(0.0, 10.0),
                          )
                        ]),
                  ),
                  onTap: () async {
                  },
                ),
              ],
            )),

      ],
    )
        //  : Loader(),
        );
  }
}

class CustomDialogs extends StatefulWidget {
  final String? title,
      description,
      buttontext,
      imagen,
      cantidad,
      alias;
  final Image? image;

  CustomDialogs(
      {this.title,
      this.description,
      this.buttontext,
      this.image,
      this.imagen,
      this.cantidad,
      this.alias});

  _CustomDialogsState createState() => _CustomDialogsState();
}

class _CustomDialogsState extends State<CustomDialogs> {

  List? dataconductores;
  String? dropdownValue;
  @override
  Future<void> AtualizarAcopios(String pacopios, int tipo) async {
    var response = await http.get(
        Uri.parse(
            "http://web.acpagro.com/acp/index.php/transportearandano/setAcopios?accion=estado&alias=" +
                pacopios +
                "&tipo=" +
                tipo.toString()),
        headers: {"Accept": "application/json"});
    if (mounted) {
      setState(() {
        var extraerData = json.decode(response.body);
        String result = extraerData["state"].toString();
        print("RESULTADO: " + result.toString());
      });
    }
  }
  Future<void> MostrarConductores() async {
    var response = await http.get(
        Uri.parse(
            "${url_base}WSPowerBI/controller/transportearandano.php?accion=transportistasvigentes"),
        headers: {"Accept": "application/json"});
    setState(() {
      var extraerData = json.decode(response.body);
      dataconductores = extraerData["datos"];
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    MostrarConductores();
  }


  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: dialogContents(context),
    );
  }

  dialogContents(BuildContext context) {
    final myControllerPD = TextEditingController();


    var mediaQuery = MediaQuery.of(context);
    Size size = MediaQuery.of(context).size;
    return Stack(
      children: <Widget>[
        AnimatedContainer(
          padding: mediaQuery.padding,
          duration: const Duration(milliseconds: 500),
          child: Container(
            padding: const EdgeInsets.only(top: 50, bottom: 16, left: 16, right: 16),
            margin: EdgeInsets.only(top: 16),
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
                  widget.title!,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Divider(),
                const SizedBox(height: 10.0),
                Text(
                  'Total de jabas por cargar: ' + widget.cantidad!,
                  style: const TextStyle(fontSize: 14.0),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 15.0),
                widget.title!.contains("LIBRE") ?
                SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child:Row(children: <Widget>[
                   dataconductores != null
                      ? DropdownButton<String>(
                    value: dropdownValue,
                    icon: const Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    hint: const Text('Selecciona el conductor'),
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
                    items: dataconductores!.map((list) {
                      return DropdownMenuItem(
                        value: list['IDVIAJES'].toString(),
                        child: Text(list['NAME']),
                      );
                    }).toList(),
                  )
                      : const Center(
                    child: CircularProgressIndicator(),
                  ),
              ]),
                ) :
                Flexible( child: Container(
                  child: Form(
                    key: _formKey,
                    child: TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Debe ingresar la cantidad de jabas';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                      // textInputAction: TextInputAction.go,
                      cursorColor: kPrimaryColor,
                      controller: myControllerPD,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: 'Cant. de jabas',
                        labelStyle: const TextStyle(color: Colors.grey),
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
                  ),
                )),
                const SizedBox(height: 8),
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

                            },
                            child: Text(
                              widget.title!.contains("LIBRE") ? "Asignar" : "Liberar",
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
                              "Cerrar Acopio",
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
        Positioned(
          top: 0,
          left: size.width / 3.5,
          //right: 16,
          child: CircleAvatar(
            backgroundColor: Colors.white,
            radius: 50,
            backgroundImage: AssetImage(widget.imagen!),
          ),
        )
      ],
    );
  }
}

class CustomDialogsBuscar extends StatelessWidget {
  final String? title, description, buttontext, imagen;
  final Image? image;

  CustomDialogsBuscar(
      {this.title, this.description, this.buttontext, this.image, this.imagen});
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
          padding: const EdgeInsets.only(top: 50, bottom: 16, left: 16, right: 16),
          margin: const EdgeInsets.only(top: 16),
          decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(50),
              boxShadow: const[
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

class CustomDialogsActividad extends StatefulWidget {
  final String? title;


  const CustomDialogsActividad(
      {Key? key,
        this.title})
      : super(key: key);
  @override
  _CustomDialogsActividadState createState() => _CustomDialogsActividadState();
}

class _CustomDialogsActividadState extends State<CustomDialogsActividad>{

  List? datajabas;
  Future<void> cargarCantidadesJabas() async {
    print("prueba de cantidad de jabas");
    /*showDialog(
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
                    child: Column(children:  const <Widget>[
                      CircularProgressIndicator(),
                      SizedBox(height: 5),
                      Text("Verificando jabas")
                    ]),
                  )));
        });*/
    var response1 = await http.get(
        Uri.parse("${url_base}WSPowerBI/controller/transportearandano.php?accion=jabascosechadas"),
        headers: {"Accept": "application/json"});
    //if (mounted) {
     setState(() {
        var extraerData1 = json.decode(response1.body);
        print("PRUEBA JABAS: ----"+extraerData1.toString());
        datajabas = extraerData1["datos"];
    });
   // Navigator.pop(context);

  }

  void initState() {
    super.initState();
    cargarCantidadesJabas();
  }

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
              const Text(
                "MÓDULO |COSECHADO| POR CARGAR",
                style:  TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w700,
                  color: kPrimaryColor
                ),
              ),
              const Divider(),
              const SizedBox(height: 10.0),
              SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SizedBox(
             // height: size.height / 1.5,
                child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: datajabas == null ? 0 : datajabas!.length,
                itemBuilder: (BuildContext context, i) {
                //  print("JABAAAAASSSS: "+datajabas![i]["CONSUMIDOR"]);
                  if (datajabas!.isEmpty) {
                    return const Center(
                        child: Text("Sin datos",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black)));
                  } else {
                       /* child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [*/
                          return Container(child:Text(datajabas![i]["CONSUMIDOR"] + " | "+datajabas![i]["CANTIDAD_JABAS"]+" | "+datajabas![i]["JABAS_PORCARGAR"], style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black)));
                      //  ]);
                    //  MapBottomPillHome();
                  }
                  //return Container();
                },
              ),),),
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
      ],
    );
  }
}