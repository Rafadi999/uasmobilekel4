import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uasmobile_kelompok4/screens/student/student_schedule.dart';
import '../../providers/theme_provider.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import '../teacher/announcement_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    // Ambil current user
    final currentUser = FirebaseAuth.instance.currentUser;
    final className = currentUser?.displayName ?? "Kelas Default"; // fallback

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard Siswa"),
        actions: [
          IconButton(
            icon: Icon(theme.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: theme.toggleTheme,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
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
      body: GridView.count(
        padding: const EdgeInsets.all(20),
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _DashboardCard(
            icon: Icons.schedule,
            label: 'Lihat Jadwal Pelajaran',
            color: Colors.teal,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StudentScheduleScreen(className: className),
                ),
              );
            },
          ),
          _DashboardCard(
            icon: Icons.grade,
            label: 'Lihat Nilai',
            color: Colors.amber,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Belum tersedia')));
            },
          ),
          _DashboardCard(
            icon: Icons.picture_as_pdf,
            label: 'Lihat / Ekspor Rapor',
            color: Colors.redAccent,
            onTap: () {},
          ),
          _DashboardCard(
            icon: Icons.campaign,
            label: 'Pengumuman',
            color: Colors.indigo,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AnnouncementScreen(role: "siswa"),
                ),
              );
            },
          ),
        ],
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
    return Card(
      elevation: 4,
      color: color.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: color, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}