import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:mira/Provider/user_model.dart';
import 'package:mira/Screens/MenuScreens/Actualit%C3%A9%20et%20docuements%20admin/Calendriers.dart';
import 'package:mira/Screens/MenuScreens/Cours.dart';
import 'package:mira/Screens/MenuScreens/ActualityPage.dart';
import 'package:mira/Screens/Profil/Profil.dart';
import 'package:mira/Widgets/HomeWidgets/UserDrawer.dart';

class Accueil extends StatefulWidget {
  final UserModel userModel;

  const Accueil({Key? key, required this.userModel}) : super(key: key);

  @override
  _AccueilState createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> {
  int _selectedIndex = 0;
  late GlobalKey<ScaffoldState> _scaffoldKey;
  List<dynamic> donnees = [];
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    _scaffoldKey = GlobalKey<ScaffoldState>();
    fetchInstitutData();
  }

  Future<void> fetchInstitutData() async {
    String apiUrl = 'http://192.168.1.22:8000/client/get_Institut/';
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
          donnees = data;
          _isLoading = false;
        });
      } else {
        print('Failed to load the data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading the data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget drawerWidget = UserDrawer(userModel: widget.userModel);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(donnees.isNotEmpty ? donnees[0]['acronyme'] ?? '' : ''),
        automaticallyImplyLeading: false,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        leading: FlutterFlowIconButton(
          borderRadius: 30,
          buttonSize: 60,
          icon: Icon(
            Icons.menu_rounded,
            color: FlutterFlowTheme.of(context).primaryText,
            size: 30,
          ),
          onPressed:
              _onMenuButtonPressed, // Appel de la fonction pour ouvrir le tiroir utilisateur
        ),
      ),
      drawer: drawerWidget,
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(16, 16, 0, 12),
              child: Text(
                'Calendriers universitaires',
                style: FlutterFlowTheme.of(context).labelMedium.override(
                      fontFamily: 'Readex Pro',
                      letterSpacing: 0,
                    ),
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CalendriersWidget(
                              userModel: widget.userModel,
                            )),
                  );
                },
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
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
                          padding: EdgeInsetsDirectional.fromSTEB(0, 1, 1, 1),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              'https://images.unsplash.com/photo-1601342630314-8427c38bf5e6?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHNlYXJjaHwyMHx8Y2FsZW5kcmllcnxlbnwwfHx8fDE3MTQ1ODYwNTh8MA&ixlib=rb-4.0.3&q=80&w=1080',
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(8, 8, 4, 0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Calendriers Universitaires',
                                  style: FlutterFlowTheme.of(context)
                                      .headlineSmall
                                      .override(
                                        fontFamily: 'Outfit',
                                        letterSpacing: 0,
                                      ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0, 4, 8, 0),
                                  child: AutoSizeText(
                                    'Voir tous',
                                    textAlign: TextAlign.start,
                                    style: FlutterFlowTheme.of(context)
                                        .labelMedium
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
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                              child: Icon(
                                Icons.chevron_right_rounded,
                                color: Color(0xFF57636C),
                                size: 24,
                              ),
                            ),
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 12, 4, 8),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: FlutterFlowTheme.of(context).primary,
        unselectedItemColor: FlutterFlowTheme.of(context).secondaryText,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school_rounded),
            label: 'Cours',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note_rounded),
            label: 'Actualités',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CoursWidget(
              userModel: widget.userModel,
            ),
          ),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ActualiteWidget(
              userModel: widget.userModel,
            ),
          ),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Profile(
              firstName: widget.userModel.firstName,
              lastName: widget.userModel.lastName,
              statut: widget.userModel.statut,
              cin: widget.userModel.cin,
            ),
          ),
        );
        break;
      default:
        break;
    }
  }

  void _onMenuButtonPressed() {
    _scaffoldKey.currentState?.openDrawer();
  }
}
