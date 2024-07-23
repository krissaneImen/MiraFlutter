import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:http/http.dart' as http;
import 'package:mira/Provider/user_model.dart';
import 'package:url_launcher/url_launcher.dart';

class RapportDetails extends StatefulWidget {
  final String rapportId;
  final UserModel userModel;

  const RapportDetails({
    Key? key,
    required this.rapportId,
    required this.userModel,
  }) : super(key: key);

  @override
  _RapportDetailsState createState() => _RapportDetailsState();
}

class _RapportDetailsState extends State<RapportDetails> {
  dynamic rapportDetails;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchphotocopieDetails();
  }

  Future<void> _fetchphotocopieDetails() async {
    print('photocopie ID: ${widget.rapportId}');

    String apiUrl =
        'http://192.168.1.22:8000/rapport/get_Rapport_by_id/${widget.rapportId}';
    try {
      var response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Accept-Charset': 'utf-8'},
      );

      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          rapportDetails = data;
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
    final url = 'http://192.168.1.22:8000/rapport/open_pdf/${widget.rapportId}';

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
            Icons.arrow_back_rounded,
            color: FlutterFlowTheme.of(context).primaryText,
            size: 30,
          ),
        ),
        title: Text(
          'Détails de rapport',
          style: FlutterFlowTheme.of(context).headlineMedium.override(
                fontFamily: 'Outfit',
                letterSpacing: 0,
              ),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: SafeArea(
        top: true,
        child: _isLoading
            ? Center(
                child:
                    CircularProgressIndicator()) // Show loading indicator while fetching data
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Titre: ${rapportDetails['Titre']}',
                        style: FlutterFlowTheme.of(context).bodyLarge.override(
                              fontFamily: 'Readex Pro',
                              letterSpacing: 0,
                            ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Version: ${rapportDetails['Version']}',
                        style: FlutterFlowTheme.of(context).bodyLarge.override(
                              fontFamily: 'Readex Pro',
                              letterSpacing: 0,
                            ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Nature de Stage: ${rapportDetails['NatureStage']}',
                        style: FlutterFlowTheme.of(context).bodyLarge.override(
                              fontFamily: 'Readex Pro',
                              letterSpacing: 0,
                            ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Année Universitaire: ${rapportDetails['anneeUniversitaire']}',
                        style: FlutterFlowTheme.of(context).bodyLarge.override(
                              fontFamily: 'Readex Pro',
                              letterSpacing: 0,
                            ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Nom de l\'étudiant: ${rapportDetails['NomEtudiant']}',
                        style: FlutterFlowTheme.of(context).bodyLarge.override(
                              fontFamily: 'Readex Pro',
                              letterSpacing: 0,
                            ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Cin de d\'étudiant: ${rapportDetails['Cin']}',
                        style: FlutterFlowTheme.of(context).bodyLarge.override(
                              fontFamily: 'Readex Pro',
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
                            'Voir Rapport',
                            style: FlutterFlowTheme.of(context)
                                .bodyLarge
                                .override(
                                  fontFamily: 'Readex Pro',
                                  color: FlutterFlowTheme.of(context).primary,
                                  letterSpacing: 0,
                                ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
