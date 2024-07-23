import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:mira/Screens/AuthScreens/login.dart';
import 'package:mira/Screens/acceuil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserModel extends ChangeNotifier {
  late String? _selectedRole;
  late String statut = '';
  late String firstName = '';
  late String lastName = '';
  late String date_de_delivrance;
  late String email = '';
  late String cin = '';
  late int phoneNumber;
  late Image profileImage = Image.asset('assets/default_avatar.jpeg');
  late bool passwordVisibility;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _cinController;
  late TextEditingController _dateDeDelivranceController;
  late TextEditingController _emailController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _statutController;
  late TextEditingController _passwordController;
  late TextEditingController _resetPasswordController;
  late Function(String) _showSnackBar;
  late String _photoBase64;
  late String titre;
  late String publicIpAddress;
  late String privateIpAddress;
  UserModel(this._showSnackBar) {
    passwordVisibility = false;
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _cinController = TextEditingController();
    _dateDeDelivranceController = TextEditingController();
    _emailController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _statutController = TextEditingController();
    _passwordController = TextEditingController();
    _resetPasswordController = TextEditingController();
  }

  void setSelectedRole(String? role) {
    _selectedRole = role;
    notifyListeners();
  }

  TextEditingController get firstNameController => _firstNameController;
  TextEditingController get lastNameController => _lastNameController;
  TextEditingController get cinController => _cinController;
  TextEditingController get dateDeDelivranceController =>
      _dateDeDelivranceController;
  TextEditingController get emailController => _emailController;
  TextEditingController get phoneNumberController => _phoneNumberController;
  TextEditingController get statutController => _statutController;
  TextEditingController get passwordController => _passwordController;
  TextEditingController get resetPasswordController => _resetPasswordController;
  String? getPhotoBase64() => _photoBase64;
  Future<void> getUserIpAddress() async {
    try {
      var response = await http
          .get(Uri.parse('http://192.168.1.22:8000/abscence/my_IpAdress/'));
      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes));
        privateIpAddress = data['private_ip_address'];
        publicIpAddress = data['ip_address'];
        print('Adresse IP privée : $privateIpAddress');
        print('Adresse IP publique : $publicIpAddress');
        // Stockez les adresses IP dans votre modèle utilisateur
        // Vous pouvez les stocker dans des variables dans votre modèle ou les utiliser directement
      } else {
        print('Failed to get IP address');
      }
    } catch (e) {
      print('Exception while getting IP address: $e');
    }
  }

  // Connexion
  Future<void> loginUser(BuildContext context) async {
    try {
      var url = Uri.parse('http://192.168.1.22:8000/users/login/');
      var headers = {'Content-Type': 'application/json'};
      var body = json.encode({
        'cin': _cinController.text,
        'password': _passwordController.text,
      });

      var response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        var userData = json.decode(response.body);
        await startSession();
        await getUserIpAddress();

        firstName = userData['firstName'] ?? '';
        lastName = userData['lastName'] ?? '';
        statut = userData['statut'] ?? '';
        email = userData['email'] ?? '';
        cin = userData['cin'] ?? '';
        titre = userData['titre'] ?? '';

        notifyListeners();

        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => Accueil(userModel: this),
        ));
      } else {
        String errorMessage = response.body.isEmpty
            ? 'Erreur inconnue lors de la connexion'
            : response.body;
        throw Exception(
            'Erreur lors de la connexion: ${response.statusCode} - $errorMessage');
      }
    } catch (e) {
      _showSnackBar(e.toString());
    }
  }

  @override
  void dispose() {
    passwordVisibility = false;
    _firstNameController.dispose();
    _lastNameController.dispose();
    _cinController.dispose();
    _dateDeDelivranceController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _statutController.dispose();
    _passwordController.dispose();
    _resetPasswordController.dispose();

    super.dispose();
  }

  Future<void> clearSession(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove(
          'isAuthenticated'); // Supprimez la clé 'isAuthenticated' de SharedPreferences
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      print('Error clearing session: $e');
    }
  }

  Future<void> registerUser(BuildContext context) async {
    try {
      var userUrl = Uri.parse('http://192.168.1.22:8000/users/register/');
      var profileUrl = Uri.parse('http://192.168.1.22:8000/profil/create/');

      var headers = {'Content-Type': 'application/json'};
      var userBody = json.encode({
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'cin': _cinController.text,
        'dateDeDelivrance': _dateDeDelivranceController.text,
        'email': _emailController.text,
        'phoneNumber': int.parse(_phoneNumberController.text),
        'statut': _selectedRole,
        'password': _passwordController.text,
        'resetPassword': _resetPasswordController.text,
      });

      var userResponse =
          await http.post(userUrl, headers: headers, body: userBody);

      print('User Response Status Code: ${userResponse.statusCode}');
      print('User Response Body: ${userResponse.body}');

      if (userResponse.statusCode == 201) {
        var profileBody = json.encode({
          'cartCin': _cinController.text,
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'dateDeDelivrance': _dateDeDelivranceController.text,
          'email': _emailController.text,
          'phoneNumber': _phoneNumberController.text,
        });

        var profileResponse =
            await http.post(profileUrl, headers: headers, body: profileBody);

        print('Profile Response Status Code: ${profileResponse.statusCode}');
        print('Profile Response Body: ${profileResponse.body}');

        if (profileResponse.statusCode == 201) {
          _showSnackBar(
              'Inscription réussie ! Veuillez patienter pendant que nous activons votre compte.');
          Future.delayed(Duration(seconds: 1), () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => LoginPage(),
            ));
          });
        } else {
          String errorMessage = profileResponse.body.isEmpty
              ? 'Erreur inconnue lors de la création du profil'
              : profileResponse.body;
          throw Exception(
              'Erreur lors de la création du profil: ${profileResponse.statusCode} - $errorMessage');
        }
      } else {
        String errorMessage = userResponse.body.isEmpty
            ? 'Erreur inconnue lors de l\'inscription'
            : userResponse.body;
        throw Exception(
            'Erreur lors de l\'inscription: ${userResponse.statusCode} - $errorMessage');
      }

      notifyListeners();
    } catch (e) {
      _showSnackBar('Erreur lors de l\'inscription: $e');
      print('Error during registration: $e');
    }
  }

  Future<void> startSession() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('isAuthenticated', true);
      print('Session started successfully');
    } catch (e) {
      print('Error starting session: $e');
    }
  }

  Future<bool> isSessionActive() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isAuthenticated') ?? false;
  }

  Future<void> getProfileImage() async {
    if (cin == null) {
      print('CIN est null');
      return;
    }
    String apiUrl = 'http://192.168.1.22:8000/profil/profiles/cin/$cin';

    try {
      var response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        var profileData = json.decode(response.body);

        String base64Image = profileData['image'];

        if (base64Image.isNotEmpty) {
          List<int> imageBytes = base64.decode(base64Image);
          profileImage = Image.memory(Uint8List.fromList(imageBytes));
          notifyListeners();
        }
      } else {
        print('Failed to load profile image: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading profile image: $e');
    }
  }
}
