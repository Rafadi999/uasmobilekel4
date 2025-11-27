import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/schedule_provider.dart';
import '../../models/schedule.dart';

class TeacherScheduleScreen extends StatefulWidget {
  final String teacherId;
  final String teacherName;

  const TeacherScheduleScreen({
    super.key,
    required this.teacherId,
    required this.teacherName,
  });

  @override
  _TeacherScheduleScreenState createState() => _TeacherScheduleScreenState();
}

class _TeacherScheduleScreenState extends State<TeacherScheduleScreen> {
  @override
  void initState() {
    super.initState();

    // 🔥 Load jadwal sesuai Id Guru
    final provider = Provider.of<ScheduleProvider>(context, listen: false);
    provider.loadSchedules("guru", idGuru: widget.teacherId);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ScheduleProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Jadwal Mengajar ${widget.teacherName}"),
      ),

      body: provider.schedules.isEmpty
          ? const Center(
              child: Text(
                "Belum ada jadwal mengajar",
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: provider.schedules.length,
              itemBuilder: (ctx, i) {
                Schedule s = provider.schedules[i];

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 4,
                  child: ListTile(
                    title: Text(
                      "${s.pelajaran} - ${s.namakelas}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    subtitle: Text(
                      "${s.hari}, ${s.waktumulai} - ${s.waktuselesai}",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
