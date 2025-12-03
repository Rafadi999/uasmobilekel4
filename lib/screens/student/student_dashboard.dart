import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Tambahkan import ini
import '../../providers/theme_provider.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import '../teacher/announcement_screen.dart';
import 'student_schedule.dart';
import 'nilai/student_nilai_screen.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final isDark = theme.isDarkMode;

    // Ambil current user dari Auth
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        toolbarHeight: 70,
        title: const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text(
            "Portal Siswa",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ),
        actions: [
          _GlassIconButton(
            icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            onTap: theme.toggleTheme,
          ),
          const SizedBox(width: 8),
          _GlassIconButton(
            icon: Icons.logout_rounded,
            onTap: () async {
              await AuthService().logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: Stack(
        children: [
          // 1. Background Gradient (Teal/Tosca)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF0F2027), const Color(0xFF203A43)]
                    : [Colors.teal.shade400, Colors.teal.shade800],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // 2. Decorative Circles
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),

          // 3. MAIN CONTENT
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // --- HEADER PROFILE CARD (TERHUBUNG KE DATABASE) ---
                    StreamBuilder<DocumentSnapshot>(
                      // Pastikan nama collection Anda benar ('users' atau 'students')
                      stream: FirebaseFirestore.instance
                          .collection('users') 
                          .doc(currentUser?.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        // Default values jika loading
                        String displayName = "Memuat...";
                        String className = "...";

                        if (snapshot.hasData && snapshot.data!.exists) {
                          // Ambil data dari dokumen
                          final data = snapshot.data!.data() as Map<String, dynamic>;
                          // Gunakan field 'nama' sesuai database Anda
                          displayName = data['nama'] ?? data['name'] ?? "Siswa";
                          // Gunakan field 'kelas' sesuai database Anda
                          className = data['kelas'] ?? "Belum ada kelas";
                        }

                        return ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  )
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Avatar Besar
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withOpacity(0.2),
                                      border: Border.all(
                                          color: Colors.white.withOpacity(0.4),
                                          width: 2),
                                    ),
                                    child: const Icon(
                                      Icons.person_rounded,
                                      size: 40,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 20),

                                  // Info Nama & Kelas
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Halo, Siswa",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white70,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          displayName, // Nama dari Database
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            letterSpacing: 0.5,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        // Badge Kelas
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(
                                                color: Colors.white24),
                                          ),
                                          child: Text(
                                            className, // Kelas dari Database
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 35),

                    Text(
                      "Menu Akademik",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- GRID MENU (DIPERBESAR / 2 KOLOM) ---
                    GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      childAspectRatio: 1.1,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      children: [
                        // Kita perlu mempassing className ke schedule agar bisa fetch jadwal
                        // Namun karena kita ada di dalam StreamBuilder di atas, 
                        // kita perlu cara untuk passing data.
                        // SOLUSI: Untuk tombol jadwal, kita fetch lagi atau pass default.
                        // Disini saya gunakan fetch manual di tombol untuk simplisitas UI
                        // atau passing static jika user sudah load.
                        
                        _BigFeatureCard(
                          label: "Jadwal Pelajaran",
                          icon: Icons.calendar_month_rounded,
                          onTap: () async {
                             // Ambil data user lagi untuk memastikan kelas terbaru saat klik
                             final doc = await FirebaseFirestore.instance.collection('users').doc(currentUser?.uid).get();
                             final kelasUser = doc.data()?['kelas'] ?? "XII IPA 1"; // Default fallback
                             
                            if (context.mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      StudentScheduleScreen(className: kelasUser),
                                ),
                              );
                            }
                          },
                        ),
                        _BigFeatureCard(
                          label: "Nilai & Rapor",
                          icon: Icons.bar_chart_rounded,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const StudentNilaiScreen()),
                            );
                          },
                        ),
                        _BigFeatureCard(
                          label: "Cetak Dokumen",
                          icon: Icons.print_rounded,
                          onTap: () {
                            // Aksi Dokumen
                          },
                        ),
                        _BigFeatureCard(
                          label: "Pengumuman",
                          icon: Icons.campaign_rounded,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    AnnouncementScreen(role: "siswa"),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// Widget Tombol AppBar Glass
class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onTap,
      ),
    );
  }
}

// Widget Card Fitur yang Diperbesar
class _BigFeatureCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _BigFeatureCard({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: Colors.white.withOpacity(0.2),
            highlightColor: Colors.white.withOpacity(0.1),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.15),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: const Offset(0, 4))
                        ]),
                    child: Icon(icon, size: 36, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}