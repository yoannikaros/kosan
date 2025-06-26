import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:esc_pos_utils_updated/esc_pos_utils_updated.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:kosan/models/payment.dart';
import 'package:kosan/models/rental.dart';
import 'package:kosan/models/room.dart';
import 'package:kosan/models/tenant.dart';
import 'package:kosan/models/setting.dart';

class ReceiptHelper {
  static final _dateFormat = DateFormat('dd/MM/yyyy');
  static final _currencyFormat = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  // Membuat dokumen PDF dari data struk
  static Future<Uint8List> generatePdf({
    required Payment payment,
    required Rental? rental,
    required Room? room,
    required Tenant? tenant,
    required Setting? setting,
  }) async {
    try {
      // Muat font
      pw.Font? ttf;
      pw.Font? ttfBold;

      try {
        final fontData = await rootBundle.load("assets/fonts/Poppins-Regular.ttf");
        ttf = pw.Font.ttf(fontData);

        final fontBold = await rootBundle.load("assets/fonts/Poppins-Bold.ttf");
        ttfBold = pw.Font.ttf(fontBold);
      } catch (e) {
        // Gunakan font default jika font kustom tidak tersedia
        ttf = null;
        ttfBold = null;
      }

      // Buat dokumen PDF
      final pdf = pw.Document();

      // Tambahkan halaman
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a5,
          build: (pw.Context context) {
            return pw.Container(
              padding: const pw.EdgeInsets.all(16),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Header
                  pw.Center(
                    child: pw.Column(
                      children: [
                        pw.Text(
                          setting?.businessName ?? 'Manajemen Kost',
                          style: ttfBold != null
                              ? pw.TextStyle(font: ttfBold, fontSize: 18)
                              : pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                          textAlign: pw.TextAlign.center,
                        ),
                        pw.SizedBox(height: 4),
                        if (setting?.noteHeader != null && setting!.noteHeader!.isNotEmpty)
                          pw.Text(
                            setting.noteHeader!,
                            style: ttf != null ? pw.TextStyle(font: ttf, fontSize: 10) : pw.TextStyle(fontSize: 10),
                            textAlign: pw.TextAlign.center,
                          ),
                      ],
                    ),
                  ),
                  pw.Divider(thickness: 2),

                  // Informasi Pembayaran
                  pw.Center(
                    child: pw.Text(
                      'STRUK PEMBAYARAN',
                      style: ttfBold != null
                          ? pw.TextStyle(font: ttfBold, fontSize: 14)
                          : pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.SizedBox(height: 16),

                  // Detail Pembayaran
                  _buildPdfDetailRow('No. Pembayaran', '#${payment.id ?? "New"}', ttf, ttfBold),
                  _buildPdfDetailRow('Tanggal', _dateFormat.format(DateTime.parse(payment.paymentDate)), ttf, ttfBold),
                  _buildPdfDetailRow('Jumlah', _currencyFormat.format(payment.amount), ttf, ttfBold),
                  if (payment.paymentMethod != null && payment.paymentMethod!.isNotEmpty)
                    _buildPdfDetailRow('Metode Pembayaran', payment.paymentMethod!, ttf, ttfBold),

                  pw.Divider(),

                  // Detail Kamar & Penyewa
                  if (room != null)
                    _buildPdfDetailRow('Kamar', 'Kamar ${room.roomNumber}', ttf, ttfBold),
                  if (tenant != null)
                    _buildPdfDetailRow('Penyewa', tenant.name, ttf, ttfBold),
                  if (rental != null) ...[
                    _buildPdfDetailRow(
                        'Periode Sewa',
                        '${_dateFormat.format(DateTime.parse(rental.startDate))} - ${_dateFormat.format(DateTime.parse(rental.endDate))}',
                        ttf, ttfBold
                    ),
                    _buildPdfDetailRow('Harga Sewa', _currencyFormat.format(rental.rentPrice), ttf, ttfBold),
                  ],

                  if (payment.note != null && payment.note!.isNotEmpty) ...[
                    pw.Divider(),
                    _buildPdfDetailRow('Catatan', payment.note!, ttf, ttfBold),
                  ],

                  pw.Divider(thickness: 2),

                  // Footer
                  if (setting?.noteFooter != null && setting!.noteFooter!.isNotEmpty)
                    pw.Center(
                      child: pw.Text(
                        setting.noteFooter!,
                        style: ttf != null ? pw.TextStyle(font: ttf, fontSize: 10) : pw.TextStyle(fontSize: 10),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),

                  pw.SizedBox(height: 8),
                  pw.Center(
                    child: pw.Text(
                      'Terima Kasih',
                      style: ttfBold != null
                          ? pw.TextStyle(font: ttfBold, fontSize: 12)
                          : pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

      return pdf.save();
    } catch (e) {
      throw Exception('Gagal membuat PDF: ${e.toString()}');
    }
  }

  // Helper untuk membuat baris detail di PDF
  static pw.Widget _buildPdfDetailRow(
      String label,
      String value,
      [pw.Font? font, pw.Font? boldFont]  // Make font parameters optional and nullable
      ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              label,
              style: boldFont != null ? pw.TextStyle(font: boldFont) : pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Text(' : '),
          pw.Expanded(
            child: pw.Text(
              value,
              style: font != null ? pw.TextStyle(font: font) : null,
            ),
          ),
        ],
      ),
    );
  }

  // Menyimpan PDF ke penyimpanan lokal
  static Future<File> savePdf(Uint8List pdfBytes, String fileName) async {
    try {
      // Minta izin penyimpanan
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        // Coba gunakan direktori aplikasi jika izin tidak diberikan
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);

        // Tulis file
        await file.writeAsBytes(pdfBytes);
        return file;
      }

      // Jika izin diberikan, gunakan direktori dokumen
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);

      // Tulis file
      await file.writeAsBytes(pdfBytes);
      return file;
    } catch (e) {
      throw Exception('Gagal menyimpan PDF: ${e.toString()}');
    }
  }

  // Mencetak ke printer thermal
  static Future<void> printThermal({
    required Payment payment,
    required Rental? rental,
    required Room? room,
    required Tenant? tenant,
    required Setting? setting,
  }) async {
    try {
      // Simplified implementation that shows a message about thermal printing
      // This is a placeholder since the actual printer library has compatibility issues
      throw Exception('Printer thermal tidak tersedia. Fitur ini memerlukan konfigurasi printer yang sesuai.');

      /* Original code with issues:
    // Inisialisasi printer
    final printerManager = PrinterManager.instance;

    // Dapatkan daftar printer yang tersedia
    final devices = await printerManager.discoverPrinters();

    if (devices.isEmpty) {
      throw Exception('Tidak ada printer yang ditemukan. Pastikan printer thermal terhubung dan diaktifkan.');
    }

    // Tampilkan dialog pemilihan printer jika ada lebih dari satu printer
    // Catatan: Implementasi dialog pemilihan printer seharusnya dilakukan di UI, bukan di helper
    final printer = devices.first;

    // Buat generator ESC/POS
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);

    // Buat konten struk
    List<int> bytes = [];

    // Header
    bytes += generator.text(
      setting?.businessName ?? 'Manajemen Kost',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );

    // ... rest of the thermal printing code ...

    // Cetak ke printer
    try {
      await printerManager.connect(
        type: printer.type,
        model: printer.name,
        address: printer.address,  // This parameter doesn't exist
      );

      await printerManager.send(type: printer.type, bytes: bytes);
      await printerManager.disconnect(type: printer.type);
    } catch (e) {
      throw Exception('Gagal mencetak ke printer: ${e.toString()}');
    }
    */

    } catch (e) {
      rethrow;
    }
  }
}
