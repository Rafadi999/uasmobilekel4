import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/announcement_provider.dart';

class AnnouncementScreen extends StatelessWidget {
  final String role; // "guru" atau "siswa"

  const AnnouncementScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1B2A) : Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Pengumuman"),
        backgroundColor: isDark ? Colors.blue.shade900 : Colors.blue.shade700,
        elevation: 0,
      ),

      body: Consumer<AnnouncementProvider>(
        builder: (context, provider, child) {
          final list = provider.announcements.where(
            (a) => a.targetRole == "all" || a.targetRole == role,
          ).toList();

          if (list.isEmpty) {
            return const Center(
              child: Text(
                "Tidak ada pengumuman.",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final data = list[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(20),
                  shadowColor: Colors.black.withOpacity(0.15),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.blueGrey.shade900 : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.blue.shade300.withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(18),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Judul pengumuman
                        Text(
                          data.nama,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.blue.shade800,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Isi pengumuman
                        Text(
                          data.tentang,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Footer: tanggal + target role
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Tanggal: ${data.dibuat.day}/${data.dibuat.month}/${data.dibuat.year}",
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white54 : Colors.grey.shade700,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: data.targetRole == "all"
                                    ? Colors.blue.shade600
                                    : data.targetRole == "guru"
                                        ? Colors.green.shade700
                                        : Colors.orange.shade700,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Text(
                                data.targetRole == "all"
                                    ? "Semua"
                                    : data.targetRole == "guru"
                                        ? "Guru"
                                        : "Siswa",
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
