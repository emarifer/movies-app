import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:movies_app/helpers/debouncer.dart';

import '../models/models.dart';

class MoviesProvider extends ChangeNotifier {
  static const String _apiKey = '1865f43a0549ca50d341dd9ab8b29f49';
  static const String _baseUrl = 'api.themoviedb.org';
  static const String _language = 'es-ES';

  List<Movie> onDisplayMovies = [];
  List<Movie> popularMovies = [];
  Map<int, List<Cast>> moviesCast = {};

  int _popularPage = 0;

  final Debouncer debouncer =
      Debouncer(duration: const Duration(milliseconds: 500));

  final StreamController<List<Movie>> _suggestionsStreamController =
      StreamController.broadcast();
  Stream<List<Movie>> get suggestionsStream =>
      _suggestionsStreamController.stream;

  MoviesProvider() {
    // print('MoviesProvider Inicializado');

    getOnDisplayMovies();
    getPopularMovies();
  }

  Future<String> _getJsonData(String endpoint, [int page = 1]) async {
    final Uri url = Uri.https(
      _baseUrl,
      endpoint,
      {
        'api_key': _apiKey,
        'language': _language,
        'page': '$page',
      },
    );

    // Await the http get response, then decode the json-formatted response
    final http.Response response = await http.get(url);
    return response.body;
  }

  getOnDisplayMovies() async {
    final NowPlayingResponse nowPlayingResponse =
        NowPlayingResponse.fromJson(await _getJsonData('3/movie/now_playing'));
    onDisplayMovies = nowPlayingResponse.results;
    notifyListeners(); // nofifica a los widgets que lo usen para que re-renderizen
  }

  getPopularMovies() async {
    _popularPage++;
    final PopularResponse popularResponse = PopularResponse.fromJson(
        await _getJsonData('3/movie/popular', _popularPage));
    popularMovies = [...popularMovies, ...popularResponse.results];
    notifyListeners(); // nofifica a los widgets que lo usen para que re-renderizen
  }

  Future<List<Cast>> getMovieCast(int movieId) async {
    if (moviesCast.containsKey(movieId)) return moviesCast[movieId]!;

    // print('Pidiendo info del Cast al servidor…');

    final String jsonData = await _getJsonData('3/movie/$movieId/credits');
    final CreditsResponse creditsResponse = CreditsResponse.fromJson(jsonData);

    moviesCast[movieId] = creditsResponse.cast;
    return creditsResponse.cast;
  }

  Future<List<Movie>> searchMovies(String query) async {
    final Uri url = Uri.https(_baseUrl, '3/search/movie', {
      'api_key': _apiKey,
      'language': _language,
      'query': query,
    });

    // Await the http get response, then decode the json-formatted response
    final http.Response response = await http.get(url);
    final SearchResponse searchResponse =
        SearchResponse.fromJson(response.body);
    return searchResponse.results;
  }

  void getSuggestionsByQuery(String searchTerm) {
    debouncer.value = '';

    debouncer.onValue = (value) async {
      // print('Tenemos valor a buscar: $value'); // Gracias al debouncer la peticion
      // http solo se dispara despues de un cierto tiempo
      final List<Movie> results = await searchMovies(value);

      _suggestionsStreamController.add(results);
    };

    final Timer timer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      debouncer.value = searchTerm;
    });

    Future.delayed(const Duration(milliseconds: 301))
        .then((_) => timer.cancel());
  }
}
