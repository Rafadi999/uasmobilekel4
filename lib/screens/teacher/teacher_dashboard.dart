import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import '../teacher/announcement_screen.dart';
import '../teacher/teacher_schedule.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../screens/nilai/select_mapel_screen.dart';


class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final isDark = theme.isDarkMode;

    final currentUser = FirebaseAuth.instance.currentUser;
    final teacherName = currentUser?.displayName ?? "Guru";

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1B2A) : Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? Colors.blue.shade900 : Colors.blue.shade700,
        title: const Text(
          "Dashboard Guru",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: Colors.white,
            ),
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

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Salam guru
            Text(
              "Halo, $teacherName 👋",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.blue.shade800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Selamat datang di panel guru.",
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.white70 : Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 25),

            // Grid Menu
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.only(top: 12),
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: [
                  _DashboardCard(
  icon: Icons.assignment_rounded,
  label: "Input Nilai",
  color: Colors.orange.shade700,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SelectMapelScreen(
          teacherId: currentUser?.uid ?? "",
          teacherName: teacherName,
        ),
      ),
    );
  },
),


                  _DashboardCard(
                    icon: Icons.schedule_rounded,
                    label: "Jadwal Mengajar",
                    color: Colors.green.shade600,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TeacherScheduleScreen(
                            teacherId: currentUser?.uid ?? "",
                            teacherName: teacherName,
                          ),
                        ),
                      );
                    },
                  ),
                  _DashboardCard(
                    icon: Icons.campaign_rounded,
                    label: "Pengumuman",
                    color: Colors.blue.shade700,
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
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 7,
      shadowColor: Colors.black.withOpacity(0.15),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.5), width: 1.3),
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: color),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
