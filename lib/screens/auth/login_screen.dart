import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/auth_service.dart';
import '../admin/admin_dashboard.dart';
import '../teacher/teacher_dashboard.dart';
import '../student/student_dashboard.dart';

// Catatan: Pastikan Anda telah membuat widget placeholder untuk:
// - AdminDashboard
// - TeacherDashboard
// - StudentDashboard
// - ThemeProvider (di providers/theme_provider.dart)
// - AuthService (di services/auth_service.dart)

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // **PERBAIKAN 1: Menghapus nilai default agar input kosong saat aplikasi dimuat**
  final TextEditingController emailC = TextEditingController(); 
  final TextEditingController passC = TextEditingController(); 
  bool loading = false;

  // Widget kustom untuk kotak dialog pesan (lebih baik dari AlertDialog standar)
  void _showCustomMessage(String title, String message, Color color, IconData icon) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: color,
        title: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "OK",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void showErrorPopup() {
    _showCustomMessage(
      "Login Gagal",
      "Email atau password salah. Silakan coba lagi!",
      Colors.redAccent,
      Icons.error_outline,
    );
  }

  void login() async {
    // Basic validation
    if (emailC.text.trim().isEmpty || passC.text.trim().isEmpty) {
       _showCustomMessage(
        "Input Kosong",
        "Mohon masukkan Email dan Password Anda.",
        Colors.orange.shade700,
        Icons.warning_amber_rounded,
      );
      return;
    }

    setState(() => loading = true);
    
    // Asumsi AuthService().loginUser mengembalikan Map jika sukses, atau null jika gagal
    final result = await AuthService().loginUser(
      email: emailC.text.trim(),
      password: passC.text.trim(),
    );
    
    setState(() => loading = false);

    if (result == null) {
      showErrorPopup();
      return;
    }

    final role = result['role'];
    Widget next;
    // Menghapus const pada navigasi
    if (role == 'admin') {
      next = AdminDashboard();
    } else if (role == 'guru') {
      next = TeacherDashboard();
    } else {
      next = StudentDashboard();
    }

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => next));
  }
  
  // Widget kustom untuk Input Field
  Widget _buildInputField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool isPassword = false,
  }) {
    final theme = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = theme.isDarkMode;

    // **PERBAIKAN 2: Memastikan label dan ikon terlihat SANGAT jelas**
    // Label dan ikon menggunakan warna putih di Dark Mode dan Teal/Cyan tua di Light Mode
    final labelColor = isDark ? Colors.white : Colors.teal.shade900; 
    final iconColor = isDark ? Colors.white : Colors.teal.shade900; 
    // Warna teks yang diketik di Light Mode
    final textColor = isDark ? Colors.white : Colors.black87; 

    return Container(
      decoration: BoxDecoration(
        // Background input field
        color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: labelColor, fontWeight: FontWeight.bold), // Label lebih tebal
          prefixIcon: Icon(icon, color: iconColor), 
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none, // Hilangkan border default
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            // Warna fokus menggunakan aksen Teal/Cyan
            borderSide: BorderSide(color: isDark ? Colors.teal.shade400 : Colors.cyan.shade600, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Gunakan listen: true untuk memastikan UI diperbarui saat tema berubah
    final theme = Provider.of<ThemeProvider>(context);
    final isDark = theme.isDarkMode;

    return Scaffold(
      // Atur warna latar belakang Scaffold menjadi transparan karena Stack akan menangani latar belakang
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 1. 🌈 Background Gradient (Teal/Cyan Theme)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    // Dark Mode: Dark Teal/Greenish Blue
                    ? [const Color(0xFF1E4941), const Color(0xFF13322A)] 
                    // Light Mode: Brighter Teal/Cyan
                    : [Colors.teal.shade300, Colors.cyan.shade600], 
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          
          // 2. 🌟 Efek Lingkaran di Latar Belakang (Opsional: hanya untuk pemanis visual)
          Positioned(
            top: -150,
            left: -150,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? Colors.teal.withOpacity(0.15) : Colors.white.withOpacity(0.15),
              ),
            ),
          ),
           Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? Colors.cyan.withOpacity(0.1) : Colors.white.withOpacity(0.1),
              ),
            ),
          ),

          // 3. 🔵 Login Card (Glassmorphism + Scrollable)
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30), // Sudut lebih membulat
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), // Blur yang lebih kuat
                  child: Container(
                    // Lebar Card disesuaikan dengan constraints max lebar layar
                    width: 400,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      // Warna background card (transparan)
                      color: Colors.white.withOpacity(isDark ? 0.05 : 0.2), 
                      borderRadius: BorderRadius.circular(30),
                      // Border Glassmorphism
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4), // Border putih tipis
                        width: 1.5,
                      ),
                      // Shadow lembut
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ]
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 🎓 Logo/Icon
                        Icon(Icons.school_rounded,
                            size: 90,
                            color: isDark ? Colors.white : Colors.white),

                        const SizedBox(height: 12),

                        // Judul
                        Text(
                          "SISTEM AKADEMIK SEKOLAH",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Subtitle
                        Text(
                          "Silakan login untuk mengakses portal Anda.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.cyan.shade200 : Colors.white70,
                          ),
                        ),

                        const SizedBox(height: 35),

                        // ✉️ Email
                        _buildInputField(
                          controller: emailC,
                          labelText: "Email",
                          icon: Icons.email_rounded,
                        ),

                        const SizedBox(height: 18),

                        // 🔒 Password
                        _buildInputField(
                          controller: passC,
                          labelText: "Password",
                          icon: Icons.lock_rounded,
                          isPassword: true,
                        ),

                        const SizedBox(height: 30),

                        // 🔘 Login Button
                        loading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: isDark
                                          // Tombol menggunakan warna Teal yang cerah
                                          ? [Colors.teal.shade700, Colors.teal.shade500]
                                          : [Colors.white, Colors.cyan.shade100],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: login,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                    ),
                                    child: Text(
                                      "Login",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        // Teks tombol menggunakan Teal tua di Light Mode
                                        color: isDark ? Colors.white : Colors.teal.shade800,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                        const SizedBox(height: 25),

                        // 🌙 Dark Mode Toggle
                        GestureDetector(
                          onTap: theme.toggleTheme,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isDark
                                    ? Icons.light_mode_rounded
                                    : Icons.dark_mode_rounded,
                                color: isDark ? Colors.yellow.shade300 : Colors.white70,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isDark ? "Ganti ke Light Mode" : "Ganti ke Dark Mode",
                                style: TextStyle(
                                    color: isDark ? Colors.yellow.shade300 : Colors.white70,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}