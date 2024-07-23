import 'package:flutter/material.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:mira/Provider/user_model.dart';
import 'package:mira/Screens/MenuScreens/Reglements/ReglementDetailsPage.dart';
import 'package:mira/Screens/MenuScreens/photoCopies.dart';
import 'package:mira/Screens/acceuil.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TypesReglement extends StatefulWidget {
  final UserModel userModel;

  const TypesReglement({super.key, required this.userModel});

  @override
  State<TypesReglement> createState() => _TypesReglementState();
}

class _TypesReglementState extends State<TypesReglement> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  List<dynamic> reglementTypes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchReglementTypes();
  }

  Future<void> fetchReglementTypes() async {
    final userType =
        'administratif'.toLowerCase(); // Normalisation en minuscules
    final response = await http.get(Uri.parse(
        'http://192.168.1.22:8000/GestionType/types/$userType/Reglement/'));
    if (response.statusCode == 200) {
      setState(() {
        reglementTypes = json.decode(response.body);
        isLoading = false;
      });
    } else {
      // Gérer l'erreur ici
      setState(() {
        isLoading = false;
      });
    }
  }

  void navigateToReglementDetails(String reglementType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReglementDetailsPage(
          userModel: widget.userModel,
          reglementType: reglementType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        appBar: AppBar(
          title: Text(
            'Règlements',
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
                builder: (context) => Accueil(
                  userModel: widget.userModel,
                ),
              ));
            },
          ),
          centerTitle: false,
          elevation: 0,
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : SafeArea(
                top: true,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: reglementTypes.map((reglementType) {
                      // Vérifiez que le type est une chaîne de caractères non nulle
                      final String? type = reglementType['name'];
                      if (type == null || type.isEmpty) {
                        return SizedBox.shrink();
                      }
                      return Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 12),
                        child: InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {
                            navigateToReglementDetails(type);
                          },
                          child: Container(
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .primaryBackground,
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 3,
                                  color: Color(0x33000000),
                                  offset: Offset(
                                    0,
                                    1,
                                  ),
                                )
                              ],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    type,
                                    style: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .override(
                                          fontFamily: 'Readex Pro',
                                          letterSpacing: 0,
                                        ),
                                  ),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    size: 24,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
      ),
    );
  }
}
