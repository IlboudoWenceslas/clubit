import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Addformation extends StatefulWidget {
  @override
  _AddformationState createState() => _AddformationState();
}

class _AddformationState extends State<Addformation> {
  final _formKey = GlobalKey<FormState>(); // Clé pour le formulaire

  // Variables pour stocker les valeurs des champs
  String? _titreFormation;
  String? _nomFormateur;
  String? _niveauFormateur;
  String? _nomAssistant;
  String? _niveauAssistant;
  String? _numeroFormateur;
  String? _numeroAssistant;
  DateTime? _dateDebutFormation;
  String? _statusFormation = 'En cours'; // Initialisé à "En cours"
  String? _categorieFormation;
  bool _ajouterPrix = false;
  double? _prixFormation;

  // Liste des options pour les listes déroulantes
  final List<String> _niveaux = [
    '1ère année',
    '2ème année',
    '3ème année',
    '4ème année',
    '5ème année',
    'Docteur',
    'Professionnel',
  ];

  final List<String> _categories = [
    'Basique',
    'Intermédiaire',
    'Avancé',
  ];

  final List<String> _status = [
    'En cours',
    'Terminé',
  ];

  // Fonction pour afficher un date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _dateDebutFormation) {
      setState(() {
        _dateDebutFormation = picked;
      });
    }
  }

  // Fonction pour enregistrer la formation
  void _enregistrerFormation() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final user = FirebaseAuth.instance.currentUser;
      final email = user?.email;

      try {
        // Référence au document sans l'ajouter immédiatement
        DocumentReference formationRef = FirebaseFirestore.instance.collection('formations').doc();

        await formationRef.set({
          'id': formationRef.id, // Ajout de l'ID généré automatiquement
          'titre': _titreFormation,
          'nomFormateur': _nomFormateur,
          'niveauFormateur': _niveauFormateur,
          'nomAssistant': _nomAssistant,
          'niveauAssistant': _niveauAssistant,
          'numeroFormateur': _numeroFormateur,
          'numeroAssistant': _numeroAssistant,
          'dateDebut': _dateDebutFormation != null ? Timestamp.fromDate(_dateDebutFormation!) : null,
          'status': _statusFormation,
          'categorie': _categorieFormation,
          if (_ajouterPrix) 'prix': _prixFormation, // Ajout conditionnel
          'email': email,
          'timestamp': FieldValue.serverTimestamp(),
          'participants': [], // Initialise les participants comme liste vide
        });

        // Afficher un message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Formation enregistrée avec succès !')),
        );

        // Réinitialiser le formulaire
        _formKey.currentState?.reset();
        setState(() {
          _ajouterPrix = false;
          _dateDebutFormation = null;
        });
      } catch (e) {
        // Afficher un message d'erreur en cas d'échec
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'enregistrement : $e')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter une Formation'),
        backgroundColor: Color(0xFF4A47A3),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Titre de la formation
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Titre de la formation',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un titre';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _titreFormation = value;
                  },
                ),
                SizedBox(height: 16),

                // Nom du formateur
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Nom du formateur',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un nom';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _nomFormateur = value;
                  },
                ),
                SizedBox(height: 16),

                // Niveau du formateur (liste déroulante)
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Niveau du formateur',
                    border: OutlineInputBorder(),
                  ),
                  value: _niveauFormateur,
                  items: _niveaux.map((niveau) {
                    return DropdownMenuItem(
                      value: niveau,
                      child: Text(niveau),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _niveauFormateur = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez sélectionner un niveau';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Nom de l'assistant
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Nom de l\'assistant',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un nom';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _nomAssistant = value;
                  },
                ),
                SizedBox(height: 16),

                // Niveau de l'assistant (liste déroulante)
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Niveau de l\'assistant',
                    border: OutlineInputBorder(),
                  ),
                  value: _niveauAssistant,
                  items: _niveaux.map((niveau) {
                    return DropdownMenuItem(
                      value: niveau,
                      child: Text(niveau),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _niveauAssistant = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez sélectionner un niveau';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Numéro du formateur
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Numéro du formateur',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un numéro';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _numeroFormateur = value;
                  },
                ),
                SizedBox(height: 16),

                // Numéro de l'assistant
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Numéro de l\'assistant',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un numéro';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _numeroAssistant = value;
                  },
                ),
                SizedBox(height: 16),

                // Date de début de la formation
                InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Date de début de la formation',
                      border: OutlineInputBorder(),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _dateDebutFormation == null
                              ? 'Sélectionnez une date'
                              : '${_dateDebutFormation!.day}/${_dateDebutFormation!.month}/${_dateDebutFormation!.year}',
                        ),
                        Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Statut de la formation (liste déroulante)
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Statut de la formation',
                    border: OutlineInputBorder(),
                  ),
                  value: _statusFormation,
                  items: _status.map((statut) {
                    return DropdownMenuItem(
                      value: statut,
                      child: Text(statut),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _statusFormation = value;
                    });
                  },
                ),
                SizedBox(height: 16),

                // Catégorie de la formation (liste déroulante)
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Catégorie de la formation',
                    border: OutlineInputBorder(),
                  ),
                  value: _categorieFormation,
                  items: _categories.map((categorie) {
                    return DropdownMenuItem(
                      value: categorie,
                      child: Text(categorie),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _categorieFormation = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez sélectionner une catégorie';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Case à cocher pour ajouter le prix de la formation
                CheckboxListTile(
                  title: Text('Ajouter le prix de la formation'),
                  value: _ajouterPrix,
                  onChanged: (value) {
                    setState(() {
                      _ajouterPrix = value!;
                    });
                  },
                ),
                SizedBox(height: 16),

                // Champ pour le prix de la formation (visible si la case est cochée)
                if (_ajouterPrix)
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Prix de la formation',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onSaved: (value) {
                      _prixFormation = double.tryParse(value!);
                    },
                  ),
                SizedBox(height: 16),

                // Bouton Envoie
                ElevatedButton(
                  onPressed: _enregistrerFormation,
                  child: Text('Enregistrer', style: TextStyle(color: Colors.green)),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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