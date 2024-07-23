import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:mira/Provider/user_model.dart';
import 'package:mira/Screens/MenuScreens/photoCopies.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailsPhotocopieWidget extends StatelessWidget {
  final String photocopieId;
  final UserModel userModel;
  final String idDemande;
  const DetailsPhotocopieWidget({
    Key? key,
    required this.photocopieId,
    required this.userModel,
    required this.idDemande,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _DetailsWidgetState(
      photocopieId: photocopieId,
      idDemande: idDemande,
      userModel: userModel,
    );
  }
}

class _DetailsWidgetState extends StatefulWidget {
  final String photocopieId;
  final UserModel userModel;
  final String idDemande;

  const _DetailsWidgetState({
    Key? key,
    required this.photocopieId,
    required this.userModel,
    required this.idDemande,
  }) : super(key: key);

  @override
  __DetailsWidgetStateState createState() => __DetailsWidgetStateState();
}

class __DetailsWidgetStateState extends State<_DetailsWidgetState> {
  Map<String, dynamic> photocopiesDetails = {};
  Map<String, dynamic> Etats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchphotocopieDetails();
    _fetchEtatData();
  }

  Future<void> _fetchphotocopieDetails() async {
    print('photocopie ID: ${widget.photocopieId}');

    String apiUrl =
        'http://192.168.1.22:8000/photocopie/get_photocopie_by_id/${widget.photocopieId}';
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
          photocopiesDetails = data;
          _isLoading = false;
        });
      } else {
        print('Failed to load  details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading  details: $e');
    }
  }

  Future<void> _openPdf(BuildContext context) async {
    final url =
        'http://192.168.1.22:8000/photocopie/open_pdf/${widget.photocopieId}';

    try {
      // Ouvrir le PDF dans une visionneuse PDF externe
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Impossible de lancer $url';
      }
    } catch (e) {
      print('Erreur lors de l\'ouverture du PDF: $e');
    }
  }

  Future<void> _fetchEtatData() async {
    String apiUrl =
        'http://192.168.1.22:8000/demande/get_demande_by_id/${widget.idDemande}';
    try {
      var response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Accept-Charset': 'utf-8'},
      );

      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          Etats = data;
          _isLoading = false;
          print('Etats: $Etats'); // Print the whole Etats map

          print('Etat récupéré: ${Etats['Etat']}'); // Add this line
        });
      } else {
        print('Failed to load the data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading the data: $e');
    }
  }

  Color getStatusColor(String etat) {
    switch (etat.toLowerCase()) {
      case 'terminé':
        return FlutterFlowTheme.of(context).secondary;
      case 'rejeté':
        return Colors.red;
      case 'en cours':
        return FlutterFlowTheme.of(context).primary;
      case 'en attente':
        return FlutterFlowTheme.of(context).tertiary;
      default:
        return Colors.black; // Par défaut, la couleur est noire
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Détails de demande',
          style: FlutterFlowTheme.of(context).titleLarge,
        ),
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        automaticallyImplyLeading: false,
        leading: FlutterFlowIconButton(
          borderColor: Colors.transparent,
          borderRadius: 30,
          borderWidth: 1,
          buttonSize: 60,
          icon: Icon(
            Icons.arrow_back_rounded,
            color: FlutterFlowTheme.of(context).primaryText,
            size: 30,
          ),
          onPressed: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => PhotocopieWidget(
                userModel: widget.userModel,
              ),
            ));
          },
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: SafeArea(
        top: true,
        child: _isLoading
            ? CircularProgressIndicator() // Show loading indicator while fetching data
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Nom enseignant: ${photocopiesDetails['NomEnseignant']}',
                        style:
                            FlutterFlowTheme.of(context).headlineSmall.override(
                                  fontFamily: 'Outfit',
                                  letterSpacing: 0,
                                ),
                      ),
                    ),
                    Divider(
                      height: 12,
                      thickness: 1,
                      color: FlutterFlowTheme.of(context).alternate,
                    ),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Matière: ${photocopiesDetails['cour']}',
                        style:
                            FlutterFlowTheme.of(context).headlineSmall.override(
                                  fontFamily: 'Outfit',
                                  letterSpacing: 0,
                                ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Nombre de photocopies: ${photocopiesDetails['nombreCopie']}',
                        style: FlutterFlowTheme.of(context).labelLarge.override(
                              fontFamily: 'Readex Pro',
                              letterSpacing: 0,
                            ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 4,
                              color: Color(0x33000000),
                              offset: Offset(
                                0,
                                2,
                              ),
                            )
                          ],
                          color: getStatusColor(Etats['Etat'] ?? ''),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: AlignmentDirectional(0, 0),
                        child: Text(
                          '${Etats['Etat']}',
                          style:
                              FlutterFlowTheme.of(context).titleSmall.override(
                                    fontFamily: 'Readex Pro',
                                    letterSpacing: 0,
                                  ),
                        ),
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.all(16),
                        child: GestureDetector(
                          onTap: () {
                            _openPdf(context);
                          },
                          child: Container(
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).accent1,
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 4,
                                  color: Color(0x33000000),
                                  offset: Offset(
                                    0,
                                    2,
                                  ),
                                )
                              ],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: FlutterFlowTheme.of(context).primary,
                                width: 2,
                              ),
                            ),
                            alignment: AlignmentDirectional(0, 0),
                            child: Text(
                              'Voir PDF',
                              style: FlutterFlowTheme.of(context)
                                  .bodyLarge
                                  .override(
                                    fontFamily: 'Readex Pro',
                                    color: FlutterFlowTheme.of(context).primary,
                                    letterSpacing: 0,
                                  ),
                            ),
                          ),
                        )),
                  ],
                ),
              ),
      ),
    );
  }
}
