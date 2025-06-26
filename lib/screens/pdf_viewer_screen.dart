import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:share_plus/share_plus.dart';

class PdfViewerScreen extends StatefulWidget {
  final File pdfFile;
  final String title;

  const PdfViewerScreen({
    Key? key,
    required this.pdfFile,
    required this.title,
  }) : super(key: key);

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  int _totalPages = 0;
  int _currentPage = 0;
  bool _isLoading = true;

  // Perbaikan pada _sharePdf untuk menangani error dengan lebih baik
  Future<void> _sharePdf() async {
    try {
      if (!await widget.pdfFile.exists()) {
        throw Exception('File PDF tidak ditemukan');
      }

      await Share.shareXFiles(
        [XFile(widget.pdfFile.path)],
        text: 'Struk Pembayaran',
        subject: widget.title,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saat berbagi PDF: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Tambahkan fungsi untuk menangani error pada PDFView
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _sharePdf,
            tooltip: 'Bagikan PDF',
          ),
        ],
      ),
      body: FutureBuilder<bool>(
        future: widget.pdfFile.exists(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || (snapshot.hasData && !snapshot.data!)) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'File PDF tidak dapat dibuka: ${snapshot.error ?? "File tidak ditemukan"}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Kembali'),
                  ),
                ],
              ),
            );
          }

          return Stack(
            children: [
              PDFView(
                filePath: widget.pdfFile.path,
                enableSwipe: true,
                swipeHorizontal: false,
                autoSpacing: true,
                pageFling: true,
                pageSnap: true,
                defaultPage: _currentPage,
                fitPolicy: FitPolicy.BOTH,
                preventLinkNavigation: false,
                onRender: (_pages) {
                  setState(() {
                    _totalPages = _pages!;
                    _isLoading = false;
                  });
                },
                onError: (error) {
                  setState(() {
                    _isLoading = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $error'),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
                onPageError: (page, error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error pada halaman $page: $error'),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
                onViewCreated: (PDFViewController pdfViewController) {
                  // Controller dapat digunakan untuk navigasi halaman
                },
                onPageChanged: (int? page, int? total) {
                  if (page != null) {
                    setState(() {
                      _currentPage = page;
                    });
                  }
                },
              ),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: _totalPages > 1
          ? BottomAppBar(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Halaman ${_currentPage + 1} dari $_totalPages',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
