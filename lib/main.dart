import 'package:flutter/material.dart';
import 'package:flutter_telegram_web_app/flutter_telegram_web_app.dart' as tg;
import 'package:flutter_telegram_web_app/flutter_telegram_web_app.dart';
import 'package:js/js.dart';

void main() {
  runApp(const MyApp());
}

// Theme mode notifier
final ValueNotifier<ThemeMode> _themeNotifier =
    ValueNotifier(tg.isDarkMode ? ThemeMode.dark : ThemeMode.light);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeNotifier,
      builder: (BuildContext context, ThemeMode mode, Widget? child) {
        return MaterialApp(
          title: 'Telegram Mini App',
          debugShowCheckedModeBanner: false,
          theme: TelegramTheme.light,
          darkTheme: TelegramTheme.dark,
          themeMode: mode,
          home: const MyHomePage(),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isInitialized = false;
  String userName = "Guest";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeTelegramWebApp();
    });
  }

  void _initializeTelegramWebApp() {
    try {
      setState(() {
        isInitialized = true;
      });

      // Show the main button with wrapped callback
      tg.MainButton
        ..setText("Submit")
        ..show()
        ..onClick(allowInterop(_handleMainButtonClick));

      // Set theme based on Telegram theme
      _themeNotifier.value = tg.isDarkMode ? ThemeMode.dark : ThemeMode.light;
      
      // Print debug info
      print('Initialized: $isInitialized');
      print('Platform: ${tg.platform}');
      print('Version: ${tg.version}');
      
    } catch (e) {
      print('Error in initialization: $e');
    }
  }

  void _handleMainButtonClick() {
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Action Confirmed'),
        content: const Text('You clicked the main button!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Telegram Mini App'),
        actions: [
          IconButton(
            icon: Icon(
              _themeNotifier.value == ThemeMode.light 
                ? Icons.dark_mode 
                : Icons.light_mode
            ),
            onPressed: () {
              _themeNotifier.value =
                  _themeNotifier.value == ThemeMode.light
                      ? ThemeMode.dark
                      : ThemeMode.light;
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (!isInitialized)
              const CircularProgressIndicator()
            else
              Column(
                children: [
                  Text(
                    'Welcome ${userName}!',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Platform: ${tg.platform}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      try {
                        tg.showAlert('Hello from Flutter!');
                      } catch (e) {
                        print('Error showing alert: $e');
                      }
                    },
                    child: const Text('Show Alert'),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'WebApp Version: ${tg.version}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    try {
      tg.MainButton.hide();
    } catch (e) {
      print('Error hiding MainButton: $e');
    }
    super.dispose();
  }
}