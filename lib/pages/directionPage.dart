import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'Accueil.dart'; // Assurez-vous d'importer vos pages
import 'login.dart'; // Assurez-vous d'importer vos pages

class DirectionPage extends StatelessWidget {
  final Connectivity _connectivity = Connectivity();

  Future<Widget> checkConnection() async {
    try {
      List<ConnectivityResult> results = await _connectivity.checkConnectivity();
      ConnectivityResult result = results.isNotEmpty ? results.first : ConnectivityResult.none;

      if (result != ConnectivityResult.none) {
        return LoginPage(); // Rediriger vers la page de connexion
      } else {
        return Acceuilpage(); // Rediriger vers la page d'accueil
      }
    } catch (e) {
      print('Erreur lors de la vérification de la connectivité : $e');
      return Center(child: Text('Une erreur est survenue'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Widget>(
        future: checkConnection(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // Indicateur de chargement
          } else if (snapshot.hasError) {
            return Center(child: Text("Erreur de connexion"));
          } else if (snapshot.hasData) {
            // Une fois la connexion vérifiée, rediriger vers la bonne page
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => snapshot.data!),
              );
            });
            return SizedBox(); // Retourne un widget vide pour éviter les erreurs d'affichage
          } else {
            return Center(child: Text("Patientez..."));
          }
        },
      ),
    );
  }
}
