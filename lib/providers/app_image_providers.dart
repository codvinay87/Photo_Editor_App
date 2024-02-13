// ignore_for_file: prefer_final_fields, non_constant_identifier_names

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

import '../widgets/images.dart';

class AppImageProvider extends ChangeNotifier {
  List<Uint8List> _images = [];
  List<TextInfo> _text = [];
  List<ImagesWidget> finalList = [];
  int globalScreenIndex = 0;
  int _imageIndex = 0;
  int _textIndex = 0;
  List<int> _screenTrack = [];
  int _screenTrackIndex = 0;

  bool canUndo = false;
  bool canRedo = false;
  Future<Map<String, dynamic>> retrieveImagesWidgetFromFirestore(
      String documentId) async {
    CollectionReference documentSnapshot =
        await FirebaseFirestore.instance.collection('imagesWidgetCollectio');
    final snapShot = await documentSnapshot.doc(documentId).get();

    final data = snapShot.data() as Map<String, dynamic>;
    return data;
  }

  void ConvertFetchedDataToWidget() async {
    finalList = [];
    late Uint8List imageDecoded;

    for (int i = 0; i < 3; i++) {
      List<TextInfo> retrievedText = [];

      Map<String, dynamic> map =
          await retrieveImagesWidgetFromFirestore(i.toString());

      imageDecoded = base64.decode(map['image']);

      for (var texts in map['texts']) {
        print(texts['top']);
        texts['left'];
        TextInfo textInfo = TextInfo(
            id: texts['id'],
            title: texts["title"],
            align: TextAlign.center,
            style: TextStyle(
              fontFamily: texts['style']['fontFamily'],
              color: Color(texts['style']['color']),
              fontSize: texts['style']['fontSize'],
            ),
            top: texts['top'].toDouble(),
            left: texts['left'].toDouble());
        retrievedText.add(textInfo);
      }

      ImagesWidget imagemodel =
          ImagesWidget(image: imageDecoded, texts: retrievedText);
      finalList.add(imagemodel);
    }
    _add(imageDecoded);
  }

  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load(path);

    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.create(recursive: true);
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

  done(ImagesWidget imageWidget) {
    finalList.add(imageWidget);
  }

  changeImageFile(File image) {
    _add(image.readAsBytesSync());
    finalList.add(ImagesWidget(image: image.readAsBytesSync(), texts: []));
    finalList.add(ImagesWidget(image: image.readAsBytesSync(), texts: []));
    finalList.add(ImagesWidget(image: image.readAsBytesSync(), texts: []));
  }

  addText(String title, TextStyle style, TextAlign align, String? id,
      double top, double left, int screenTrackIndexFromScreen) {
    _addTextInfo(
        title, style, align, id, top, left, screenTrackIndexFromScreen);
  }

  changeImage(Uint8List image) {
    _add(image);
  }

  Uint8List? get currentImage {
    return _images[_imageIndex];
  }

  _add(Uint8List image) {
    if (_images.isEmpty) {
      _images.add(image);
    } else {
      int removeUntil = (_images.length - 1) - _imageIndex;
      _images.length = _images.length - removeUntil;
      _images.add(image);
      _imageIndex++;
    }
    _undoRedo();
    notifyListeners();
  }

  _addTextInfo(String title, TextStyle style, TextAlign align, String? id,
      double top, double left, int screenTrackIndexFromScreen) {
    _screenTrack.add(screenTrackIndexFromScreen);
    _screenTrackIndex++;
    if (_text.isEmpty) {
      _text.add(TextInfo(
          title: title,
          align: align,
          style: style,
          top: top,
          left: left,
          id: id));
    } else {
      int removeUntil = (_text.length - 1) - _textIndex;
      _text.length = _text.length - removeUntil;
      _text.add(TextInfo(
          title: title,
          align: align,
          style: style,
          top: top,
          left: left,
          id: id));
      _textIndex++;
    }
    _undoRedo();
    notifyListeners();
  }

  undo() {
    if (_textIndex > 0) {
      _textIndex--;
      _screenTrackIndex--;

      int indexInFinalList;

      indexInFinalList = finalList[globalScreenIndex]
          .texts
          .indexWhere((element) => _text[_textIndex].id == element.id);

      if (indexInFinalList >= 0) {
        finalList[globalScreenIndex].texts[indexInFinalList].title =
            _text[_textIndex].title;
        finalList[globalScreenIndex].texts[indexInFinalList].style =
            _text[_textIndex].style;
        finalList[globalScreenIndex].texts[indexInFinalList].align =
            _text[_textIndex].align;
        finalList[globalScreenIndex].texts[indexInFinalList].top =
            _text[_textIndex].top;
        finalList[globalScreenIndex].texts[indexInFinalList].left =
            _text[_textIndex].left;
      }
    }
    if (_textIndex == 0) {
      _textIndex++;

      finalList[globalScreenIndex]
          .texts
          .removeWhere((element) => element.id == _text[_textIndex].id);
      _textIndex--;
    }

    _undoRedo();
    notifyListeners();
  }

  redo() {
    if (_textIndex < _text.length - 1) {
      _textIndex++;
      int indexInFinalList;

      indexInFinalList = finalList[globalScreenIndex]
          .texts
          .indexWhere((element) => _text[_textIndex].id == element.id);
      if (indexInFinalList >= 0) {
        finalList[globalScreenIndex].texts[indexInFinalList].title =
            _text[_textIndex].title;
        finalList[globalScreenIndex].texts[indexInFinalList].style =
            _text[_textIndex].style;
        finalList[globalScreenIndex].texts[indexInFinalList].align =
            _text[_textIndex].align;
        finalList[globalScreenIndex].texts[indexInFinalList].top =
            _text[_textIndex].top;
        finalList[globalScreenIndex].texts[indexInFinalList].left =
            _text[_textIndex].left;
      }
    }
    _screenTrackIndex++;
    if (_textIndex == _text.length - 1) {
      _textIndex--;
      finalList[globalScreenIndex].texts.add(_text[_textIndex]);

      _textIndex++;
    }

    _undoRedo();
    notifyListeners();
  }

  _undoRedo() {
    canUndo = (_textIndex != 0) ? true : false;
    canRedo = (_textIndex < _text.length - 1) ? true : false;
  }
}
