import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../providers/grade_provider.dart';
import '../../models/grade.dart';
import '../../services/pdf_service.dart';

class ReportCardScreen extends StatelessWidget {
  final String studentId;
  final String studentName;

  const ReportCardScreen({
    super.key,
    required this.studentId,
    required this.studentName,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GradeProvider>(context, listen: false);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("Rapor - $studentName"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: Stack(
        children: [
          // BACKGROUND GRADIENT
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade400, Colors.teal.shade900],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // DECO BUBBLE
          Positioned(
            top: -80,
            right: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // MAIN CONTENT
          SafeArea(
            child: StreamBuilder<List<Grade>>(
              stream: provider.getNilaiByStudent(studentId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: Colors.white));
                }

                final list = snapshot.data ?? [];

                if (list.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada nilai.',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  );
                }

                return Column(
                  children: [
                    const SizedBox(height: 20),

                    // HEADER CARD
                    _glassHeader(studentName),

                    const SizedBox(height: 20),

                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(26)),
                        ),
                        child: Column(
                          children: [
                            // ===========================
                            // TABLE NILAI
                            // ===========================
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  headingRowColor:
                                      MaterialStateProperty.all(Colors.white24),
                                  dataRowColor:
                                      MaterialStateProperty.all(Colors.white10),
                                  columns: const [
                                    DataColumn(label: Text('Mapel', style: _col)),
                                    DataColumn(label: Text('Tugas', style: _col)),
                                    DataColumn(label: Text('UTS', style: _col)),
                                    DataColumn(label: Text('UAS', style: _col)),
                                    DataColumn(label: Text('Akhir', style: _col)),
                                    DataColumn(label: Text('Predikat', style: _col)),
                                  ],
                                  rows: list.map((g) {
                                    return DataRow(
                                      cells: [
                                        DataCell(Text(g.mapel, style: _row)),
                                        DataCell(Text("${g.tugas}", style: _row)),
                                        DataCell(Text("${g.uts}", style: _row)),
                                        DataCell(Text("${g.uas}", style: _row)),
                                        DataCell(Text(g.finalScore.toStringAsFixed(2),
                                            style: _row)),
                                        DataCell(Text(g.predicate, style: _row)),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // ===========================
                            // BAR CHART WARNA-WARNI
                            // ===========================
                            SizedBox(height: 260, child: _colorfulBarChart(list)),

                            // ===========================
                            // BUTTON EXPORT PDF
                            // ===========================
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.teal.shade800,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14)),
                                ),
                                icon: const Icon(Icons.picture_as_pdf),
                                label: const Text("Export ke PDF"),
                                onPressed: () async {
                                  await PdfService.generateRaporPDF(
                                    studentName: studentName,
                                    nis: "123456",
                                    kelas: "XI IPA 1",
                                    jurusan: "IPA",
                                    nilaiList: list,
                                  );
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          )
        ],
      ),
    );
  }

  // =====================================================================================
  // GLASS HEADER
  // =====================================================================================
  Widget _glassHeader(String name) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(22),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Text(
                "Rapor Siswa",
                style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                name,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =====================================================================================
  // BAR CHART WARNA-WARNI
  // =====================================================================================
  Widget _colorfulBarChart(List<Grade> list) {
    final List<Color> chartColors = [
      Colors.amber,
      Colors.pinkAccent,
      Colors.blueAccent,
      Colors.greenAccent,
      Colors.deepPurpleAccent,
      Colors.orangeAccent,
      Colors.cyanAccent,
      Colors.redAccent,
    ];

    return BarChart(
      BarChartData(
        borderData: FlBorderData(show: false),
        backgroundColor: Colors.white.withOpacity(0.15),
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (value, _) => Text(
                value.toInt().toString(),
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                if (value < 0 || value >= list.length) return const Text("");
                return Text(list[value.toInt()].mapel,
                    style: const TextStyle(color: Colors.white, fontSize: 10));
              },
            ),
          ),
        ),
        barGroups: List.generate(list.length, (i) {
          final g = list[i];
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: g.finalScore,
                color: chartColors[i % chartColors.length],
                width: 18,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }),
      ),
    );
  }
}

// Text style tabel
const _col = TextStyle(
    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13);
const _row = TextStyle(color: Colors.white);
