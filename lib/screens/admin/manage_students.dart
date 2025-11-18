import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/student.dart';
import '../../services/firestore_service.dart';

class ManageStudentsScreen extends StatelessWidget {
  ManageStudentsScreen({super.key});
  final FirestoreService _svc = FirestoreService();

  final TextEditingController _nis = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _kelas = TextEditingController();
  final TextEditingController _jurusan = TextEditingController();

  void _showForm(BuildContext ctx, {Student? edit}) {
    if (edit != null) {
      _nis.text = edit.nis;
      _name.text = edit.name;
      _kelas.text = edit.kelas;
      _jurusan.text = edit.jurusan;
    } else {
      _nis.clear(); _name.clear(); _kelas.clear(); _jurusan.clear();
    }

    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text(edit == null ? 'Tambah Siswa' : 'Edit Siswa'),
        content: SingleChildScrollView(
          child: Column(children: [
            TextField(controller: _nis, decoration: const InputDecoration(labelText: 'NIS')),
            TextField(controller: _name, decoration: const InputDecoration(labelText: 'Nama')),
            TextField(controller: _kelas, decoration: const InputDecoration(labelText: 'Kelas')),
            TextField(controller: _jurusan, decoration: const InputDecoration(labelText: 'Jurusan')),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(onPressed: () async {
            final data = {
              'nis': _nis.text.trim(),
              'name': _name.text.trim(),
              'kelas': _kelas.text.trim(),
              'jurusan': _jurusan.text.trim(),
              'createdAt': DateTime.now().toIso8601String()
            };
            if (edit == null) {
              await _svc.addData('students', data);
            } else {
              await _svc.updateData('students', edit.id, data);
            }
            Navigator.pop(ctx);
          }, child: const Text('Simpan'))
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Siswa')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('students').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final docs = snap.data?.docs ?? [];
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (ctx, i) {
              final d = docs[i];
              final s = Student.fromMap(d.id, d.data() as Map<String,dynamic>);
              return ListTile(
                title: Text(s.name),
                subtitle: Text('NIS: ${s.nis} • ${s.kelas} ${s.jurusan}'),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  IconButton(icon: const Icon(Icons.edit), onPressed: () => _showForm(context, edit: s)),
                  IconButton(icon: const Icon(Icons.delete), onPressed: () => _svc.deleteData('students', s.id)),
                ]),
              );
            },
          );
        }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}