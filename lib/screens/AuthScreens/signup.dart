import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:mira/Provider/Auth_model.dart';
import 'package:mira/Provider/user_model.dart';
import 'package:mira/Screens/AuthScreens/login.dart';
import 'package:mira/Utils/animations.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:mira/Widgets/SignUpWidgets/CustomCINFormField.dart';
import 'package:mira/Widgets/SignUpWidgets/CustomDateField.dart';
import 'package:mira/Widgets/SignUpWidgets/CustomEmailField.dart';
import 'package:mira/Widgets/SignUpWidgets/CustomPasswordField.dart';
import 'package:mira/Widgets/SignUpWidgets/CustomPhoneNumberField.dart';
import 'package:mira/Widgets/SignUpWidgets/CustomTextFormField.dart';
import 'package:http/http.dart' as http;

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> with TickerProviderStateMixin {
  final cinController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final statutController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final dateController = TextEditingController();
  String? phoneNumberError;
  PhoneNumber? phoneNumber;

  late UserModel _model;
  String? _selectedRole; // Déclaration de la variable _selectedRole
  final _formKey = GlobalKey<FormState>();
  List<dynamic> donnees = [];
  bool _isLoading = true;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final animationsMap = AnimationHelper.animationsMap;

  @override
  void initState() {
    super.initState();
    _model = UserModel((message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    });
    fetchData(); // Appeler la nouvelle fonction
  }

  Future<void> fetchData() async {
    List<dynamic> data =
        await fetchInstitutData(); // Utiliser la fonction importée
    setState(() {
      donnees = data;
      _isLoading = false;
    });
  }

  Widget _buildLogoImage() {
    try {
      if (donnees.isNotEmpty && donnees[0].containsKey('logo')) {
        // Essayer de charger l'image depuis les données
        return Image.memory(
          base64.decode(donnees[0]['logo']),
          width: 200,
          height: 70,
        );
      }
    } catch (e) {
      print('Failed to load image: $e');
    }
    return Image.asset(
      'assets/Instituts.jpeg',
      width: 200,
      height: 70,
    );
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isiOS) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarBrightness: Theme.of(context).brightness,
          systemStatusBarContrastEnforced: true,
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              FlutterFlowTheme.of(context).primaryBackground,
              FlutterFlowTheme.of(context).primaryBackground
            ],
            stops: [0, 1],
            begin: AlignmentDirectional(0.87, -1),
            end: AlignmentDirectional(-0.87, 1),
          ),
        ),
        alignment: AlignmentDirectional(0, -1),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 70, 0, 32),
                  child: Container(
                    width: 200,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: AlignmentDirectional(0, 0),
                    child: _buildLogoImage(),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      maxWidth: 570,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 4,
                          color: Color(0x33000000),
                          offset: Offset(0, 2),
                        )
                      ],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Align(
                      alignment: AlignmentDirectional(0, 0),
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'S\'inscrire ',
                              textAlign: TextAlign.center,
                              style: FlutterFlowTheme.of(context)
                                  .displaySmall
                                  .override(
                                    fontFamily: 'Plus Jakarta Sans',
                                    color: Color(0xFF101213),
                                    fontSize: 36,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 12, 0, 24),
                              child: Text(
                                'Créez  Votre  Compte  Maintenant',
                                textAlign: TextAlign.center,
                                style: FlutterFlowTheme.of(context)
                                    .labelMedium
                                    .override(
                                      fontFamily: 'Plus Jakarta Sans',
                                      color: Color(0xFF57636C),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                              child: CustomTextFormField(
                                controller: _model.firstNameController,
                                labelText: 'Nom *',
                                autofillHints: [AutofillHints.name],
                                keyboardType: TextInputType.name,
                              ),
                            ),
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                              child: CustomTextFormField(
                                controller: _model.lastNameController,
                                labelText: 'Prénom *',
                                autofillHints: [AutofillHints.name],
                                keyboardType: TextInputType.name,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0, 0, 0, 16),
                              child: CustomCINFormField(
                                controller: _model.cinController,
                                labelText: 'CIN *',
                                autofillHints: [AutofillHints.telephoneNumber],
                              ),
                            ),
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                              child: CustomDateField(
                                controller: _model.dateDeDelivranceController,
                                labelText: 'Date de délivrance de la CIN *',
                                onDatePicked: (pickedDate) {
                                  // Utilisez pickedDate selon vos besoins
                                },
                              ),
                            ),
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                              child: CustomEmailField(
                                controller: _model
                                    .emailController, // Utilisez le même contrôleur ici aussi
                                labelText: 'Email *',
                              ),
                            ),
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                              child: CustomPhoneNumberField(
                                controller: _model
                                    .phoneNumberController, // Mettez à jour cette ligne
                                labelText: 'Numéro de téléphone *',
                                onInputValidated: (bool value) {},
                              ),
                            ),
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                              child: Container(
                                width: double.infinity,
                                child: DropdownButtonFormField<String>(
                                  value: _selectedRole,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedRole = newValue;
                                      _model.setSelectedRole(
                                          newValue); // Définir la valeur du rôle sélectionné
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Veuillez sélectionner un rôle';
                                    }
                                    return null;
                                  },
                                  items: <String>[
                                    'Etudiant',
                                    'Enseignant',
                                    'Administratif'
                                  ].map<DropdownMenuItem<String>>(
                                    (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    },
                                  ).toList(),
                                  decoration: InputDecoration(
                                    labelText: 'Rôle *',
                                    labelStyle: FlutterFlowTheme.of(context)
                                        .labelLarge
                                        .override(
                                          fontFamily: 'Plus Jakarta Sans',
                                          color: Color(0xFF57636C),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0xFFF1F4F8),
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0xFF4B39EF),
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0xFFE0E3E7),
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0xFFE0E3E7),
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: Color(0xFFF1F4F8),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                              child: CustomPasswordField(
                                controller: _model.passwordController,
                                labelText: 'Mot de passe *',
                                autofillHints: [AutofillHints.password],
                              ),
                            ),
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                              child: FFButtonWidget(
                                onPressed: () async {
                                  _model.registerUser(context);
                                },
                                text: 'S\'inscrire',
                                options: FFButtonOptions(
                                  width: double.infinity,
                                  height: 44,
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0, 0, 0, 0),
                                  iconPadding: EdgeInsetsDirectional.fromSTEB(
                                      0, 0, 0, 0),
                                  color: Color(0xFF4B39EF),
                                  textStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        fontFamily: 'Plus Jakarta Sans',
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                  elevation: 3,
                                  borderSide: BorderSide(
                                    color: Colors.transparent,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 12, 0, 12),
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'vous avez déjà un compte? ',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'se connecter',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'Plus Jakarta Sans',
                                            color: Color(0xFF4B39EF),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Navigator.of(context,
                                                  rootNavigator: true)
                                              .push(MaterialPageRoute(
                                            builder: (context) => LoginPage(),
                                          ));
                                        },
                                    ),
                                  ],
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Plus Jakarta Sans',
                                        color: Color(0xFF101213),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                                textScaler: TextScaler.linear(
                                    MediaQuery.of(context).textScaleFactor),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
