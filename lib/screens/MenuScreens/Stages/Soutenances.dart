import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:http/http.dart' as http;
import 'package:mira/Provider/user_model.dart';
import 'package:mira/Screens/MenuScreens/Stages/SoutenanceDetails.dart';
import 'package:mira/Screens/MenuScreens/Stages/Stages.dart';
import 'package:mira/Screens/acceuil.dart';

class SoutenanceList extends StatefulWidget {
  final UserModel userModel;

  const SoutenanceList({required this.userModel});

  @override
  _SoutenanceListState createState() => _SoutenanceListState();
}

class _SoutenanceListState extends State<SoutenanceList> {
  List<dynamic> soutenances = [];
  List<dynamic> filteredSoutenances = [];
  bool _isLoading = true;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchSoutenancesData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchSoutenancesData() async {
    String apiUrl = 'http://192.168.1.22:8000/soutenance/soutenances/';
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
          soutenances = data;
          filteredSoutenances = soutenances;
          _isLoading = false;
        });
      } else {
        print('Failed to load the data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading the data: $e');
    }
  }

  void navigateToSoutenanceDetails(Map<String, dynamic> soutenance) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SoutenanceDetails(
          soutenanceData: soutenance,
        ),
      ),
    );
  }

  void _searchSoutenances(String value) {
    setState(() {
      filteredSoutenances = soutenances
          .where((soutenance) =>
              (soutenance['Etudiants'][0]['NomEtudiant'] as String)
                  .toLowerCase()
                  .contains(value.toLowerCase()) ||
              (soutenance['Etudiants'][0]['Cin'] as String)
                  .toLowerCase()
                  .contains(value.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Liste des soutenances',
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
          : Column(
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16, 8, 16, 12),
                  child: TextFormField(
                    controller: _searchController,
                    autofocus: false,
                    onChanged: _searchSoutenances,
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
                    itemCount: filteredSoutenances.length,
                    itemBuilder: (context, index) {
                      var soutenance = filteredSoutenances[index];
                      var natureStage = soutenance['NatureStage'];
                      var cin = soutenance['Etudiants'][0]['Cin'];
                      var nomEtudiant =
                          soutenance['Etudiants'][0]['NomEtudiant'];
                      var imageUrl =
                          'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHNlYXJjaHwxNHx8dW5pfGVufDB8fHx8MTcxNDY3OTU3M3ww&ixlib=rb-4.0.3&q=80&w=1080';

                      return GestureDetector(
                        onTap: () {
                          navigateToSoutenanceDetails(soutenance);
                        },
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
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
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Image.network(
                                        imageUrl,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
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
                                            natureStage,
                                            style: FlutterFlowTheme.of(context)
                                                .headlineSmall
                                                .override(
                                                  fontFamily: 'Outfit',
                                                  letterSpacing: 0,
                                                ),
                                          ),
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    0, 4, 8, 0),
                                            child: AutoSizeText(
                                              nomEtudiant,
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
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    0, 4, 8, 0),
                                            child: AutoSizeText(
                                              'CIN: $cin',
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
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
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
