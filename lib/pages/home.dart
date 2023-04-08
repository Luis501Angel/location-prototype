import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:motum_prototype/user_data.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late GoogleMapController mapController;
  late LatLng _initialLocation = const LatLng(0.0, 0.0);
  String message = '';
  bool locationStatus = false;
  StreamSubscription<Position>? _positionStreamSubscription;
  String idDevice = "";
  late UserData user;

  @override
  void initState() {
    super.initState();
    _handleLocationPermission();
    _getInitialPosition();
    _getDeviceId();
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Los servicios de ubicacion estan desactivados. Por favor activarlos')));
      }
      return false;
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Los servicios de ubicacion estan negados')));
        }
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Los servicios de ubicacion estan desactivados permanenntemente.')));
      }
      return false;
    }

    return true;
  }

  Future<void> _getInitialPosition() async {
    final hasPermission = await _handleLocationPermission();

    if (hasPermission) {
      await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      )
          .then((Position position) => {
                setState(() => {
                      user = UserData(
                          idDevice: idDevice,
                          lat: position.latitude,
                          lon: position.longitude,
                          tsGps: position.timestamp!.microsecondsSinceEpoch),
                      _initialLocation =
                          LatLng(position.latitude, position.longitude),
                      mapController.animateCamera(CameraUpdate.newLatLngZoom(
                          LatLng(_initialLocation.latitude,
                              _initialLocation.longitude),
                          14))
                    }),
              })
          .catchError((e) {
        debugPrint(e);
      });
    }
  }

  void _onLocationChange() async {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    if (_positionStreamSubscription == null) {
      _positionStreamSubscription =
          Geolocator.getPositionStream(locationSettings: locationSettings)
              .listen((Position position) {
        print('Location Change Active');
        user = UserData(
            idDevice: idDevice,
            lat: position.latitude,
            lon: position.longitude,
            tsGps: position.timestamp!.microsecondsSinceEpoch);
        message =
            'ID: ${user.idDevice} Latitud: ${user.lat}  Longitud: ${user.lon} GPSTime: ${user.tsGps}';
        print(message);
        _sendDataToVidente(user);
        mapController.animateCamera(CameraUpdate.newLatLngZoom(
            LatLng(position.latitude, position.longitude), 14));
        setState(() => {locationStatus = true});
      });
    } else {
      print('Location Change Desactive');
      _positionStreamSubscription!.cancel();
      _positionStreamSubscription = null;
      setState(() {
        locationStatus = false;
      });
    }
  }

  Future<void> _getDeviceId() async {
    String identifier = '';
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      identifier = androidDeviceInfo.androidId!;
    }
    print(Platform.localHostname);
    idDevice = identifier;
  }

  Future<void> _sendDataToVidente(UserData userData) async {
    String body = jsonEncode(userData.toJson());
    var url = Uri.parse(
        '');
    var response = await http.post(url, body: body);

    if (response.statusCode == 200) {
      print('Datos guardados correctamente');
      print(response.body);
    } else {
      print('Error: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
              child: GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(target: _initialLocation),
            myLocationEnabled: true,
            zoomControlsEnabled: false,
          )),
          Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(
                    top: 10, bottom: 10, left: 20, right: 20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: Offset.zero)
                    ]),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        onPressed: () {
                          print('Presionando boton');
                        },
                        icon: const Icon(Icons.person)),
                    Text(
                      'user${Random().nextInt(1000)}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    TextButton(
                      onPressed: _onLocationChange,
                      style: ButtonStyle(
                          padding: MaterialStateProperty.all(
                              const EdgeInsets.all(12)),
                          foregroundColor:
                              MaterialStateProperty.all(Colors.indigo),
                          backgroundColor:
                              MaterialStateProperty.all(Colors.indigo),
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(22.0),
                                  side:
                                      const BorderSide(color: Colors.indigo)))),
                      child: locationStatus
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.stop,
                                  color: Colors.white,
                                ),
                                Text(
                                    style: TextStyle(color: Colors.white),
                                    'Detener')
                              ],
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                ),
                                Text(
                                    style: TextStyle(color: Colors.white),
                                    '  Comenzar')
                              ],
                            ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
