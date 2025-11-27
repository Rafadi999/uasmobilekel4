import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/schedule_provider.dart';

class StudentScheduleScreen extends StatefulWidget {
  final String className;
  const StudentScheduleScreen({super.key, required this.className});

  @override
  State<StudentScheduleScreen> createState() => _StudentScheduleScreenState();
}

class _StudentScheduleScreenState extends State<StudentScheduleScreen> {
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ScheduleProvider>(context, listen: false);
    provider.loadSchedules("siswa", idKelas: widget.className);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Jadwal Kelas ${widget.className}")),
      body: Consumer<ScheduleProvider>(
        builder: (context, provider, _) {
          final schedules = provider.schedules;

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