class UserData {
  String idDevice;
  double lat;
  double lon;
  int tsGps;

  UserData({ required this.idDevice, required this.lat,  required this.lon, required this.tsGps });

  Map<String, dynamic> toJson() => {
    'idDevice': idDevice,
    'lat': lat,
    'lon': lon,
    'tsGps': tsGps
  };
}