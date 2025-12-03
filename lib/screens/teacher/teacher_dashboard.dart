import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Wajib import ini untuk database
import '../../providers/theme_provider.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import '../teacher/announcement_screen.dart';
import '../teacher/teacher_schedule.dart';
import '../../screens/nilai/select_mapel_screen.dart';

// 🎨 Warna tema Teal/Cyan (Sesuai request awal)
const MaterialColor primaryTealSwatch = Colors.teal;
const MaterialColor accentCyanSwatch = Colors.cyan;

// Warna icon
final Color iconColor1 = accentCyanSwatch.shade400; 
final Color iconColor2 = primaryTealSwatch.shade400; 
final Color iconColor3 = Colors.yellow.shade300; 

class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});

  // Widget kustom untuk Kartu Menu (Grid)
  Widget _DashboardCard({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    final theme = Provider.of<ThemeProvider>(context);
    final isDark = theme.isDarkMode;
    final cardOpacity = isDark ? 0.10 : 0.25;

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: Colors.white.withOpacity(cardOpacity),
          child: InkWell(
            onTap: onTap,
            splashColor: iconColor.withOpacity(0.2),
            highlightColor: Colors.white.withOpacity(0.05),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 55, color: iconColor),
                  const SizedBox(height: 12),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
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

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final isDark = theme.isDarkMode;
    final currentUser = FirebaseAuth.instance.currentUser;

    // Background Gradient
    final LinearGradient backgroundGradient = LinearGradient(
      colors: isDark
          ? [const Color(0xFF1E4941), const Color(0xFF13322A)]
          : [primaryTealSwatch.shade100, accentCyanSwatch.shade300],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text(
          "Dashboard Guru",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: Colors.white),
            onPressed: theme.toggleTheme,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await AuthService().logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. Background
          Container(
            decoration: BoxDecoration(gradient: backgroundGradient),
          ),

          // 2. Lingkaran Dekorasi
          Positioned(
            top: -120, left: -120,
            child: Container(
              width: 260, height: 260,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.08)),
            ),
          ),
          Positioned(
            bottom: -150, right: -120,
            child: Container(
              width: 280, height: 280,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.06)),
            ),
          ),

          // 3. MAIN CONTENT
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),

                    // ============================================
                    // STREAM BUILDER UNTUK DATA PROFIL GURU (REALTIME)
                    // ============================================
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(currentUser?.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        // Default Values
                        String teacherName = "Guru";
                        String teacherNip = "...";
                        String teacherMapel = "...";

                        if (snapshot.hasData && snapshot.data!.exists) {
                          final data = snapshot.data!.data() as Map<String, dynamic>;
                          teacherName = data['nama'] ?? "Guru";
                          teacherNip = data['nip'] ?? "-";
                          teacherMapel = data['mapel'] ?? "-";
                        }

                        // Kartu Profil Glassmorphism
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(isDark ? 0.08 : 0.2),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                    color: Colors.white.withOpacity(isDark ? 0.2 : 0.4)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Avatar
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withOpacity(0.2),
                                      border: Border.all(color: Colors.white38, width: 2),
                                    ),
                                    child: const Icon(Icons.person_pin_circle_rounded,
                                        size: 45, color: Colors.white),
                                  ),
                                  const SizedBox(width: 16),
                                  
                                  // Text Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Selamat Datang,",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white.withOpacity(0.8),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        // NAMA GURU DARI FIRESTORE
                                        Text(
                                          teacherName,
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white.withOpacity(0.95),
                                            shadows: [
                                              Shadow(
                                                offset: const Offset(0, 2),
                                                blurRadius: 4,
                                                color: Colors.black.withOpacity(0.1),
                                              ),
                                            ],
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        // Badge NIP & Mapel
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 4,
                                          children: [
                                            _buildInfoBadge("NIP: $teacherNip"),
                                            _buildInfoBadge(teacherMapel),
                                          ],
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

                    const SizedBox(height: 30),

                    Text(
                      "MENU GURU",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // GRID MENU
                    GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      childAspectRatio: 1,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _DashboardCard(
                          context: context,
                          label: "Input Nilai Siswa",
                          icon: Icons.assignment_rounded,
                          iconColor: iconColor1,
                          onTap: () {
                            // Kita kirim data nama guru agar tidak perlu fetch ulang di screen berikutnya
                            // Namun karena di dalam Stream, kita pakai nama dari Auth atau fetch lagi 
                            // jika di screen nilai butuh data lengkap.
                            // Untuk amannya kirim ID & DisplayName dr Auth dulu
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SelectMapelScreen(
                                  teacherId: currentUser?.uid ?? "",
                                  teacherName: currentUser?.displayName ?? "Guru", 
                                ),
                              ),
                            );
                          },
                        ),
                        _DashboardCard(
                          context: context,
                          label: "Jadwal Mengajar",
                          icon: Icons.schedule_rounded,
                          iconColor: iconColor2,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TeacherScheduleScreen(
                                  teacherId: currentUser?.uid ?? "",
                                  teacherName: currentUser?.displayName ?? "Guru",
                                ),
                              ),
                            );
                          },
                        ),
                        _DashboardCard(
                          context: context,
                          label: "Buat Pengumuman",
                          icon: Icons.campaign_rounded,
                          iconColor: iconColor3,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AnnouncementScreen(role: "guru"),
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

  // Helper Widget untuk Badge kecil (NIP / Mapel)
  Widget _buildInfoBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }
}