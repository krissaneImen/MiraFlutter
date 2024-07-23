import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:http/http.dart' as http;
import 'package:mira/Provider/user_model.dart';
import 'package:mira/Screens/ServicesDeStage/JournalDetails.dart';
import 'package:mira/Screens/MenuScreens/Stages/Stages.dart';
import 'package:mira/Screens/acceuil.dart';

class StudentJournals extends StatefulWidget {
  final String cin;
  final UserModel userModel;

  const StudentJournals({Key? key, required this.cin, required this.userModel})
      : super(key: key);

  @override
  _StudentJournalsState createState() => _StudentJournalsState();
}

class _StudentJournalsState extends State<StudentJournals> {
  List<dynamic> journals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStudentJournals();
  }

  Future<void> _fetchStudentJournals() async {
    String apiUrl;
    if (widget.userModel.statut.toLowerCase() == 'etudiant') {
      apiUrl =
          'http://192.168.1.22:8000/journale/get_all_journale/${widget.cin}';
    } else if (widget.userModel.statut.toLowerCase() == 'enseignant') {
      apiUrl =
          'http://192.168.1.22:8000/journale/get_students_by_rapporteur_cin/${widget.cin}';
    } else {
      // Default URL if the user's status is not 'Etudiant' or 'Enseignant'
      apiUrl = 'http://192.168.1.22:8000/journale/get_all_journale/';
    }

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
          journals = data;
          _isLoading = false;
        });
      } else {
        print('Failed to load journals: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading journals: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Liste de journaux',
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
              builder: (context) => Stages(
                userModel: widget.userModel,
              ),
            ));
          },
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: journals.length,
              itemBuilder: (context, index) {
                final journal = journals[index];
                return GestureDetector(
                  onTap: () {
                    if (journal.containsKey('id')) {
                      String journalId = journal['id'];
                      print('Journal ID: $journalId');
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => JournalDetails(
                          userModel: widget.userModel,
                          journalId: journalId,
                          // Passer les données du journal à JournalDetails
                          journalData: journal,
                        ),
                      ));
                    } else {
                      print('Error: Journal ID not found.');
                    }
                  },
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Container(
                              width: 2,
                              height: 100,
                              color: FlutterFlowTheme.of(context).primary,
                            ),
                          ],
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(16, 16, 16, 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Text(
                                      journal['NatureStage'],
                                      style: FlutterFlowTheme.of(context)
                                          .bodyLarge
                                          .override(
                                            fontFamily: 'Readex Pro',
                                            letterSpacing: 0,
                                          ),
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          8, 0, 0, 0),
                                      child: Text(
                                        journal['Entreprise'],
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: 'Readex Pro',
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondary,
                                              letterSpacing: 0,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0, 12, 0, 0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Voir Détails',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily: 'Readex Pro',
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                                letterSpacing: 0,
                                              ),
                                        ),
                                      ),
                                      Container(
                                        width: 2,
                                        height: 24,
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            8, 0, 0, 0),
                                        child: Text(
                                          journal['PeriodeStage'],
                                          style: FlutterFlowTheme.of(context)
                                              .labelMedium
                                              .override(
                                                fontFamily: 'Readex Pro',
                                                letterSpacing: 0,
                                              ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.chevron_right_rounded,
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                        size: 24,
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
