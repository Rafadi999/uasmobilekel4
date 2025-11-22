import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/schedule_provider.dart';
import '../../models/schedule.dart';

class StudentScheduleScreen extends StatelessWidget {
  final String className; // dari login siswa

  const StudentScheduleScreen({super.key, required this.className});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ScheduleProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text("Jadwal Kelas $className")),
      body: StreamBuilder<List<Schedule>>(
        stream: provider.getSchedulesByClass(className),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final schedules = snapshot.data!;

          if (schedules.isEmpty) {
            return const Center(child: Text("Belum ada jadwal."));
          }

          return ListView.builder(
            itemCount: schedules.length,
            itemBuilder: (context, i) {
              final s = schedules[i];
              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text("${s.pelajaran} — ${s.guru}"),
                  subtitle:
                      Text("${s.hari} • ${s.waktumulai} - ${s.waktuselesai}"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}