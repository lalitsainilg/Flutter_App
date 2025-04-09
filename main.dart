import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qualhon_test/providers/post_provider.dart';
import 'package:qualhon_test/providers/user_provider.dart';
import 'package:qualhon_test/screen/start_screen.dart';
import 'package:qualhon_test/screen/home_screen.dart';
import 'package:qualhon_test/screen/newpostscreen.dart';
import 'package:qualhon_test/screen/share_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(
          create: (_) => UserProvider()..fetchUsers(),
        ),
      ],
      child: const PhotoSharingApp(),
    ),
  );
}

class PhotoSharingApp extends StatelessWidget {
  const PhotoSharingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Sharing App',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const StartScreen(),
        '/home': (context) => const HomeScreen(),
        '/newpost': (context) => const NewPostScreen(),
        '/share': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map;
          return ShareScreen(
            images: args['images'],
            filterIndex: args['filterIndex'],
            filterStrength: args['filterStrength'],
          );
        },
      },
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigationService.navigatorKey,
    );
  }
}

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}