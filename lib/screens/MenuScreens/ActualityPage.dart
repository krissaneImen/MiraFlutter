import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:mira/Provider/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:mira/Screens/MenuScreens/ActualityDetails.dart';
import 'package:mira/Screens/acceuil.dart';

class ActualiteWidget extends StatefulWidget {
  final UserModel userModel;

  const ActualiteWidget({Key? key, required this.userModel}) : super(key: key);

  @override
  State<ActualiteWidget> createState() => _ActualiteWidgetState();
}

class _ActualiteWidgetState extends State<ActualiteWidget> {
  bool _isLoading = true;
  List<dynamic> nouveautes = [];
  final scaffoldKey = GlobalKey<ScaffoldState>();
  List<String> imageUrls = [
    'https://images.unsplash.com/photo-1600195077077-7c815f540a3d?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHNlYXJjaHw4fHx1bml2ZXJzaXR5JTIwfGVufDB8fHx8MTcxNDczOTc4OXww&ixlib=rb-4.0.3&q=80&w=1080',
    'https://images.unsplash.com/photo-1503676382389-4809596d5290?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHNlYXJjaHwzfHx1bml8ZW58MHx8fHwxNzE0Njc5NTczfDA&ixlib=rb-4.0.3&q=80&w=1080',
    'https://images.unsplash.com/photo-1491975474562-1f4e30bc9468?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHNlYXJjaHwxMXx8dW5pfGVufDB8fHx8MTcxNDY3OTU3M3ww&ixlib=rb-4.0.3&q=80&w=1080',
    'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHNlYXJjaHwxNHx8dW5pfGVufDB8fHx8MTcxNDY3OTU3M3ww&ixlib=rb-4.0.3&q=80&w=1080',
  ];

  @override
  void initState() {
    super.initState();
    _fetchActulityData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchActulityData() async {
    String statut = widget.userModel.statut.toLowerCase();

    String apiUrl =
        'http://192.168.1.22:8000/actualite/get_all_actualite/${statut}';
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
          nouveautes = data;
          _isLoading = false;
        });
      } else {
        print('Failed to load the data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading the data: $e');
    }
  }

  void navigateToCalendPage(String actualiteId) {
    print('Actualité ID: $actualiteId'); // Ajout du print
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DetailsActualiteWidget(
          actualiteId: actualiteId,
          userModel: widget.userModel,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(
          'Actualités',
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
                    itemCount: nouveautes.length,
                    itemBuilder: (context, index) {
                      if (index < nouveautes.length) {
                        var actualite = nouveautes[index];
                        String imageUrl = imageUrls[index % imageUrls.length];
                        return GestureDetector(
                          onTap: () {
                            navigateToCalendPage(actualite['id']);
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
                                    offset: Offset(
                                      0.0,
                                      1,
                                    ),
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
                                              actualite['intitule'] ?? '',
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
                                                actualite[
                                                        'anneeUniversitaire'] ??
                                                    '',
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
