import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/theme_provider.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import '../teacher/announcement_screen.dart'; // Digunakan untuk Pengumuman
import '../teacher/teacher_schedule.dart'; // Digunakan untuk Jadwal Mengajar
import '../../screens/nilai/select_mapel_screen.dart'; // Digunakan untuk Input Nilai

// 🎨 Warna tema Teal/Cyan yang lebih MUDA dan CERAH
// Didefinisikan sebagai MaterialColor agar bisa menggunakan shade di bawah
const MaterialColor primaryTealSwatch = Colors.teal;
const MaterialColor accentCyanSwatch = Colors.cyan;

// Warna icon menggunakan shade yang lebih muda
final Color iconColor1 = accentCyanSwatch.shade400; // Aksen untuk Input Nilai
final Color iconColor2 = primaryTealSwatch.shade400; // Primary untuk Jadwal
final Color iconColor3 = Colors.yellow.shade300; // Kontras untuk Pengumuman

class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});

  // Widget kustom untuk Kartu Menu Glassmorphism
  Widget _DashboardCard({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    final theme = Provider.of<ThemeProvider>(context);
    final isDark = theme.isDarkMode;
    // Opacity disesuaikan agar card terlihat jelas di Light Mode
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
                      fontSize: 17,
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

    // Ambil data user yang login
    final currentUser = FirebaseAuth.instance.currentUser;
    final teacherName = currentUser?.displayName ?? "Guru";

    // Definisikan Gradient yang Disesuaikan (Lebih Muda/Cerah)
    final LinearGradient backgroundGradient = LinearGradient(
      colors: isDark
          ? [const Color(0xFF1E4941), const Color(0xFF13322A)] // Dark Mode
          // Menggunakan shade langsung dari MaterialColor untuk menghindari error .shade
          : [primaryTealSwatch.shade100, accentCyanSwatch.shade300], // Light Mode (Lebih cerah)
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      // Mengaktifkan full screen background
      extendBodyBehindAppBar: true, 
      backgroundColor: Colors.transparent,

      appBar: AppBar(
        elevation: 0,
        // AppBar Transparan
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
          // 1. Background gradient (Teal/Cyan Lebih Muda)
          Container(
            decoration: BoxDecoration(
              gradient: backgroundGradient,
            ),
          ),

          // 2. Decorative circles (optional)
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

          // 3. MAIN CONTENT (Header Card + Grid Menu)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10), 

                    // HEADER CARD (Glassmorphism)
                    ClipRRect(
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
                              const Icon(Icons.person_pin_circle_rounded,
                                  size: 50, color: Colors.white),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Halo, Guru 👋",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                    ),
                                    // Tulisan Nama Guru yang besar
                                    Text(
                                      teacherName, 
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white.withOpacity(0.95),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    // Deskripsi
                                    Text(
                                      "Selamat datang di panel guru. Kelola nilai dan jadwal Anda di sini.",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                    
                    Text(
                      "MENU UTAMA",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => SelectMapelScreen(
                                        teacherId: currentUser?.uid ?? "",
                                        teacherName: teacherName)),
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
                                        teacherName: teacherName)),
                            );
                          },
                        ),
                        _DashboardCard(
                          context: context,
                          label: "Pengumuman",
                          icon: Icons.campaign_rounded,
                          iconColor: iconColor3, 
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => AnnouncementScreen(role: "guru")),
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
