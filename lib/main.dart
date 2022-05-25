import 'package:flutter/material.dart';
import 'package:transporte_arandanov2/screens/principal_page.dart';
import 'constants.dart';
import 'Dart:io';

void main() {
  runApp(const MyApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.

  @override

  Widget build(BuildContext context) {
    HttpOverrides.global = MyHttpOverrides();
    return MaterialApp(
      title: 'Transporte Arandano',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}
