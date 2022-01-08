import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

import 'Models/allUsers.dart';
import 'Models/drivers.dart';

String mapKey = "AIzaSyBYsZ0WQhbK8RPc6Z8xRx0bL4cLRAFCkmc";

User? firebaseUser;

Users? userCurrentInfo;

User? currentfirebaseUser;

StreamSubscription<Position>? homeTabPageStreamSubscription;

StreamSubscription<Position>? rideStreamSubscription;

final assetsAudioPlayer = AssetsAudioPlayer();

late Position currentPosition;

Drivers? driversInformation;

String title ="";

double starCounter =0.0;