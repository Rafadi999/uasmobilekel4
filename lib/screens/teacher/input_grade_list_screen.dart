import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/student.dart';
import '../nilai/input_nilai_form.dart';

class InputGradeListScreen extends StatelessWidget {
  final String subject;
  final String teacherId;

  const InputGradeListScreen({
    super.key,
    required this.subject,
    required this.teacherId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Pilih Siswa - $subject",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),

      body: Stack(
        children: [
          // 🌿 Gradient hijau toska
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1E8A6B),
                  Color(0xFF0E5F4B),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // ✨ Circle dekorasi blur
          Positioned(
            top: -120,
            left: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            bottom: -130,
            right: -90,
            child: Container(
              width: 230,
              height: 230,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),

          // MAIN CONTENT
          SafeArea(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .where("role", isEqualTo: "siswa")
                  .orderBy("nama")
                  .snapshots(),
              builder: (context, snap) {
                if (snap.hasError) {
                  return Center(
                    child: Text(
                      "Terjadi error: ${snap.error}",
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }

                if (!snap.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                final students = snap.data!.docs;

                if (students.isEmpty) {
                  return const Center(
                    child: Text(
                      "Tidak ada siswa",
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  itemCount: students.length,
                  itemBuilder: (context, i) {
                    final s = students[i];

                    final siswa = Student(
                      id: s.id,
                      nis: s.get("nis") ?? '',
                      nama: s.get("nama") ?? '',
                      kelas: s.get("kelas") ?? '',
                      email: s.get("email") ?? '',
                      jurusan: s.get("jurusan") ?? '',
                    );

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 9, sigmaY: 9),
                          child: Material(
                            color: Colors.white.withOpacity(0.18),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => InputNilaiForm(
                                      siswa: siswa,
                                      mapel: subject,
                                    ),
                                  ),
                                );
                              },
                              splashColor: Colors.white.withOpacity(0.15),
                              highlightColor: Colors.white.withOpacity(0.05),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                child: Row(
                                  children: [
                                    // Avatar
                                    CircleAvatar(
                                      radius: 26,
                                      backgroundColor:
                                          Colors.tealAccent.withOpacity(0.22),
                                      child: const Icon(Icons.person,
                                          color: Colors.white, size: 28),
                                    ),
                                    const SizedBox(width: 16),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            siswa.nama,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "Kelas: ${siswa.kelas}",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color:
                                                  Colors.white.withOpacity(0.85),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    Icon(Icons.arrow_forward_ios_rounded,
                                        color: Colors.white.withOpacity(0.9),
                                        size: 20),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
