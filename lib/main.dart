import 'dart:io';
import 'dart:ui' as ui;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as image;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Canvas Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // home: MyImage(),
      home: MyPainter(),
    );
  }
}

class MyImage extends StatelessWidget {
  const MyImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Painter"),
      ),
      body: Image.asset('images/sitemap.jpg'),
    );
  }
}

class MyPainter extends StatelessWidget {
  const MyPainter({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Painter"),
      ),
      body: FutureBuilder(
        builder: (BuildContext context, AsyncSnapshot<ui.Image> snapshot) {
          return FittedBox(
            child: SizedBox(
              width: 400,
              height: 400,
              child: CustomPaint(
                painter: ImagePainter(snapshot.data),
                child: Container(),
              ),
            ),
          );
        },
        future: loadImageResize(),
      ),
    );
  }
}

class ShapePainter extends CustomPainter {
  void drawCirc(Canvas canvas, Size size, paint) {
    Offset center = Offset(size.width / 2, size.height / 2);

    canvas.drawCircle(center, 10, paint);
  }

  void drawHorizontalLine(Canvas canvas, Size size, paint) {
    Offset startingPoint = Offset(0, size.height / 2);
    Offset endingPoint = Offset(size.width, size.height / 2);

    canvas.drawLine(startingPoint, endingPoint, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.teal
      ..strokeWidth = 5
      // ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    drawHorizontalLine(canvas, size, paint);
    drawCirc(canvas, size, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

Future<ui.Image> loadImage() async {
  final bytesBuffer = await rootBundle.load('images/sitemap.jpg');
  Uint8List fileBytes = bytesBuffer.buffer
      .asUint8List(bytesBuffer.offsetInBytes, bytesBuffer.lengthInBytes);
  return decodeImageFromList(fileBytes);
}

Future<ui.Image> loadImageResize() async {
  final bytesBuffer = await rootBundle.load('images/sitemap.jpg');
  Uint8List fileBytes = bytesBuffer.buffer
      .asUint8List(bytesBuffer.offsetInBytes, bytesBuffer.lengthInBytes);

  ui.Codec codec = await ui.instantiateImageCodec(
      bytesBuffer.buffer.asUint8List(),
      targetHeight: 600,
      targetWidth: 400);
  ui.FrameInfo frameInfo = await codec.getNextFrame();
  return frameInfo.image;
}

Future<ui.Image> loadImageResize2() async {
  //using the image package
  final assetImageByteData = await rootBundle.load('images/sitemap.jpg');
  image.Image baseSizeImage =
      image.decodeImage(assetImageByteData.buffer.asUint8List()) as image.Image;

  image.Image resizeImage =
      image.copyResize(baseSizeImage, height: 400, width: 400);

  ui.Codec codec = await ui.instantiateImageCodec(image.encodePng(resizeImage));
  ui.FrameInfo frameInfo = await codec.getNextFrame();
  return frameInfo.image;
}

class ImagePainter extends CustomPainter {
  final ui.Image? siteMapImage;
  ImagePainter(this.siteMapImage);

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    if (siteMapImage != null) {
      canvas.drawImage(siteMapImage!, Offset.zero, Paint());
    }
  }

  @override
  bool shouldRepaint(ImagePainter oldDelegate) {
    return siteMapImage != oldDelegate.siteMapImage;
  }
}
