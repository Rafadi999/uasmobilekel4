// lib/services/pdf_service.dart
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart'; 
import 'package:printing/printing.dart';
import '../models/grade.dart';

class PdfService {
  static Future<void> generateRaporPDF({
    required String studentName,
    required List<Grade> nilaiList,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text('RAPOR AKADEMIK', style: pw.TextStyle(fontSize: 24)),
            ),
            pw.Text('Nama: $studentName'),
            pw.SizedBox(height: 12),
            pw.Table.fromTextArray(
              headers: ['Mapel', 'Tugas', 'UTS', 'UAS', 'Akhir', 'Predikat'],
              data: nilaiList.map((g) {
                return [
                  g.subject,
                  g.tugas.toString(),
                  g.uts.toString(),
                  g.uas.toString(),
                  (g.finalScore).toStringAsFixed(2),
                  g.predicate,
                ];
              }).toList(),
            ),
            pw.SizedBox(height: 20),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text('Tanggal: ${DateTime.now().toLocal()}'),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
}
