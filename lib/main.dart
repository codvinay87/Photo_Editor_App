import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

import 'providers/app_image_providers.dart';
import 'screens/home_screen.dart';
import 'screens/start_screen.dart';
import 'screens/text_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AppImageProvider())],
      child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Editor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xff111111),
          primarySwatch: Colors.blue,
          appBarTheme: const AppBarTheme(
              color: Colors.black, centerTitle: true, elevation: 0),
          sliderTheme: const SliderThemeData(
              showValueIndicator: ShowValueIndicator.always)),
      routes: <String, WidgetBuilder>{
        '/': (_) => StartScreen(),
        '/home': (_) => const HomeScreen(),
        '/text': (_) => const TextScreen(),
        // '/editing': (_) => UserEditsScreen(),
      },
      initialRoute: '/',
    );
  }
}
