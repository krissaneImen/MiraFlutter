import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:http/http.dart' as http;
import 'package:mira/Provider/user_model.dart';
import 'package:badges/badges.dart' as badges;
import 'package:mira/Utils/CustomAlertDialog.dart';

class JournalDetails extends StatefulWidget {
  final String journalId;
  final UserModel userModel;
  final Map<String, dynamic> journalData;

  const JournalDetails({
    Key? key,
    required this.userModel,
    required this.journalId,
    required this.journalData,
  }) : super(key: key);

  @override
  _JournalDetailsState createState() => _JournalDetailsState();
}

class _JournalDetailsState extends State<JournalDetails> {
  Map<String, dynamic> JournauxDetails = {};
  bool _isLoading = true;
  String? lastUpdate;

  @override
  void initState() {
    super.initState();
    _fetchTachesDetails();
    _fetchEvaluationsDetails();
  }

  Future<void> _fetchTachesDetails() async {
    print('Tache ID: ${widget.journalId}');
    String apiUrl =
        'http://192.168.1.22:8000/tache/get_all_tache/${widget.journalId}';
    try {
      var response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Accept-Charset': 'utf-8',
        },
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(utf8.decode(response.bodyBytes));
        if (responseData is List && responseData.isNotEmpty) {
          setState(() {
            JournauxDetails = responseData[0];
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Aucune tâche ajoutée"),
                content:
                    Text("Il n'y a pas de tâches ajoutées pour le moment."),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("OK"),
                  ),
                ],
              );
            },
          );
        }
      } else {
        print('Failed to load details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading details: $e');
    }
  }

  Future<void> _fetchEvaluationsDetails() async {
    print('Evaluation ID: ${widget.journalId}');
    String apiUrl =
        'http://192.168.1.22:8000/stageEvaluation/get_all_Evaluations/${widget.userModel.cin}/${widget.journalId}';
    try {
      var response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Accept-Charset': 'utf-8',
        },
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(utf8.decode(response.bodyBytes));
        // Update the lastUpdate variable with the details of the latest update
        if (responseData is List && responseData.isNotEmpty) {
          setState(() {
            lastUpdate = responseData[0]['LastModified'];
          });
        }
      } else {
        print('Failed to load details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading details: $e');
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
          'Détails du journal ',
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
                    padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(mainAxisSize: MainAxisSize.max, children: [
                          Text(
                            widget.journalData['Nom'] ?? '',
                            style:
                                FlutterFlowTheme.of(context).bodyLarge.override(
                                      fontFamily: 'Readex Pro',
                                      letterSpacing: 0,
                                    ),
                          ),
                          Text(
                            '   ${widget.journalData['Prenom'] ?? ''}',
                            style:
                                FlutterFlowTheme.of(context).bodyLarge.override(
                                      fontFamily: 'Readex Pro',
                                      letterSpacing: 0,
                                    ),
                          ),
                        ]),
                        Row(mainAxisSize: MainAxisSize.max, children: [
                          Text(
                            widget.journalData['NatureStage'] ?? '',
                            style: FlutterFlowTheme.of(context)
                                .titleMedium
                                .override(
                                  fontFamily: 'Readex Pro',
                                  color: FlutterFlowTheme.of(context).primary,
                                  letterSpacing: 0,
                                ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(8, 0, 0, 0),
                            child: Text(
                              widget.journalData['Entreprise'],
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'Readex Pro',
                                    color:
                                        FlutterFlowTheme.of(context).secondary,
                                    letterSpacing: 0,
                                  ),
                            ),
                          ),
                          Text(
                            widget.journalData[''] ?? '',
                            style: FlutterFlowTheme.of(context)
                                .headlineMedium
                                .override(
                                  fontFamily: 'Outfit',
                                  letterSpacing: 0,
                                ),
                          ),
                        ]),
                        Text(
                          'Période de stage ${widget.journalData['PeriodeStage'] ?? ''}',
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Readex Pro',
                                    letterSpacing: 0,
                                  ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0, 8, 0, 8),
                          child: Text(
                            lastUpdate ?? '',
                            style: FlutterFlowTheme.of(context)
                                .titleMedium
                                .override(
                                  fontFamily: 'Readex Pro',
                                  color: FlutterFlowTheme.of(context).primary,
                                  letterSpacing: 0,
                                ),
                          ),
                        ),
                        Divider(
                          height: 32,
                          thickness: 1,
                          color: FlutterFlowTheme.of(context).alternate,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!_isLoading && JournauxDetails.isEmpty)
                          Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(16, 12, 0, 4),
                            child: Text(
                              'Aucune tâche ajoutée',
                              style: FlutterFlowTheme.of(context)
                                  .headlineMedium
                                  .override(
                                    fontFamily: 'Outfit',
                                    letterSpacing: 0,
                                  ),
                            ),
                          ),
                        if (!_isLoading && JournauxDetails.isEmpty)
                          Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(16, 4, 0, 0),
                            child: Text(
                              "Il n'y a pas de tâches ajoutées pour le moment.",
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'Readex Pro',
                                    letterSpacing: 0,
                                  ),
                            ),
                          ),
                        if (!_isLoading && JournauxDetails.isEmpty)
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                            child: ListView(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              children: [
                                // Vous pouvez ajouter d'autres widgets ou du contenu ici selon vos besoins
                              ],
                            ),
                          ),
                        if (!_isLoading && JournauxDetails.isNotEmpty)
                          Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(16, 12, 0, 4),
                            child: Text(
                              'Taches',
                              style: FlutterFlowTheme.of(context)
                                  .headlineMedium
                                  .override(
                                    fontFamily: 'Outfit',
                                    letterSpacing: 0,
                                  ),
                            ),
                          ),
                        if (!_isLoading && JournauxDetails.isNotEmpty)
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                            child: ListView(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              children: [
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0, 0, 0, 1),
                                  child: Container(
                                    width: 100,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      boxShadow: [
                                        BoxShadow(
                                          blurRadius: 0,
                                          color: Color(0xFFE0E3E7),
                                          offset: Offset(
                                            0,
                                            1,
                                          ),
                                        )
                                      ],
                                    ),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0, 0, 0, 2),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    16, 8, 0, 8),
                                            child: Container(
                                              width: 4,
                                              height: 100,
                                              decoration: BoxDecoration(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(12, 12, 12, 0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    JournauxDetails[
                                                            'TacheJournaliere'] ??
                                                        '',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily:
                                                              'Readex Pro',
                                                          letterSpacing: 0,
                                                        ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(
                                                                0, 8, 0, 0),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(0,
                                                                      0, 4, 0),
                                                          child: Text(
                                                            'Ajoutée le:',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodySmall
                                                                .override(
                                                                  fontFamily:
                                                                      'Readex Pro',
                                                                  letterSpacing:
                                                                      0,
                                                                ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                            JournauxDetails[
                                                                    'Date'] ??
                                                                '',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily:
                                                                      'Readex Pro',
                                                                  letterSpacing:
                                                                      0,
                                                                ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(0,
                                                                      0, 8, 0),
                                                          child:
                                                              GestureDetector(
                                                            child: badges.Badge(
                                                              badgeContent:
                                                                  Text(
                                                                '!',
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      fontFamily:
                                                                          'Readex Pro',
                                                                      color: Colors
                                                                          .white,
                                                                      letterSpacing:
                                                                          0,
                                                                    ),
                                                              ),
                                                              showBadge: true,
                                                              position: badges
                                                                      .BadgePosition
                                                                  .topStart(),
                                                              child: Padding(
                                                                padding:
                                                                    EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            16,
                                                                            4,
                                                                            0,
                                                                            0),
                                                                child: Text(
                                                                  'Dernière modification: ${JournauxDetails['LastModified'] ?? ''}',
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .override(
                                                                        fontFamily:
                                                                            'Readex Pro',
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .primary,
                                                                        letterSpacing:
                                                                            0,
                                                                      ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
