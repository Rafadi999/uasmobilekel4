import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/schedule_provider.dart';
import '../../models/schedule.dart';

class StudentScheduleScreen extends StatelessWidget {
  final String className; // diisi otomatis dari data siswa login
  const StudentScheduleScreen({super.key, required this.className});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ScheduleProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text("Jadwal Kelas $className")),
      body: StreamBuilder<List<Schedule>>(
        stream: provider.getSchedulesByClass(className),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final data = snap.data!;
          if (data.isEmpty) return const Center(child: Text("Tidak ada jadwal"));

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (ctx, i) {
              final s = data[i];
              return Card(
                child: ListTile(
                  title: Text("${s.pelajaran} — ${s.guru}"),
                  subtitle: Text("${s.hari}, ${s.waktumulai} - ${s.waktuselesai}"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}