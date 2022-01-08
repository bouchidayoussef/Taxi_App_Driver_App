import 'package:drivers_app_taxi_rouge/AllScreens/HistoryScreen.dart';
import 'package:drivers_app_taxi_rouge/DataHandler/appData.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class EarningTabPage extends StatelessWidget{
  @override
  Widget build(BuildContext context)
  {
    return Column(
      children: [
        Container(
        color: Colors.red[600],
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 70),
          child: Column(
          children: [
            Text('Total Earnings', style: TextStyle(color: Colors.yellowAccent),),
            Text('${Provider.of<AppData>(context, listen: false).earnings} dh',style: TextStyle(color: Colors.yellowAccent, fontSize: 50, fontFamily: 'Brand Bold'),)
          ],
        ),
        ),
    ),

        // ignore: deprecated_member_use
        FlatButton(
          padding: EdgeInsets.all(0),
            onPressed: (){
              Navigator.push(context,MaterialPageRoute(builder: (context)=> HistoryScreen()));
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 18),
              child: Row(
                children: [
                Image.asset('images/taxi.png',width: 70,),
                SizedBox(width: 16,),
                Text('Total Trips', style: TextStyle(fontSize: 16),),
                Expanded(child: Container(child: Text(Provider.of<AppData>(context, listen: false).countTrips.toString(),textAlign:  TextAlign.end, style: TextStyle(fontSize: 18),)))
                ],
              ),
            ),
        ),

        Divider(height: 2.0, thickness: 2.0,),
      ],
    );
  }
}
