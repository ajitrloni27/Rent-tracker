import 'dart:io';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../models/transaction.dart';
import '../utils/formatters.dart';

class ExportService {
  static Future<void> exportCSV(List<Transaction> transactions) async {
    List<List<dynamic>> rows = [];
    
    // Header
    rows.add([
      "Date",
      "Type",
      "Description",
      "Amount"
    ]);

    for (var t in transactions) {
      rows.add([
        AppFormatters.date(t.date),
        t.type.name.toUpperCase(),
        t.description,
        t.amount
      ]);
    }

    String csvData = const ListToCsvConverter().convert(rows);

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/rent_tracker_export.csv');
    await file.writeAsString(csvData);
    
    await Share.shareXFiles([XFile(file.path)], text: 'Rent Tracker CSV Export');
  }

  static Future<void> exportPDF(List<Transaction> transactions) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Rent Tracker - Transactions Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                context: context,
                data: <List<String>>[
                  <String>['Date', 'Type', 'Description', 'Amount'],
                  ...transactions.map((t) => [
                    AppFormatters.date(t.date),
                    t.type.name.toUpperCase(),
                    t.description,
                    AppFormatters.currency(t.amount)
                  ])
                ],
              ),
            ],
          );
        },
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/rent_tracker_report.pdf');
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles([XFile(file.path)], text: 'Rent Tracker PDF Report');
  }

  static Future<bool> backupDatabase() async {
    return false; // Deprecated due to permissions
  }

  static Future<bool> restoreDatabase() async {
    return false; // Deprecated due to permissions
  }
}
