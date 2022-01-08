import 'dart:async';
import 'package:drivers_app_taxi_rouge/Assistants/assistantMethods.dart';
import 'package:drivers_app_taxi_rouge/Models/drivers.dart';
import 'package:drivers_app_taxi_rouge/Notifications/pushNotificationService.dart';
import 'package:drivers_app_taxi_rouge/configMaps.dart';
import 'package:drivers_app_taxi_rouge/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeTabPage extends StatefulWidget{

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  _HomeTabPageState createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  late GoogleMapController newGoogleMapController;


  var geoLocator = Geolocator();

String driverStatusText = "Offline Now - Go Online";

Color driverStatusColor = Colors.red;

bool isDriverAvailable = false;

@override
void initState() {
  super.initState();

  getCurrentDriverInfo();
}

getRatings()
{
  driversRef.child(currentfirebaseUser!.uid).child("ratings").once().then((DataSnapshot dataSnapshot)
  {
    if(dataSnapshot.value != null)
    {
      double ratings = double.parse(dataSnapshot.value.toString());
      setState(() {
        starCounter = ratings;
      });
      if(starCounter <= 1.5)
      {
        setState(() {
          title = "Very Bad";
        });
        return;
      }
      if(starCounter <= 2.5)
      {
        setState(() {
          title = " Bad";
        });
        return;
      }
      if(starCounter <= 3.5)
      {
        setState(() {
          title = "Good";
        });
        return;
      }
      if(starCounter <= 4.5)
      {
        setState(() {
          title = "Very Good";
        });
        return;
      }
      if(starCounter <= 5.5)
      {
        setState(() {
          title = "Exellent";
        });
        return;
      }
    }
  });
}
  void locatePosition() async
  {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    LatLng latLatPosition = LatLng(position.latitude, position.longitude);

    CameraPosition cameraPosition= new CameraPosition(target: latLatPosition, zoom: 14);
    newGoogleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

   // String address = await AssistantMethods.searchCoordinateAddress(position,context);
 //   print("This is your Address :: " + address);
  }

  void getCurrentDriverInfo() async
  {
    currentfirebaseUser = FirebaseAuth.instance.currentUser;

    driversRef.child(currentfirebaseUser!.uid).once().then((DataSnapshot dataSnapShot){
      if(dataSnapShot.value !=null)
        {
            driversInformation = Drivers.fromSnapshot(dataSnapShot);
        }
    });

    PushNotificationService pushNotificationService = PushNotificationService();

    pushNotificationService.initialize(context);
    pushNotificationService.getToken();

    AssistantMethods.retrieveHistoryInfo(context);
    getRatings();
  }

  @override
  Widget build(BuildContext context)
  {
    return Stack(
      children: [
      GoogleMap(
        mapType: MapType.normal,
        myLocationButtonEnabled: true,
        initialCameraPosition: HomeTabPage._kGooglePlex,
        myLocationEnabled: true,
        zoomGesturesEnabled: true,
        zoomControlsEnabled: true,

        onMapCreated: (GoogleMapController controller)
        {
          _controllerGoogleMap.complete(controller);
          newGoogleMapController = controller;

          locatePosition();
          },
      ),

        Container(
          height: 140.0,
          width: double.infinity,
          color: Colors.black54,
        ),

        Positioned(
          top: 60.0,
          left: 0.0,
          right: 0.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                // ignore: deprecated_member_use
                child: RaisedButton(
                  onPressed: ()
                  {


                        if(isDriverAvailable != true)
                          {
                            makeDriverOnlineNow();
                            getLocationLiveUpdates();

                            setState(() {
                              driverStatusColor = Colors.yellowAccent;
                              driverStatusText = "Online Now";
                              isDriverAvailable = true;
                            });
                            displayToastMessage("you are Online Now.",context);
                          }
                        else{
                          setState(() {
                            driverStatusColor = Colors.red;
                            driverStatusText = "Offline Now - Go Online";
                            isDriverAvailable = false;
                          });
                                  makeDriverOfflineNow();
                                  displayToastMessage("you are Offline Now.", context);
                        }
                  },
                  color: driverStatusColor,
                  child: Padding(
                    padding: EdgeInsets.all(17.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(driverStatusText,style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.black),),
                        Icon(Icons.phone_android, color: Colors.black,size: 26.0,),
                      ],
                    ),
                  ),
                ),
              ),
            ],
        ),
        )
      ],
    );
  }

  void makeDriverOnlineNow() async
  {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    Geofire.initialize("availableDrivers");
    Geofire.setLocation(currentfirebaseUser!.uid, currentPosition.latitude, currentPosition.longitude);

    rideRequestRef!.set("searching");
    rideRequestRef!.onValue.listen((event)
    {

    });
  }

  void getLocationLiveUpdates()
  {
    homeTabPageStreamSubscription= Geolocator.getPositionStream().listen((Position position){
      currentPosition = position;
      if(isDriverAvailable == true)
        {
          Geofire.setLocation(currentfirebaseUser!.uid, position.latitude, position.longitude);

        }
      LatLng latLng = LatLng(position.latitude, position.longitude);
      newGoogleMapController.animateCamera(CameraUpdate.newLatLng(latLng));
    });
  }

  void makeDriverOfflineNow()
  {
    Geofire.removeLocation(currentfirebaseUser!.uid);
    rideRequestRef!.onDisconnect();
    rideRequestRef!.remove();
    rideRequestRef=null;
  }

  displayToastMessage(String message, BuildContext context)
  {
    Fluttertoast.showToast(msg: message);
  }
}


