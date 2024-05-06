import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;

class PDFHelper {
  static Future<void> createCustomPdf(List<Uint8List> images, String filename, String userName) async {
    final pdf = pw.Document();
    final imageLogo = (await rootBundle.load('assets/images/enfologo.png')).buffer.asUint8List();

    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4, // Define the page size explicitly if needed
      build: (pw.Context context) => pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Image(pw.MemoryImage(imageLogo), width: 50, height: 50),
                pw.Text('Company Name', style: const pw.TextStyle(fontSize: 18)),
              ],
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 10),
            child: pw.Text('Hello, $userName!', style: pw.TextStyle(fontSize: 14)),
          ),
          ...images.map((imageData) => pw.Expanded(
            child: pw.Center(
              child: pw.Image(pw.MemoryImage(imageData), fit: pw.BoxFit.contain),
            ),
          )),
        ],
      ),
    ));

    // Save or print the PDF file
    await Printing.sharePdf(bytes: await pdf.save(), filename: filename);
  }
}
