import 'package:firebase_database/firebase_database.dart';

class Drivers
{
  String name="hell";
  String phone="hell";
  String email="hell";
  String id="hell";
  String car_color="hell";
  String car_model="hell";
  String car_number="hell";

  Drivers({required this.name,required this.phone,required this.email,required this.id,required this.car_color,required this.car_model,required this.car_number});

  Drivers.fromSnapshot(DataSnapshot dataSnapshot)
  {
    id = dataSnapshot.key!;
    phone=  dataSnapshot.value["phone"];
    email = dataSnapshot.value["email"];
    name =  dataSnapshot.value["name"];
    car_color = dataSnapshot.value["car_details"]["car_color"];
    car_model =  dataSnapshot.value["car_details"]["car_model"];
    car_number =  dataSnapshot.value["car_details"]["car_number"];
  }
}