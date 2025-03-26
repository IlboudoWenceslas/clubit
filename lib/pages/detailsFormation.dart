import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:url_launcher/url_launcher.dart';
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
  String truncateWithEllipsis(int cutoff, String myString) {
    return (myString.length <= cutoff) ? myString : '${myString.substring(0, cutoff)}...';
  }

  Future<List<String>> getNumerosParticipants(String formationId) async {
    final doc = await FirebaseFirestore.instance.collection('formations').doc(formationId).get();
    final data = doc.data();
    if (data == null || data['participants'] == null) return [];

    final participants = data['participants'] as List<dynamic>;
    return participants.map((p) => p['telephone'].toString()).toList();
  }


  Future<void> envoyerMessageWhatsApp(String numero, String message) async {
    final url = 'https://wa.me/$numero?text=${Uri.encodeComponent(message)}';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Impossible d'ouvrir WhatsApp pour $numero")),
      );
    }
  }



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
                      truncateWithEllipsis(20, formation['titre']),
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
                    Text(truncateWithEllipsis(20, formation['nomFormateur']), style: TextStyle(fontWeight: FontWeight.bold)),
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
          ),SpeedDialChild(
            child: Icon(Icons.send),
            label: 'Message de Diffusion',
            onTap: () async {
              // Récupère les numéros des participants
              List<String> numerosParticipants = await getNumerosParticipants(widget.formationId);

              if (numerosParticipants.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Aucun participant à notifier.")),
                );
                return;
              }

              // Contrôleur pour récupérer le message saisi
              TextEditingController messageController = TextEditingController();

              // Étape 1 : demander de rédiger le message
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("Rédiger le message"),
                    content: TextField(
                      controller: messageController,
                      maxLines: 10,
                      decoration: InputDecoration(
                        hintText: "Entrez le message à diffuser via WhatsApp",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    actions: [
                      TextButton(
                        child: Text("Annuler"),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      TextButton(
                        child: Text("Continuer"),
                        onPressed: () async {
                          Navigator.of(context).pop(); // fermer la boîte de rédaction

                          String message = messageController.text.trim();

                          if (message.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Le message ne peut pas être vide.")),
                            );
                            return;
                          }

                          // Étape 2 : confirmation avant envoi
                          bool? confirmer = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text("Confirmation"),
                              content: Text("Envoyer ce message à ${numerosParticipants.length} participants via WhatsApp ?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: Text("Non"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text("Oui"),
                                ),
                              ],
                            ),
                          );

                          if (confirmer != true) return;

                          // Étape 3 : envoi WhatsApp pour chaque numéro
                          for (String numero in numerosParticipants) {
                            await envoyerMessageWhatsApp(numero, message);
                            await Future.delayed(Duration(seconds: 10)); // pour éviter les conflits d'ouverture
                          }
                        },
                      ),
                    ],
                  );
                },
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