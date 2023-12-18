//classes
import 'package:galary/provider/theme_provider.dart';
//pages
import 'screens/home_page.dart';
//libs
import 'package:flutter/material.dart';
import 'package:galary/models/image_model.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
//config
import 'config/routes.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.init;

  final appDocumentDirectory = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDirectory.path);

  Hive.registerAdapter(ImageModelAdapter());

  await Hive.openBox<ImageModel>(galeryBox);

  runApp(ChangeNotifierProvider(create: (context) => ThemeProvider(), lazy: false,
  child: const HomePage(),));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).themeData,
      initialRoute: authRoute,
      routes: routeGalary,
    );
  }
}

