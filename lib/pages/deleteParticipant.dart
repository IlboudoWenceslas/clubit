import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeleteParticipant extends StatefulWidget {
  final String formationId;
  DeleteParticipant({required this.formationId});

  @override
  _DeleteParticipantState createState() => _DeleteParticipantState();
}

class _DeleteParticipantState extends State<DeleteParticipant> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _telephoneController = TextEditingController();

  Future<void> _supprimerParticipant() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Récupérer la formation
        DocumentSnapshot formationSnapshot = await FirebaseFirestore.instance
            .collection('formations')
            .doc(widget.formationId)
            .get();

        List<dynamic> participants = formationSnapshot['participants'];

        // Trouver le participant avec le numéro de téléphone saisi
        var participant = participants.firstWhere(
              (p) => p['telephone'] == _telephoneController.text.trim(),
          orElse: () => null,
        );

        if (participant != null) {
          // Supprimer le participant
          await FirebaseFirestore.instance.collection('formations').doc(widget.formationId).update({
            'participants': FieldValue.arrayRemove([participant]),
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Participant supprimé avec succès!')),
          );

          Navigator.pop(context); // Revenir à la page précédente
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Aucun participant trouvé avec ce numéro de téléphone.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la suppression du participant: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Supprimer un participant'),
        backgroundColor: Color(0xFF4A47A3),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
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
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _supprimerParticipant,
                child: Text('Supprimer'),
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