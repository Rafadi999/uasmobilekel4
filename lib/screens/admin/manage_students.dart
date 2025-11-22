import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/student.dart';

class ManageStudentsScreen extends StatelessWidget {
  ManageStudentsScreen({super.key});

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final TextEditingController _email = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _nis = TextEditingController();
  final TextEditingController _kelas = TextEditingController();
  final TextEditingController _jurusan = TextEditingController();

  void _showForm(BuildContext ctx, {Student? edit}) {
    if (edit != null) {
      _email.text = edit.email;
      _name.text = edit.nama;
      _nis.text = edit.nis;
      _kelas.text = edit.kelas;
      _jurusan.text = edit.jurusan;
    } else {
      _email.clear();
      _name.clear();
      _nis.clear();
      _kelas.clear();
      _jurusan.clear();
    }

    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text(edit == null ? 'Tambah Siswa' : 'Edit Siswa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: _name, decoration: const InputDecoration(labelText: 'Nama')),
            TextField(controller: _nis, decoration: const InputDecoration(labelText: 'NIS')),
            TextField(controller: _kelas, decoration: const InputDecoration(labelText: 'Kelas')),
            TextField(controller: _jurusan, decoration: const InputDecoration(labelText: 'Jurusan')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              final data = {
                'email': _email.text.trim(),
                'nama': _name.text.trim(),
                'nis': _nis.text.trim(),
                'kelas': _kelas.text.trim(),
                'jurusan': _jurusan.text.trim(),
                'role': 'siswa',
                'aktif': true,
                'createdAt': DateTime.now()
              };

              if (edit == null) {
                await _db.collection('users').add(data);
              } else {
                await _db.collection('users').doc(edit.id).update(data);
              }

              Navigator.pop(ctx);
            },
            child: const Text('Simpan'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Data Siswa')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _db.collection('users').where('role', isEqualTo: 'siswa').snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snap.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (ctx, i) {
              final d = docs[i];
              final s = Student.fromMap(d.id, d.data() as Map<String, dynamic>);
              return ListTile(
                title: Text(s.nama),
                subtitle: Text("NIS: ${s.nis} | ${s.kelas}-${s.jurusan}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showForm(context, edit: s),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Hapus Siswa'),
                            content: Text('Yakin ingin menghapus ${s.nama}?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Batal', style: TextStyle(color: Colors.black)),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  await _db.collection('users').doc(s.id).delete();
                                  Navigator.pop(ctx);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text('Hapus', style: TextStyle(color: Colors.black)),
                              ),
                            ],
                          ),
                        );
                      },
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