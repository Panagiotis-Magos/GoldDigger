import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class GPSScreen extends StatefulWidget {
  final int userId;
  final int taskId;

  const GPSScreen({Key? key, required this.userId, required this.taskId})
      : super(key: key);

  @override
  _GPSScreenState createState() => _GPSScreenState();
}


class _GPSScreenState extends State<GPSScreen> {
  String currentLocation = 'Fetching location...';
  String coordinates = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        // Get current location
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        setState(() {
          coordinates = 'Lat: ${position.latitude}, Lon: ${position.longitude}';
          currentLocation = 'Coordinates fetched!'; // Placeholder text
          isLoading = false;

          // Uncomment below if reverse geocoding is used:
          // _getAddressFromCoordinates(position.latitude, position.longitude);
        });
      } else {
        setState(() {
          currentLocation = 'Location permissions denied.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        currentLocation = 'Error fetching location: $e';
        isLoading = false;
      });
    }
  }

  // Reverse geocoding (Optional: Replace with a real API or package)
  Future<void> _getAddressFromCoordinates(
      double latitude, double longitude) async {
    try {
      // Use a geocoding API or package like `geocoding`
      String address = 'Paris, France'; // Simulated response
      setState(() {
        currentLocation = address;
      });
    } catch (e) {
      setState(() {
        currentLocation = 'Error fetching address: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Location'),
        backgroundColor: Colors.amber,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Column(
                    children: [
                      Text(
                        currentLocation,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        coordinates,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Location Verified!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          // Pass true back to the previous screen to indicate success
                          Navigator.pop(context, true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                        ),
                        child: Text('Confirm Location'),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
