import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:hive_flutter/adapters.dart';
import 'addParticipant.dart';
//import 'addParticipant.dart'; // Importez la nouvelle page
import 'deleteParticipant.dart';
//import 'delete_participant.dart'; // Importez la nouvelle page
import 'listeParticipant.dart';
//import 'liste_participants.dart'; // Importez la nouvelle page
//import 'package:badges/badges.dart';


class DetailsFormation extends StatefulWidget {
  final String formationId;
  DetailsFormation({required this.formationId});

  @override
  _DetailsFormationState createState() => _DetailsFormationState();
}

class _DetailsFormationState extends State<DetailsFormation> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final participantsBox = Hive.box('participantsBox');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails de la formation'),
        backgroundColor: Color(0xFF4A47A3),
        actions: [
          Badge(
            isLabelVisible: participantsBox.isNotEmpty, // Afficher le badge si des participants sont en attente
            label: Text('${participantsBox.length}'),
            child: IconButton(
              icon: Icon(Icons.sync),color: Colors.green,
              onPressed: () async {
                await _synchroniserParticipants();
              },
            ),
          ),
        ],

      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('formations').doc(widget.formationId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          var formation = snapshot.data!.data() as Map<String, dynamic>;
          List<dynamic> participants = formation['participants'] ?? [];
          Timestamp timestamp = formation['dateDebut'];
          String formattedDate = timestamp.toDate().toString();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      formation['titre'],
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    // IconButton(
                    //   icon: Icon(Icons.sync),
                    //   onPressed: (){
                    //
                    //   },
                    // )
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Text('Nom Formateur: '),
                    Text('${formation['nomFormateur']}', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Text('Nom Assistant: '),
                    Text('${formation['nomAssistant']}', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Text('Numéro Formateur: '),
                    Text('${formation['numeroFormateur']}', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Text('Numéro Assistant: '),
                    Text('${formation['numeroAssistant']}', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 8),
                Text('Date de début: $formattedDate'),
                SizedBox(height: 8),
                Text('Catégorie: ${formation['categorie']}'),
                SizedBox(height: 8),
                Text('Statut: ${formation['status']}'),
                SizedBox(height: 8),
                Text('Participants: ${participants.length}',style: TextStyle(color: Color(0xFF4A47A3),fontSize: 17,fontWeight: FontWeight.bold),),
                SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: participants.length,
                    itemBuilder: (context, index) {
                      var participant = participants[index];
                      return ListTile(
                        title: Text(participant['nom']),
                        subtitle:Column(
                          children: [
                            Text(participant['universiter']??'inconnue'),
                            Text(participant['telephone']),
                          ],
                        )
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.menu,
        activeIcon: Icons.close,
        children: [
          SpeedDialChild(
            child: Icon(Icons.add),
            label: 'Ajouter un participant',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddParticipant(formationId: widget.formationId),
                ),
              );
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.remove),
            label: 'Supprimer un participant',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DeleteParticipant(formationId: widget.formationId),
                ),
              );
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.list),
            label: 'Voir la liste des participants',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ListeParticipants(formationId: widget.formationId),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  Future<void> _synchroniserParticipants() async {
    final participantsBox = Hive.box('participantsBox');
    final formationRef = _firestore.collection('formations').doc(widget.formationId);

    for (var participant in participantsBox.values) {
      if (participant['formationId'] == widget.formationId) {
        // Vérifier si le participant existe déjà en ligne
        final formationSnapshot = await formationRef.get();
        final participantsEnLigne = formationSnapshot['participants'] ?? [];

        final existeDeja = participantsEnLigne.any((p) =>
        p['email'] == participant['email'] || p['telephone'] == participant['telephone']);

        if (!existeDeja) {
          await formationRef.update({
            'participants': FieldValue.arrayUnion([participant]),
          });
        }
      }
    }

    // Vider la boîte locale après synchronisation
    participantsBox.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Synchronisation terminée.')),
    );

    setState(() {}); // Rafraîchir l'interface
  }

}