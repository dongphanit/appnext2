import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPickerPage extends StatefulWidget {
  @override
  _LocationPickerPageState createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  Position? _currentPosition;
  LatLng? _selectedLocation;
  GoogleMapController? _mapController;

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Vui lòng cấp quyền truy cập vị trí trong cài đặt')));
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _currentPosition = position;
      _selectedLocation = LatLng(position.latitude, position.longitude);
      _mapController?.animateCamera(CameraUpdate.newLatLng(_selectedLocation!));
    });
  }

  void _onMapTapped(LatLng latLng) {
    setState(() {
      _selectedLocation = latLng;
    });
  }

  void _confirmLocation() {
    if (_selectedLocation != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Địa điểm đã chọn: $_selectedLocation")),
      );
      // Gửi _selectedLocation về server hoặc lưu state
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chọn địa điểm lấy hàng")),
      body: Column(
        children: [
          Expanded(
            child: _selectedLocation == null
                ? Center(child: CircularProgressIndicator())
                : GoogleMap(
                    onMapCreated: (controller) => _mapController = controller,
                    initialCameraPosition: CameraPosition(
                      target: _selectedLocation!,
                      zoom: 16,
                    ),
                    onTap: _onMapTapped,
                    markers: {
                      Marker(
                        markerId: MarkerId("picked"),
                        position: _selectedLocation!,
                      )
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: _confirmLocation,
              icon: Icon(Icons.check),
              label: Text("Xác nhận địa điểm"),
            ),
          ),
        ],
      ),
    );
  }
}
