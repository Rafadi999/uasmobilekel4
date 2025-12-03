import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Tambahkan ini
import 'package:firebase_core/firebase_core.dart'; // Tambahkan ini
import '../../models/teacher.dart';

class ManageTeachersScreen extends StatelessWidget {
  ManageTeachersScreen({super.key});

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController(); // Controller Password
  final TextEditingController _name = TextEditingController();
  final TextEditingController _nip = TextEditingController();
  final TextEditingController _mapel = TextEditingController();

  final Color primaryColor = Colors.blue.shade700;
  final Color accentColor = Colors.lightBlueAccent;

  // ===========================
  // INPUT FIELD
  // ===========================
  Widget _buildField(TextEditingController c, String label, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        obscureText: isPassword, // Sembunyikan teks jika password
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
      _password.clear(); // Password tidak ditampilkan saat edit demi keamanan
    } else {
      _email.clear();
      _name.clear();
      _nip.clear();
      _mapel.clear();
      _password.clear();
    }

    showDialog(
      context: ctx,
      barrierDismissible: false, // Mencegah dialog tertutup tidak sengaja saat loading
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          edit == null ? "Tambah Guru Baru" : "Edit Data Guru",
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildField(_email, "Email Guru"),
              // Password hanya muncul saat Tambah Baru (edit == null)
              if (edit == null) 
                _buildField(_password, "Password Login", isPassword: true),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              // Validasi Sederhana
              if (_email.text.isEmpty || _name.text.isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text("Email dan Nama wajib diisi!")));
                return;
              }
              if (edit == null && _password.text.length < 6) {
                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text("Password minimal 6 karakter!")));
                return;
              }

              // Tutup dialog form dulu agar loading terlihat clean (opsional, bisa juga pakai state loading)
              Navigator.pop(ctx); 

              // Tampilkan Loading Indicator
              showDialog(
                context: ctx,
                barrierDismissible: false,
                builder: (c) => const Center(child: CircularProgressIndicator()),
              );

              try {
                if (edit == null) {
                  // =============== TAMBAH DATA BARU (AUTH + FIRESTORE) ===============
                  
                  // 1. Buat Instance Firebase App Sekunder agar Admin tidak ter-logout
                  FirebaseApp secondaryApp = await Firebase.initializeApp(
                    name: 'SecondaryApp',
                    options: Firebase.app().options,
                  );

                  try {
                    // 2. Buat User di Authentication menggunakan App Sekunder
                    UserCredential userCredential = await FirebaseAuth.instanceFor(app: secondaryApp)
                        .createUserWithEmailAndPassword(
                      email: _email.text.trim(),
                      password: _password.text.trim(),
                    );

                    String uid = userCredential.user!.uid;

                    // 3. Simpan data ke Firestore dengan ID yang sama dengan Auth UID
                    // Ini praktik terbaik agar mudah menghubungkan Auth & DB
                    await _db.collection('users').doc(uid).set({
                      'email': _email.text.trim(),
                      'nama': _name.text.trim(),
                      'nip': _nip.text.trim(),
                      'mapel': _mapel.text.trim(),
                      'role': 'guru',
                      'aktif': true,
                      'createdAt': FieldValue.serverTimestamp(),
                      'lastUpdated': FieldValue.serverTimestamp(),
                    });

                    // Hapus App Sekunder setelah selesai
                    await secondaryApp.delete();

                    Navigator.pop(ctx); // Tutup Loading
                    
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(content: Text("Akun Guru berhasil dibuat & bisa login!"), backgroundColor: Colors.green),
                    );

                  } catch (e) {
                    // Pastikan menghapus app sekunder jika terjadi error
                    await secondaryApp.delete();
                    throw e; 
                  }

                } else {
                  // =============== UPDATE DATA SAJA ===============
                  final data = {
                    'email': _email.text.trim(),
                    'nama': _name.text.trim(),
                    'nip': _nip.text.trim(),
                    'mapel': _mapel.text.trim(),
                    'lastUpdated': FieldValue.serverTimestamp(),
                  };

                  await _db.collection('users').doc(edit.id).update(data);
                  
                  Navigator.pop(ctx); // Tutup Loading
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text("Data guru berhasil diperbarui!"), backgroundColor: Colors.blue),
                  );
                }

              } catch (e) {
                Navigator.pop(ctx); // Tutup Loading jika error
                print("Error saving: $e");
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

  // ===========================
  // KONFIRMASI HAPUS (OPSIONAL: Hapus juga dari Auth?)
  // ===========================
  // Catatan: Menghapus user dari Auth lewat Client SDK sulit jika Admin yang melakukan.
  // Biasanya hanya "soft delete" (aktif: false) atau pakai Cloud Functions.
  // Di sini kita hanya hapus data Firestore sesuai kode awal.
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
                SnackBar(content: Text("${t.nama} berhasil dihapus!"), backgroundColor: Colors.red),
              );
            },
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

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
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return const Center(
              child: Text("Belum ada data guru.", style: TextStyle(fontSize: 16)),
            );
          }

          final docs = snap.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (ctx, i) {
              final t = Teacher.fromMap(docs[i].id, docs[i].data() as Map<String, dynamic>);
              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: primaryColor.withOpacity(0.15),
                    child: Icon(Icons.person, color: primaryColor),
                  ),
                  title: Text(t.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("NIP: ${t.nip} | Mapel: ${t.mapel}"),
                      Text(t.email, style: const TextStyle(color: Colors.grey)),
                    ],
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