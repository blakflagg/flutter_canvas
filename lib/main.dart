import 'dart:io';
import 'dart:ui' as ui;
import 'dart:convert';
import 'dart:collection';
import 'dart:math';
import 'package:flutter/gestures.dart';
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

class MyPainter extends StatefulWidget {
  const MyPainter({super.key});

  @override
  State<MyPainter> createState() => _MyPainterState();
}

class _MyPainterState extends State<MyPainter> {
  List<Point> points = [];

  double tX = 0;
  double tY = 0;
  double scale = 1.0;

  void addPoint(Offset position) {
    double x, y;
    x = position.dx / scale;
    y = position.dy / scale;

    Point p = Point(x - tX, y - tY);
    print(p.toString());
    setState(() {
      points.add(p);
    });
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    double scaleDelta = 0.0;

    double scaleTemp = 1.0;
    scaleTemp = details.scale.clamp(-0.24, 2.5);

    if (scaleTemp != 1 && scaleTemp >= -0.24 && scaleTemp <= 2.5) {
      scaleDelta = scale - scaleTemp;
    } else {
      scaleDelta = 0;
    }

    setState(() {
      if (scaleDelta < 0) {
        zoomIn(scaleDelta);
      } else if (scaleDelta > 0) {
        zoomOut(scaleDelta);
      }

      tX += details.focalPointDelta.dx;
      tY += details.focalPointDelta.dy;
    });
    scaleTemp = 0;
  }

  void zoomIn(double scaleDelta) {
    if (scale > 2.5) {
      scale = 2.5;
    }

    if (scale < 2.5) {
      scale += 0.01; //scaleDelta.abs();
    }
  }

  void zoomOut(double scaleDelta) {
    if (scale <= 0.24) {
      scale = 0.24;
    }

    if (scale > -0.24) {
      scale -= 0.01;
    }
  }

  void _completeLongPress(LongPressStartDetails details) {
    addPoint(details.localPosition);
  }

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
              height: 600,
              child: GestureDetector(
                onScaleUpdate: _handleScaleUpdate,
                onLongPressStart: _completeLongPress,
                // onScaleEnd: _handleScaleEnd,
                child: CustomPaint(
                  painter: ImagePainter(snapshot.data, points, tX, tY, scale),
                  child: Container(),
                ),
              ),
            ),
          );
        },
        future: loadImageResize(),
      ),
    );
  }
}

class Point {
  final double x, y;
  Point(this.x, this.y);

  @override
  String toString() {
    return 'x:$x y:$y';
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
      targetHeight: 2200,
      targetWidth: 1700);
  ui.FrameInfo frameInfo = await codec.getNextFrame();
  return frameInfo.image;
}

class ImagePainter extends CustomPainter {
  final ui.Image? siteMapImage;
  final List<Point> points;
  final scale;
  final double tX, tY;
  ImagePainter(this.siteMapImage, this.points, this.tX, this.tY, this.scale);

  void drawPoint(Canvas canvas, Point coords, double size, Paint paint) {
    paint..color = ui.Color.fromRGBO(244, 236, 7, 0.56);

    Offset center = Offset(coords.x, coords.y);
    canvas.drawCircle(center, size, paint);
  }

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    if (siteMapImage != null) {
      canvas.scale(scale);
      canvas.translate(tX, tY);
      canvas.drawImage(siteMapImage!, Offset.zero, Paint());
      for (var i = 0; i < points.length; i++) {
        drawPoint(canvas, points[i], 10, Paint());
      }
    }
  }

  @override
  bool shouldRepaint(ImagePainter oldDelegate) {
    return (siteMapImage != oldDelegate.siteMapImage ||
        points.length != oldDelegate.points.length ||
        tX != oldDelegate.tX ||
        tY != oldDelegate.tY);
  }
}
