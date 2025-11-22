import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/schedule_provider.dart';
import '../../models/schedule.dart';

class TeacherScheduleScreen extends StatelessWidget {
  final String teacherName;
  const TeacherScheduleScreen({super.key, required this.teacherName});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ScheduleProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text("Jadwal $teacherName")),
      body: StreamBuilder<List<Schedule>>(
        stream: provider.getSchedulesByTeacher(teacherName),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final data = snap.data!;
          if (data.isEmpty) return const Center(child: Text("Tidak ada jadwal"));

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: data.length,
            itemBuilder: (ctx, i) {
              final s = data[i];
              return Card(
                child: ListTile(
                  title: Text("${s.pelajaran} — ${s.namakelas}"),
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