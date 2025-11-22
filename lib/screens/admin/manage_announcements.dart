import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/announcement.dart';
import '../../providers/announcement_provider.dart';

class ManageAnnouncementScreen extends StatefulWidget {
  const ManageAnnouncementScreen({super.key});

  @override
  State<ManageAnnouncementScreen> createState() => _ManageAnnouncementScreenState();
}

class _ManageAnnouncementScreenState extends State<ManageAnnouncementScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController msgController = TextEditingController();

  void showForm({Announcement? announcement}) {
    if (announcement != null) {
      titleController.text = announcement.title;
      msgController.text = announcement.message;
    } else {
      titleController.clear();
      msgController.clear();
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(announcement == null ? "Tambah Pengumuman" : "Edit Pengumuman"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Judul"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: msgController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: "Isi Pesan"),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal")
          ),
          ElevatedButton(
            onPressed: () {
              if (announcement == null) {
                Provider.of<AnnouncementProvider>(context, listen: false)
                    .addAnnouncement(
                  Announcement(
                    title: titleController.text,
                    message: msgController.text,
                    date: DateTime.now(),
                  ),
                );
              } else {
                Provider.of<AnnouncementProvider>(context, listen: false)
                    .updateAnnouncement(
                  Announcement(
                    id: announcement.id,
                    title: titleController.text,
                    message: msgController.text,
                    date: announcement.date,
                  ),
                );
              }
              Navigator.pop(context);
            },
            child: const Text("Simpan"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<AnnouncementProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Manage Pengumuman")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showForm(),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Announcement>>(
        stream: prov.getAnnouncements(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final data = snapshot.data!;
          if (data.isEmpty) {
            return const Center(child: Text("Belum ada pengumuman"));
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (_, i) {
              final ann = data[i];
              return ListTile(
                title: Text(ann.title),
                subtitle: Text(ann.message),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => showForm(announcement: ann),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => prov.deleteAnnouncement(ann.id!),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}