import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
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
      "Category",
      "Reason",
      "Amount",
      "Notes"
    ]);

    for (var t in transactions) {
      rows.add([
        AppFormatters.date(t.date),
        t.type.name.toUpperCase(),
        t.category,
        t.reason,
        t.amount,
        t.notes ?? ""
      ]);
    }

    String csvData = const ListToCsvConverter().convert(rows);

    final result = await FilePicker.platform.saveFile(
      dialogTitle: 'Save CSV',
      fileName: 'rent_tracker_export.csv',
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      final file = File(result);
      await file.writeAsString(csvData);
    }
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
                  <String>['Date', 'Type', 'Category', 'Reason', 'Amount'],
                  ...transactions.map((t) => [
                    AppFormatters.date(t.date),
                    t.type.name.toUpperCase(),
                    t.category,
                    t.reason,
                    AppFormatters.currency(t.amount)
                  ])
                ],
              ),
            ],
          );
        },
      ),
    );

    final result = await FilePicker.platform.saveFile(
      dialogTitle: 'Save PDF',
      fileName: 'rent_tracker_report.pdf',
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      final file = File(result);
      await file.writeAsBytes(await pdf.save());
    }
  }

  static Future<bool> backupDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbFile = File('${dir.path}/default.isar');
    
    if (await dbFile.exists()) {
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Database Backup',
        fileName: 'rent_tracker_backup.isar',
        type: FileType.custom,
        allowedExtensions: ['isar'],
      );

      if (result != null) {
        await dbFile.copy(result);
        return true;
      }
    }
    return false;
  }

  static Future<bool> restoreDatabase() async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Select Backup File',
      type: FileType.custom,
      allowedExtensions: ['isar'],
    );

    if (result != null && result.files.single.path != null) {
      final dir = await getApplicationDocumentsDirectory();
      final backupFile = File(result.files.single.path!);
      final dbFile = File('${dir.path}/default.isar');
      
      await backupFile.copy(dbFile.path);
      return true;
    }
    return false;
  }
}
