import 'package:flutter/material.dart';
import 'package:proyecto_grafitos/pages/main_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GrafitosApp',
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orangeAccent,
          dynamicSchemeVariant: DynamicSchemeVariant.rainbow,
        ),
      ),
      home: MainPage(),
    );
  }
}
