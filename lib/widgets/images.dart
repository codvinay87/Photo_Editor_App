import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

class TextInfo {
  TextInfo(
      {required this.title,
      required this.align,
      required this.style,
      required this.top,
      required this.left,
      String? id})
      : id = id ?? uuid.v4();
  String id;
  String title;
  TextStyle style;
  TextAlign align;
  double left;
  double top;
  Map<String, dynamic> textStyleToMap(TextStyle textStyle) {
    return {
      'fontSize': textStyle.fontSize,
      'fontWeight': textStyle.fontWeight?.index,
      'fontStyle': textStyle.fontStyle,
      'color': textStyle.color?.value,
      'fontFamily': textStyle.fontFamily
      // Add other TextStyle properties as needed
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'style': textStyleToMap(style),
      'align': align.toString(), // Store as string or convert to another format
      'left': left,
      'top': top,
    };
  }

  static TextInfo fromMap(DocumentSnapshot<Object?> documentSnapshot) {
    final Map<String, dynamic>? data =
        documentSnapshot.data() as Map<String, dynamic>?;

    if (data == null) {
      throw Exception('Document data is null or not a Map');
    }

    return TextInfo(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      style: TextInfo.textStyleFromMap(data['style']),
      align: TextAlign.values.firstWhere(
        (value) => value.toString() == 'TextAlign.${data['align']}',
        orElse: () => TextAlign.left,
      ),
      left: data['left'] ?? 0.0,
      top: data['top'] ?? 0.0,
    );
  }

  static textStyleFromMap(Map<String, dynamic> map) {
    return TextStyle(
      fontSize: map['fontSize'],
      fontWeight: FontWeight.values[map['fontWeight']],
      fontStyle: FontStyle.values[map['fontStyle']],
      color: Color(map['color']),
      // Add other TextStyle properties as needed
    );
  }
}

class ImagesWidget {
  ImagesWidget({
    required this.image,
    required this.texts,
  });
  Uint8List image;
  List<TextInfo> texts = [];
  Map<String, dynamic> toMap() {
    return {
      'image': base64Encode(image), // Convert image to base64 or another format
      'texts': texts.map((textInfo) => textInfo.toMap()).toList(),
    };
  }

  static ImagesWidget fromMap(Map<String, dynamic> map) {
    return ImagesWidget(
      image: base64Decode(
          map['image']), // Convert image back to Uint8List or another format
      texts: (map['texts'] as List<dynamic>)
          .map((textInfoMap) => TextInfo.fromMap(textInfoMap))
          .toList(),
    );
  }
}
