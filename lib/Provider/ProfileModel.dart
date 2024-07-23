import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ProfileModel {
  Future<void> updateProfile({
    required String cin,
    required String email,
    required String phoneNumber,
    required String nom,
    required String prenom,
    required DateTime dateDelivrance,
    required String prenomArabe,
    required String nomArabe,
    required String nationalite,
    required String gouvernerat,
    required String delegation,
    required String lieuNaissanceArabe,
    required String adresseArabe,
    required String delegationArabe,
    required String genre,
    required String etatCivil,
    required DateTime dateNaissance,
    required String lieuNaissance,
    required String adresse,
    required String codePostal,
    required String image,
    required BuildContext context, // Ajout du contexte
  }) async {
    String apiUrl = 'http://192.168.1.22:8000/profil/update/$cin/';

    try {
      var response = await http.put(
        Uri.parse(apiUrl),
        body: {
          'lieuNaissanceArabe': lieuNaissanceArabe,
          'prenom_arabe': prenomArabe,
          'nomArabe': nomArabe,
          'cartCin': cin,
          'adresse': adresse,
          'email': email,
          'phoneNumber': phoneNumber,
          'firstName': nom,
          'lastName': prenom,
          'dateDeDelivrance': DateFormat('yyyy-MM-dd').format(dateDelivrance),
          'nationalite': nationalite,
          'gouvernorat': gouvernerat,
          'delegation': delegation,
          'adresseArabe': adresseArabe,
          'delegationArabe': delegationArabe,
          'genre': genre,
          'etatCivil': etatCivil,
          'dateNaissance': DateFormat('yyyy-MM-dd').format(dateNaissance),
          'lieuNaissance': lieuNaissance,
          'codePostal': codePostal,
          'image': image,
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profil mis à jour avec succès'),
            duration: Duration(seconds: 2),
          ),
        );
        print('Profil mis à jour avec succès');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Erreur lors de la mise à jour du profil: ${response.statusCode}'),
            duration: Duration(seconds: 2),
          ),
        );
        print(
            'Erreur lors de la mise à jour du profil: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la mise à jour du profil: $e'),
          duration: Duration(seconds: 2),
        ),
      );
      print('Erreur lors de la mise à jour du profil: $e');
    }
  }
}
