import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importation de Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Importation de Firestore
import 'Accueil.dart'; // Importation de la page Acceuilpage
import 'addUser.dart'; // Importation de la page AddUser

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>(); // Clé pour le formulaire
  final _auth = FirebaseAuth.instance; // Instance de Firebase Auth
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Instance de Firestore

  // Contrôleurs pour les champs du formulaire
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false; // Pour gérer l'état du chargement

  // Fonction pour gérer la connexion
  Future<void> _loginUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Activer le chargement
      });

      try {
        // Connexion avec Firebase Auth
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Si la connexion est réussie, récupérer le nom de l'utilisateur depuis Firestore
        if (userCredential.user != null) {
          String userId = userCredential.user!.uid;

          // Récupérer le document de l'utilisateur dans Firestore
          DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();

          if (userDoc.exists) {
            String userName = userDoc['nom']; // Supposons que le champ du nom est 'name'

            // Naviguer vers la page Acceuilpage avec le nom de l'utilisateur
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Acceuilpage(username: userName),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Utilisateur non trouvé dans Firestore')),
            );
          }
        }
      } on FirebaseAuthException catch (e) {
        // Gérer les erreurs de connexion
        String errorMessage = 'Une erreur s\'est produite';
        if (e.code == 'user-not-found') {
          errorMessage = 'Aucun utilisateur trouvé avec cet email';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Mot de passe incorrect';
        }

        // Afficher l'erreur à l'utilisateur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } finally {
        setState(() {
          _isLoading = false; // Désactiver le chargement
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEDEDF4), // Couleur de fond
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo ou titre
                  Text(
                    'Connexion',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A47A3), // Couleur principale
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'CLUB_IT',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A47A3), // Couleur principale
                    ),
                  ),
                  SizedBox(height: 32),

                  // Champ email
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Adresse email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.email, color: Color(0xFF4A47A3)),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre email';
                      }
                      if (!value.contains('@')) {
                        return 'Email invalide';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Champ mot de passe
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.lock, color: Color(0xFF4A47A3)),
                    ),
                    obscureText: true, // Masquer le mot de passe
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un mot de passe';
                      }
                      if (value.length < 6) {
                        return 'Le mot de passe doit contenir au moins 6 caractères';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24),

                  // Bouton de connexion
                  ElevatedButton(
                    onPressed: _isLoading ? null : _loginUser,
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                      'Se connecter',
                      style: TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4A47A3), // Couleur du bouton
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Lien pour s'inscrire
                  TextButton(
                    onPressed: () {
                      // Naviguer vers la page AddUser
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddUserPage()),
                      );
                    },
                    child: Text(
                      'Pas encore inscrit ? S\'inscrire',
                      style: TextStyle(
                        color: Color(0xFF4A47A3), // Couleur du texte
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}