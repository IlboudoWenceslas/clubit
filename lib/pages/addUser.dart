import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Pour Firestore
import 'Accueil.dart'; // Votre page d'accueil

class AddUserPage extends StatefulWidget {
  @override
  _AddUserPageState createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Instance de Firestore

  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  // Enregistrer l'utilisateur dans Firestore
  Future<void> _saveUserToFirestore(String uid) async {
    try {
      await _firestore.collection("users").doc(uid).set({
        "nom": _nomController.text.trim(),
        "email": _emailController.text.trim(),
        "password":_passwordController.text.trim(),
        "uid": uid,
        "createdAt": Timestamp.now(),
      });
    } catch (e) {
      print("Erreur lors de l'enregistrement dans Firestore : $e");
      throw e; // Propager l'erreur pour la gérer dans _registerUser
    }
  }

  // Inscription et enregistrement
  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Créer l'utilisateur avec Firebase Auth
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (userCredential.user != null) {
          // Enregistrer l'utilisateur dans Firestore
          await _saveUserToFirestore(userCredential.user!.uid);

          // Afficher un message de succès
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Inscription réussie 🎉")),
          );

          // Rediriger vers la page d'accueil
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Acceuilpage(
                username: _nomController.text.trim(),
              ),
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'Une erreur s\'est produite';
        if (e.code == 'weak-password') {
          errorMessage = 'Le mot de passe est trop faible';
        } else if (e.code == 'email-already-in-use') {
          errorMessage = 'Cet email est déjà utilisé';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'Email invalide';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } catch (e) {
        // Gérer les autres erreurs (par exemple, Firestore)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de l'inscription : $e")),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEDEDF4),
      appBar: AppBar(
        title: Text('S\'inscrire'),
        backgroundColor: Color(0xFF4A47A3),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 50),
                Text(
                  'CLUB_IT',
                  style: TextStyle(
                    color: Color(0xFF4A47A3),
                    fontSize: 28,
                  ),
                ),
                SizedBox(height: 50),

                // Champ nom
                TextFormField(
                  controller: _nomController,
                  decoration: InputDecoration(
                    labelText: 'Nom',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.person, color: Color(0xFF4A47A3)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre nom';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

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
                  obscureText: true,
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

                // Bouton s'inscrire
                ElevatedButton(
                  onPressed: _isLoading ? null : _registerUser,
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                    'S\'inscrire',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4A47A3),
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}