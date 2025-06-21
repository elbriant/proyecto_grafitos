import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_grafitos/global_data.dart';
import 'package:proyecto_grafitos/pages/main_page.dart';
import 'package:proyecto_grafitos/provider/debug_provider.dart';
import 'package:proyecto_grafitos/provider/settings_provider.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await databaseSetup();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => DebugProvider()),
      ],
      child: MaterialApp(
        title: 'GrafitosApp',
        navigatorKey: NavigationService.navigatorKey,
        theme: ThemeData.from(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.orangeAccent,
            dynamicSchemeVariant: DynamicSchemeVariant.rainbow,
          ),
        ),
        home: MainPage(),
      ),
    );
  }
}

Future<void> databaseSetup() async {
  if (Platform.isWindows || Platform.isLinux) {
    // Initialize FFI
    sqfliteFfiInit();
    // Change the default factory. On iOS/Android, if not using `sqlite_flutter_lib` you can forget
    // this step, it will use the sqlite version available on the system.
    databaseFactory = databaseFactoryFfi;
  }

  var databasesPath = await getDatabasesPath();
  String dbPath = join(databasesPath, 'database.db');

  // copy db file from Assets folder to database folder (only if not already there...)
  if (FileSystemEntity.typeSync(dbPath) == FileSystemEntityType.notFound || kDebugMode) {
    ByteData data = await rootBundle.load("assets/database.db");
    final buffer = data.buffer;
    File(dbPath).createSync(recursive: true);
    File(dbPath).writeAsBytesSync(buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }
}
