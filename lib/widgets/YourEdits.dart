import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';

import '../providers/app_image_providers.dart';

class YourEditsWidget extends StatelessWidget {
  YourEditsWidget({super.key, required this.index});
  int index;
  late AppImageProvider imageProvider;

  @override
  Widget build(BuildContext context) {
    imageProvider = Provider.of<AppImageProvider>(context, listen: false);

    return Scaffold(
      body: Column(children: [
        Consumer<AppImageProvider>(
          builder: (BuildContext context, value, Widget? child) {
            if (value.currentImage != null) {
              return Stack(children: [
                Image.memory(
                  value.finalList[0].image,
                ),
                for (final textToShow in value.finalList[0].texts)
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/text'),
                    child: Positioned(
                      left: textToShow.left,
                      top: textToShow.top,
                      child: Text(
                        textToShow.title,
                        style: textToShow.style,
                        textAlign: textToShow.align,
                      ),
                    ),
                  )
              ]);
            }

            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ]),
    );
  }
}
