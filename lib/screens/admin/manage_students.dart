import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Wajib untuk Auth
import 'package:firebase_core/firebase_core.dart'; // Wajib untuk Secondary App

// ===== MODEL STUDENT =====
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
  final TextEditingController _password = TextEditingController(); // Controller Password
  final TextEditingController _name = TextEditingController();
  final TextEditingController _nis = TextEditingController();
  final TextEditingController _kelas = TextEditingController();
  final TextEditingController _jurusan = TextEditingController();

  final Color primaryColor = Colors.blue.shade700;
  final Color accentColor = Colors.lightBlueAccent;

  // =========================================================
  // INPUT FIELD
  // =========================================================
  Widget _buildTextField(TextEditingController controller, String labelText, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        obscureText: isPassword, // Sembunyikan teks jika password
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
      _password.clear(); // Bersihkan password saat edit (keamanan)
    } else {
      _email.clear();
      _name.clear();
      _nis.clear();
      _kelas.clear();
      _jurusan.clear();
      _password.clear();
    }

    showDialog(
      context: ctx,
      barrierDismissible: false, // Mencegah tutup tak sengaja saat loading
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Text(
          edit == null ? 'Tambah Siswa Baru' : 'Edit Data Siswa',
          style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(_email, 'Email'),
              // Field Password hanya muncul saat tambah baru
              if (edit == null)
                _buildTextField(_password, 'Password Login', isPassword: true),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              // --- VALIDASI ---
              if (_email.text.isEmpty || _name.text.isEmpty || _nis.text.isEmpty) {
                 ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text("Email, Nama, dan NIS wajib diisi!")));
                 return;
              }
              if (edit == null && _password.text.length < 6) {
                 ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text("Password minimal 6 karakter!")));
                 return;
              }

              // Tutup dialog form
              Navigator.pop(ctx);

              // Tampilkan Loading
              showDialog(
                context: ctx,
                barrierDismissible: false,
                builder: (c) => const Center(child: CircularProgressIndicator()),
              );

              try {
                if (edit == null) {
                  // =============== TAMBAH DATA BARU (AUTH + FIRESTORE) ===============
                  
                  // 1. Buat Instance Firebase App Sekunder
                  FirebaseApp secondaryApp = await Firebase.initializeApp(
                    name: 'SecondaryAppStudent', // Nama unik bebas
                    options: Firebase.app().options,
                  );

                  try {
                    // 2. Buat User di Authentication
                    UserCredential userCredential = await FirebaseAuth.instanceFor(app: secondaryApp)
                        .createUserWithEmailAndPassword(
                      email: _email.text.trim(),
                      password: _password.text.trim(),
                    );

                    String uid = userCredential.user!.uid;

                    // 3. Simpan data ke Firestore dengan ID = UID
                    await _db.collection('users').doc(uid).set({
                      'email': _email.text.trim(),
                      'nama': _name.text.trim(),
                      'nis': _nis.text.trim(),
                      'kelas': _kelas.text.trim(),
                      'jurusan': _jurusan.text.trim(),
                      'role': 'siswa', // Role diset otomatis
                      'aktif': true,
                      'createdAt': FieldValue.serverTimestamp(),
                      'lastUpdated': FieldValue.serverTimestamp(),
                    });

                    // Hapus App Sekunder
                    await secondaryApp.delete();

                    Navigator.pop(ctx); // Tutup Loading
                    
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(content: Text("Akun Siswa berhasil dibuat & bisa login!"), backgroundColor: Colors.green),
                    );

                  } catch (e) {
                    await secondaryApp.delete();
                    throw e; 
                  }

                } else {
                  // =============== UPDATE DATA SAJA ===============
                  final data = {
                    'email': _email.text.trim(),
                    'nama': _name.text.trim(),
                    'nis': _nis.text.trim(),
                    'kelas': _kelas.text.trim(),
                    'jurusan': _jurusan.text.trim(),
                    'lastUpdated': FieldValue.serverTimestamp(),
                  };

                  await _db.collection('users').doc(edit.id).update(data);

                  Navigator.pop(ctx); // Tutup Loading
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text("Perubahan data siswa berhasil disimpan!"), backgroundColor: Colors.blue),
                  );
                }

              } catch (e) {
                Navigator.pop(ctx); // Tutup Loading
                print("Error: $e");
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(content: Text("Gagal menyimpan: $e"), backgroundColor: Colors.red),
                );
              }
            },
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await _db.collection('users').doc(s.id).delete();
              Navigator.pop(ctx);

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
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return const Center(
              child: Text("Belum ada data siswa.", style: TextStyle(fontSize: 16)),
            );
          }

          final docs = snap.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (ctx, i) {
              final s = Student.fromMap(docs[i].id, docs[i].data() as Map<String, dynamic>);

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 12),
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