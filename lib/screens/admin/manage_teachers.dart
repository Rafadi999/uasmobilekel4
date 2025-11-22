import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/teacher.dart';

class ManageTeachersScreen extends StatelessWidget {
  ManageTeachersScreen({super.key});

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final TextEditingController _email = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _nip = TextEditingController();
  final TextEditingController _mapel = TextEditingController();

  void _showForm(BuildContext ctx, {Teacher? edit}) {
    if (edit != null) {
      _email.text = edit.email;
      _name.text = edit.nama;
      _nip.text = edit.nip;
      _mapel.text = edit.mapel;
    } else {
      _email.clear();
      _name.clear();
      _nip.clear();
      _mapel.clear();
    }

    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text(edit == null ? 'Tambah Guru' : 'Edit Guru'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: _name, decoration: const InputDecoration(labelText: 'Nama')),
            TextField(controller: _nip, decoration: const InputDecoration(labelText: 'NIP')),
            TextField(controller: _mapel, decoration: const InputDecoration(labelText: 'Mata Pelajaran')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final data = {
                'email': _email.text.trim(),
                'nama': _name.text.trim(),
                'nip': _nip.text.trim(),
                'mapel': _mapel.text.trim(),
                'role': 'guru',
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

  void _confirmDelete(BuildContext context, Teacher t) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Guru'),
        content: Text('Yakin ingin menghapus ${t.nama}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await _db.collection('users').doc(t.id).delete();
              Navigator.pop(ctx);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Data Guru')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _db.collection('users').where('role', isEqualTo: 'guru').snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snap.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (ctx, i) {
              final d = docs[i];
              final t = Teacher.fromMap(d.id, d.data() as Map<String, dynamic>);
              return ListTile(
                title: Text(t.nama),
                subtitle: Text("NIP: ${t.nip} | ${t.mapel}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showForm(context, edit: t),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(context, t),
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