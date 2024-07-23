import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:http/http.dart' as http;
import 'package:mira/Provider/user_model.dart';

class FormationsDetails extends StatefulWidget {
  final String formationId;
  final UserModel userModel;

  const FormationsDetails({
    Key? key,
    required this.userModel,
    required this.formationId,
  }) : super(key: key);

  @override
  _FormationsDetailsState createState() => _FormationsDetailsState();
}

class _FormationsDetailsState extends State<FormationsDetails> {
  Map<String, dynamic> formationsDetails = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFormationsDetails();
  }

  Future<void> _fetchFormationsDetails() async {
    // Afficher l'ID de la formation récupéré dans la console
    print('Formation ID: ${widget.formationId}');

    String apiUrl =
        'http://192.168.1.22:8000/formation/getFormation/${widget.formationId}';
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
          formationsDetails = data;
          _isLoading = false;
        });
      } else {
        print('Failed to load formation details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading formation details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        automaticallyImplyLeading: false,
        leading: InkWell(
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () async {
            Navigator.of(context).pop();
          },
          child: Icon(
            Icons.arrow_back_rounded,
            color: FlutterFlowTheme.of(context).primaryText,
            size: 30,
          ),
        ),
        title: Text(
          'Détails de formation ',
          style: FlutterFlowTheme.of(context).headlineMedium.override(
                fontFamily: 'Outfit',
                letterSpacing: 0,
              ),
        ),
        actions: [],
        centerTitle: false,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        base64Decode(formationsDetails['poster']),
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 16),
                    Table(
                      columnWidths: {
                        0: FixedColumnWidth(150),
                        1: FlexColumnWidth(),
                      },
                      border: TableBorder.all(color: Colors.grey),
                      children: [
                        _buildTableRow(
                            'Intitulé', formationsDetails['intitule']),
                        _buildTableRow(
                            'Formateur', formationsDetails['formateur']),
                        _buildTableRow(
                            'Responsable', formationsDetails['responsable']),
                        _buildTableRow('Numéro de responsable',
                            formationsDetails['phoneNumber']),
                        _buildTableRow('Date de formation',
                            formationsDetails['dateDeFormation']),
                        _buildTableRow('Lieu de formation',
                            formationsDetails['lieuFormation']),
                        _buildTableRow(
                            'Description', formationsDetails['description']),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  TableRow _buildTableRow(String label, String? value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            label,
            style: FlutterFlowTheme.of(context).labelLarge.override(
                  fontFamily: 'Readex Pro',
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            value ?? 'Inconnu',
            style: FlutterFlowTheme.of(context).labelLarge.override(
                  fontFamily: 'Readex Pro',
                ),
          ),
        ),
      ],
    );
  }
}
