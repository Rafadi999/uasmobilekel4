import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/schedule_provider.dart';
import '../../models/schedule.dart';

class TeacherScheduleScreen extends StatelessWidget {
  final String teacherId;
  final String teacherName;

  const TeacherScheduleScreen({
    super.key,
    required this.teacherId,
    required this.teacherName,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ScheduleProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text("Jadwal Mengajar $teacherName"),
      ),

      body: StreamBuilder<List<Schedule>>(
        stream: provider.getSchedulesByTeacher(teacherId), // 🔥 FIX UTAMA
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snap.data!;
          if (data.isEmpty) {
            return const Center(
              child: Text(
                "Belum ada jadwal mengajar",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (ctx, i) {
              final s = data[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 4,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  title: Text(
                    "${s.pelajaran} - ${s.namakelas}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text(
                    "${s.hari}, ${s.waktumulai} - ${s.waktuselesai}",
                    style: const TextStyle(color: Colors.grey),
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
