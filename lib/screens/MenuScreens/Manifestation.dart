import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:http/http.dart' as http;
import 'package:mira/Provider/user_model.dart';

class Manifestation extends StatefulWidget {
  final String manifestationId;
  final UserModel userModel;

  const Manifestation({
    Key? key,
    required this.userModel,
    required this.manifestationId,
  }) : super(key: key);

  @override
  _ManifestationDetailsState createState() => _ManifestationDetailsState();
}

class _ManifestationDetailsState extends State<Manifestation> {
  Map<String, dynamic> ManifestationDetails = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchmanifestationsDetails();
  }

  Future<void> _fetchmanifestationsDetails() async {
    // Afficher l'ID de la formation récupéré dans la console
    print('manifestation ID: ${widget.manifestationId}');

    String apiUrl =
        'http://192.168.1.22:8000/manifestation/getManifestation/${widget.manifestationId}';
    try {
      var response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Accept-Charset': 'utf-8',
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          ManifestationDetails = data;
          _isLoading = false;
        });
      } else {
        print('Failed to load manifestations details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading manifestations details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        automaticallyImplyLeading: false,
        leading: InkWell(
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () async {
            Navigator.of(context).pop();
          },
          child: Icon(
            Icons.chevron_left_rounded,
            color: FlutterFlowTheme.of(context).primaryText,
            size: 32,
          ),
        ),
        title: Text(
          'Détails de manifestation ',
          style: FlutterFlowTheme.of(context).headlineMedium.override(
                fontFamily: 'Outfit',
                letterSpacing: 0,
              ),
        ),
        actions: [],
        centerTitle: false,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        base64Decode(ManifestationDetails['poster']),
                        width: double.infinity,
                        height: 200, // Définir une hauteur fixe pour l'image
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Table(
                      columnWidths: {
                        0: FixedColumnWidth(150.0),
                        1: FlexColumnWidth(),
                      },
                      border: TableBorder.all(color: Colors.black),
                      children: [
                        TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Intitulé',
                                style:
                                    FlutterFlowTheme.of(context).headlineMedium,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                ManifestationDetails['intitule'] ?? '',
                                style: FlutterFlowTheme.of(context).labelLarge,
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Formateurs',
                                style:
                                    FlutterFlowTheme.of(context).headlineMedium,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                ManifestationDetails['formateurs'] ?? '',
                                style: FlutterFlowTheme.of(context).labelLarge,
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Date Début',
                                style:
                                    FlutterFlowTheme.of(context).headlineMedium,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                ManifestationDetails['dateDebut'] ?? '',
                                style: FlutterFlowTheme.of(context).labelLarge,
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Date Fin',
                                style:
                                    FlutterFlowTheme.of(context).headlineMedium,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                ManifestationDetails['dateFin'] ?? '',
                                style: FlutterFlowTheme.of(context).labelLarge,
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Lieu',
                                style:
                                    FlutterFlowTheme.of(context).headlineMedium,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                ManifestationDetails['lieuManifestation'] ?? '',
                                style: FlutterFlowTheme.of(context).labelLarge,
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Responsables',
                                style:
                                    FlutterFlowTheme.of(context).headlineMedium,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                ManifestationDetails['responsables'] ?? '',
                                style: FlutterFlowTheme.of(context).labelLarge,
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Description',
                                style:
                                    FlutterFlowTheme.of(context).headlineMedium,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                ManifestationDetails['description'] ?? '',
                                style: FlutterFlowTheme.of(context).labelLarge,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
