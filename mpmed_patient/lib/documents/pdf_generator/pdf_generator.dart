import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mpmed_patient/documents/pdf_generator/pdf_screen.dart';
import 'package:mpmed_patient/documents/provider/documents_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show ByteData, rootBundle;

class PdfGenerator {
  Future<void> generatePDF(BuildContext context, Map documentElement,
      List<DocumentMediaModel> documentMediaList) async {
    //Create a PDF document.
    final PdfDocument document = PdfDocument();
    //Add page to the PDF
    PdfPage page = document.pages.add();
    PdfGraphicsState state = page.graphics.save();
    page.graphics.setTransparency(0.25);
    ByteData WMbytes = await rootBundle.load('assets/img/drawer_logo.png');
    page.graphics.drawImage(
        PdfBitmap.fromBase64String(
            base64.encode(Uint8List.view(WMbytes.buffer))),
        Rect.fromLTWH(0, 0, page.graphics.clientSize.width,
            page.graphics.clientSize.height));
    page.graphics.restore(state);
    //Get page client size
    final Size pageSize = page.getClientSize();
    //Draw rectangle
    page.graphics.drawRectangle(
        bounds: Rect.fromLTWH(0, 0, pageSize.width, pageSize.height),
        pen: PdfPen(PdfColor(142, 170, 219, 255)));
    //Generate PDF grid.
    // final PdfGrid grid = _getGrid();
    //Draw the header section by creating text element
    String fullName =
        '${documentElement['name']}${documentElement['last_name']}';
    String desc =
        ' این مدرک برای بیمار ${fullName} که در ${documentElement['lab_name']} توسط  ${documentElement['doctor_name']} انجام شده است.';

    _drawHeader(page, pageSize, desc);

    documentMediaList = documentMediaList.toSet().toList();
    List<String> docUrls = [];

    for (var i = 0; i < documentMediaList.length; i++) {
      if (!docUrls.contains(documentMediaList[i].docUrl)) {
        docUrls.add(documentMediaList[i].docUrl);
      }
    }

    for (var i = 0; i < docUrls.length; i++) {
      page = document.pages.add();
      http.Response response =
          await http.get(Uri.parse(docUrls[i]));
      page.graphics.drawImage(
          PdfBitmap(response.bodyBytes),
          Rect.fromLTWH(50, 0, page.getClientSize().width - 100,
              page.getClientSize().height - 100));
      PdfGraphicsState state = page.graphics.save();
      page.graphics.setTransparency(0.25);
      ByteData WMbytes = await rootBundle.load('assets/img/drawer_logo.png');
      page.graphics.drawImage(
          PdfBitmap.fromBase64String(
              base64.encode(Uint8List.view(WMbytes.buffer))),
          Rect.fromLTWH(0, 0, page.graphics.clientSize.width,
              page.graphics.clientSize.height));
      page.graphics.restore(state);
    }

    //Save and dispose the document.
    final List<int> bytes = document.save();
    document.dispose();
    //Launch file.
    //await FileSaveHelper.saveAndLaunchFile(bytes, 'Invoice.pdf');

    //Get external storage directory
    Directory? directory = await getExternalStorageDirectory();
    //Get directory path
    String? path = directory?.path;
    print(path);
    //Create an empty file to write PDF data

    final String documentPath =
        '$path/MizePezeshk-MdDocument-${DateTime.now().microsecondsSinceEpoch.toString()}.pdf';

    File file = File(documentPath);
    //Write PDF data
    await file.writeAsBytes(bytes, flush: true);

    //Open the PDF document in mobile
    // OpenFile.open('$path/Output.pdf');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFScreen(path: documentPath),
      ),
    );
  }

  //Draws the invoice header
  _drawHeader(PdfPage page, Size pageSize, String desc) async {
    //Draw rectangle
    page.graphics.drawRectangle(
        brush: PdfSolidBrush(PdfColor(211, 211, 211, 255)),
        bounds: Rect.fromLTWH(0, 0, pageSize.width - 115, 90));
    //Draw string
    page.graphics.drawString(
        'Medical Document', PdfStandardFont(PdfFontFamily.helvetica, 30),
        brush: PdfBrushes.white,
        bounds: Rect.fromLTWH(25, 0, pageSize.width - 115, 90),
        format: PdfStringFormat(lineAlignment: PdfVerticalAlignment.middle));
    page.graphics.drawRectangle(
        bounds: Rect.fromLTWH(400, 0, pageSize.width - 400, 90),
        brush: PdfSolidBrush(PdfColor(189, 189, 189, 255)));

    ByteData bytes = await rootBundle.load('assets/img/drawer_logo.png');
    page.graphics.drawImage(PdfBitmap(bytes.buffer.asUint8List()),
        Rect.fromLTWH(400, 0, pageSize.width - 410, 90));

    ByteData fontInBytes =
        await rootBundle.load('assets/fonts/Kalameh-Regular.ttf');
    final contentFont = PdfTrueTypeFont(fontInBytes.buffer.asUint8List(), 21);

    final Size contentSize = contentFont.measureString(desc);

    page.graphics.drawString(desc, contentFont,
        brush: PdfBrushes.black,
        bounds: Rect.fromLTWH(-10, 120, page.graphics.clientSize.width,
            page.getClientSize().height),
        format: PdfStringFormat(
            textDirection: PdfTextDirection.rightToLeft,
            alignment: PdfTextAlignment.right,
            paragraphIndent: 35));
  }

  //Draw the invoice footer data.
  void _drawFooter(PdfPage page, Size pageSize) {
    final PdfPen linePen =
        PdfPen(PdfColor(142, 170, 219, 255), dashStyle: PdfDashStyle.custom);
    linePen.dashPattern = <double>[3, 3];
    //Draw line
    page.graphics.drawLine(linePen, Offset(0, pageSize.height - 100),
        Offset(pageSize.width, pageSize.height - 100));
    const String footerContent =
        '800 Interchange Blvd.\r\n\r\nSuite 2501, Austin, TX 78721\r\n\r\nAny Questions? support@adventure-works.com';
    //Added 30 as a margin for the layout
    page.graphics.drawString(
        footerContent, PdfStandardFont(PdfFontFamily.helvetica, 9),
        format: PdfStringFormat(alignment: PdfTextAlignment.right),
        bounds: Rect.fromLTWH(pageSize.width - 30, pageSize.height - 70, 0, 0));
  }

  getApplicationDocumentsDirectory() {}
}
