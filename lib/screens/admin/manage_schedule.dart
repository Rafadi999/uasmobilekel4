import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/schedule.dart';
import '../../providers/schedule_provider.dart';

class ManageScheduleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ScheduleProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Manage Schedule")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context),
        child: Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: provider.schedules.length,
        itemBuilder: (context, index) {
          final s = provider.schedules[index];
          return ListTile(
            title: Text("${s.pelajaran} - ${s.namakelas}"),
            subtitle: Text("${s.hari}, ${s.waktumulai} - ${s.waktuselesai}"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _openForm(context, schedule: s),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => provider.deleteSchedule(s.id),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openForm(BuildContext context, {Schedule? schedule}) {
    final provider = Provider.of<ScheduleProvider>(context, listen: false);

    final guruCtrl = TextEditingController(text: schedule?.guru);
    final pelajaranCtrl = TextEditingController(text: schedule?.pelajaran);
    final hariCtrl = TextEditingController(text: schedule?.hari);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(schedule == null ? "Tambah Jadwal" : "Edit Jadwal"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: guruCtrl, decoration: InputDecoration(labelText: "Guru")),
            TextField(controller: pelajaranCtrl, decoration: InputDecoration(labelText: "Pelajaran")),
            TextField(controller: hariCtrl, decoration: InputDecoration(labelText: "Hari")),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              if (schedule == null) {
                provider.addSchedule(
                  Schedule(
                    id: "",
                    guru: guruCtrl.text,
                    pelajaran: pelajaranCtrl.text,
                    hari: hariCtrl.text,
                    idguru: "guru123",
                    idkelas: "kelas_12_ipa_1",
                    namakelas: "XII IPA 2",
                    role: "all",
                    waktumulai: "10.00",
                    waktuselesai: "12.00",
                  ),
                );
              } else {
                provider.updateSchedule(
                  Schedule(
                    id: schedule.id,
                    guru: guruCtrl.text,
                    pelajaran: pelajaranCtrl.text,
                    hari: hariCtrl.text,
                    idguru: schedule.idguru,
                    idkelas: schedule.idkelas,
                    namakelas: schedule.namakelas,
                    role: schedule.role,
                    waktumulai: schedule.waktumulai,
                    waktuselesai: schedule.waktuselesai,
                  ),
                );
              }

              Navigator.pop(context);
            },
            child: Text("Simpan"),
          ),
        ],
      ),
    );
  }
}