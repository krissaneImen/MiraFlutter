import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:http/http.dart' as http;
import 'package:mira/Provider/user_model.dart';
import 'package:mira/Screens/MenuScreens/Photocopie.dart';
import 'package:mira/Screens/MenuScreens/Services.dart';

class PhotocopieWidget extends StatefulWidget {
  final UserModel userModel;

  const PhotocopieWidget({Key? key, required this.userModel}) : super(key: key);

  @override
  State<PhotocopieWidget> createState() => _PhotocopieWidgetState();
}

class _PhotocopieWidgetState extends State<PhotocopieWidget> {
  bool _isLoading = true;
  List<dynamic> photocopies = [];
  final scaffoldKey = GlobalKey<ScaffoldState>();
  List<String> imageUrls = [
    'https://images.unsplash.com/photo-1614332625575-6bef549fcc7b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHNlYXJjaHwyfHxjb3B5fGVufDB8fHx8MTcxNTAwNjgwM3ww&ixlib=rb-4.0.3&q=80&w=1080',
    'https://images.unsplash.com/photo-1612815154858-60aa4c59eaa6?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHNlYXJjaHwxfHxjb3BpZXJ8ZW58MHx8fHwxNzE1MDA3MTI5fDA&ixlib=rb-4.0.3&q=80&w=1080',
    'https://images.unsplash.com/photo-1666101041092-468eb2818c87?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHNlYXJjaHwzfHxjb3BpZXJ8ZW58MHx8fHwxNzE1MDA3MTI5fDA&ixlib=rb-4.0.3&q=80&w=1080',
    'https://images.unsplash.com/photo-1612814266697-e5814f3063cf?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHNlYXJjaHw1fHxjb3BpZXJ8ZW58MHx8fHwxNzE1MDA3MTI5fDA&ixlib=rb-4.0.3&q=80&w=1080'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.userModel.statut.toLowerCase() == 'enseignant') {
      _fetchPhotocopieDataForEnseignant();
    } else if (widget.userModel.statut.toLowerCase() == 'administratif') {
      _fetchPhotocopieListData();
    }
  }

  Future<void> _fetchPhotocopieDataForEnseignant() async {
    String cin = widget.userModel.cin;
    String apiUrl =
        'http://192.168.1.22:8000/photocopie/photocopie_by_cin/${cin}';
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
          photocopies = data;
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

  Future<void> _fetchPhotocopieListData() async {
    String apiUrl = 'http://192.168.1.22:8000/photocopie/get_photocopie_list/';
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
          photocopies = data;
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

  void navigateToPhotocopiePage(String photocopieId, String idDemande) {
    print('Photocopie ID: $photocopieId , idDemande : $idDemande');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DetailsPhotocopieWidget(
          photocopieId: photocopieId,
          idDemande: idDemande,
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
          'Demandes de photocopie',
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
              builder: (context) => Services(
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
                    itemCount: photocopies.length,
                    itemBuilder: (context, index) {
                      if (index < photocopies.length) {
                        var photocopie = photocopies[index];
                        String imageUrl = imageUrls[index % imageUrls.length];
                        return GestureDetector(
                          onTap: () {
                            navigateToPhotocopiePage(photocopies[index]['id'],
                                photocopies[index]['idDemande']);
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
                                              photocopie['cour'] ?? '',
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
                                                'Nombre de photocopies: ${photocopies[index]['nombreCopie']}',
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
