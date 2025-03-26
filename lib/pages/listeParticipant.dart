import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ListeParticipants extends StatelessWidget {
  final String formationId;
  ListeParticipants({required this.formationId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des participants'),
        backgroundColor: Color(0xFF4A47A3),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('formations').doc(formationId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          var formation = snapshot.data!.data() as Map<String, dynamic>;
          List<dynamic> participants = formation['participants'] ?? [];

          if (participants.isEmpty) {
            return Center(
              child: Text('Aucun participant pour cette formation.'),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: participants.length,
            itemBuilder: (context, index) {
              var participant = participants[index];
              return ListTile(
                title: Text(participant['nom'],style:TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.blue),),
                subtitle: Column(
                  children: [
                    Text( participant['prenom']??'un prénom n\'est pas renseigner',style:TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.indigo),),
                    Text( participant['universiter']??'une universiter n\'est pas renseigner',style:TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.indigo),),
                    Text( participant['filiere']??'une filiére n\'est pas renseigner',style:TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.indigo),),
                    Text( participant['niveau']??'un niveau n\'est pas renseigner',style:TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.indigo),),
                    Text( participant['email']??'une adresse mail n\'est pas renseigner',style:TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.indigo),),
                    Text(participant['telephone'],style:TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.indigo),),

                  ],
                ),
                );
            },
          );
        },
      ),
    );
  }
}