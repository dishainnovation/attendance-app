import 'dart:ffi';

class SiteModel {
  int id;
  String name;
  double latitude;
  double longitude;
  int geoFenceArea;
  int port;
  String? portName;

  SiteModel(
      {required this.id,
      required this.name,
      required this.latitude,
      required this.longitude,
      required this.geoFenceArea,
      required this.port,
      this.portName});

  factory SiteModel.fromJson(Map<String, dynamic> json) {
    return SiteModel(
        id: json['id'],
        name: json['name'],
        latitude: json['latitude'],
        longitude: json['longitude'],
        geoFenceArea: json['geofence_area'],
        port: json['port'],
        portName: json['port_name']);
  }

  Map<String, dynamic> toJson() => {
        'id': id.toString(),
        'name': name,
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'geofence_area': geoFenceArea.toString(),
        'port': port.toString(),
        'port_name': portName ?? ''
      };
}
