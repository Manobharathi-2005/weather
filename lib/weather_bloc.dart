import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherEvent {}

class FetchWeather extends WeatherEvent {
  final String zipcode;
  FetchWeather(this.zipcode);
}

class ToggleFavorite extends WeatherEvent {
  final String location;
  ToggleFavorite(this.location);
}

class WeatherState {}

class WeatherLoading extends WeatherState {}

class WeatherLoaded extends WeatherState {
  final WeatherInfo weatherInfo;
  final List<String> favorites;
  WeatherLoaded(this.weatherInfo, this.favorites);

  get weatherInfoList => null;
}

class WeatherError extends WeatherState {
  final String message;
  WeatherError(this.message);
}

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  WeatherInfo? _weatherInfo;
  List<String> _favorites = [];

  WeatherBloc() : super(WeatherLoading()) {
    on<FetchWeather>((event, emit) async {
      await Future.delayed(Duration(seconds: 2));
      final apiKey = "1895d93a3b2f913ae6391e92c421bb97";
      final requestUrl =
          "https://api.openweathermap.org/data/2.5/weather?zip=${event.zipcode},in&units=metric&appid=$apiKey";
      final response = await http.get(Uri.parse(requestUrl));
      if (response.statusCode == 200) {
        _weatherInfo = WeatherInfo.fromJSON(jsonDecode(response.body));
        emit(WeatherLoaded(_weatherInfo!, _favorites));
      } else {
        emit(WeatherError("Error loading request"));
      }
    });

    on<ToggleFavorite>((event, emit) {
      if (_favorites.contains(event.location)) {
        _favorites.remove(event.location);
      } else {
        _favorites.add(event.location);
      }
      if (_weatherInfo != null) {
        emit(WeatherLoaded(_weatherInfo!, _favorites));
      }
    });
  }
}

class WeatherInfo {
  final String location;
  final double temp;
  final String weather;
  final int humidity;
  final double windspeed;

  WeatherInfo({
    required this.location,
    required this.temp,
    required this.weather,
    required this.humidity,
    required this.windspeed,
  });

  factory WeatherInfo.fromJSON(Map<String, dynamic> json) {
    return WeatherInfo(
      location: json['name'],
      temp: json['main']['temp'].toDouble(),
      weather: json['weather'][0]['description'],
      humidity: json['main']['humidity'],
      windspeed: json['wind']['speed'].toDouble(),
    );
  }
}
