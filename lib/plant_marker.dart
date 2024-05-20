import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';
import 'package:flutter_cache_manager/file.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/*植物圖片(校園地圖)*/
class CustomMarker {
  static Future<Marker?> buildMarkerFromUrl({
    required String id,
    required String url,
    required LatLng position,
    double? width,
    double? height,
    Offset offset = const Offset(0.5, 0.5),
    VoidCallback? onTap,
  }) async {
    var icon = await getIconFromUrl(
      url,
      height: height,
      width: width,
    );

    if (icon == null) return null;

    return Marker(
      markerId: MarkerId(id),
      position: position,
      icon: BitmapDescriptor.fromBytes(icon),
      anchor: offset,
      onTap: onTap,
    );
  }

  static Future<Uint8List?> getIconFromUrl(String url, {
    double? width, // Change to double for flexibility
    double? height, // Change to double for flexibility
  }) async {
    var cache = CacheManager(Config(
      "markers",
      stalePeriod: const Duration(days: 7),
    ));

    File file = await cache.getSingleFile(url);

    // Load image bytes
    var imageBytes = await file.readAsBytes();

    // Create circular image
    ui.Image? image = await createCircularImage(imageBytes, width, height);

    // Convert image to PNG bytes
    if (image != null) {
      return await image.toByteData(format: ui.ImageByteFormat.png)
          .then((byteData) => byteData!.buffer.asUint8List());
    }

    return null;
  }

  static Future<ui.Image?> createCircularImage(
      Uint8List imageBytes, double? width, double? height) async { // Change to double for flexibility
    ui.Image? result;
    final Completer<ui.Image> completer = Completer();
    final Uint8List data = Uint8List.fromList(imageBytes);

    ui.decodeImageFromList(data, (ui.Image img) {
      var recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      double imageSize = width != null && height != null
          ? width < height
          ? width.toDouble()
          : height.toDouble()
          : img.width.toDouble() < img.height.toDouble()
          ? img.width.toDouble()
          : img.height.toDouble();

      var paint = Paint()..isAntiAlias = true;
      var imageSizeRect = Rect.fromLTWH(0, 0, imageSize, imageSize);

      // Create a circular path
      var path = Path()
        ..addOval(imageSizeRect);

      // Clip the canvas to the circular path
      canvas.clipPath(path);

      canvas.drawImageRect(
        img,
        Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
        imageSizeRect,
        paint,
      );

      recorder.endRecording().toImage(imageSize.toInt(), imageSize.toInt()).then((img) {
        completer.complete(img);
      });
    });

    result = await completer.future;
    return result;
  }
}
