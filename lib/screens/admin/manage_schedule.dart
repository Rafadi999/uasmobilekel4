import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/schedule.dart';
import '../../providers/schedule_provider.dart';

class ManageScheduleScreen extends StatelessWidget {
  const ManageScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ScheduleProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Jadwal')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Schedule>>(
        stream: provider.getSchedules(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snap.hasData || snap.data!.isEmpty) return const Center(child: Text('Belum ada jadwal'));

          final items = snap.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            itemBuilder: (ctx, i) {
              final s = items[i];
              return Card(
                child: ListTile(
                  title: Text("${s.pelajaran} — ${s.namakelas}"),
                  subtitle: Text("${s.hari}, ${s.waktumulai} - ${s.waktuselesai}\nGuru: ${s.guru}"),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit), onPressed: () => _openForm(context, edit: s)),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _confirmDelete(context, s)),
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

  void _openForm(BuildContext context, {Schedule? edit}) {
    final classCtrl = TextEditingController(text: edit?.namakelas ?? '');
    final subjectCtrl = TextEditingController(text: edit?.pelajaran ?? '');
    final teacherCtrl = TextEditingController(text: edit?.guru ?? '');
    final dayCtrl = TextEditingController(text: edit?.hari ?? '');
    final startCtrl = TextEditingController(text: edit?.waktumulai ?? '');
    final endCtrl = TextEditingController(text: edit?.waktuselesai ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(edit == null ? 'Tambah Jadwal' : 'Edit Jadwal'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: classCtrl, decoration: const InputDecoration(labelText: 'Kelas')),
              TextField(controller: subjectCtrl, decoration: const InputDecoration(labelText: 'Mata Pelajaran')),
              TextField(controller: teacherCtrl, decoration: const InputDecoration(labelText: 'Guru')),
              TextField(controller: dayCtrl, decoration: const InputDecoration(labelText: 'Hari')),
              Row(
                children: [
                  Expanded(child: TextField(controller: startCtrl, decoration: const InputDecoration(labelText: 'Mulai'))),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: endCtrl, decoration: const InputDecoration(labelText: 'Selesai'))),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              final provider = Provider.of<ScheduleProvider>(context, listen: false);
              final namakelas = classCtrl.text.trim();
              final pelajaran = subjectCtrl.text.trim();
              final guru = teacherCtrl.text.trim();
              final hari = dayCtrl.text.trim();
              final waktumulai = startCtrl.text.trim();
              final waktuselesai = endCtrl.text.trim();

              if (namakelas.isEmpty || pelajaran.isEmpty || guru.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Kelas, Pelajaran, dan Guru wajib diisi'))
                );
                return;
              }

              if (edit == null) {
                await provider.addSchedule(Schedule(
                  id: '',
                  namakelas: namakelas,
                  pelajaran: pelajaran,
                  guru: guru,
                  hari: hari,
                  waktumulai: waktumulai,
                  waktuselesai: waktuselesai,
                ));
              } else {
                await provider.updateSchedule(Schedule(
                  id: edit.id,
                  namakelas: namakelas,
                  pelajaran: pelajaran,
                  guru: guru,
                  hari: hari,
                  waktumulai: waktumulai,
                  waktuselesai: waktuselesai,
                ));
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
        title: const Text('Hapus Jadwal?'),
        content: Text("Hapus ${s.pelajaran} - ${s.namakelas}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              final provider = Provider.of<ScheduleProvider>(context, listen: false);
              await provider.deleteSchedule(s.id);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}