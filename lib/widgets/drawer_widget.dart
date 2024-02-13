import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_image_providers.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    late AppImageProvider appImageProvider;
    appImageProvider = Provider.of<AppImageProvider>(context, listen: false);
    return Drawer(
        child: Column(
      children: [
        DrawerHeader(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.primaryContainer.withOpacity(0.8)
          ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
          child: Row(
            children: [
              Icon(
                Icons.fastfood_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(
                width: 16,
              ),
              Text(
                'CeleBrare',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(color: Theme.of(context).colorScheme.primary),
              ),
            ],
          ),
        ),
        ListTile(
          leading: Icon(
            Icons.home,
            size: 26,
          ),
          title: Text(
            "Home",
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: Theme.of(context).colorScheme.onBackground,
                fontSize: 24),
          ),
          onTap: () {
            Navigator.of(context).pushNamed('/home');
          },
        ),
        ListTile(
          leading: Icon(
            Icons.mode_edit,
            size: 26,
          ),
          title: Text(
            "Your Edits",
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: Theme.of(context).colorScheme.onBackground,
                fontSize: 24),
          ),
          onTap: () {
            appImageProvider.ConvertFetchedDataToWidget();

            Navigator.of(context).pushNamed('/home');
          },
        ),
      ],
    ));
  }
}
