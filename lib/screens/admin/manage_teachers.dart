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

  final Color primaryColor = Colors.blue.shade700;
  final Color accentColor = Colors.lightBlueAccent;

  // ===========================
  // INPUT FIELD
  // ===========================
  Widget _buildField(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
        ),
      ),
    );
  }

  // ===========================
  // FORM ADD / EDIT
  // ===========================
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          edit == null ? "Tambah Guru Baru" : "Edit Data Guru",
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _buildField(_email, "Email Guru"),
              _buildField(_name, "Nama Guru"),
              _buildField(_nip, "NIP"),
              _buildField(_mapel, "Mata Pelajaran"),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
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
                'lastUpdated': FieldValue.serverTimestamp(),
              };

              try {
                if (edit == null) {
                  // =============== TAMBAH DATA BARU ===============
                  await _db.collection('users').add({
                    ...data,
                    'createdAt': FieldValue.serverTimestamp(),
                  });

                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(
                      content: const Text("Data guru berhasil ditambahkan!"),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.all(16),
                      duration: Duration(seconds: 2),
                    ),
                  );
                } else {
                  // =============== UPDATE DATA TANPA createdAt ===============
                  await _db.collection('users').doc(edit.id).update(data);

                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(
                      content: const Text("Data guru berhasil diperbarui!"),
                      backgroundColor: Colors.blue,
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.all(16),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }

                Navigator.pop(ctx);
              } catch (e) {
                print("Error saving: $e");
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text(edit == null ? "Simpan" : "Update"),
          ),
        ],
      ),
    );
  }

  // ===========================
  // KONFIRMASI HAPUS
  // ===========================
  void _confirmDelete(BuildContext context, Teacher t) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Hapus Guru"),
        content: Text("Yakin ingin menghapus ${t.nama}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await _db.collection('users').doc(t.id).delete();
              Navigator.pop(ctx);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("${t.nama} berhasil dihapus!"),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(16),
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

  // ===========================
  // UI LIST GURU
  // ===========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kelola Data Guru"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: accentColor,
        onPressed: () => _showForm(context),
        child: const Icon(Icons.person_add_alt_1_rounded, size: 28),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: _db.collection('users').where('role', isEqualTo: 'guru').snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snap.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text("Belum ada data guru.", style: TextStyle(fontSize: 16)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (ctx, i) {
              final t = Teacher.fromMap(docs[i].id, docs[i].data() as Map<String, dynamic>);

              return Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: primaryColor.withOpacity(0.15),
                    child: Icon(Icons.person, color: primaryColor),
                  ),
                  title: Text(
                    t.nama,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("NIP: ${t.nip}"),
                        Text("Mapel: ${t.mapel}"),
                        Text("Email: ${t.email}",
                            style: const TextStyle(
                                fontStyle: FontStyle.italic, fontSize: 12)),
                      ],
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.orange.shade700),
                        onPressed: () => _showForm(context, edit: t),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_forever, color: Colors.red),
                        onPressed: () => _confirmDelete(context, t),
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
}
