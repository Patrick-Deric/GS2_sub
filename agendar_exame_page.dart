import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Importe o pacote do Firestore
import 'firebase_options.dart'; // Importe o arquivo com o serviço do Firebase

class AgendarExamePage extends StatefulWidget {
  const AgendarExamePage({Key? key}) : super(key: key);

  @override
  _AgendarExamePageState createState() => _AgendarExamePageState();
}

class _AgendarExamePageState extends State<AgendarExamePage> {
  String? selectedMedicalArea;
  List<DateTime> selectedDates = [];
  String? selectedCity;
  String? selectedHospital;
  String? userEmail;

  final List<String> medicalAreas = [
    'Pediatria',
    'Pneumologia',
    'Urologia',
    'Dermatologia',
    'Oftalmologia',
    // Adicione mais áreas médicas aqui, se necessário
  ];

  final List<String> saoPauloCities = [
    'São Paulo',
    'Guarulhos',
    'Campinas',
    'São Bernardo do Campo',
    // Adicione mais cidades de São Paulo aqui
  ];

  final Map<String, List<String>> citiesAndHospitals = {
    'São Paulo': [
      'Einstein',
      'Sírio Libanês',
      'Oswaldo Cruz',
      'Hospital das Clínicas',
      // Adicione mais hospitais disponíveis em São Paulo aqui
    ],
    // Adicione outras cidades e seus hospitais correspondentes aqui
  };

  void _confirmAppointment() {
    if (selectedMedicalArea == null ||
        selectedDates.isEmpty ||
        selectedHospital == null ||
        selectedCity == null) {
      // Mostrar um alerta se algum campo estiver vazio
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Campos Obrigatórios'),
            content: const Text('Por favor, preencha todos os campos antes de confirmar a consulta.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Alteração aqui para fechar o diálogo

                  // O código abaixo agendará a consulta no Firebase Firestore
                  agendarConsulta(selectedMedicalArea!, selectedDates, selectedCity!, selectedHospital!, userEmail!);

                  // Limpar os campos após agendar a consulta
                  setState(() {
                    selectedMedicalArea = null;
                    selectedDates.clear();
                    selectedCity = null;
                    selectedHospital = null;
                    userEmail = null;
                  });
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Consulta Confirmada!'),
          content: Text(
            'Sua consulta de $selectedMedicalArea foi agendada para ${selectedDates.map((date) => DateFormat.yMd().format(date)).join(', ')} no $selectedHospital em $selectedCity.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  selectedMedicalArea = null;
                  selectedDates.clear();
                  selectedCity = null;
                  selectedHospital = null;
                  userEmail = null;
                });
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (picked != null) {
      setState(() {
        selectedDates.add(picked);
        if (selectedCity != null) {
          selectedHospital = null;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendamento de Consulta'),
      ),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Selecione a área médica:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: selectedMedicalArea,
              items: medicalAreas.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedMedicalArea = newValue;
                  selectedDates.clear();
                  selectedCity = null;
                  selectedHospital = null;
                });
              },
              hint: const Text('Selecione a área médica'),
            ),
            const SizedBox(height: 20),
            DropdownButton<String>(
              value: selectedCity,
              items: saoPauloCities.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedCity = newValue;
                  selectedHospital = null; // Limpar o hospital ao selecionar uma nova cidade
                });
              },
              hint: const Text('Selecione a cidade em São Paulo'),
            ),
            const SizedBox(height: 20),
            if (selectedDates.isNotEmpty)
              DropdownButton<String>(
                value: selectedHospital,
                items: citiesAndHospitals[selectedCity ?? '']?.map((String hospital) {
                  return DropdownMenuItem<String>(
                    value: hospital,
                    child: Text(hospital),
                  );
                }).toList() ?? [],
                onChanged: (String? newValue) {
                  setState(() {
                    selectedHospital = newValue;
                  });
                },
                hint: const Text('Selecione o hospital'),
              ),
            const SizedBox(height: 20),
            if (selectedMedicalArea != null &&
                selectedDates.isNotEmpty &&
                selectedHospital != null &&
                selectedCity != null)
              ElevatedButton(
                onPressed: () {
                  _confirmAppointment();
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.blue,
                ),
                child: const Text('Confirmar Consulta'),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _selectDate(context);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.blue,
              ),
              child: const Text('Selecionar Data da Consulta'),
            ),
          ],
        ),
      ),
    );
  }

  void agendarConsulta(String selectedMedicalArea, List<DateTime> selectedDates, String selectedCity, String selectedHospital, String userEmail) {
    final CollectionReference appointments = FirebaseFirestore.instance.collection('appointments');

    appointments.add({
      'medical_area': selectedMedicalArea,
      'dates': selectedDates.map((date) => Timestamp.fromDate(date)).toList(),
      'city': selectedCity,
      'hospital': selectedHospital,
      'user_email': userEmail,
    }).then((value) {
      print('Consulta agendada com sucesso! ID: ${value.id}');
    }).catchError((error) {
      print('Erro ao agendar consulta: $error');
    });
  }
}
