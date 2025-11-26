import 'package:flutter/material.dart';
import 'select_siswa_screen.dart';

class SelectMapelScreen extends StatelessWidget {
  final List<String> mapelGuru = ["Matematika", "IPA", "IPS", "B. Indonesia"];

  SelectMapelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pilih Mapel")),
      body: ListView.builder(
        itemCount: mapelGuru.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(mapelGuru[index]),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SelectSiswaScreen(mapel: mapelGuru[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
