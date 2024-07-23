import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mira/Provider/user_model.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:mira/Screens/MenuScreens/Reglements/ContenueReglements.dart';
import 'package:url_launcher/url_launcher.dart';

class ReglementDetailsPage extends StatefulWidget {
  final UserModel userModel;
  final String reglementType;

  const ReglementDetailsPage({
    Key? key,
    required this.userModel,
    required this.reglementType,
  }) : super(key: key);

  @override
  _ReglementDetailsPageState createState() => _ReglementDetailsPageState();
}

class _ReglementDetailsPageState extends State<ReglementDetailsPage> {
  List<dynamic> reglements = [];
  List<dynamic> pdfReglements = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchReglements();
  }

  Future<void> fetchReglements() async {
    try {
      final response1 = await http.get(
        Uri.parse(
            'http://192.168.1.22:8000/documentation/reglements/${widget.reglementType}/'),
        headers: {
          'Accept-Charset': 'utf-8'
        }, // Ajout de l'en-tête Accept-Charset
      );
      final response2 = await http.get(
        Uri.parse(
            'http://192.168.1.22:8000/reglement/get_reglement_list/${widget.reglementType}/'),
        headers: {
          'Accept-Charset': 'utf-8'
        }, // Ajout de l'en-tête Accept-Charset
      );

      if (response1.statusCode == 200 && response2.statusCode == 200) {
        setState(() {
          reglements = json.decode(response1.body);
          pdfReglements = json.decode(response2.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _openPdf(String reglementId) async {
    final url = 'http://192.168.1.22:8000/reglement/open_pdf/$reglementId';

    try {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Impossible de lancer $url';
      }
    } catch (e) {
      print('Erreur lors de l\'ouverture du PDF: $e');
    }
  }

  void _navigateToDetailsPage(String name, String description) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContenueReglementSpecifique(
          name: name,
          description: description,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
      appBar: AppBar(
        title: Text(
          widget.reglementType,
          style: FlutterFlowTheme.of(context).titleLarge,
        ),
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        automaticallyImplyLeading: true,
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
              top: true,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...reglements.map((reglement) =>
                        buildReglementCard(context, reglement, false)),
                    ...pdfReglements.map((reglement) =>
                        buildReglementCard(context, reglement, true)),
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildReglementCard(
      BuildContext context, Map<String, dynamic> reglement, bool hasPdf) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
      child: GestureDetector(
        onTap: !hasPdf
            ? () {
                _navigateToDetailsPage(
                    reglement['name'], reglement['description']);
              }
            : null, // Désactiver le geste si un PDF est disponible
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            boxShadow: [
              BoxShadow(
                blurRadius: 3,
                color: Color(0x33000000),
                offset: Offset(0, 1),
              ),
            ],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Icon(
                  Icons.description,
                  size: 44,
                  color: FlutterFlowTheme.of(context).primaryText,
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reglement['name'],
                          style:
                              FlutterFlowTheme.of(context).bodyLarge.override(
                                    fontFamily: 'Readex Pro',
                                    letterSpacing: 0,
                                  ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                          child: Text(
                            reglement['description'],
                            style: FlutterFlowTheme.of(context)
                                .labelSmall
                                .override(
                                  fontFamily: 'Readex Pro',
                                  letterSpacing: 0,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (hasPdf)
                  Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0),
                      child: FFButtonWidget(
                        onPressed: () {
                          _openPdf(reglement['id']);
                        },
                        text: 'Voir PDF',
                        options: FFButtonOptions(
                          width: 150,
                          height: 44,
                          padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                          iconPadding:
                              EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                          color: FlutterFlowTheme.of(context).primaryBackground,
                          textStyle:
                              FlutterFlowTheme.of(context).bodyLarge.override(
                                    fontFamily: 'Readex Pro',
                                    letterSpacing: 0,
                                  ),
                          elevation: 0,
                          borderSide: BorderSide(
                            color: FlutterFlowTheme.of(context).alternate,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
