import 'package:flutter/material.dart';
import 'controllers/movie_controller.dart';
import 'services/tmdb_service.dart';
import 'views/home_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // ATENÇÃO: Insira aqui a sua chave de API v3 obtida no The Movie Database (TMDb):
  // https://www.themoviedb.org/settings/api
  const String tmdbApiKey = '5577763f4f97a1bd637ce81547de87d4';

  final tmdbService = TmdbService(apiKey: tmdbApiKey);
  final movieController = MovieController(service: tmdbService);

  runApp(CineClickApp(controller: movieController));
}

/// Ponto de entrada da aplicação CineClick.
class CineClickApp extends StatelessWidget {
  final MovieController controller;

  const CineClickApp({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CineClick - APS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 0,
          centerTitle: false,
        ),
        cardColor: const Color(0xFF1E1E1E),
        useMaterial3: true,
      ),
      home: HomeView(controller: controller),
    );
  }
}
