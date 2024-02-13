import 'dart:math';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:text_editor/text_editor.dart';

import '../helper/fonts.dart';
import '../providers/app_image_providers.dart';
import '../widgets/images.dart';

class TextScreen extends StatefulWidget {
  const TextScreen({Key? key}) : super(key: key);

  @override
  State<TextScreen> createState() => _TextScreenState();
}

class _TextScreenState extends State<TextScreen> {
  late AppImageProvider imageProvider;
  bool showEditor = true;
  bool editContent = false;
  TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    imageProvider = Provider.of<AppImageProvider>(context, listen: false);
    if (imageProvider.finalList.isNotEmpty) {}

    super.initState();
  }

  void _tapHandler(int index) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      transitionDuration: const Duration(
        milliseconds: 200,
      ),
      pageBuilder: (_, __, ___) {
        return Container(
          color: Colors.black.withOpacity(0.4),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              // top: false,
              child: Container(
                child: TextEditor(
                  fonts: Fonts().list(),
                  text: imageProvider.finalList[imageProvider.globalScreenIndex]
                      .texts[index].title,
                  textStyle: imageProvider
                      .finalList[imageProvider.globalScreenIndex]
                      .texts[index]
                      .style,
                  textAlingment: imageProvider
                      .finalList[imageProvider.globalScreenIndex]
                      .texts[index]
                      .align,
                  minFontSize: 10,
                  maxFontSize: 100,
                  onEditCompleted: (style, align, newText) {
                    setState(() {
                      Navigator.of(context).pop();
                      imageProvider.finalList[imageProvider.globalScreenIndex]
                          .texts[index].title = newText;
                      imageProvider.finalList[imageProvider.globalScreenIndex]
                          .texts[index].style = style;
                      imageProvider.finalList[imageProvider.globalScreenIndex]
                          .texts[index].align = align;
                      // imageProvider.addText(textList[index]);
                    });
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Text'),
            actions: [
              IconButton(
                  onPressed: () {
                    imageProvider.undo();
                  },
                  icon: Icon(
                    Icons.undo,
                    color: imageProvider.canUndo ? Colors.white : Colors.grey,
                  )),
              IconButton(
                  onPressed: () {
                    imageProvider.redo();
                  },
                  icon: Icon(
                    Icons.redo,
                    color: imageProvider.canRedo ? Colors.white : Colors.grey,
                  )),
              IconButton(
                  onPressed: () {}, icon: const Icon(Icons.close_rounded)),
              IconButton(
                  onPressed: () async {
                    if (!mounted) return;
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.done))
            ],
          ),
          body: Center(
            child: Consumer<AppImageProvider>(
              builder: (BuildContext context, value, Widget? child) {
                // Size siz = getImageSize();
                if (value.currentImage != null) {
                  return ReorderableListView(
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          if (oldIndex < newIndex) {
                            newIndex--;
                          }
                          final tile =
                              imageProvider.finalList.removeAt(oldIndex);
                          imageProvider.finalList.insert(newIndex, tile);
                        });
                      },
                      children: [
                        for (int finalListIndex = 0;
                            finalListIndex < imageProvider.finalList.length;
                            finalListIndex++)
                          ListTile(
                            key: ValueKey(
                                imageProvider.finalList[finalListIndex]),
                            onTap: () {
                              setState(() {
                                imageProvider.globalScreenIndex =
                                    finalListIndex;
                              });
                            },
                            title: Stack(
                              children: [
                                Image.memory(
                                  imageProvider.finalList[0].image,
                                ),
                                for (final textToShow in imageProvider
                                    .finalList[finalListIndex].texts)
                                  Positioned(
                                    left: textToShow.left,
                                    top: textToShow.top,
                                    child: GestureDetector(
                                        onPanUpdate: (details) {
                                          textToShow.left = max(
                                              0,
                                              textToShow.left +
                                                  details.delta.dx);
                                          textToShow.top = max(
                                              0,
                                              textToShow.top +
                                                  details.delta.dy);

                                          setState(() {});
                                        },
                                        onPanEnd: (details) {
                                          imageProvider.addText(
                                              textToShow.title,
                                              textToShow.style,
                                              textToShow.align,
                                              textToShow.id,
                                              textToShow.top,
                                              textToShow.left,
                                              finalListIndex);
                                        },
                                        onTap: () {
                                          int indexInLoop = imageProvider
                                              .finalList[finalListIndex].texts
                                              .indexWhere((element) =>
                                                  textToShow.id == element.id);
                                          _tapHandler(indexInLoop);
                                          imageProvider.addText(
                                              imageProvider
                                                  .finalList[finalListIndex]
                                                  .texts[indexInLoop]
                                                  .title,
                                              imageProvider
                                                  .finalList[finalListIndex]
                                                  .texts[indexInLoop]
                                                  .style,
                                              imageProvider
                                                  .finalList[finalListIndex]
                                                  .texts[indexInLoop]
                                                  .align,
                                              imageProvider
                                                  .finalList[finalListIndex]
                                                  .texts[indexInLoop]
                                                  .id,
                                              imageProvider
                                                  .finalList[finalListIndex]
                                                  .texts[indexInLoop]
                                                  .top,
                                              imageProvider
                                                  .finalList[finalListIndex]
                                                  .texts[indexInLoop]
                                                  .left,
                                              finalListIndex);
                                        },
                                        // onLongPress: () {
                                        //   setState(() {
                                        //     imageProvider.finalList[index].texts
                                        //         .removeWhere((element) =>
                                        //             element.id ==
                                        //             textToShow.id);
                                        //   });
                                        // },
                                        onDoubleTap: () {
                                          setState(() {
                                            editContent = true;
                                            _textEditingController.text =
                                                textToShow.title;
                                          });
                                        },
                                        child: editContent
                                            ? SizedBox(
                                                width: 200,
                                                child: TextField(
                                                  style: textToShow.style,
                                                  controller:
                                                      _textEditingController,
                                                  onEditingComplete: () {
                                                    setState(() {
                                                      editContent = false;
                                                    });
                                                    imageProvider.addText(
                                                        textToShow.title,
                                                        textToShow.style,
                                                        textToShow.align,
                                                        textToShow.id,
                                                        textToShow.top,
                                                        textToShow.left,
                                                        finalListIndex);
                                                  },
                                                  onChanged: (value) {
                                                    setState(() {
                                                      textToShow.title = value;
                                                    });
                                                  },
                                                ),
                                              )
                                            : Text(
                                                textToShow.title,
                                                style: textToShow.style,
                                                textAlign: textToShow.align,
                                              )),
                                  ),
                              ],
                            ),
                          ),
                      ]);
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
          bottomNavigationBar: Container(
            width: double.infinity,
            height: 50,
            color: Colors.black,
            child: Center(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    showEditor = true;
                  });
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, color: Colors.white),
                    Text(
                      "Add Text",
                      style: TextStyle(color: Colors.white),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        if (showEditor)
          Scaffold(
            backgroundColor: Colors.black.withOpacity(0.85),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: TextEditor(
                  fonts: Fonts().list(),
                  textStyle: const TextStyle(color: Colors.white),
                  minFontSize: 10,
                  maxFontSize: 100,
                  onEditCompleted: (style, align, text) {
                    setState(() {
                      showEditor = false;
                      if (text.isNotEmpty) {
                        imageProvider
                            .finalList[imageProvider.globalScreenIndex].texts
                            .add(
                          TextInfo(
                            top: 0,
                            left: 0,
                            title: text,
                            align: align,
                            style: style,
                          ),
                        );
                      }
                    });
                  },
                ),
              ),
            ),
          )
      ],
    );
  }
}
