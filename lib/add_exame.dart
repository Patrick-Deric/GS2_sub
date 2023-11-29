import 'package:flutter/material.dart';

class AdicionarExamePage extends StatefulWidget {
  const AdicionarExamePage({super.key});

  @override
  _AdicionarExamePageState createState() => _AdicionarExamePageState();
}

class _AdicionarExamePageState extends State<AdicionarExamePage> {
  String? selectedMedicalArea;
  String? selectedRegion;
  String? enteredHospital;
  DateTime? selectedDate;

  final List<String> medicalAreas = [
    'Urologia',
    'Cardiorrespiratória',
    // Adicione mais áreas médicas aqui, se necessário
  ];

  final List<String> regions = [
    'São Paulo',
    'Rio de Janeiro',
    // Adicione mais regiões aqui
  ];

  final Map<String, List<String>> regionsAndHospitals = {
    'São Paulo': [
      'Hospital A',
      'Hospital B',
      // Adicione mais hospitais em São Paulo aqui
    ],
    'Rio de Janeiro': [
      'Hospital X',
      'Hospital Y',
      // Adicione mais hospitais no Rio de Janeiro aqui
    ],
    // Adicione outras regiões e seus respectivos hospitais aqui
  };

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)), // 365 dias atrás
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Exame em Calendário'),
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
                });
              },
              hint: const Text('Selecione a área médica'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Selecione a região:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: selectedRegion,
              items: regions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedRegion = newValue;
                  enteredHospital = null; // Reset entered hospital when region changes
                });
              },
              hint: const Text('Selecione a região'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Digite o nome do hospital:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              onChanged: (value) {
                setState(() {
                  enteredHospital = value;
                });
              },
              decoration: const InputDecoration(
                hintText: 'Nome do hospital',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _selectDate(context);
              },
              child: const Text('Selecionar Data do Exame'),
            ),
            const SizedBox(height: 20),
            if (selectedMedicalArea != null &&
                selectedRegion != null &&
                enteredHospital != null &&
                selectedDate != null)
              ElevatedButton(
                onPressed: () {
                  // Adicionar lógica para salvar o exame no calendário
                  // Exemplo: saveAppointment(selectedMedicalArea, selectedRegion, enteredHospital, selectedDate);
                },
                child: const Text('Adicionar ao Calendário'),
              ),
          ],
        ),
      ),
    );
  }
}
