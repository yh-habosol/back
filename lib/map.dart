import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geodesy/geodesy.dart';
import 'package:routemaster/routemaster.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late Position _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Page'),
      ),
      body: FutureBuilder(
        // Fetch the Posts collection
        future: FirebaseFirestore.instance.collection('Posts').get(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            // Process the data and build your UI here
            final List<DocumentSnapshot> posts = snapshot.data!.docs;

            // Filter posts within 5km
            final List<DocumentSnapshot> nearbyPosts = posts.where((post) {
              final double postLongitude = post['location']['log'];
              final double postLatitude = post['location']['lat'];
              const Distance distance = Distance();

              final double km = distance.as(
                LengthUnit.Kilometer,
                LatLng(postLatitude, postLongitude),
                LatLng(_currentPosition.latitude, _currentPosition.longitude),
              );

              // 1km 이내에 있는 게시물만 반환
              return km <= 1000;
            }).toList();

            return ListView.builder(
              itemCount: nearbyPosts.length,
              itemBuilder: (context, index) {
                // Access each post's data using posts[index].data()
                // Customize the ListTile based on your data structure
                return ListTile(
                  title: Text(nearbyPosts[index]['title']),
                  subtitle: Text(nearbyPosts[index]['content']),
                  onTap: () {
                    Routemaster.of(context)
                        .push('/community/${nearbyPosts[index].id}');
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
