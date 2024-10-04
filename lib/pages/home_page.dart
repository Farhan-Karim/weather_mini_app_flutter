import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';
import 'dart:async';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:weather_mini/consts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final WeatherFactory _wf = WeatherFactory(OPEN_WEATHER_API);
  final TextEditingController _controller = TextEditingController();

  final StreamController<Weather?> _weatherController =
      StreamController<Weather?>();

  Weather? _previousWeather; // To store last successful weather data

  @override
  void initState() {
    super.initState();
    _getWeather("Gilgit");
  }

  @override
  void dispose() {
    _weatherController.close();
    super.dispose();
  }

  // Fetch weather and add it to the stream
  void _getWeather(String cityName) {
    _weatherController.add(null); // Indicate loading state
    _wf.currentWeatherByCityName(cityName).then((w) {
      _previousWeather = w; // Store successful weather data
      _weatherController.add(w);
    }).catchError((error) {
      _weatherController.addError('Error fetching weather data');
      _showErrorDialog();
      if (_previousWeather != null) {
        _weatherController.add(_previousWeather); // Revert to previous weather
      }
    });
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Location Not Found'),
          content: const Text('No such location found.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _searchWeather() {
    String cityName = _controller.text.trim();
    if (cityName.isNotEmpty) {
      _getWeather(cityName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildUI(),
      appBar: AppBar(
        title: const Text(
          'Weather App',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurpleAccent,
      ),
    );
  }

  Widget _buildUI() {
    return StreamBuilder<Weather?>(
      stream: _weatherController.stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            !snapshot.hasData) {
          return const Center(
            child: SpinKitFadingCircle(
              color: Colors.deepPurpleAccent,
              size: 50.0,
            ),
          );
        } else if (snapshot.hasError) {
          return const Center(
            child: Text("Error loading weather data."),
          );
        }

        final Weather? weather = snapshot.data;

        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _locationInputField(),
            _locationHeader(weather),
            const SizedBox(height: 20),
            _dateTimeInfo(weather),
            const SizedBox(height: 20),
            _weatherIcon(weather),
            const SizedBox(height: 20),
            _currentTemp(weather),
            const SizedBox(height: 20),
            _extractInfo(weather),
          ],
        );
      },
    );
  }

  Widget _locationInputField() {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
        ),
        labelText: 'Enter City Name',
        suffixIcon: Container(
          decoration: BoxDecoration(
            color: Colors.deepPurpleAccent,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(10.0),
              bottomRight: Radius.circular(10.0),
            ),
          ),
          child: IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: _searchWeather,
          ),
        ),
      ),
    );
  }

  Widget _locationHeader(Weather? weather) {
    return Text(
      weather?.areaName ?? "",
      style: const TextStyle(fontSize: 35, fontWeight: FontWeight.w500),
      textAlign: TextAlign.center,
    );
  }

  Widget _dateTimeInfo(Weather? weather) {
    DateTime now = weather!.date!;
    return Column(
      children: [
        Text(
          DateFormat("h:mm a").format(now),
          style: const TextStyle(fontSize: 35),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              " ${DateFormat("EEEE").format(now)}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            Text(
              "     ${DateFormat("d.m.y").format(now)}",
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ],
    );
  }

  Widget _weatherIcon(Weather? weather) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.20,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                  "https://openweathermap.org/img/wn/${weather?.weatherIcon}@4x.png"),
            ),
          ),
        ),
        Text(
          weather?.weatherDescription ?? "",
          style: const TextStyle(fontSize: 25),
        ),
      ],
    );
  }

  Widget _currentTemp(Weather? weather) {
    return Center(
      child: Text(
        "${weather?.temperature?.celsius?.toStringAsFixed(0)}° C",
        style: const TextStyle(
          fontSize: 50,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _extractInfo(Weather? weather) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.80,
      height: MediaQuery.of(context).size.height * 0.15,
      decoration: BoxDecoration(
        color: Colors.deepPurpleAccent,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                "Max: ${weather?.tempMax?.celsius?.toStringAsFixed(0)} ° C",
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
              Text(
                "Min: ${weather?.tempMin?.celsius?.toStringAsFixed(0)} ° C",
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                "Wind: ${weather?.windSpeed?.toStringAsFixed(0)} m/s",
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
              Text(
                "Humidity: ${weather?.humidity?.toStringAsFixed(0)} %",
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
