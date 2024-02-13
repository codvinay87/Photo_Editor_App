import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../data/data.dart';
import '../providers/app_image_providers.dart';
import '../widgets/drawer_widget.dart';
import '../widgets/templates_item.dart';

class StartScreen extends StatelessWidget {
  StartScreen({Key? key}) : super(key: key);

  late AppImageProvider imageProvider;

  @override
  Widget build(BuildContext context) {
    BorderRadiusGeometry radius = BorderRadius.only(
      topLeft: Radius.circular(24.0),
      topRight: Radius.circular(24.0),
    );
    imageProvider = Provider.of<AppImageProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black54,
        title: const Text(
          "Celebrare",
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontSize: 40,
            fontWeight: FontWeight.bold,
            // letterSpacing: 3,
            // wordSpacing: 2
          ),
        ),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) => TemplateItem(index: index),
        itemCount: images.length,
      ),
      drawer: MainDrawer(),
    );
  }
}
