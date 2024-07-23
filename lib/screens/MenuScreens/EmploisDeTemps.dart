import 'dart:convert';

import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:mira/Provider/user_model.dart';
import 'package:mira/Screens/acceuil.dart';

class EmploiWidget extends StatefulWidget {
  final UserModel userModel;
  const EmploiWidget({super.key, required this.userModel});

  @override
  State<EmploiWidget> createState() => _EmploiWidgetState();
}

class _EmploiWidgetState extends State<EmploiWidget> {
  List<dynamic> EmploisEnseignants = [];
  bool _isLoading = true;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _fetchEmploisData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchEmploisData() async {
    String cin = widget.userModel.cin;
    String apiUrl =
        'http://192.168.1.22:8000/enseignantEmploi/get_employment_by_cin/${cin}';
    try {
      var response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Accept-Charset': 'utf-8',
        },
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(utf8.decode(response.bodyBytes));

        // Vérifier si les données sont un objet JSON ou une liste
        if (jsonData is List) {
          // Si les données sont déjà une liste, affectez-les directement à EmploisEnseignants
          setState(() {
            EmploisEnseignants = jsonData;
            _isLoading = false;
          });
        } else if (jsonData is Map<String, dynamic>) {
          // Si les données sont un objet JSON, convertissez-les en liste et affectez-les à EmploisEnseignants
          var emploisList = jsonData.values.toList();
          setState(() {
            EmploisEnseignants = emploisList;
            _isLoading = false;
          });
        } else {
          print('Données non prises en charge');
        }
      } else {
        print('Failed to load the data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading the data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // Affichez un indicateur de chargement pendant le chargement des données
      return Center(
        child: CircularProgressIndicator(),
      );
    } else if (EmploisEnseignants.isEmpty) {
      // Gérez le cas où aucune donnée n'est disponible
      return Center(
        child: Text("Aucun emploi d'enseignant disponible"),
      );
    } else {
      // Utilisez une boucle pour afficher les données pour chaque emploi d'enseignant
      return ListView.builder(
        padding: EdgeInsets.fromLTRB(0, 12, 0, 44),
        itemCount: EmploisEnseignants.length,
        itemBuilder: (context, index) {
          var emploi = EmploisEnseignants[index];
          return Padding(
            padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(
                maxWidth: 800,
              ),
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: FlutterFlowTheme.of(context).alternate,
                  width: 1,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // ClipRRect(
                    //   borderRadius: BorderRadius.circular(4),
                    //   child: Image.network(
                    //     emploi[
                    //         'image_url'], // Assurez-vous de remplacer 'image_url' par la clé correcte pour l'URL de l'image
                    //     width: double.infinity,
                    //     height: 200,
                    //     fit: BoxFit.cover,
                    //   ),
                    // ),r
                    Padding(
                      padding: EdgeInsets.all(4),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  emploi[
                                      'nom'], // Assurez-vous de remplacer 'nom' par la clé correcte pour le nom de l'emploi
                                  style: FlutterFlowTheme.of(context)
                                      .labelSmall
                                      .override(
                                        fontFamily: 'Readex Pro',
                                        letterSpacing: 0,
                                      ),
                                ),
                                Text(
                                  emploi[
                                      'description'], // Assurez-vous de remplacer 'description' par la clé correcte pour la description de l'emploi
                                  style: FlutterFlowTheme.of(context)
                                      .bodyLarge
                                      .override(
                                        fontFamily: 'Readex Pro',
                                        letterSpacing: 0,
                                      ),
                                ),
                              ].divide(SizedBox(height: 4)),
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Rating:',
                                  style: TextStyle(),
                                ),
                                TextSpan(
                                  text: emploi['rating']
                                      .toString(), // Assurez-vous de remplacer 'rating' par la clé correcte pour le rating de l'emploi
                                  style: TextStyle(),
                                ),
                              ],
                              style: FlutterFlowTheme.of(context)
                                  .labelSmall
                                  .override(
                                    fontFamily: 'Readex Pro',
                                    letterSpacing: 0,
                                  ),
                            ),
                          ),
                        ].divide(SizedBox(width: 8)),
                      ),
                    ),
                  ].divide(SizedBox(height: 8)),
                ),
              ),
            ),
          );
        },
      );
    }
  }
}
