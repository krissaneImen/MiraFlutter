import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:http/http.dart' as http;
import 'package:mira/Provider/user_model.dart';
import 'package:mira/Screens/Absences.dart';

class Marquage extends StatefulWidget {
  final UserModel userModel;
  final String groupe;
  final String matiere;

  const Marquage({
    Key? key,
    required this.userModel,
    required this.groupe,
    required this.matiere,
  }) : super(key: key);

  @override
  _MarquageState createState() => _MarquageState();
}

class _MarquageState extends State<Marquage> {
  bool _isLoading = true;
  List<dynamic> students = [];
  Map<String, bool> attendance = {};

  @override
  void initState() {
    super.initState();
    _fetchStudentsData();
  }

  Future<void> _fetchStudentsData() async {
    String apiUrl =
        'http://192.168.1.22:8000/groupe/get_students_by_group/${widget.groupe}';
    try {
      var response = await http
          .get(Uri.parse(apiUrl), headers: {'Accept-Charset': 'utf-8'});

      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          students = data ?? [];
          _isLoading = false;
          for (var student in students) {
            attendance[student['Cin']] = false;
          }
        });
      } else {
        _showSnackBar(
            'Échec du chargement des données : ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      _showSnackBar('Erreur de chargement des données : $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitAttendance() async {
    List<String> absentStudents = [];

    attendance.forEach((cin, isAbsent) {
      if (isAbsent) {
        absentStudents.add(cin);
      }
    });

    if (absentStudents.isNotEmpty) {
      String apiUrl = 'http://192.168.1.22:8000/abscence/create/';

      try {
        var response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'group': widget.groupe,
            'matiere': widget.matiere,
            'absents': absentStudents,
          }),
        );

        if (response.statusCode == 200) {
          _showSnackBar('Présence soumise avec succès');
        } else {
          _showSnackBar(
              'Échec de la soumission de la présence : ${response.statusCode}');
        }
      } catch (e) {
        _showSnackBar('Erreur de soumission de la présence : $e');
      }
    } else {
      _showSnackBar('Aucun étudiant n\'est marqué absent');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).secondaryText,
        automaticallyImplyLeading: false,
        leading: FlutterFlowIconButton(
          borderColor: Colors.transparent,
          borderRadius: 30,
          buttonSize: 46,
          icon: Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 25,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SeancesWidget(
                  userModel: widget.userModel,
                ),
              ),
            );
          },
        ),
        title: Text(
          'Fiche d\'absence',
          style: FlutterFlowTheme.of(context).titleSmall.override(
                fontFamily: 'Plus Jakarta Sans',
                color: Colors.white,
                fontSize: 16,
                letterSpacing: 0,
                fontWeight: FontWeight.w500,
              ),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  _buildGroupInfo(context),
                  _buildStudentList(),
                  _buildSubmitButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildGroupInfo(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 12),
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryText,
          boxShadow: [
            BoxShadow(
              blurRadius: 5,
              color: Color(0x32171717),
              offset: Offset(0.0, 2),
            )
          ],
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 12),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                        child: Text(
                          'Nom du Groupe: ${widget.groupe}',
                          style: FlutterFlowTheme.of(context)
                              .displaySmall
                              .override(
                                fontFamily: 'Outfit',
                                color: Colors.white,
                                fontSize: 24,
                                letterSpacing: 0,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 12, 0, 0),
                      child: Text(
                        'Matière: ${widget.matiere}',
                        style:
                            FlutterFlowTheme.of(context).displaySmall.override(
                                  fontFamily: 'Outfit',
                                  color: Colors.white,
                                  fontSize: 24,
                                  letterSpacing: 0,
                                  fontWeight: FontWeight.normal,
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
    );
  }

  Widget _buildStudentList() {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(20, 0, 20, 12),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                'Liste des étudiants:',
                style: FlutterFlowTheme.of(context).displaySmall.override(
                      fontFamily: 'Outfit',
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: students.length,
            itemBuilder: (context, index) {
              var student = students[index];
              String studentName = student['NomEtudiant'] ?? 'No name';
              String studentCin = student['Cin'] ?? 'No Cin';
              return ListTile(
                title: Text(
                  studentName,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Outfit',
                        color: Color(0xFF0F1113),
                        fontSize: 14,
                        letterSpacing: 0,
                        fontWeight: FontWeight.normal,
                      ),
                ),
                subtitle: Text(studentCin),
                trailing: Checkbox(
                  activeColor: FlutterFlowTheme.of(context).secondaryText,
                  checkColor: Colors.white,
                  side: BorderSide(
                    color: Color(0xFF57636C),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  value: attendance[studentCin],
                  onChanged: (bool? value) {
                    setState(() {
                      attendance[studentCin] = value ?? false;
                    });
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0, 32, 0, 32),
      child: FFButtonWidget(
        onPressed: _submitAttendance,
        text: 'Enregistrer',
        options: FFButtonOptions(
          width: 300,
          height: 50,
          padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
          iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
          color: FlutterFlowTheme.of(context).secondaryText,
          textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                fontFamily: 'Outfit',
                color: Colors.white,
                fontSize: 16,
                letterSpacing: 0,
                fontWeight: FontWeight.normal,
              ),
          elevation: 3,
          borderSide: BorderSide(
            color: Colors.transparent,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(40),
        ),
      ),
    );
  }
}
