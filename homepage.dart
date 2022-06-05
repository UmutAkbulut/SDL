import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:smartdoorlock/Mechanism/Mechanism.dart';
import 'package:smartdoorlock/Pages/registerMechanismPage.dart';
import 'package:http/http.dart' as http;


import '../main.dart';



class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child:
      ListView(

        padding: EdgeInsets.zero,
        children: [


          Container(
            height: 88,
            child: DrawerHeader(
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: <Color>[
                    Colors.red,
                    Colors.redAccent,
                    Colors.deepOrangeAccent,
                  ])

              ),
              child: Container(
                child: Column(



                ),
              ),
            ),
          ),


          CustomListTile(Icons.home, "Home Page", (){
            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => HomePage()), (Route<dynamic> route) => false);

          }),

          CustomListTile(Icons.qr_code, "Register Mechanism", (){
            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => RegisterMechanism()), (Route<dynamic> route) => false);

          }),

          CustomListTile(Icons.logout, "Log Out", (){
            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => MyHomePage()), (Route<dynamic> route) => false);
          }),


        ],
      ),
    );
  }
}

class CustomListTile extends StatelessWidget {

  IconData icon;
  String text;
  final Function() onPressed;

  CustomListTile(this.icon,this.text, this.onPressed);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: InkWell(
        splashColor: Colors.grey,
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade400))
          ),
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(

                children: [

                  Icon(icon),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(text, style: TextStyle(
                      fontSize: 16.0,

                    ),),
                  ),

                ],

              ),

              Icon(Icons.arrow_right),
            ],


          ),
        ),


      ),
    );
  }
}

List<Mechanism> mechanismList = <Mechanism>[];

void changeMechanismStatus(int mechanism_id, String action) async{

  await Dio().get(api_ip + "/changeLockStatus?mechanism_id=" +  mechanism_id.toString() + "&user_phone=" + phoneNumber + "&action=" + action);

}

void changeAutoLockStatus(int mechanism_id, String action) async{

  await Dio().get(api_ip + "/changeAutoLockStatus?mechanism_id=" +  mechanism_id.toString() + "&user_phone=" + phoneNumber + "&action=" + action);

}

Future<void> showMechanism() async {
  mechanismList = await getMechanism();
}

Future<List<Mechanism>> getMechanism() async {

  var respond = await Dio().get(api_ip + "/getMechanisms?user_phone="+ phoneNumber);
  var jsonData = json.decode(respond.data);
  var jsonArray = jsonData as List;
  mechanismList = jsonArray.map((obj) => Mechanism.fromJson(obj)).toList();

  return mechanismList;



}



class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    showMechanism();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text("Smart Door Lock")),),
      drawer: CustomDrawer(),
      body: FutureBuilder(
        future: showMechanism(),
        builder: (context, snapshot){
          if(snapshot.connectionState == ConnectionState.none){

            return Container(
              child: Text("Test"),
            );

          }

          return  ListView.builder(
              itemCount: mechanismList.length,
              itemBuilder: (BuildContext context,int index){
                return ListTile(
                    trailing: Wrap(
                      spacing: 12,
                      children: [





                        mechanismList[index].auto_lock == 0 ? GestureDetector(onTap: (){

                          setState(() {
                            changeAutoLockStatus(mechanismList[index].mechanism_id, "on");

                          });

                        },child: Text("Auto Lock", style: TextStyle(color: Colors.red, fontSize: 20),)) : GestureDetector(onTap:(){
                          setState(() {
                            changeAutoLockStatus(mechanismList[index].mechanism_id, "off");
                          });

                        }, child: Text("Auto Lock", style: TextStyle(color: Colors.green, fontSize: 20),),),



                        mechanismList[index].lock_status == 0 ? GestureDetector(onTap: (){

                          setState(() {
                            changeMechanismStatus(mechanismList[index].mechanism_id, "lock");

                          });

                        },child: Icon(Icons.lock_open, color: Colors.red,)) : GestureDetector(onTap:(){
                          setState(() {
                            changeMechanismStatus(mechanismList[index].mechanism_id, "unlock");
                          });

                        }, child: Icon(Icons.lock, color: Colors.green,)),


                      ],

                    ),
                    title:Text("Door Lock: " + mechanismList[index].mechanism_id.toString()),
                );
              }
          );




        },



      ),
    );
  }
}
