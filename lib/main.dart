import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clubit/pages/directionPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:clubit/pages/Accueil.dart';
import 'package:hive_flutter/adapters.dart';
import 'pages/login.dart';
import 'package:path_provider/path_provider.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Assure l'initialisation des widgets
  await Firebase.initializeApp(); // Initialise Firebase


  // Activer la persistance locale
  FirebaseFirestore.instance.settings = Settings(
    persistenceEnabled: true, // Activer la persistance locale
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED, // Taille illimitée du cache
  );

  // Initialiser Hive
  final appDocumentDirectory = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDirectory.path);
  await Hive.openBox('participantsBox'); // Ouvrir une boîte pour les participants

  runApp(MyApp());
}
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      initialRoute: '/',
      routes:{
        '/':(context)=>DirectionPage(),
      }

    );
  }
}
