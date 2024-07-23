import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:http/http.dart' as http;
import 'package:mira/Provider/user_model.dart';
import 'package:mira/Screens/acceuil.dart';

class AttestationWidget extends StatefulWidget {
  final UserModel userModel;

  const AttestationWidget({Key? key, required this.userModel})
      : super(key: key);

  @override
  State<AttestationWidget> createState() => _AttestationWidgetState();
}

class _AttestationWidgetState extends State<AttestationWidget> {
  List<String> imageUrls = [
    'https://images.unsplash.com/photo-1643647706050-4a011a91b7b9?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHNlYXJjaHwxfHxjYWxlbmRyaWVyfGVufDB8fHx8MTcxNDU4NjA1OHww&ixlib=rb-4.0.3&q=80&w=1080',
    'https://images.unsplash.com/photo-1644317167083-a719327bb3f2?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHNlYXJjaHw4fHxjYWxlbmRyaWVyfGVufDB8fHx8MTcxNDU4NjA1OHww&ixlib=rb-4.0.3&q=80&w=1080',
    'https://images.unsplash.com/photo-1643647705844-75abcec40a1e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHNlYXJjaHwyfHxjYWxlbmRyaWVyfGVufDB8fHx8MTcxNDU4NjA1OHww&ixlib=rb-4.0.3&q=80&w=1080',
    'https://images.unsplash.com/photo-1601342630314-8427c38bf5e6?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHNlYXJjaHwyMHx8Y2FsZW5kcmllcnxlbnwwfHx8fDE3MTQ1ODYwNTh8MA&ixlib=rb-4.0.3&q=80&w=1080',
    'https://images.unsplash.com/photo-1624969862293-b749659ccc4e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHNlYXJjaHwyNHx8Y2FsZW5kcmllcnxlbnwwfHx8fDE3MTQ1ODYwNTh8MA&ixlib=rb-4.0.3&q=80&w=1080',
  ];
  List<dynamic> attestations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAttestationsData();
  }

  Future<void> _fetchAttestationsData() async {
    String cin = widget.userModel.cin;
    String apiUrl = 'http://192.168.1.22:8000/demande/demandes/${cin}';
    try {
      var response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Accept-Charset': 'utf-8'},
      );

      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          attestations = data;
          _isLoading = false;
        });
      } else {
        print('Failed to load the data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading the data: $e');
    }
  }

  Color getStatusColor(String etat) {
    switch (etat.toLowerCase()) {
      case 'terminé':
        return FlutterFlowTheme.of(context).secondary;
      case 'rejeté':
        return Colors.red;
      case 'en cours':
        return FlutterFlowTheme.of(context).primary;
      case 'en attente':
        return FlutterFlowTheme.of(context).tertiary;
      default:
        return Colors.black; // Par défaut, la couleur est noire
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Demandes en cours'),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded),
          onPressed: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => Accueil(userModel: widget.userModel),
            ));
          },
        ),
        centerTitle: false,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tous',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: attestations.length,
                      itemBuilder: (context, index) {
                        // Utilisation de la classe Random pour générer un index aléatoire
                        int randomIndex = Random().nextInt(imageUrls.length);
                        return Padding(
                          padding:
                              EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 3,
                                  color: Color(0x33000000),
                                  offset: Offset(0, 1),
                                )
                              ],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      imageUrls[randomIndex],
                                      width: 44,
                                      height: 44,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          12, 0, 0, 0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            attestations[index]['Demande'],
                                            style: FlutterFlowTheme.of(context)
                                                .bodyLarge
                                                .override(
                                                  fontFamily: 'Readex Pro',
                                                  letterSpacing: 0,
                                                ),
                                          ),
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    0, 4, 0, 0),
                                            child: Text(
                                              'Date de demande ${attestations[index]['DateDemande']}',
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .labelSmall
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
                                                    0, 4, 0, 0),
                                            child: Text(
                                              'Prête le ${attestations[index]['PretLe']}',
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .labelSmall
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
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0, 8, 0, 0),
                                        child: Container(
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: getStatusColor(
                                                attestations[index]['Etat']),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                              color: getStatusColor(
                                                  attestations[index]['Etat']),
                                              width: 2,
                                            ),
                                          ),
                                          child: Align(
                                            alignment:
                                                AlignmentDirectional(0, 0),
                                            child: Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(12, 0, 12, 0),
                                              child: Text(
                                                '${attestations[index]['Etat']}',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily:
                                                              'Readex Pro',
                                                          letterSpacing: 0,
                                                        ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
