import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'addformation.dart';
import 'detailsFormation.dart';
//import 'detailsFormation.dart'; // Nouvelle page pour les détails de la formation

class Acceuilpage extends StatefulWidget {
  final String? username;
  Acceuilpage({ this.username});

  @override
  _AcceuilpageState createState() => _AcceuilpageState();
}

class _AcceuilpageState extends State<Acceuilpage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isOnline = true; // Par défaut, supposons que l'utilisateur est en ligne

  Future<bool> isConnected() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    bool connected = await isConnected();
    setState(() {
      _isOnline = connected;
    });
  }
  String truncateWithEllipsis(int cutoff, String myString) {
    return (myString.length <= cutoff) ? myString : '${myString.substring(0, cutoff)}...';
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEDEDF4),
      appBar: AppBar(
        backgroundColor: Color(0xFF4A47A3),
        centerTitle: true,
        title: const Text(
          'CLUB_IT',
          style: TextStyle(fontSize: 17, color: Colors.white, letterSpacing: 0.5),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        leading: InkWell(
          onTap: () {},
          child: const Icon(
            Icons.subject,
            color: Colors.white,
          ),
        ),
        actions: [
          InkWell(
            onTap: () {},
            child: const Padding(
              padding: EdgeInsets.all(8.0),
            ),
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110.0),
          child: Container(
            padding: EdgeInsets.all(16),
            color: Color(0xFF4A47A3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Salut, ${widget.username}',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, color: Color(0xFF4A47A3)),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher une formation',
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (!_isOnline)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Vous êtes hors ligne. Les données affichées sont celles de la dernière connexion.',
                  style: TextStyle(color: Colors.orange),
                ),
              ),
            // Formations les plus suivies (défilement horizontal)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Les Formations les plus suivies',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Text('Voir tout', style: TextStyle(color: Colors.blue)),
                    ],
                  ),
                  SizedBox(height: 12),
                  Container(
                    height: 150,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection('formations')
                          .orderBy('participants', descending: true)
                          .limit(4)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }
                        var formations = snapshot.data!.docs;
                        if (formations.isEmpty) {
                          return Center(
                            child: Text(
                              'Pour le moment, il n\'y a pas de formations les plus suivies.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          );
                        }
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: formations.length,
                          itemBuilder: (context, index) {
                            var formation = formations[index].data() as Map<String, dynamic>;
                            List<dynamic> participants = formation['participants'] ?? [];
                            return Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: _buildLanguageCard(
                                truncateWithEllipsis(08, formation['titre']), // tronque à 20 caractères par exempl
                                _getIconForCategory(formation['categorie']),
                                _getColorForCategory(formation['categorie']),
                                participants.length,
                                formation['id'].toString(),
                                // Passer l'ID de la formation
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Toutes les formations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            // Toutes les formations (défilement vertical)
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('formations')
                    .where('titre', isGreaterThanOrEqualTo: _searchQuery)
                    .where('titre', isLessThan: _searchQuery + 'z')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  var formations = snapshot.data!.docs;
                  if (formations.isEmpty) {
                    return Center(
                      child: Text(
                        'Aucune formation disponible pour le moment.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: formations.length,
                    itemBuilder: (context, index) {
                      var formation = formations[index].data() as Map<String, dynamic>;
                      List<dynamic> participants = formation['participants'] ?? [];
                      Timestamp timestamp = formation['dateDebut'];
                      String formattedDate = timestamp.toDate().toString();

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: _buildCourseCard(
                          formation['titre'],
                          formattedDate,
                          participants.length,
                          formation['categorie'],
                          formation['id'].toString(), // Passer l'ID de la formation
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Addformation()),
          );
        },
        child: Icon(Icons.book, color: Colors.white),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildLanguageCard(String title, IconData icon, Color color, int participants, String formationId) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailsFormation(formationId: formationId),
          ),
        );
      },
      child: Container(
        width: 140,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              participants > 0 ? '$participants participants' : 'Aucun',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard(String title, String date, int participants, String categorie, String formationId) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailsFormation(formationId: formationId),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(_getIconForCategory(categorie), size: 40, color: _getColorForCategory(categorie)),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(date, style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  participants > 0 ? '$participants participants' : 'Aucun participant',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForCategory(String categorie) {
    switch (categorie) {
      case 'Basique':
        return Icons.book;
      case 'Intermédiaire':
        return Icons.web;
      case 'Avancé':
        return Icons.computer;
      default:
        return Icons.book;
    }
  }

  Color _getColorForCategory(String categorie) {
    switch (categorie) {
      case 'Basique':
        return Colors.orange;
      case 'Intermédiaire':
        return Colors.red;
      case 'Avancé':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }
}