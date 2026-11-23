import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentation/provider/notes_provider.dart';
import 'presentation/screens/notes_screen.dart';

void main() {
  runApp(const NotesApp());
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  static const Color brandSeed = Color.fromARGB(255, 255, 0, 136);

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        final ColorScheme lightScheme =
            (lightDynamic?.harmonized()) ??
            ColorScheme.fromSeed(
              seedColor: brandSeed,
              brightness: Brightness.light,
            );

        final ColorScheme darkScheme =
            (darkDynamic?.harmonized()) ??
            ColorScheme.fromSeed(
              seedColor: brandSeed,
              brightness: Brightness.dark,
            );

        return MaterialApp(
          themeMode: ThemeMode.system,
          theme: ThemeData(colorScheme: lightScheme, useMaterial3: true),
          darkTheme: ThemeData(colorScheme: darkScheme, useMaterial3: true),
          home: ChangeNotifierProvider(
            create: (_) => NotesProvider(),
            child: const NotesScreen(),
          ),
        );
      },
    );
  }
}
