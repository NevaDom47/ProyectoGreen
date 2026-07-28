import 'dart:io';
import 'package:exif/exif.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class ImageVerificationResult {
  final bool isLive;
  final int confidenceScore;
  final String label;

  ImageVerificationResult({
    required this.isLive,
    required this.confidenceScore,
    required this.label,
  });
}

class ImageVerificationService {
  static Future<ImageVerificationResult> analyzeImage(XFile xFile, ImageSource source) async {
    int score = 0;
    
    // 1. Base Source Evaluation
    if (source == ImageSource.camera) {
      score += 50;
    } else {
      score -= 50;
    }

    final now = DateTime.now();

    try {
      // 2. File modification time (only available on native via dart:io)
      if (!kIsWeb) {
        File file = File(xFile.path);
        if (file.existsSync()) {
          final stat = file.statSync();
          final modifiedDiff = now.difference(stat.modified).inMinutes.abs();
          if (modifiedDiff < 2) {
            score += 20;
          } else {
            score -= 20;
          }
        }
      }

      // 3. EXIF Analysis
      final bytes = await xFile.readAsBytes();
      final Map<String, IfdTag> exifData = await readExifFromBytes(bytes);

      if (exifData.isNotEmpty) {
        final dateTimeTag = exifData['Image DateTime'] ?? exifData['EXIF DateTimeOriginal'];
        if (dateTimeTag != null) {
          try {
            // Exif format: "YYYY:MM:DD HH:MM:SS"
            final parts = dateTimeTag.printable.split(' ');
            if (parts.length == 2) {
              final dateParts = parts[0].split(':');
              final timeParts = parts[1].split(':');
              if (dateParts.length == 3 && timeParts.length >= 2) {
                final exifDate = DateTime(
                  int.parse(dateParts[0]),
                  int.parse(dateParts[1]),
                  int.parse(dateParts[2]),
                  int.parse(timeParts[0]),
                  int.parse(timeParts[1]),
                  timeParts.length == 3 ? int.parse(timeParts[2]) : 0,
                );
                final exifDiff = now.difference(exifDate).inMinutes.abs();
                if (exifDiff < 2) {
                  score += 20;
                } else {
                  score -= 30; // old photo
                }
              }
            }
          } catch (e) {
            debugPrint("EXIF Date parsing error: $e");
          }
        }

        final softwareTag = exifData['Image Software'];
        if (softwareTag != null) {
          final software = softwareTag.printable.toLowerCase();
          if (software.contains('photoshop') || 
              software.contains('lightroom') || 
              software.contains('canva') || 
              software.contains('snapseed')) {
            score -= 50; // Heavily edited
          }
        }
      } else {
        // No EXIF data. If it came from camera, that's normal for some devices temp files.
        if (source == ImageSource.camera) {
          score += 10;
        }
      }
    } catch (e) {
      debugPrint("Error analyzing image: $e");
    }

    final isLive = score >= 40;
    return ImageVerificationResult(
      isLive: isLive,
      confidenceScore: score,
      label: isLive ? 'En Vivo' : 'De Galería',
    );
  }
}
