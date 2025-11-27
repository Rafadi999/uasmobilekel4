// lib/screens/admin/manage_schedule_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/schedule.dart';
import '../../providers/schedule_provider.dart';

class ManageScheduleScreen extends StatefulWidget {
  const ManageScheduleScreen({Key? key}) : super(key: key);

  @override
  _ManageScheduleScreenState createState() => _ManageScheduleScreenState();
}

class _ManageScheduleScreenState extends State<ManageScheduleScreen> {
  final Color primaryColor = Colors.blue.shade700;
  final Color accentColor = Colors.lightBlueAccent;

  @override
  void initState() {
    super.initState();
    // Pastikan provider telah di-provide di parent (MultiProvider)
    Future.microtask(() {
      Provider.of<ScheduleProvider>(context, listen: false)
          .loadSchedules('all'); // 'all' or 'admin' -> no filter
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ScheduleProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Kelola Jadwal Pelajaran"),
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            centerTitle: true,
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: accentColor,
            onPressed: () => _openForm(context),
            child: const Icon(Icons.add, size: 28),
          ),
          body: provider.schedules.isEmpty
              ? const Center(
                  child: Text(
                    "Belum ada jadwal.",
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.schedules.length,
                  itemBuilder: (context, index) {
                    final s = provider.schedules[index];

                    return Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: primaryColor.withOpacity(0.15),
                          child: Icon(Icons.schedule, color: primaryColor),
                        ),
                        title: Text(
                          "${s.pelajaran} - ${s.namakelas}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Guru: ${s.guru}"),
                              Text("Hari: ${s.hari}"),
                              Text("Waktu: ${s.waktumulai} - ${s.waktuselesai}"),
                            ],
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.orange.shade700),
                              onPressed: () => _openForm(context, schedule: s),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_forever, color: Colors.red),
                              onPressed: () => _confirmDelete(context, s),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, Schedule s) {
    final provider = Provider.of<ScheduleProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Hapus Jadwal"),
        content: Text("Yakin ingin menghapus jadwal ${s.pelajaran} untuk kelas ${s.namakelas}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await provider.deleteSchedule(s.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Jadwal berhasil dihapus!"),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.all(16),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  void _openForm(BuildContext context, {Schedule? schedule}) {
    final provider = Provider.of<ScheduleProvider>(context, listen: false);

    final guruCtrl = TextEditingController(text: schedule?.guru ?? "");
    final pelajaranCtrl = TextEditingController(text: schedule?.pelajaran ?? "");
    final hariCtrl = TextEditingController(text: schedule?.hari ?? "");
    final kelasCtrl = TextEditingController(text: schedule?.namakelas ?? "");
    final mulaiCtrl = TextEditingController(text: schedule?.waktumulai ?? "");
    final selesaiCtrl = TextEditingController(text: schedule?.waktuselesai ?? "");

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(schedule == null ? "Tambah Jadwal Baru" : "Edit Jadwal",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _buildField(guruCtrl, "Nama Guru"),
              _buildField(pelajaranCtrl, "Mata Pelajaran"),
              _buildField(hariCtrl, "Hari"),
              _buildField(kelasCtrl, "Nama Kelas"),
              _buildField(mulaiCtrl, "Waktu Mulai (Contoh: 08:00)"),
              _buildField(selesaiCtrl, "Waktu Selesai (Contoh: 10:00)"),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700, foregroundColor: Colors.white),
            onPressed: () async {
              if (schedule == null) {
                // ADD: createdAt null -> serverTimestamp set in toMap()
                await provider.addSchedule(
                  Schedule(
                    id: "", // empty here; Firestore doc id used on read
                    guru: guruCtrl.text,
                    idguru: "none",
                    hari: hariCtrl.text,
                    pelajaran: pelajaranCtrl.text,
                    waktumulai: mulaiCtrl.text,
                    waktuselesai: selesaiCtrl.text,
                    idkelas: "none",
                    namakelas: kelasCtrl.text,
                    role: "all",
                    createdAt: null,
                  ),
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Jadwal berhasil ditambahkan!"),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.all(16),
                  ),
                );
              } else {
                // UPDATE: keep existing createdAt
                await provider.updateSchedule(
                  Schedule(
                    id: schedule.id,
                    guru: guruCtrl.text,
                    idguru: schedule.idguru,
                    hari: hariCtrl.text,
                    pelajaran: pelajaranCtrl.text,
                    waktumulai: mulaiCtrl.text,
                    waktuselesai: selesaiCtrl.text,
                    idkelas: schedule.idkelas,
                    namakelas: kelasCtrl.text,
                    role: schedule.role,
                    createdAt: schedule.createdAt,
                  ),
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Jadwal berhasil diperbarui!"),
                    backgroundColor: Colors.blue,
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.all(16),
                  ),
                );
              }

              Navigator.pop(ctx);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
          ),
        ),
      ),
    );
  }
}