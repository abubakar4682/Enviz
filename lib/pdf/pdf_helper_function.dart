import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;

class PDFHelper {
  static Future<void> createCustomPdf(List<Uint8List> images, String filename, String userName) async {
    final pdf = pw.Document();
    final imageLogo = (await rootBundle.load('assets/images/enfologo.png')).buffer.asUint8List();

    // Format the date in a more readable format
    String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Image(pw.MemoryImage(imageLogo), width: 50, height: 50),
                  pw.Text('Date: $formattedDate', style: const pw.TextStyle(fontSize: 18)),
                ],
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 20, bottom: 10),
              child: pw.Text('Hello: $userName!', style: pw.TextStyle(fontSize: 16)),
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: images.map((imageData) => pw.Container(
                margin: const pw.EdgeInsets.symmetric(vertical: 10),
                child: pw.Image(pw.MemoryImage(imageData), fit: pw.BoxFit.contain),
              )).toList(),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 10),
              child: pw.Text('Total Due: \$XX.XX', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            ),
          ],
        ),
      ),
    );

    // Save or print the PDF file
    await Printing.sharePdf(bytes: await pdf.save(), filename: filename);
  }
}
