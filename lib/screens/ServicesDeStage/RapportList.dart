import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:http/http.dart' as http;
import 'package:mira/Provider/user_model.dart';
import 'package:mira/Screens/MenuScreens/Stages/Stages.dart';
import 'package:mira/Screens/ServicesDeStage/RapportDetails.dart';

class RapportList extends StatefulWidget {
  final UserModel userModel;

  const RapportList({required this.userModel});

  @override
  _RapportListState createState() => _RapportListState();
}

class _RapportListState extends State<RapportList> {
  List<dynamic> rapports = [];
  List<dynamic> filteredRapports = [];
  bool _isLoading = true;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchRapportsData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchRapportsData() async {
    String apiUrl;
    if (widget.userModel.statut.toLowerCase() == 'etudiant') {
      apiUrl =
          'http://192.168.1.22:8000/rapport/get_Rapport_list_by_cin/${widget.userModel.cin}';
    } else if (widget.userModel.statut.toLowerCase() == 'administratif') {
      apiUrl = 'http://192.168.1.22:8000/rapport/get_Rapport_list/';
    } else {
      apiUrl =
          'http://192.168.1.22:8000/rapport/get_students_by_rapporteur_cin/${widget.userModel.cin}';
    }

    try {
      var response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Accept-Charset': 'utf-8'},
      );

      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          rapports = data ?? [];
          filteredRapports = rapports;
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

  void _searchRapports(String value) {
    setState(() {
      filteredRapports = rapports.where((rapport) {
        var etudiant =
            rapport['Etudiants'] != null && rapport['Etudiants'].isNotEmpty
                ? rapport['Etudiants'][0]
                : null;
        return (etudiant != null &&
                (etudiant['NomEtudiant'] as String)
                    .toLowerCase()
                    .contains(value.toLowerCase())) ||
            (etudiant != null &&
                (etudiant['Cin'] as String)
                    .toLowerCase()
                    .contains(value.toLowerCase()));
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Liste des rapports',
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
        actions: [],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : rapports.isEmpty
              ? Center(
                  child: Text(
                    'Aucun rapport à afficher',
                    style: FlutterFlowTheme.of(context).bodyText1,
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(16, 8, 16, 12),
                      child: TextFormField(
                        controller: _searchController,
                        autofocus: false,
                        onChanged: _searchRapports,
                        obscureText: false,
                        decoration: InputDecoration(
                          isDense: true,
                          labelText: 'Rechercher',
                          labelStyle:
                              FlutterFlowTheme.of(context).labelMedium.override(
                                    fontFamily: 'Readex Pro',
                                    letterSpacing: 0,
                                  ),
                          hintStyle:
                              FlutterFlowTheme.of(context).labelMedium.override(
                                    fontFamily: 'Readex Pro',
                                    letterSpacing: 0,
                                  ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).primary,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(32),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0x00000000),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(32),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0x00000000),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(32),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0x00000000),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(32),
                          ),
                          prefixIcon: Icon(
                            Icons.search_outlined,
                          ),
                        ),
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Readex Pro',
                              letterSpacing: 0,
                            ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredRapports.length,
                        itemBuilder: (context, index) {
                          var rapport = filteredRapports[index];
                          var etudiant = rapport['Etudiants'] != null &&
                                  rapport['Etudiants'].isNotEmpty
                              ? rapport['Etudiants'][0]
                              : null;
                          var natureStage = rapport['NatureStage'] ?? 'N/A';
                          var Nom = rapport['NomEtudiant'] ?? 'N/A';
                          var Cin = rapport['Cin'] ?? 'N/A';

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RapportDetails(
                                    rapportId: rapports[index]['id'],
                                    userModel: widget.userModel,
                                  ),
                                ),
                              );
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
                                      offset: Offset(0, 1),
                                    ),
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
                                        child: Icon(
                                          Icons.description,
                                          size: 80,
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  8, 8, 4, 0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                natureStage,
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
                                                  Nom,
                                                  textAlign: TextAlign.start,
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .labelMedium
                                                      .override(
                                                        fontFamily:
                                                            'Readex Pro',
                                                        letterSpacing: 0,
                                                      ),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(0, 4, 8, 0),
                                                child: AutoSizeText(
                                                  Cin,
                                                  textAlign: TextAlign.start,
                                                  style: FlutterFlowTheme.of(
                                                          context)
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
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
