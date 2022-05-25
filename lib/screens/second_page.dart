// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:transporte_arandanov2/components/my_bottom_nav_bar.dart';
import 'package:transporte_arandanov2/screens/body.dart';

class SecondPage extends StatefulWidget {
  const SecondPage({Key? key}) : super(key: key);
  @override
  _SecondPageState createState() =>
      // ignore: no_logic_in_create_state
      _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Body(),
      bottomNavigationBar: MyBottomNavBar(),
    );
  }
}
