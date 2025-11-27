import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../teacher/input_grade_list_screen.dart';

class SelectMapelScreen extends StatefulWidget {
  final String teacherId;
  final String teacherName;

  const SelectMapelScreen({
    super.key,
    required this.teacherId,
    required this.teacherName,
  });

  @override
  State<SelectMapelScreen> createState() => _SelectMapelScreenState();
}

class _SelectMapelScreenState extends State<SelectMapelScreen> {
  String? selectedMapel;

  Stream<List<String>> getMapel() {
    return FirebaseFirestore.instance
        .collection("mapel")
        .snapshots()
        .map((snap) => snap.docs.map((d) => d["nama"].toString()).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Background gradient toska (nice & smooth)
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF073B3A), // dark toska
              Color(0xFF0ABFBC), // bright toska
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // soft glowing bubbles (fixed: use BoxShadow for glow)
            _bubble(230, Colors.white.withOpacity(0.05), top: -80, left: -50),
            _bubble(180, Colors.white.withOpacity(0.04), top: -40, left: 240),
            _bubble(260, Colors.white.withOpacity(0.06), top: 340, left: -60),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: StreamBuilder<List<String>>(
                  stream: getMapel(),
                  builder: (context, snap) {
                    if (!snap.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }

                    final mapel = snap.data!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        const Text(
                          "Pilih Mata Pelajaran",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 22),

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D4D4A).withOpacity(0.8),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.18),
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedMapel,
                              icon: const Icon(Icons.arrow_drop_down,
                                  color: Colors.white),
                              dropdownColor: const Color(0xFF0D4D4A),
                              hint: const Text(
                                "Pilih mapel",
                                style: TextStyle(color: Colors.white70),
                              ),
                              style: const TextStyle(color: Colors.white),
                              isExpanded: true,
                              items: mapel.map((e) {
                                return DropdownMenuItem(
                                  value: e,
                                  child: Text(e),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() => selectedMapel = val);
                              },
                            ),
                          ),
                        ),

                        const Spacer(),

                        // BUTTON LANJUT (gradient toska)
                        InkWell(
                          onTap: selectedMapel == null
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => InputGradeListScreen(
                                        subject: selectedMapel!,
                                        teacherId: widget.teacherId,
                                      ),
                                    ),
                                  );
                                },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: selectedMapel == null
                                  ? LinearGradient(
                                      colors: [
                                        Colors.white.withOpacity(0.18),
                                        Colors.white.withOpacity(0.12),
                                      ],
                                    )
                                  : const LinearGradient(
                                      colors: [
                                        Color(0xFF14E2C6),
                                        Color(0xFF6FFFE9),
                                      ],
                                    ),
                              boxShadow: selectedMapel == null
                                  ? []
                                  : [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      )
                                    ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "Lanjut",
                              style: TextStyle(
                                color: selectedMapel == null
                                    ? Colors.white54
                                    : Colors.black87,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // fixed bubble: use Positioned + Container with BoxShadow for glow
  Widget _bubble(double size, Color color, {double? top, double? left}) {
    return Positioned(
      top: top,
      left: left,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          // boxShadow creates the soft glow (instead of invalid blurRadius)
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: 40,
              spreadRadius: 6,
            ),
          ],
          // slightly transparent background so glow shows nicely
          color: color.withOpacity(0.02),
        ),
      ),
    );
  }
}
