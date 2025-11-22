import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/announcement.dart';
import '../../providers/announcement_provider.dart';

class ManageAnnouncementsScreen extends StatelessWidget {
  const ManageAnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kelola Pengumuman")),
      body: Consumer<AnnouncementProvider>(
        builder: (context, provider, child) {
          if (provider.announcements.isEmpty) {
            return const Center(child: Text("Belum ada pengumuman"));
          }

          return ListView.builder(
            itemCount: provider.announcements.length,
            itemBuilder: (context, index) {
              final data = provider.announcements[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(data.nama),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data.tentang),
                      Text(
                        "Ditujukan: ${data.targetRole == 'all' ? 'Semua' : data.targetRole == 'guru' ? 'Guru' : 'Siswa'}",
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddEditAnnouncementScreen(
                                announcement: data,
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          provider.delete(data.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddEditAnnouncementScreen(),
            ),
          );
        },
      ),
    );
  }
}

class AddEditAnnouncementScreen extends StatefulWidget {
  final Announcement? announcement;
  const AddEditAnnouncementScreen({super.key, this.announcement});

  @override
  State<AddEditAnnouncementScreen> createState() =>
      _AddEditAnnouncementScreenState();
}

class _AddEditAnnouncementScreenState extends State<AddEditAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _tentangController = TextEditingController();
  String _targetRole = "all";

  @override
  void initState() {
    super.initState();
    if (widget.announcement != null) {
      _namaController.text = widget.announcement!.nama;
      _tentangController.text = widget.announcement!.tentang;
      _targetRole = widget.announcement!.targetRole;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AnnouncementProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.announcement == null
            ? "Tambah Pengumuman"
            : "Edit Pengumuman"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: "Judul Pengumuman"),
                validator: (value) =>
                    value!.isEmpty ? "Judul tidak boleh kosong" : null,
              ),
              TextFormField(
                controller: _tentangController,
                decoration: const InputDecoration(labelText: "Isi Pengumuman"),
                validator: (value) =>
                    value!.isEmpty ? "Isi tidak boleh kosong" : null,
              ),
              DropdownButtonFormField(
                value: _targetRole,
                decoration: const InputDecoration(labelText: "Ditujukan Untuk"),
                items: const [
                  DropdownMenuItem(value: "all", child: Text("Semua")),
                  DropdownMenuItem(value: "guru", child: Text("Guru")),
                  DropdownMenuItem(value: "siswa", child: Text("Siswa")),
                ],
                onChanged: (value) {
                  setState(() {
                    _targetRole = value.toString();
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;

                  final newData = Announcement(
                    id: widget.announcement?.id ?? '',
                    nama: _namaController.text,
                    tentang: _tentangController.text,
                    dibuat: widget.announcement?.dibuat ?? DateTime.now(),
                    targetRole: _targetRole,
                  );

                  if (widget.announcement == null) {
                    await provider.add(newData);
                  } else {
                    await provider.update(newData);
                  }

                  Navigator.pop(context);
                },
                child: Text(
                    widget.announcement == null ? "Tambah" : "Simpan Perubahan"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}