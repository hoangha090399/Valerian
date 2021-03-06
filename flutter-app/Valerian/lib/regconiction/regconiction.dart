import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;

// import 'dart:ui' as ui;
const JPEG_EOI = [255, 217];

/// [Recognition] model & lable & documentation
/// from tensorflow could be found here
/// https://www.tensorflow.org/lite/models/object_detection/overview
///

class Recognition {
  static List<int> temper;
  static List<dynamic> detectionResult;
  // static ui.Image testFlutterImageLib;
  Future<bool> loadModel() async {
    try {
      String res = await Tflite.loadModel(
          model: 'assets/model/detect.tflite',
          numThreads: 1,
          labels: "assets/model/labelmap.txt");
      if (res != null) {
        print("Model loaded");
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print(e);
    }
  }

  static Uint8List imageToByteListUint8(img.Image image, int inputSize) {
    var convertedBytes = Uint8List(1 * inputSize * inputSize * 3);
    var buffer = Uint8List.view(convertedBytes.buffer);
    int pixelIndex = 0;
    for (var i = 0; i < inputSize; i++) {
      for (var j = 0; j < inputSize; j++) {
        var pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = img.getRed(pixel);
        buffer[pixelIndex++] = img.getGreen(pixel);
        buffer[pixelIndex++] = img.getBlue(pixel);
      }
    }
    return convertedBytes.buffer.asUint8List();
  }

  objectDection(img.Image img) async {
    try {
      var recognitions = await Tflite.detectObjectOnBinary(
          binary: imageToByteListUint8(img, 300), // required
          threshold: 0.1, // defaults to 0.1
          numResultsPerClass: 10, // defaults to 5
          asynch: true);
      if (recognitions != null) {
        return recognitions;
      } else {
        return null;
      }
    } catch (e) {
      print(e);
    }
  }

  static Future<List<dynamic>> objectDection_V1(String imgURL) async {
    try {
      if (!imgURL.contains("http")) {
        return null;
      }
      var respone = await http.get(imgURL);
      if (respone.statusCode != 200) {
        return null;
      }
      var pic = img.decodeImage(respone.bodyBytes); // byte Input
      var resize = img.copyResize(pic, width: 300, height: 300); // Resize
      // ui.decodeImageFromList(respone.bodyBytes, (result) {
      //   testFlutterImageLib = result;
      //  });
      // resize.getBytes();
      var recognitions = await Tflite.detectObjectOnBinary(
          binary: imageToByteListUint8(resize, 300),
          threshold: 0.3, // defaults to 0.1
          numResultsPerClass: 1, // defaults to 5
          asynch: true);
      if (recognitions != null) {
        temper = img.encodePng(pic); // Faster then jpeg
        // (
        // pic,
        // 100,
        // 200,
        // 300,
        // 400,
        // // (recognitions[0]['rect']['y'] * 300).round(),
        // // (recognitions[0]['rect']['w'] * 300).round(),
        // // (recognitions[0]['rect']['x'] * 300).round(),
        // // (recognitions[0]['rect']['h'] * 300).round(),
        // Color.fromRGBO(255, 100, 50, 1).red)
        // )
        print("Decteced");
        return recognitions;
      } else {
        return null;
      }
    } catch (e) {
      print(e);
    }
  }

  static bool jpegCheck(Uint8List imgBytes) {
    if (imgBytes.last != 217 &&
        imgBytes.elementAt(imgBytes.length - 2) != 255) {
      print("Missing JPEG EOI");
    }
  }

  static Future<List<dynamic>> objectDection_V2_BlueSerial(
      Uint8List imgBytes) async {
    try {
      img.Image pic;
      if (imgBytes.last != 217 &&
          imgBytes.elementAt(imgBytes.length - 2) != 255) {
        print("Missing JPEG EOI");
        // imgBytes.addAll([255, 217]);
      }
      pic = img.decodeImage(imgBytes); // byte Input

      // // var newer  = Image.memory(imgBytes);
      print('${pic.width}  :  ${pic.height}');
      var resize = img.copyResize(pic, width: 300, height: 300); // Resize
      temper = img.encodePng(pic);
      var recognitions = await Tflite.detectObjectOnBinary(
          binary: imageToByteListUint8(resize, 300),
          threshold: 0.3, // defaults to 0.1
          numResultsPerClass: 1, // defaults to 5
          asynch: true);
      if (recognitions != null) {
        // temper = img.encodePng(pic); // Faster then jpeg
        // print("Decteced");
        return recognitions;
      } else {
        return null;
      }
    } catch (e) {
      print(e);
    }
  }

  dispose() async {
    await Tflite.close();
  }

  static final Recognition _singleton = Recognition._internal();

  factory Recognition() {
    return _singleton;
  }

  Recognition._internal();
}

// static Future<List<dynamic>> objectDection_V2_BlueSerial(Uint8List imgBytes) async {
//   try {
//     img.Image pic;
//     Uint8List newIamge;
//     if (imgBytes.last != 217 &&
//         imgBytes.elementAt(imgBytes.length - 2) != 255) {
//       print("Missing JPEG EOI");
//       // imgBytes.addAll([255, 217]);
//       newIamge = new Uint8List.fromList([...imgBytes.toList(), ...JPEG_EOI]);
//     }
//     if (newIamge != null) {
//       pic = img.decodeImage(newIamge);
//     } else {
//       pic = img.decodeImage(imgBytes); // byte Input

//     }
//     // // var newer  = Image.memory(imgBytes);
//     print('${pic.width}  :  ${pic.height}');
//     var resize = img.copyResize(pic, width: 300, height: 300); // Resize
//     temper = img.encodePng(pic);
//     var recognitions = await Tflite.detectObjectOnBinary(
//         binary: imageToByteListUint8(resize, 300),
//         threshold: 0.3, // defaults to 0.1
//         numResultsPerClass: 1, // defaults to 5
//         asynch: true);
//     if (recognitions != null) {
//       // temper = img.encodePng(pic); // Faster then jpeg
//       // print("Decteced");
//       return recognitions;
//     } else {
//       return null;
//     }
//   } catch (e) {
//     print(e);
//   }
// }
