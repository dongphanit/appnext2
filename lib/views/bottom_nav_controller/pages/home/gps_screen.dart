import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationPickerWebPage extends StatefulWidget {
  @override
  _LocationPickerWebPageState createState() => _LocationPickerWebPageState();
}

class _LocationPickerWebPageState extends State<LocationPickerWebPage> {
  LatLng? _selectedLocation = LatLng(10.762622, 106.660172); // Default TP.HCM

  void _onTap(LatLng latlng) {
    setState(() {
      _selectedLocation = latlng;
    });
  }

  void _confirmLocation() {
    if (_selectedLocation != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đã chọn: ${_selectedLocation!.latitude}, ${_selectedLocation!.longitude}")),
      );
    }
    // back
    Navigator.pop(context, _selectedLocation);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chọn địa điểm")),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                center: _selectedLocation,
                zoom: 15,
                onTap: (_, latlng) => _onTap(latlng),
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                if (_selectedLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _selectedLocation!,
                         child: Icon(Icons.location_pin, color: Colors.red, size: 40),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _confirmLocation,
              icon: Icon(Icons.check),
              label: Text("Xác nhận vị trí"),
            ),
          ),
        ],
      ),
    );
  }
}
