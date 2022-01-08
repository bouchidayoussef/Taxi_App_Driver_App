import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:drivers_app_taxi_rouge/Models/rideDetails.dart';
import 'package:drivers_app_taxi_rouge/Notifications/notificationDialog.dart';
import 'package:drivers_app_taxi_rouge/configMaps.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../main.dart';
import 'dart:io' show Platform;

import 'notificationDialog.dart';


class PushNotificationService {
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  Future initialize(context) async {
    // NotificationSettings settings = await firebaseMessaging.requestPermission(
    //   alert: true,
    //   announcement: false,
    //   badge: true,
    //   carPlay: false,
    //   criticalAlert: false,
    //   provisional: false,
    //   sound: true,
    // );

    await Firebase.initializeApp(); // necessary for initializing firebase

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      retrieveRideRequestInfo(getRideRequestId(message),context);

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });

  }

  Future<String?> getToken() async
  {
    String? token = await firebaseMessaging.getToken();
    print("This is token :");
    print(token);
    driversRef.child(currentfirebaseUser!.uid).child("token").set(token);
    await FirebaseMessaging.instance.subscribeToTopic('alldrivers');
    await FirebaseMessaging.instance.subscribeToTopic('allusers');
  }

  String getRideRequestId(RemoteMessage message)
  {
    String rideRequestId= "";
    if(Platform.isAndroid)
      {
        rideRequestId = message.data['ride_request_id'];
      }
    else
      {
        rideRequestId = message.data['ride_request_id'];
      }
    return rideRequestId;
  }

  void retrieveRideRequestInfo(String rideRequestId, BuildContext context)
  {
    newRequestsRef.child(rideRequestId).once().then((DataSnapshot dataSnapShot)
        {
          if(dataSnapShot.value!=null)
            {
              assetsAudioPlayer.open(Audio("sounds/alert.mp3"));
              assetsAudioPlayer.play();

              double pickUpLocationLat = double.parse(dataSnapShot.value['pickup']['latitude'].toString());
              double pickUpLocationLng = double.parse(dataSnapShot.value['pickup']['longitude'].toString());
              String pickUpAddress =dataSnapShot.value['pickup_address'].toString();

              double dropOffLocationLat = double.parse(dataSnapShot.value['dropoff']['latitude'].toString());
              double dropOffLocationLng = double.parse(dataSnapShot.value['dropoff']['longitude'].toString());
              String dropOffAddress =dataSnapShot.value['dropoff_address'].toString();

              String paymentMethod = dataSnapShot.value['payment_method'].toString();

              String rider_name = dataSnapShot.value["rider_name"];
              String rider_phone = dataSnapShot.value["rider_phone"];


              RideDetails rideDetails = RideDetails(pickup_address: "pickup_address", dropoff_address: "dropoff_address", pickup: LatLng(pickUpLocationLat,pickUpLocationLng), dropoff: LatLng(dropOffLocationLat,dropOffLocationLng), ride_request_id: "ride_request_id", payment_method: "payment_method", rider_name: "rider_name", rider_phone: "rider_phone");
              rideDetails.ride_request_id = rideRequestId;
              rideDetails.pickup_address = pickUpAddress;
              rideDetails.dropoff_address = dropOffAddress;
              rideDetails.pickup = LatLng(pickUpLocationLat,pickUpLocationLng);
              rideDetails.dropoff=LatLng(dropOffLocationLat,dropOffLocationLng);
              rideDetails.payment_method = paymentMethod;
              rideDetails.rider_name= rider_name;
              rideDetails.rider_phone=rider_phone;

              print("Information ::");
              print(rideDetails.pickup_address);
              print(rideDetails.dropoff_address);

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) => NotificationDialog(rideDetails: rideDetails),
              );
            }
                  });
  }
}

