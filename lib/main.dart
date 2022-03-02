import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './providers/movies_provider.dart';

import 'screens/screens.dart';

void main() => runApp(const AppState());

class AppState extends StatelessWidget {
  const AppState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => MoviesProvider(),
          lazy: false, // Hace que se cree el Provider al construir la app
        ),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Movies App',
      initialRoute: 'home',
      routes: {
        'home': (_) => const HomeScreen(), // No es necesario el BuildContext
        'details': (_) => const DetailsScreen(),
      },
      theme: ThemeData.light().copyWith(
        appBarTheme: const AppBarTheme(
          color: Colors.indigoAccent,
          elevation: 0,
        ),
        // textTheme: const TextTheme(
        //   headline5: TextStyle(
        //     fontSize: 40,
        //     color: Colors.blueAccent,
        //   ),
        // ),
      ),
    );
  }
}
