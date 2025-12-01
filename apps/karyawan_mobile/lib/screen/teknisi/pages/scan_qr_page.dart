import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanQRPage extends StatefulWidget {
  const ScanQRPage({super.key});

  @override
  State<ScanQRPage> createState() => _ScanQRPageState();
}

class _ScanQRPageState extends State<ScanQRPage> {
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );

  bool _isScanning = true;
  String? _scannedCode;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture barcodeCapture) {
    if (!_isScanning) return;

    final List<Barcode> barcodes = barcodeCapture.barcodes;
    if (barcodes.isNotEmpty) {
      final String code = barcodes.first.rawValue ?? '';

      setState(() {
        _isScanning = false;
        _scannedCode = code;
      });

      // Haptic feedback
      // HapticFeedback.mediumImpact();

      // Tampilkan dialog hasil scan
      _showScanResult(code);
    }
  }

  void _showScanResult(String code) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.qr_code_scanner, color: Color(0xFF0A9C5D)),
                SizedBox(width: 8),
                Text('QR Code Terdeteksi'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kode yang di-scan:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: SelectableText(
                    code,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _isScanning = true;
                    _scannedCode = null;
                  });
                },
                child: const Text('Scan Lagi'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Proses kode QR (misalnya: cari mesin berdasarkan kode)
                  _processQRCode(code);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A9C5D),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Proses'),
              ),
            ],
          ),
    );
  }

  void _processQRCode(String code) {
    // TODO: Implementasi logika untuk memproses QR code
    // Contoh: Cari mesin berdasarkan kode, buka detail mesin, dll

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text('QR Code diproses: $code')),
          ],
        ),
        backgroundColor: const Color(0xFF0A9C5D),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );

    // Reset untuk scan berikutnya
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isScanning = true;
          _scannedCode = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF0A9C5D);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Scan QR Code Mesin',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              controller.torchEnabled ? Icons.flash_on : Icons.flash_off,
            ),
            onPressed: () => controller.toggleTorch(),
            tooltip: 'Toggle Flash',
          ),
          IconButton(
            icon: const Icon(Icons.switch_camera),
            onPressed: () => controller.switchCamera(),
            tooltip: 'Switch Camera',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera Preview
          MobileScanner(controller: controller, onDetect: _handleBarcode),

          // Overlay dengan frame scan
          CustomPaint(
            painter: QRScannerOverlay(scanArea: 250.0, borderColor: primary),
            child: Container(),
          ),

          // Instructions
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Arahkan kamera ke QR Code mesin',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_scannedCode != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            'Terdeteksi: $_scannedCode',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter untuk overlay frame scan
class QRScannerOverlay extends CustomPainter {
  final double scanArea;
  final Color borderColor;

  QRScannerOverlay({required this.scanArea, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;
    final double scanAreaWidth = scanArea;
    final double scanAreaHeight = scanArea;

    // Hitung posisi tengah
    final double left = (width - scanAreaWidth) / 2;
    final double top =
        (height - scanAreaHeight) / 2 - 50; // Offset untuk AppBar

    // Gambar overlay gelap di sekeliling
    final Paint overlayPaint = Paint()..color = Colors.black.withOpacity(0.5);

    // Atas
    canvas.drawRect(Rect.fromLTWH(0, 0, width, top), overlayPaint);
    // Bawah
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        top + scanAreaHeight,
        width,
        height - top - scanAreaHeight,
      ),
      overlayPaint,
    );
    // Kiri
    canvas.drawRect(Rect.fromLTWH(0, top, left, scanAreaHeight), overlayPaint);
    // Kanan
    canvas.drawRect(
      Rect.fromLTWH(
        left + scanAreaWidth,
        top,
        width - left - scanAreaWidth,
        scanAreaHeight,
      ),
      overlayPaint,
    );

    // Gambar border frame
    final Paint borderPaint =
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0;

    final double cornerLength = 30.0;

    // Corner kiri atas
    canvas.drawLine(
      Offset(left, top),
      Offset(left + cornerLength, top),
      borderPaint,
    );
    canvas.drawLine(
      Offset(left, top),
      Offset(left, top + cornerLength),
      borderPaint,
    );

    // Corner kanan atas
    canvas.drawLine(
      Offset(left + scanAreaWidth - cornerLength, top),
      Offset(left + scanAreaWidth, top),
      borderPaint,
    );
    canvas.drawLine(
      Offset(left + scanAreaWidth, top),
      Offset(left + scanAreaWidth, top + cornerLength),
      borderPaint,
    );

    // Corner kiri bawah
    canvas.drawLine(
      Offset(left, top + scanAreaHeight - cornerLength),
      Offset(left, top + scanAreaHeight),
      borderPaint,
    );
    canvas.drawLine(
      Offset(left, top + scanAreaHeight),
      Offset(left + cornerLength, top + scanAreaHeight),
      borderPaint,
    );

    // Corner kanan bawah
    canvas.drawLine(
      Offset(left + scanAreaWidth - cornerLength, top + scanAreaHeight),
      Offset(left + scanAreaWidth, top + scanAreaHeight),
      borderPaint,
    );
    canvas.drawLine(
      Offset(left + scanAreaWidth, top + scanAreaHeight - cornerLength),
      Offset(left + scanAreaWidth, top + scanAreaHeight),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
