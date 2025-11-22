// lib/screens/admin/manage_schedule.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/schedule.dart';
import '../../providers/schedule_provider.dart';

class ManageScheduleScreen extends StatelessWidget {
  const ManageScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ScheduleProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Jadwal')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Schedule>>(
        stream: provider.getSchedules(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData || snap.data!.isEmpty) {
            return const Center(child: Text('Belum ada jadwal'));
          }

          final items = snap.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (ctx, i) {
              final s = items[i];
              return Card(
                elevation: 2,
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  title: Text('${s.subject} — ${s.className}'),
                  subtitle: Text('${s.day}, ${s.startTime} - ${s.endTime}\nGuru: ${s.teacherName}'),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showForm(context, edit: s),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(context, s),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Form controllers inside function to avoid leftover text between calls
  void _showForm(BuildContext ctx, {Schedule? edit}) {
    final TextEditingController classCtrl = TextEditingController(text: edit?.className ?? '');
    final TextEditingController subjectCtrl = TextEditingController(text: edit?.subject ?? '');
    final TextEditingController teacherCtrl = TextEditingController(text: edit?.teacherName ?? '');
    final TextEditingController dayCtrl = TextEditingController(text: edit?.day ?? '');
    final TextEditingController startCtrl = TextEditingController(text: edit?.startTime ?? '');
    final TextEditingController endCtrl = TextEditingController(text: edit?.endTime ?? '');

    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text(edit == null ? 'Tambah Jadwal' : 'Edit Jadwal'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: classCtrl, decoration: const InputDecoration(labelText: 'Kelas')),
              TextField(controller: subjectCtrl, decoration: const InputDecoration(labelText: 'Mata Pelajaran')),
              TextField(controller: teacherCtrl, decoration: const InputDecoration(labelText: 'Guru')),
              TextField(controller: dayCtrl, decoration: const InputDecoration(labelText: 'Hari (contoh: Senin)')),
              Row(
                children: [
                  Expanded(child: TextField(controller: startCtrl, decoration: const InputDecoration(labelText: 'Start (08:00)'))),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: endCtrl, decoration: const InputDecoration(labelText: 'End (09:30)'))),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              final className = classCtrl.text.trim();
              final subject = subjectCtrl.text.trim();
              final teacher = teacherCtrl.text.trim();
              final day = dayCtrl.text.trim();
              final start = startCtrl.text.trim();
              final end = endCtrl.text.trim();

              if (className.isEmpty || subject.isEmpty || day.isEmpty || start.isEmpty || end.isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Field wajib diisi')));
                return;
              }

              final provider = Provider.of<ScheduleProvider>(ctx, listen: false);

              if (edit == null) {
                await provider.addSchedule(Schedule(
                  id: '',
                  className: className,
                  subject: subject,
                  teacherName: teacher,
                  day: day,
                  startTime: start,
                  endTime: end,
                ));
                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Jadwal berhasil ditambahkan')));
              } else {
                await provider.updateSchedule(Schedule(
                  id: edit.id,
                  className: className,
                  subject: subject,
                  teacherName: teacher,
                  day: day,
                  startTime: start,
                  endTime: end,
                ));
                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Jadwal berhasil diupdate')));
              }

              Navigator.pop(ctx);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Schedule s) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Jadwal'),
        content: Text('Yakin ingin menghapus jadwal ${s.subject} (${s.className})?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final provider = Provider.of<ScheduleProvider>(context, listen: false);
              await provider.deleteSchedule(s.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Jadwal dihapus')));
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}