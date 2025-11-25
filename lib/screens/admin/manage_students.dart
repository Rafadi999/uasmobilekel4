import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ===== MODEL STUDENT (WAJIB ADA) =====
class Student {
  final String id;
  final String email;
  final String nama;
  final String nis;
  final String kelas;
  final String jurusan;
  final bool aktif;
  final Object? createdAt;

  Student({
    required this.id,
    required this.email,
    required this.nama,
    required this.nis,
    required this.kelas,
    required this.jurusan,
    required this.aktif,
    this.createdAt,
  });

  factory Student.fromMap(String id, Map<String, dynamic> data) {
    return Student(
      id: id,
      email: data['email'] ?? '',
      nama: data['nama'] ?? 'N/A',
      nis: data['nis'] ?? 'N/A',
      kelas: data['kelas'] ?? 'N/A',
      jurusan: data['jurusan'] ?? 'N/A',
      aktif: data['aktif'] ?? true,
      createdAt: data['createdAt'],
    );
  }
}

// ===== MAIN SCREEN =====
class ManageStudentsScreen extends StatelessWidget {
  ManageStudentsScreen({super.key});

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final TextEditingController _email = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _nis = TextEditingController();
  final TextEditingController _kelas = TextEditingController();
  final TextEditingController _jurusan = TextEditingController();

  final Color primaryColor = Colors.blue.shade700;
  final Color accentColor = Colors.lightBlueAccent;

  // =========================================================
  // INPUT FIELD
  // =========================================================
  Widget _buildTextField(TextEditingController controller, String labelText) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  // =========================================================
  // FORM ADD / EDIT
  // =========================================================
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Text(
          edit == null ? 'Tambah Siswa Baru' : 'Edit Data Siswa',
          style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
        ),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField(_email, 'Email'),
              _buildTextField(_name, 'Nama Lengkap'),
              _buildTextField(_nis, 'NIS'),
              _buildTextField(_kelas, 'Kelas'),
              _buildTextField(_jurusan, 'Jurusan'),
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
              if (_name.text.isEmpty || _nis.text.isEmpty) return;

              final data = {
                'email': _email.text.trim(),
                'nama': _name.text.trim(),
                'nis': _nis.text.trim(),
                'kelas': _kelas.text.trim(),
                'jurusan': _jurusan.text.trim(),
                'role': 'siswa',
                'aktif': true,
                'lastUpdated': FieldValue.serverTimestamp(),
                'createdAt': edit == null
                    ? FieldValue.serverTimestamp()
                    : edit.createdAt,
              };

              try {
                if (edit == null) {
                  await _db.collection('users').add(data);

                  // ✔ SNACKBAR DATA BARU
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(
                      content:
                          const Text("Data siswa berhasil ditambahkan!"),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.all(16),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                } else {
                  await _db.collection('users').doc(edit.id).update(data);

                  // ✔ SNACKBAR UPDATE
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(
                      content:
                          const Text("Perubahan data siswa berhasil disimpan!"),
                      backgroundColor: Colors.blue,
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.all(16),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }

                Navigator.pop(ctx);
              } catch (e) {
                print("Error: $e");
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

  // =========================================================
  // DELETE CONFIRMATION
  // =========================================================
  void _showDeleteConfirmation(BuildContext context, Student s) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Konfirmasi Hapus"),
        content: Text("Yakin ingin menghapus data siswa ${s.nama}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              await _db.collection('users').doc(s.id).delete();
              Navigator.pop(ctx);

              // ✔ SNACKBAR HAPUS
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("${s.nama} berhasil dihapus!"),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(16),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // BUILD UI
  // =========================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kelola Data Siswa"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context),
        backgroundColor: accentColor,
        child: const Icon(Icons.person_add_alt_1_rounded, size: 28),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: _db.collection('users').where('role', isEqualTo: 'siswa').snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snap.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text("Belum ada data siswa.", style: TextStyle(fontSize: 16)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (ctx, i) {
              final s = Student.fromMap(docs[i].id, docs[i].data() as Map<String, dynamic>);

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
                    s.nama,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("NIS: ${s.nis}"),
                        Text("Kelas: ${s.kelas} - ${s.jurusan}"),
                        Text("Email: ${s.email}",
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 12,
                            )),
                      ],
                    ),
                  ),
                  isThreeLine: true,

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.orange.shade700),
                        onPressed: () => _showForm(context, edit: s),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_forever, color: Colors.red),
                        onPressed: () => _showDeleteConfirmation(context, s),
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
