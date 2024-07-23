import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:http/http.dart' as http;
import 'package:mira/Provider/user_model.dart';
import 'package:mira/Screens/MenuScreens/Cours.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class CoursDetails extends StatefulWidget {
  final String id;
  final UserModel userModel;

  const CoursDetails({
    Key? key,
    required this.userModel,
    required this.id,
  }) : super(key: key);

  @override
  _CoursDetailsState createState() => _CoursDetailsState();
}

class _CoursDetailsState extends State<CoursDetails> {
  Map<String, dynamic> CoursDetails = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFormationsDetails();
  }

  Future<void> _fetchFormationsDetails() async {
    // Afficher l'ID de la formation récupéré dans la console
    print('Formation ID: ${widget.id}');

    String apiUrl =
        'http://192.168.1.22:8000/cours/get_Support_by_id/${widget.id}';
    try {
      var response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Accept-Charset': 'utf-8',
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes));
        if (data != null && data.isNotEmpty) {
          setState(() {
            CoursDetails = data;
            _isLoading = false;
          });
        } else {
          print('Formation details data is null or empty');
        }
      } else {
        print('Failed to load formation details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading formation details: $e');
    }
  }

  Future<void> _openPdf(BuildContext context) async {
    final url = 'http://192.168.1.22:8000/cours/open_pdf/${widget.id}';

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
        title: Text(
          'Détails de cours',
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
              builder: (context) => CoursWidget(
                userModel: widget.userModel,
              ),
            ));
          },
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHNlYXJjaHwxOHx8Y291cnN8ZW58MHx8fHwxNzE1NjU5MDk5fDA&ixlib=rb-4.0.3&q=80&w=1080',
                      width: double.infinity,
                      height: 230,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 20),
                  // Generated code for this Text Widget...
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(16, 4, 0, 0),
                    child: Text(
                      CoursDetails['Titre'] ?? '',
                      style:
                          FlutterFlowTheme.of(context).headlineMedium.override(
                                fontFamily: 'Outfit',
                                letterSpacing: 0,
                              ),
                    ),
                  ),
// Generated code for this Text Widget...
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(16, 4, 0, 0),
                    child: Text(
                      CoursDetails['Description'] ?? '',
                      style: FlutterFlowTheme.of(context).labelLarge.override(
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
                  SizedBox(
                    height: 12,
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
                    child: FFButtonWidget(
                      onPressed: () {
                        _openPdf(context);
                      },
                      text: 'Consulter le cours',
                      options: FFButtonOptions(
                        width: double.infinity,
                        height: 50,
                        padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                        iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                        color: FlutterFlowTheme.of(context).primaryText,
                        textStyle:
                            FlutterFlowTheme.of(context).titleSmall.override(
                                  fontFamily: 'Readex Pro',
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  letterSpacing: 0,
                                ),
                        elevation: 3,
                        borderSide: BorderSide(
                          color: Colors.transparent,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
