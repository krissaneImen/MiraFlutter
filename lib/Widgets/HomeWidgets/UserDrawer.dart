import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mira/Provider/user_model.dart';
import 'package:mira/Provider/user_model.dart';
import 'package:mira/Screens/Absences.dart';
import 'package:mira/Screens/MenuScreens/Actualit%C3%A9%20et%20docuements%20admin/Calendriers.dart';
import 'package:mira/Screens/MenuScreens/ActualityPage.dart';
import 'package:mira/Screens/MenuScreens/Cours.dart';
import 'package:mira/Screens/MenuScreens/Manifestations.dart';
import 'package:mira/Screens/MenuScreens/Reglements/TypesReglements.dart';
import 'package:mira/Screens/MenuScreens/Services.dart';
import 'package:mira/Screens/MenuScreens/Stages/Stages.dart';
import 'package:mira/Screens/MenuScreens/formations.dart';
import 'package:mira/Screens/Profil/Profil.dart';
import 'package:mira/Screens/acceuil.dart';
import 'package:http/http.dart' as http;
import 'package:mira/Utils/CustomAlertDialog.dart';

class UserDrawer extends StatefulWidget {
  final UserModel userModel; // Ajoutez une instance de UserModel comme argument

  UserDrawer({required this.userModel}) {
    userModel.getProfileImage(); // Appel de la méthode _getProfileImage()
  }
  @override
  _UserDrawerState createState() => _UserDrawerState();
}

class _UserDrawerState extends State<UserDrawer> {
  bool _isDrawerOpen = false;
  List<dynamic> donnees = [];
  List<dynamic> adresses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    widget.userModel.getProfileImage();
    fetchInstitutData();
  }

  Future<bool> _checkIpAddressAllowed(String publicIpAddress) async {
    try {
      // Appel de l'API pour comparer l'adresse IP avec les plages autorisées
      var response = await http.get(
        Uri.parse(
            'http://192.168.1.22:8000/abscence/check_ip_allowed/$publicIpAddress'),
      );

      if (response.statusCode == 200) {
        // Traitement de la réponse JSON de l'API
        var responseData = jsonDecode(response.body);
        bool isAllowed = responseData['allowed'];
        // Utilisez la valeur de retour isAllowed pour décider de l'action à effectuer
        if (isAllowed) {
          print('L\'adresse IP est autorisée');
        } else {
          print('L\'adresse IP n\'est pas autorisée');
        }
        return isAllowed;
      } else {
        // Gestion des erreurs de l'appel API
        print('Failed to check IP address: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      // Gestion des erreurs d'exception
      print('Exception while checking IP address: $e');
      return false;
    }
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
    return Drawer(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isDrawerOpen = !_isDrawerOpen;
          });
        },
        child: AnimatedContainer(
          width: _isDrawerOpen ? 270 : 0,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: _buildDrawerDecoration(context),
          child: _buildDrawerContent(context),
        ),
      ),
    );
  }

  BoxDecoration _buildDrawerDecoration(BuildContext context) {
    return BoxDecoration(
      color: FlutterFlowTheme.of(context).secondaryBackground,
      borderRadius: BorderRadius.circular(0),
      boxShadow: _isDrawerOpen
          ? [
              BoxShadow(
                blurRadius: 4,
                color: Color(0x33000000),
                offset: Offset(
                  0,
                  2,
                ),
              )
            ]
          : [],
    );
  }

  Widget _buildDrawerContent(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0, 24, 0, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDrawerHeader(context),
              _buildMenuOption(
                icon: Icons.new_releases,
                text: 'Actualités',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ActualiteWidget(
                        userModel: widget.userModel,
                      ),
                    ),
                  );
                },
              ),
              _buildMenuOption(
                icon: Icons.home,
                text: 'Accueil',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Accueil(
                        userModel: widget.userModel,
                      ),
                    ),
                  );
                },
              ),
              _buildMenuOption(
                icon: Icons.person,
                text: 'Profil',
                onTap: () {
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
                },
              ),
              _buildMenuOption(
                icon: Icons.home,
                text: 'Support de cours',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CoursWidget(
                        userModel: widget.userModel,
                      ),
                    ),
                  );
                },
              ),
              if (widget.userModel.statut.toLowerCase() == 'enseignant' ||
                  widget.userModel.statut.toLowerCase() == 'administratif')
                _buildMenuOption(
                  icon: Icons.note_alt_outlined,
                  text: 'Absences',
                  onTap: () async {
                    // Appel de la méthode pour obtenir l'adresse IP de l'utilisateur
                    // Vérification de l'autorisation avec l'adresse IP récupérée
                    bool isAllowed = await _checkIpAddressAllowed(
                        widget.userModel.publicIpAddress);
                    // Si l'adresse IP est autorisée, naviguer vers la page des Absences
                    if (isAllowed) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SeancesWidget(
                            userModel: widget.userModel,
                          ),
                        ),
                      );
                    } else {
                      // Sinon, afficher un message indiquant que l'accès est refusé
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CustomAlertDialog(
                            title: 'Accès refusé',
                            content:
                                'Votre adresse IP n\'est pas autorisée à accéder à cette section.',
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          );
                        },
                      );
                    }
                  },
                ),

              _buildMenuOption(
                icon: Icons.school,
                text: 'Formations',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FormationList(
                        userModel: widget.userModel,
                      ),
                    ),
                  );
                },
              ),
              _buildMenuOption(
                icon: Icons.diversity_3,
                text: 'Manifestations',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ManifestationsWidget(
                        userModel: widget.userModel,
                      ),
                    ),
                  );
                },
              ),
              _buildMenuOption(
                icon: Icons.calendar_month_sharp,
                text: 'Calendriers',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CalendriersWidget(
                        userModel: widget.userModel,
                      ),
                    ),
                  );
                },
              ),
              _buildMenuOption(
                icon: Icons.miscellaneous_services,
                text: 'Services et Demandes',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Services(
                        userModel: widget.userModel,
                      ),
                    ),
                  );
                },
              ),
              _buildMenuOption(
                icon: Icons.library_books,
                text: 'Règlements',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TypesReglement(
                        userModel: widget.userModel,
                      ),
                    ),
                  );
                },
              ),
              _buildMenuOption(
                icon: Icons.work,
                text: 'Stages et Rapport',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Stages(
                        userModel: widget.userModel,
                      ),
                    ),
                  );
                },
              ),
              _buildMenuOption(
                icon: Icons.logout,
                text: 'Déconnexion',
                onTap: () {
                  widget.userModel.clearSession(
                      context); // Appeler clearSession lorsque l'utilisateur appuie sur l'option de déconnexion
                },
              ),
              // Ajoutez d'autres options de menu ici...
              _buildDrawerFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 24),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          FaIcon(
            FontAwesomeIcons.university,
            color: FlutterFlowTheme.of(context).primary,
            size: 32,
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
            child: Text(
              donnees.isNotEmpty ? donnees[0]['acronyme'] ?? '' : '',
              style: FlutterFlowTheme.of(context).headlineMedium.override(
                    fontFamily: 'Outfit',
                    letterSpacing: 0,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 12),
        child: Container(
          width: double.infinity,
          height: 50,
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(12, 0, 12, 0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 12, 12, 12),
                  child: Container(
                    width: 4,
                    height: 100,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                Icon(
                  icon,
                  color: FlutterFlowTheme.of(context).primaryText,
                  size: 28,
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                  child: Text(
                    text,
                    style: FlutterFlowTheme.of(context).bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerFooter(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Divider(
            height: 12,
            thickness: 2,
            color: FlutterFlowTheme.of(context).alternate,
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0, 12, 0, 0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).accent1,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: FlutterFlowTheme.of(context).primary,
                      width: 2,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(2),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: FutureBuilder<void>(
                        future: widget.userModel.getProfileImage(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            // While waiting for the image to load, display a placeholder or loading indicator
                            return Placeholder(
                              fallbackHeight: 44,
                              fallbackWidth: 44,
                            );
                          } else if (snapshot.hasError) {
                            // If there's an error loading the image, display an error message
                            return Text('Error loading profile image');
                          } else {
                            // If image is loaded successfully, display the image
                            return Image(
                              image: widget.userModel.profileImage.image,
                              width: 44,
                              height: 44,
                              fit: BoxFit.cover,
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.userModel.firstName,
                          style:
                              FlutterFlowTheme.of(context).bodyLarge.override(
                                    fontFamily: 'Readex Pro',
                                    letterSpacing: 0,
                                  ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                          child: Text(
                            widget.userModel.email,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
