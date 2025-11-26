import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/schedule.dart';
import '../../providers/schedule_provider.dart';

class ManageScheduleScreen extends StatelessWidget {
  final Color primaryColor = Colors.blue.shade700;
  final Color accentColor = Colors.lightBlueAccent;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ScheduleProvider>(context);

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
                      style:
                          const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                          icon:
                              Icon(Icons.edit, color: Colors.orange.shade700),
                          onPressed: () => _openForm(context, schedule: s),
                        ),
                        IconButton(
                          icon:
                              const Icon(Icons.delete_forever, color: Colors.red),
                          onPressed: () => _confirmDelete(context, s),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  // ====================================
  // DELETE CONFIRMATION
  // ====================================
  void _confirmDelete(BuildContext context, Schedule s) {
    final provider = Provider.of<ScheduleProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Hapus Jadwal"),
        content: Text(
            "Yakin ingin menghapus jadwal ${s.pelajaran} untuk kelas ${s.namakelas}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              provider.deleteSchedule(s.id);

              Navigator.pop(ctx);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Jadwal berhasil dihapus!"),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(16),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  // ====================================
  // FORM ADD / EDIT
  // ====================================
  void _openForm(BuildContext context, {Schedule? schedule}) {
    final provider = Provider.of<ScheduleProvider>(context, listen: false);

    // Controller nilai form
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
        title: Text(
          schedule == null ? "Tambah Jadwal Baru" : "Edit Jadwal",
          style:
              const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        content: SingleChildScrollView(
          child: Column(
            children: [
              _buildField(guruCtrl, "Nama Guru"),
              _buildField(pelajaranCtrl, "Mata Pelajaran"),
              _buildField(hariCtrl, "Hari"),
              _buildField(kelasCtrl, "Nama Kelas"),
              _buildField(mulaiCtrl, "Waktu Mulai (Contoh: 08.00)"),
              _buildField(selesaiCtrl, "Waktu Selesai (Contoh: 10.00)"),
            ],
          ),
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white),
            onPressed: () {
              if (schedule == null) {
                // ADD SCHEDULE
                provider.addSchedule(
                  Schedule(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    guru: guruCtrl.text,
                    pelajaran: pelajaranCtrl.text,
                    hari: hariCtrl.text,
                    idguru: "none",
                    idkelas: "none",
                    namakelas: kelasCtrl.text,
                    role: "all",
                    waktumulai: mulaiCtrl.text,
                    waktuselesai: selesaiCtrl.text,
                  ),
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Jadwal berhasil ditambahkan!"),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.all(16),
                  ),
                );
              } else {
                // UPDATE SCHEDULE
                provider.updateSchedule(
                  Schedule(
                    id: schedule.id,
                    guru: guruCtrl.text,
                    pelajaran: pelajaranCtrl.text,
                    hari: hariCtrl.text,
                    idguru: schedule.idguru,
                    idkelas: schedule.idkelas,
                    namakelas: kelasCtrl.text,
                    role: schedule.role,
                    waktumulai: mulaiCtrl.text,
                    waktuselesai: selesaiCtrl.text,
                  ),
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Jadwal berhasil diperbarui!"),
                    backgroundColor: Colors.blue,
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.all(16),
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

  // ==============================
  // CUSTOM TEXT FIELD
  // ==============================
  Widget _buildField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: Colors.blue.shade700, width: 2),
          ),
        ),
      ),
    );
  }
}
