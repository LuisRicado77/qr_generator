import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Generador de Código QR',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const QRGeneratorScreen(),
    );
  }
}

class QRGeneratorScreen extends StatelessWidget {
  const QRGeneratorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String bookInfo =
        "Sala: 30; \nMódulo: 57; \nEstante: 12; \nEntrepaño: 5; \nLado: B";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generador de Código QR'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FutureBuilder<Uint8List>(
            future: _generateQRCode(
                bookInfo), // Función para generar el QR como Uint8List
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData) {
                return Image.memory(snapshot.data!,
                    width: 300, height: 300); // Muestra la imagen del QR
              } else {
                return const CircularProgressIndicator(); // Muestra un indicador de carga mientras se genera el QR
              }
            },
          ),
          const SizedBox(height: 20), // Espacio entre el QR y el botón

          // Botón para guardar el QR como imagen

          ElevatedButton(
            onPressed: () async {
              final Uint8List pngBytes = await _generateQRCode(bookInfo);

              // Abrir diálogo para seleccionar el directorio
              String? selectedDirectory =
                  await FilePicker.platform.getDirectoryPath();
              if (selectedDirectory != null) {
                final path = '$selectedDirectory/qr_image.png';
                final file = File(path);
                await file.writeAsBytes(pngBytes);

                // Mostrar un mensaje al usuario
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('QR guardado en: $path'),
                ));
              }
            },
            child: const Text('Guardar QR como imagen'),
          )
        ],
      ),
    );
  }

  Future<Uint8List> _generateQRCode(String data) async {
    final qrValidationResult = QrValidator.validate(
      data: data,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.L,
    );

    if (qrValidationResult.status == QrValidationStatus.valid) {
      final qrCode = qrValidationResult.qrCode;

      final painter = QrPainter.withQr(
        qr: qrCode!,
        color: const Color(0xFF000000),
        emptyColor: const Color(0xFFFFFFFF),
        gapless: true,
      );

      // Renderizar la imagen 
      ui.PictureRecorder recorder = ui.PictureRecorder();
      Canvas canvas = Canvas(recorder);
      const size = 300.0; // Tamaño de la imagen
      painter.paint(canvas, const Size(size, size));
      final picture = recorder.endRecording();
      final img = await picture.toImage(size.toInt(), size.toInt());
      final ByteData? byteData =
          await img.toByteData(format: ui.ImageByteFormat.png);
      return byteData!.buffer.asUint8List();
    } else {
      throw Exception('Error al generar QR');
    }
  }
}
