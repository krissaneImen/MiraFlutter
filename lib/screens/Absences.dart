import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:http/http.dart' as http;
import 'package:mira/Provider/user_model.dart';
import 'package:mira/Screens/MenuScreens/Services.dart';
import 'package:mira/Screens/Marquage.dart';
import 'package:mira/Utils/CustomAlertDialog.dart'; // Importez la page Marquage

class SeancesWidget extends StatefulWidget {
  final UserModel userModel;

  const SeancesWidget({Key? key, required this.userModel}) : super(key: key);

  @override
  State<SeancesWidget> createState() => _SeancesWidgetState();
}

class _SeancesWidgetState extends State<SeancesWidget> {
  bool _isLoading = true;
  List<dynamic> seances = [];
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _fetchSeancesData();
  }

  Future<void> _fetchSeancesData() async {
    String cin = widget.userModel.cin;
    String apiUrl =
        'http://192.168.1.22:8000/emploiProf/get_seances_by_cin/$cin';
    try {
      var response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Accept-Charset': 'utf-8',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          seances = data;
          _isLoading = false;
        });
      } else {
        print('Failed to load the data: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading the data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool isCurrentSession(String horaire) {
    DateTime now = DateTime.now();
    // Parse the session time in the format "HH:mm - HH:mm"
    List<String> parts = horaire.split(' - ');
    if (parts.length == 2) {
      DateTime startTime = _parseTime(parts[0]);
      DateTime endTime = _parseTime(parts[1]);
      return now.isAfter(startTime) && now.isBefore(endTime);
    }
    return false;
  }

  DateTime _parseTime(String time) {
    DateTime now = DateTime.now();
    List<String> timeParts = time.split(':');
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  void _showAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          // Utilisez votre widget CustomAlertDialog ici
          title: "Horaire non valide",
          content: "La séance ne commence pas maintenant.",
          onPressed: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(
          'Séances',
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
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => Services(
                  userModel: widget.userModel,
                ),
              ),
            );
          },
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16, 16, 0, 12),
                  child: Text(
                    'Recents',
                    style: FlutterFlowTheme.of(context).labelMedium.override(
                          fontFamily: 'Readex Pro',
                          letterSpacing: 0,
                        ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: seances.length,
                    itemBuilder: (context, index) {
                      if (index < seances.length) {
                        var seance = seances[index];
                        return GestureDetector(
                          onTap: () {
                            if (isCurrentSession(seance['horaire'])) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => Marquage(
                                    userModel: widget.userModel,
                                    groupe: seance['groupe'],
                                    matiere: seance[
                                        'matiere'], // Pass the matiere parameter here
                                  ),
                                ),
                              );
                            } else {
                              _showAlert(
                                  context); // Afficher une alerte si l'horaire n'est pas en cours
                            }
                          },
                          child: Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 3,
                                    color: Color(0x411D2429),
                                    offset: Offset(0.0, 1),
                                  )
                                ],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0, 1, 1, 1),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: Icon(
                                          Icons.calendar_today,
                                          size: 80,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            8, 8, 4, 0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              seance['matiere'] ?? '',
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .headlineSmall
                                                      .override(
                                                        fontFamily: 'Outfit',
                                                        letterSpacing: 0,
                                                      ),
                                            ),
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(0, 4, 8, 0),
                                              child: AutoSizeText(
                                                'Horaire: ${seance['horaire']}\nSalle: ${seance['sale']}\nJour: ${seance['jourSemaine']}\nGroupe: ${seance['groupe']}',
                                                textAlign: TextAlign.start,
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium
                                                        .override(
                                                          fontFamily:
                                                              'Readex Pro',
                                                          letterSpacing: 0,
                                                        ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0, 4, 0, 0),
                                          child: Icon(
                                            Icons.chevron_right_rounded,
                                            color: Color(0xFF57636C),
                                            size: 24,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      } else {
                        return SizedBox.shrink();
                      }
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
