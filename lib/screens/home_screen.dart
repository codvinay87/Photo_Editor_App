import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

import 'package:provider/provider.dart';

import '../providers/app_image_providers.dart';
import '../widgets/images.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late AppImageProvider appImageProvider;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    appImageProvider = Provider.of<AppImageProvider>(context, listen: false);
    setState(() {});

    super.initState();
  }

  Future<void> addImagesWidgetToFirestore(
      ImagesWidget imagesWidget, int index) async {
    try {
      final List<Map<String, dynamic>> textsData =
          imagesWidget.texts.map((textInfo) {
        return {
          'id': textInfo.id,
          'title': textInfo.title,
          'style': {
            'fontSize': textInfo.style.fontSize,
            'color': textInfo.style.color.toString(),
            // Add other properties as needed
          },
          'align': textInfo.align.toString(),
          'left': textInfo.left,
          'top': textInfo.top,
        };
      }).toList();

      Map<String, dynamic> mapToAdd = imagesWidget.toMap();

      await _firestore
          .collection('imagesWidgetCollectio')
          .doc(index.toString())
          .set(mapToAdd);
    } catch (e) {
      print('Error adding ImagesWidget to Firestore: $e');
    }
  }

  _savePhoto() async {
    for (int index = 0; index < appImageProvider.finalList.length; index++) {
      await addImagesWidgetToFirestore(
          appImageProvider.finalList[index], index);
    }
    Navigator.of(context).pushReplacementNamed('/home');

    // final result = await ImageGallerySaver.saveImage(
    //     appImageProvider.currentImage!,
    //     quality: 100,
    //     name: "${DateTime.now().millisecondsSinceEpoch}");
    // if (!mounted) return false;
    // if (result['isSuccess']) {
    //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    //     content: Text('Image saved to Gallery'),
    //   ));
    // } else {
    //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    //     content: Text('Something went wrong!'),
    //   ));
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Photo Editor"),
        leading: CloseButton(
          onPressed: () {
            // Navigator.of(context).pushReplacementNamed('/');
          },
        ),
        actions: [
          TextButton(
              onPressed: () {
                _savePhoto();
              },
              child: const Text('Save'))
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: Consumer<AppImageProvider>(
              builder: (BuildContext context, value, Widget? child) {
                return ReorderableListView(
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (oldIndex < newIndex) {
                          newIndex--;
                        }
                        final tile =
                            appImageProvider.finalList.removeAt(oldIndex);
                        appImageProvider.finalList.insert(newIndex, tile);
                      });
                    },
                    children: [
                      for (int index = 0;
                          index < appImageProvider.finalList.length;
                          index++)
                        ListTile(
                          key: ValueKey(appImageProvider.finalList[index]),
                          title: Stack(children: [
                            Image.memory(
                              appImageProvider.finalList[index].image,
                            ),
                            for (final textToShow
                                in appImageProvider.finalList[index].texts)
                              Positioned(
                                left: textToShow.left,
                                top: textToShow.top,
                                child: Text(
                                  textToShow.title,
                                  style: textToShow.style,
                                  textAlign: textToShow.align,
                                ),
                              ),
                          ]),
                        )
                    ]);

                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20), color: Colors.black),
              child:
                  Consumer<AppImageProvider>(builder: (context, value, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        appImageProvider.undo();
                      },
                      icon: Icon(Icons.undo,
                          color: value.canUndo ? Colors.white : Colors.white10),
                    ),
                    IconButton(
                      onPressed: () {
                        appImageProvider.redo();
                      },
                      icon: Icon(Icons.redo,
                          color: value.canRedo ? Colors.white : Colors.white10),
                    ),
                  ],
                );
              }),
            ),
          )
        ],
      ),
      bottomNavigationBar: Container(
        width: double.infinity,
        height: 60,
        color: Colors.black,
        child: SafeArea(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _bottomBatItem(Icons.text_fields, 'Text', onPress: () {
                  Navigator.of(context).pushNamed('/text');
                }),
                _bottomBatItem(Icons.crop_rotate, 'Crop', onPress: () {
                  // Navigator.of(context).pushNamed('/crop');
                }),
                _bottomBatItem(Icons.filter_vintage_outlined, 'Filters',
                    onPress: () {
                  // Navigator.of(context).pushNamed('/filter');
                }),
                _bottomBatItem(Icons.tune, 'Adjust', onPress: () {
                  // Navigator.of(context).pushNamed('/adjust');
                }),
                _bottomBatItem(Icons.fit_screen_sharp, 'Fit', onPress: () {
                  // Navigator.of(context).pushNamed('/fit');
                }),
                _bottomBatItem(Icons.border_color_outlined, 'Tint',
                    onPress: () {
                  // Navigator.of(context).pushNamed('/tint');
                }),
                _bottomBatItem(Icons.blur_circular, 'Blur', onPress: () {
                  // Navigator.of(context).pushNamed('/blur');
                }),
                _bottomBatItem(Icons.emoji_emotions_outlined, 'Sticker',
                    onPress: () {
                  // Navigator.of(context).pushNamed('/sticker');
                }),
                _bottomBatItem(Icons.draw, 'Draw', onPress: () {
                  // Navigator.of(context).pushNamed('/draw');
                }),
                _bottomBatItem(Icons.star_border, 'Mask', onPress: () {
                  // Navigator.of(context).pushNamed('/mask');
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bottomBatItem(IconData icon, String title, {required onPress}) {
    return InkWell(
      onTap: onPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(height: 3),
            Text(
              title,
              style: const TextStyle(color: Colors.white70),
            )
          ],
        ),
      ),
    );
  }
}
