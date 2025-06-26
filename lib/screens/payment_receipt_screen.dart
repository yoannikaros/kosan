import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kosan/models/payment.dart';
import 'package:kosan/models/rental.dart';
import 'package:kosan/models/room.dart';
import 'package:kosan/models/setting.dart';
import 'package:kosan/models/tenant.dart';
import 'package:kosan/repositories/rental_repository.dart';
import 'package:kosan/repositories/room_repository.dart';
import 'package:kosan/repositories/setting_repository.dart';
import 'package:kosan/repositories/tenant_repository.dart';
import 'package:kosan/helpers/receipt_helper.dart';
import 'package:kosan/screens/pdf_viewer_screen.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'dart:typed_data';
import 'dart:async';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

class PaymentReceiptScreen extends StatefulWidget {
  final Payment payment;
  final int ownerId;

  const PaymentReceiptScreen({
    Key? key,
    required this.payment,
    required this.ownerId,
  }) : super(key: key);

  @override
  State<PaymentReceiptScreen> createState() => _PaymentReceiptScreenState();
}

class _PaymentReceiptScreenState extends State<PaymentReceiptScreen> {
  final _rentalRepository = RentalRepository();
  final _roomRepository = RoomRepository();
  final _tenantRepository = TenantRepository();
  final _settingRepository = SettingRepository();
  
  bool _isLoading = true;
  Rental? _rental;
  Room? _room;
  Tenant? _tenant;
  Setting? _setting;
  
  final _dateFormat = DateFormat('dd/MM/yyyy');
  final _currencyFormat = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  
  final GlobalKey _receiptKey = GlobalKey();
  bool _isCapturing = false;
  String _captureMessage = '';
  bool _isPrinting = false;
  bool _isGeneratingPdf = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Ambil data rental
      final rental = await _rentalRepository.getRentalById(widget.payment.rentalId);
      if (rental != null) {
        _rental = rental;
        
        // Ambil data kamar
        final room = await _roomRepository.getRoomById(rental.roomId);
        _room = room;
        
        // Ambil data penyewa
        final tenant = await _tenantRepository.getTenantById(rental.tenantId);
        _tenant = tenant;
      }
      
      // Ambil pengaturan
      final setting = await _settingRepository.getSettingByOwnerId(widget.ownerId);
      _setting = setting;
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _captureAndSaveReceipt() async {
    setState(() {
      _isCapturing = true;
      _captureMessage = 'Memproses screenshot...';
    });

    try {
      // Delay untuk memastikan UI sudah dirender dengan benar
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Pastikan context masih valid
      if (!mounted) {
        setState(() {
          _isCapturing = false;
        });
        return;
      }

      // Pastikan _receiptKey.currentContext tidak null
      if (_receiptKey.currentContext == null) {
        setState(() {
          _isCapturing = false;
          _captureMessage = 'Gagal mengambil screenshot: Context tidak ditemukan';
        });
        return;
      }
      
      RenderRepaintBoundary? boundary = _receiptKey.currentContext!.findRenderObject() as RenderRepaintBoundary?;
      
      if (boundary == null) {
        setState(() {
          _isCapturing = false;
          _captureMessage = 'Gagal mengambil screenshot: Boundary tidak ditemukan';
        });
        return;
      }
      
      // Coba ambil gambar dengan pixelRatio yang lebih rendah jika gagal
      ui.Image image;
      try {
        image = await boundary.toImage(pixelRatio: 3.0);
      } catch (e) {
        image = await boundary.toImage(pixelRatio: 1.0);
      }
      
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData != null) {
        Uint8List pngBytes = byteData.buffer.asUint8List();
        
        // Salin ke clipboard sebagai teks (karena Flutter tidak mendukung clipboard gambar secara langsung)
        await Clipboard.setData(ClipboardData(text: 'Struk Pembayaran'));
        
        setState(() {
          _captureMessage = 'Screenshot berhasil diambil!';
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Screenshot struk berhasil! Silakan ambil screenshot layar untuk menyimpan gambar.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _captureMessage = 'Error: ${e.toString()}';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isCapturing = false;
      });
    }
  }

  Future<void> _printReceipt() async {
    setState(() {
      _isPrinting = true;
    });

    try {
      // Generate PDF
      final pdfBytes = await ReceiptHelper.generatePdf(
        payment: widget.payment,
        rental: _rental,
        room: _room,
        tenant: _tenant,
        setting: _setting,
      );

      // Cetak PDF
      final result = await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
        name: 'Struk_Pembayaran_${widget.payment.id}',
      );

      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Struk berhasil dicetak'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pencetakan dibatalkan'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saat mencetak: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isPrinting = false;
      });
    }
  }

  Future<void> _printThermal() async {
    setState(() {
      _isPrinting = true;
    });

    try {
      // Periksa apakah printer thermal tersedia
      try {
        await ReceiptHelper.printThermal(
          payment: widget.payment,
          rental: _rental,
          room: _room,
          tenant: _tenant,
          setting: _setting,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Struk berhasil dicetak ke printer thermal'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        // Tampilkan dialog error yang lebih informatif
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Gagal Mencetak ke Printer Thermal'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Error: ${e.toString()}'),
                const SizedBox(height: 16),
                const Text(
                  'Pastikan:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text('1. Printer thermal terhubung dan menyala'),
                const Text('2. Bluetooth diaktifkan (untuk printer bluetooth)'),
                const Text('3. Printer terhubung ke jaringan yang sama (untuk printer jaringan)'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _printReceipt(); // Coba cetak ke printer biasa sebagai alternatif
                },
                child: const Text('Cetak ke Printer Biasa'),
              ),
            ],
          ),
        );
      }
    } finally {
      setState(() {
        _isPrinting = false;
      });
    }
  }

  Future<void> _generateAndViewPdf() async {
    setState(() {
      _isGeneratingPdf = true;
    });

    try {
      // Generate PDF
      final pdfBytes = await ReceiptHelper.generatePdf(
        payment: widget.payment,
        rental: _rental,
        room: _room,
        tenant: _tenant,
        setting: _setting,
      );

      // Simpan PDF
      final fileName = 'struk_pembayaran_${widget.payment.id ?? DateTime.now().millisecondsSinceEpoch}.pdf';
      
      try {
        final pdfFile = await ReceiptHelper.savePdf(pdfBytes, fileName);

        // Tampilkan PDF
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PdfViewerScreen(
              pdfFile: pdfFile,
              title: 'Struk Pembayaran',
            ),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan PDF: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuat PDF: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isGeneratingPdf = false;
      });
    }
  }

  Future<void> _sharePdf() async {
    setState(() {
      _isGeneratingPdf = true;
    });

    try {
      // Generate PDF
      final pdfBytes = await ReceiptHelper.generatePdf(
        payment: widget.payment,
        rental: _rental,
        room: _room,
        tenant: _tenant,
        setting: _setting,
      );

      // Simpan PDF
      final fileName = 'struk_pembayaran_${widget.payment.id ?? DateTime.now().millisecondsSinceEpoch}.pdf';
      
      try {
        final pdfFile = await ReceiptHelper.savePdf(pdfBytes, fileName);

        // Bagikan PDF
        await Share.shareXFiles(
          [XFile(pdfFile.path)],
          text: 'Struk Pembayaran',
          subject: 'Struk Pembayaran #${widget.payment.id}',
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal berbagi PDF: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuat PDF: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isGeneratingPdf = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Struk Pembayaran'),
        actions: [
          if (!_isLoading)
            PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'print') {
                  _printReceipt();
                } else if (value == 'thermal') {
                  _printThermal();
                } else if (value == 'pdf') {
                  _generateAndViewPdf();
                } else if (value == 'share') {
                  _sharePdf();
                } else if (value == 'screenshot') {
                  _captureAndSaveReceipt();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'print',
                  child: Row(
                    children: [
                      Icon(Icons.print, color: Colors.black),
                      SizedBox(width: 8),
                      Text('Cetak'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'thermal',
                  child: Row(
                    children: [
                      Icon(Icons.receipt_long, color: Colors.black),
                      SizedBox(width: 8),
                      Text('Cetak ke Thermal'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'pdf',
                  child: Row(
                    children: [
                      Icon(Icons.picture_as_pdf, color: Colors.black),
                      SizedBox(width: 8),
                      Text('Lihat PDF'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      Icon(Icons.share, color: Colors.black),
                      SizedBox(width: 8),
                      Text('Bagikan PDF'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'screenshot',
                  child: Row(
                    children: [
                      Icon(Icons.camera_alt, color: Colors.black),
                      SizedBox(width: 8),
                      Text('Screenshot'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      RepaintBoundary(
                        key: _receiptKey,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header
                              Center(
                                child: Column(
                                  children: [
                                    Text(
                                      _setting?.businessName ?? 'Manajemen Kost',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 4),
                                    if (_setting?.noteHeader != null && _setting!.noteHeader!.isNotEmpty)
                                      Text(
                                        _setting!.noteHeader!,
                                        style: const TextStyle(fontSize: 12),
                                        textAlign: TextAlign.center,
                                      ),
                                  ],
                                ),
                              ),
                              const Divider(thickness: 2),
                              
                              // Informasi Pembayaran
                              const Center(
                                child: Text(
                                  'STRUK PEMBAYARAN',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              // Detail Pembayaran
                              _buildDetailRow('No. Pembayaran', '#${widget.payment.id ?? "New"}'),
                              _buildDetailRow('Tanggal', _dateFormat.format(DateTime.parse(widget.payment.paymentDate))),
                              _buildDetailRow('Jumlah', _currencyFormat.format(widget.payment.amount)),
                              if (widget.payment.paymentMethod != null && widget.payment.paymentMethod!.isNotEmpty)
                                _buildDetailRow('Metode Pembayaran', widget.payment.paymentMethod!),
                              
                              const Divider(),
                              
                              // Detail Kamar & Penyewa
                              if (_room != null)
                                _buildDetailRow('Kamar', 'Kamar ${_room!.roomNumber}'),
                              if (_tenant != null)
                                _buildDetailRow('Penyewa', _tenant!.name),
                              if (_rental != null) ...[
                                _buildDetailRow('Periode Sewa', '${_dateFormat.format(DateTime.parse(_rental!.startDate))} - ${_dateFormat.format(DateTime.parse(_rental!.endDate))}'),
                                _buildDetailRow('Harga Sewa', _currencyFormat.format(_rental!.rentPrice)),
                              ],
                              
                              if (widget.payment.note != null && widget.payment.note!.isNotEmpty) ...[
                                const Divider(),
                                _buildDetailRow('Catatan', widget.payment.note!),
                              ],
                              
                              const Divider(thickness: 2),
                              
                              // Footer
                              if (_setting?.noteFooter != null && _setting!.noteFooter!.isNotEmpty)
                                Center(
                                  child: Text(
                                    _setting!.noteFooter!,
                                    style: const TextStyle(fontSize: 12),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              
                              const SizedBox(height: 8),
                              const Center(
                                child: Text(
                                  'Terima Kasih',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isPrinting ? null : _printReceipt,
                              icon: const Icon(Icons.print),
                              label: Text(_isPrinting ? 'Mencetak...' : 'Cetak'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isGeneratingPdf ? null : _sharePdf,
                              icon: const Icon(Icons.share),
                              label: Text(_isGeneratingPdf ? 'Memproses...' : 'Bagikan'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _isGeneratingPdf ? null : _generateAndViewPdf,
                        icon: const Icon(Icons.picture_as_pdf),
                        label: Text(_isGeneratingPdf ? 'Memproses PDF...' : 'Lihat sebagai PDF'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isCapturing ? _captureMessage : 'Pilih opsi di atas untuk mencetak atau berbagi struk',
                        style: TextStyle(
                          fontSize: 12,
                          color: _captureMessage.contains('Error') ? Colors.red : Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                if (_isPrinting || _isGeneratingPdf)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('Memproses...'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Text(' : '),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
