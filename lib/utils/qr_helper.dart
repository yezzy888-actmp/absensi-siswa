import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

class QRHelper {
  static Future<String?> detectQRFromImage(File imageFile) async {
    MobileScannerController? controller;
    List<File> tempFiles = [];

    try {
      // Validate file exists and is readable
      if (!await imageFile.exists()) {
        debugPrint('File tidak ditemukan: ${imageFile.path}');
        return null;
      }

      // Validate image format first
      final Uint8List imageBytes = await imageFile.readAsBytes();
      final img.Image? testImage = img.decodeImage(imageBytes);

      if (testImage == null) {
        debugPrint('Gambar tidak dapat dibaca atau format tidak didukung');
        return null;
      }

      debugPrint('Info gambar: ${testImage.width}x${testImage.height}');

      controller = MobileScannerController();

      // Strategy 1: Try direct analysis first
      debugPrint('Strategi 1: Analisis langsung...');
      BarcodeCapture? result = await _analyzeImageSafely(
        controller,
        imageFile.path,
      );

      if (result != null && result.barcodes.isNotEmpty) {
        return _extractQRValue(result);
      }

      // Strategy 2: Try with enhanced contrast
      debugPrint('Strategi 2: Meningkatkan kontras...');
      File? contrastFile = await _enhanceContrast(imageFile);
      if (contrastFile != null) {
        tempFiles.add(contrastFile);
        result = await _analyzeImageSafely(controller, contrastFile.path);
        if (result != null && result.barcodes.isNotEmpty) {
          return _extractQRValue(result);
        }
      }

      // Strategy 3: Try with binary threshold
      debugPrint('Strategi 3: Menggunakan binary threshold...');
      File? binaryFile = await _applyBinaryThreshold(imageFile);
      if (binaryFile != null) {
        tempFiles.add(binaryFile);
        result = await _analyzeImageSafely(controller, binaryFile.path);
        if (result != null && result.barcodes.isNotEmpty) {
          return _extractQRValue(result);
        }
      }

      // Strategy 4: Try with padding
      debugPrint('Strategi 4: Menambahkan padding...');
      File? paddedFile = await _addPaddingToImage(imageFile);
      if (paddedFile != null) {
        tempFiles.add(paddedFile);
        result = await _analyzeImageSafely(controller, paddedFile.path);
        if (result != null && result.barcodes.isNotEmpty) {
          return _extractQRValue(result);
        }
      }

      // Strategy 5: Try with different scales
      debugPrint('Strategi 5: Mencoba berbagai ukuran...');
      List<double> scales = [0.5, 1.5, 2.0];
      for (double scale in scales) {
        File? scaledFile = await _resizeImage(imageFile, scale);
        if (scaledFile != null) {
          tempFiles.add(scaledFile);
          result = await _analyzeImageSafely(controller, scaledFile.path);
          if (result != null && result.barcodes.isNotEmpty) {
            return _extractQRValue(result);
          }
        }
      }

      // Strategy 6: Try with rotations
      debugPrint('Strategi 6: Mencoba rotasi gambar...');
      List<int> rotations = [90, 180, 270];
      for (int rotation in rotations) {
        File? rotatedFile = await _rotateImage(imageFile, rotation);
        if (rotatedFile != null) {
          tempFiles.add(rotatedFile);
          result = await _analyzeImageSafely(controller, rotatedFile.path);
          if (result != null && result.barcodes.isNotEmpty) {
            return _extractQRValue(result);
          }
        }
      }

      debugPrint('Semua strategi gagal. QR Code tidak ditemukan.');
      return null;
    } catch (e, stackTrace) {
      debugPrint('=== ERROR QR DETECTION ===');
      debugPrint('Error: $e');
      debugPrint('File: ${imageFile.path}');
      debugPrint('StackTrace: $stackTrace');
      debugPrint('==========================');
      return null;
    } finally {
      // Clean up resources
      try {
        controller?.dispose();
        for (File tempFile in tempFiles) {
          if (await tempFile.exists()) {
            await tempFile.delete();
          }
        }
      } catch (e) {
        debugPrint('Error cleaning up: $e');
      }
    }
  }

  static String? _extractQRValue(BarcodeCapture result) {
    final String? qrValue = result.barcodes.first.rawValue;
    if (qrValue != null && qrValue.isNotEmpty) {
      debugPrint(
        'QR Code berhasil terdeteksi: ${qrValue.length > 50 ? qrValue.substring(0, 50) + '...' : qrValue}',
      );
      return qrValue;
    }
    return null;
  }

  static Future<BarcodeCapture?> _analyzeImageSafely(
    MobileScannerController controller,
    String imagePath,
  ) async {
    try {
      // Add small delay to prevent resource conflicts
      await Future.delayed(const Duration(milliseconds: 100));
      return await controller.analyzeImage(imagePath);
    } catch (e) {
      debugPrint('Error dalam analyzeImage: $e');
      return null;
    }
  }

  static Future<File?> _enhanceContrast(File originalFile) async {
    try {
      final Uint8List imageBytes = await originalFile.readAsBytes();
      final img.Image? originalImage = img.decodeImage(imageBytes);

      if (originalImage == null) return null;

      // Convert to grayscale first
      img.Image processedImage = img.grayscale(originalImage);

      // Apply strong contrast enhancement
      processedImage = img.contrast(processedImage, contrast: 1.5);

      // Apply brightness adjustment
      processedImage = img.adjustColor(processedImage, brightness: 30);

      return await _saveImageToTemp(processedImage, 'contrast');
    } catch (e) {
      debugPrint('Error enhancing contrast: $e');
      return null;
    }
  }

  static Future<File?> _applyBinaryThreshold(File originalFile) async {
    try {
      final Uint8List imageBytes = await originalFile.readAsBytes();
      final img.Image? originalImage = img.decodeImage(imageBytes);

      if (originalImage == null) return null;

      // Convert to grayscale
      img.Image grayImage = img.grayscale(originalImage);

      // Apply binary threshold
      img.Image binaryImage = img.Image.from(grayImage);

      for (int y = 0; y < binaryImage.height; y++) {
        for (int x = 0; x < binaryImage.width; x++) {
          final pixel = binaryImage.getPixel(x, y);
          final luminance = img.getLuminance(pixel);

          // Apply threshold (adjust this value as needed)
          final newColor =
              luminance > 128
                  ? img.ColorRgb8(255, 255, 255)
                  : img.ColorRgb8(0, 0, 0);

          binaryImage.setPixel(x, y, newColor);
        }
      }

      return await _saveImageToTemp(binaryImage, 'binary');
    } catch (e) {
      debugPrint('Error applying binary threshold: $e');
      return null;
    }
  }

  static Future<File?> _addPaddingToImage(File originalFile) async {
    try {
      final Uint8List imageBytes = await originalFile.readAsBytes();
      final img.Image? originalImage = img.decodeImage(imageBytes);

      if (originalImage == null) return null;

      // Add more substantial padding
      final int padding = (originalImage.width * 0.2).round();

      final img.Image paddedImage = img.Image(
        width: originalImage.width + (padding * 2),
        height: originalImage.height + (padding * 2),
        backgroundColor: img.ColorRgb8(255, 255, 255),
      );

      img.compositeImage(
        paddedImage,
        originalImage,
        dstX: padding,
        dstY: padding,
      );

      return await _saveImageToTemp(paddedImage, 'padded');
    } catch (e) {
      debugPrint('Error adding padding: $e');
      return null;
    }
  }

  static Future<File?> _resizeImage(File originalFile, double scale) async {
    try {
      final Uint8List imageBytes = await originalFile.readAsBytes();
      final img.Image? originalImage = img.decodeImage(imageBytes);

      if (originalImage == null) return null;

      final int newWidth = (originalImage.width * scale).round();
      final int newHeight = (originalImage.height * scale).round();

      final img.Image resizedImage = img.copyResize(
        originalImage,
        width: newWidth,
        height: newHeight,
      );

      return await _saveImageToTemp(resizedImage, 'scaled_${scale}x');
    } catch (e) {
      debugPrint('Error resizing image: $e');
      return null;
    }
  }

  static Future<File?> _rotateImage(File originalFile, int degrees) async {
    try {
      final Uint8List imageBytes = await originalFile.readAsBytes();
      final img.Image? originalImage = img.decodeImage(imageBytes);

      if (originalImage == null) return null;

      late img.Image rotatedImage;

      switch (degrees) {
        case 90:
          rotatedImage = img.copyRotate(originalImage, angle: 90);
          break;
        case 180:
          rotatedImage = img.copyRotate(originalImage, angle: 180);
          break;
        case 270:
          rotatedImage = img.copyRotate(originalImage, angle: 270);
          break;
        default:
          return null;
      }

      return await _saveImageToTemp(rotatedImage, 'rotated_${degrees}');
    } catch (e) {
      debugPrint('Error rotating image: $e');
      return null;
    }
  }

  static Future<File?> _saveImageToTemp(img.Image image, String prefix) async {
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final String tempPath =
          '${tempDir.path}/${prefix}_qr_${DateTime.now().millisecondsSinceEpoch}.png';
      final File tempFile = File(tempPath);

      await tempFile.writeAsBytes(img.encodePng(image));
      debugPrint('Gambar $prefix berhasil disimpan: $tempPath');
      return tempFile;
    } catch (e) {
      debugPrint('Error menyimpan gambar $prefix: $e');
      return null;
    }
  }

  static bool isValidImageFile(File file) {
    final String extension = file.path.toLowerCase();
    return extension.endsWith('.jpg') ||
        extension.endsWith('.jpeg') ||
        extension.endsWith('.png') ||
        extension.endsWith('.bmp') ||
        extension.endsWith('.gif') ||
        extension.endsWith('.heic') ||
        extension.endsWith('.heif') ||
        extension.endsWith('.webp');
  }

  static Future<bool> isValidFileSize(File file, {int maxSizeInMB = 10}) async {
    try {
      final int fileSizeInBytes = await file.length();
      final int maxSizeInBytes = maxSizeInMB * 1024 * 1024;
      return fileSizeInBytes <= maxSizeInBytes;
    } catch (e) {
      debugPrint('Error checking file size: $e');
      return false;
    }
  }

  static Future<String> getImageInfo(File file) async {
    try {
      final int sizeInBytes = await file.length();
      final double sizeInMB = sizeInBytes / (1024 * 1024);

      final Uint8List imageBytes = await file.readAsBytes();
      final img.Image? image = img.decodeImage(imageBytes);

      if (image != null) {
        return 'Ukuran: ${image.width}x${image.height}, '
            'File: ${sizeInMB.toStringAsFixed(2)} MB';
      } else {
        return 'File: ${sizeInMB.toStringAsFixed(2)} MB (format tidak didukung)';
      }
    } catch (e) {
      return 'Error membaca info gambar';
    }
  }
}

class QRDataProcessor {
  static Map<String, dynamic>? parseQRData(String qrRawData) {
    try {
      debugPrint('Parsing QR data: $qrRawData');

      // Try to parse as JSON first
      final Map<String, dynamic> qrData = jsonDecode(qrRawData);

      debugPrint('JSON parsed successfully: $qrData');

      // Validate required fields
      if (qrData.containsKey('token') &&
          qrData.containsKey('type') &&
          qrData['type'] == 'attendance') {
        debugPrint('Valid attendance QR detected');
        return qrData;
      }

      debugPrint('QR data structure invalid for attendance');

      // If not JSON or invalid structure, treat as plain token
      if (qrRawData.isNotEmpty) {
        debugPrint('Treating as plain token');
        return {'token': qrRawData, 'type': 'attendance'};
      }

      return null;
    } catch (e) {
      debugPrint('JSON parsing failed: $e');
      // If JSON parsing fails, treat as plain token
      if (qrRawData.isNotEmpty) {
        debugPrint('Treating as plain token (fallback)');
        return {'token': qrRawData, 'type': 'attendance'};
      }
      return null;
    }
  }

  static bool isValidAttendanceQR(Map<String, dynamic> qrData) {
    final bool isValid =
        qrData.containsKey('token') &&
        qrData.containsKey('type') &&
        qrData['type'] == 'attendance' &&
        qrData['token'].toString().isNotEmpty;

    debugPrint('QR validation result: $isValid for data: $qrData');
    return isValid;
  }

  static String getDisplayInfo(Map<String, dynamic> qrData) {
    final List<String> info = [];

    if (qrData.containsKey('subject')) {
      info.add('Mata Pelajaran: ${qrData['subject']}');
    }
    if (qrData.containsKey('class')) {
      info.add('Kelas: ${qrData['class']}');
    }
    if (qrData.containsKey('date')) {
      try {
        final DateTime date = DateTime.parse(qrData['date']);
        final String formattedDate =
            '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
        final String formattedTime =
            '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
        info.add('Tanggal: $formattedDate');
        info.add('Waktu: $formattedTime');
      } catch (e) {
        // If date parsing fails, show raw date
        info.add('Tanggal: ${qrData['date']}');
      }
    }

    return info.join('\n');
  }
}
