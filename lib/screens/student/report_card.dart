// lib/screens/student/report_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/grade_provider.dart';
import '../../models/grade.dart';
import '../../services/pdf_service.dart';

class ReportCardScreen extends StatelessWidget {
  final String studentId;
  final String studentName;

  const ReportCardScreen({super.key, required this.studentId, required this.studentName});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GradeProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Rapor - $studentName'),
      ),
      body: StreamBuilder<List<Grade>>(
        stream: provider.getNilaiByStudent(studentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = snapshot.data ?? [];
          if (list.isEmpty) {
            return const Center(child: Text('Belum ada nilai.'));
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Mapel')),
                      DataColumn(label: Text('Tugas')),
                      DataColumn(label: Text('UTS')),
                      DataColumn(label: Text('UAS')),
                      DataColumn(label: Text('Akhir')),
                      DataColumn(label: Text('Predikat')),
                    ],
                    rows: list.map((g) {
                      return DataRow(cells: [
                        DataCell(Text(g.subject)),
                        DataCell(Text(g.tugas.toString())),
                        DataCell(Text(g.uts.toString())),
                        DataCell(Text(g.uas.toString())),
                        DataCell(Text(g.finalScore.toStringAsFixed(2))),
                        DataCell(Text(g.predicate)),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Export ke PDF'),
                  onPressed: () async {
                    await PdfService.generateRaporPDF(studentName: studentName, nilaiList: list);
                  },
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
