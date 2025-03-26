import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/adapters.dart';

class AddParticipant extends StatefulWidget {
  final String formationId;
  AddParticipant({required this.formationId});

  @override
  _AddParticipantState createState() => _AddParticipantState();
}

class _AddParticipantState extends State<AddParticipant> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _prenomController =TextEditingController();
  final TextEditingController _universiterController=TextEditingController();
  final TextEditingController _filiereController=TextEditingController();
  final TextEditingController _emailController=TextEditingController();
  final TextEditingController _niveauController=TextEditingController();


  Future<bool> isConnected() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }
  Future<void> _ajouterParticipant() async {
    if (_formKey.currentState!.validate()) {
      final participant = {
        'nom': _nomController.text.trim(),
        'prenom': _prenomController.text.trim(),
        'universiter': _universiterController.text.trim(),
        'filiere': _filiereController.text.trim(),
        'niveau': _niveauController.text.trim(),
        'email': _emailController.text.trim(),
        'telephone': _telephoneController.text.trim(),
        'formationId': widget.formationId, // Ajouter l'ID de la formation
      };

      final participantsBox = Hive.box('participantsBox');

      if (await isConnected()) {
        // Si en ligne, ajouter directement à Firestore
        try {
          await FirebaseFirestore.instance.collection('formations').doc(widget.formationId).update({
            'participants': FieldValue.arrayUnion([participant]),
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Participant ajouté avec succès!')),
          );

          Navigator.pop(context);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur lors de l\'ajout du participant: $e')),
          );
        }
      } else {
        // Si hors ligne, enregistrer localement
        participantsBox.add(participant);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Participant enregistré localement. Synchronisation requise.')),
        );

        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter un participant'),
        backgroundColor: Color(0xFF4A47A3),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nomController,
                decoration: InputDecoration(
                  labelText: 'Nom du participant:',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _prenomController,
                decoration: InputDecoration(
                  labelText: 'prénom du participant:',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un prénom';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _universiterController,
                decoration: InputDecoration(
                  labelText: 'Universitée ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une universitée';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _filiereController,
                decoration: InputDecoration(
                  labelText: 'Filiére',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une filiere';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _niveauController,
                decoration: InputDecoration(
                  labelText: 'niveau étude du participant',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un niveau d\'étude';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une adresse mail';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _telephoneController,
                decoration: InputDecoration(
                  labelText: 'Numéro de téléphone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un numéro de téléphone';
                  }
                  return null;
                },
              ),
              SizedBox(height: 64),
              ElevatedButton(
                onPressed: _ajouterParticipant,
                child: Text('Ajouter'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}