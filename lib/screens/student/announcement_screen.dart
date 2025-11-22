import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/announcement_provider.dart';

class AnnouncementScreen extends StatelessWidget {
  final String role; // kirim role dari halaman utama → "guru" atau "siswa"

  const AnnouncementScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pengumuman")),
      body: Consumer<AnnouncementProvider>(
        builder: (context, provider, child) {
          // 🔹 Filter berdasarkan role
          final list = provider.announcements.where(
            (a) => a.targetRole == "all" || a.targetRole == role,
          ).toList();

          if (list.isEmpty) {
            return const Center(
              child: Text("Tidak ada pengumuman."),
            );
          }

          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final data = list[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(
                    data.nama, // ⬅️ diperbaiki
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(data.tentang), // ⬅️ diperbaiki
                  trailing: Text(
                    "${data.dibuat.day}/${data.dibuat.month}/${data.dibuat.year}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}