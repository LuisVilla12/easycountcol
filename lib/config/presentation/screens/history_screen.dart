import 'package:easycoutcol/config/api/models/Samples.dart';
import 'package:easycoutcol/config/presentation/screens/results_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HistoryScreen extends StatefulWidget {
  static const String name ='history_screen';
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
Future<List<Sample>> fetchSamples() async {
  final response = await http.get(Uri.parse('http://10.0.2.2:8000/samples'));

  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonData = jsonDecode(response.body);
    final List<dynamic> samplesList = jsonData['samples'];

    // Mapea cada sublista a un objeto Sample
    return samplesList.map((item) => Sample.fromJsonList(item)).toList();
  } else {
    throw Exception('Error al cargar las muestras');
  }
}

@override
Widget build(BuildContext context) {
  final colors=Theme.of(context).colorScheme;
  return Scaffold(
    appBar: AppBar(title: const Text('Historial')),
    body: FutureBuilder<List<Sample>>(
      future: fetchSamples(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No hay muestras disponibles'));
        } else {
          final samples = snapshot.data!;
          return ListView.builder(
  itemCount: samples.length,
  itemBuilder: (context, index) {
    final sample = samples[index];
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: sample.type == 'agua' ? Colors.lightBlue.shade100 :  colors.primary,
        child: Icon(
          sample.type == 'agua' ? Icons.opacity : Icons.science,
          color: sample.type == 'agua' ? Colors.blue : Colors.white,
        ),
      ),
      title: Text(
        sample.name,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      subtitle: Row(
        children: [
          Icon(Icons.calendar_today, size: 14, color: colors.primary),
          const SizedBox(width: 4),
          Text(
            sample.date,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Icon(Icons.access_time, size: 14, color: colors.primary),
          const SizedBox(width: 4),
          Text(
            '11:20',
            style: TextStyle(color: colors.primary),
          ),
        ],
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: colors.primary),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultsScreen(idMuestra: sample.id),
          ),
        );
      },
    );
  },
);

        }
      },
    ),
  );
}
}

