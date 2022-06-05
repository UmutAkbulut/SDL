import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:smartdoorlock/Pages/homepage.dart';
import 'package:smartdoorlock/Pages/registerPage.dart';

void main() {
  runApp(const MyApp());
}


String api_ip = "https://0222-85-153-206-67.eu.ngrok.io";

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,

      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

void dialogShow(
    BuildContext context,
    String title,
    String body,
    ) async {
  final action = await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(title),
        content: Text(body),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Okay"),
          ),

        ],
      );
    },
  );

}

String phoneNumber = "";


class MyHomePage extends StatefulWidget {

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  TextEditingController phone = TextEditingController();
  TextEditingController password = TextEditingController();

  void login() async {
    phone.text = "";
    password.text = "";

     if(phone.text == "" || password.text == ""){

        dialogShow(context, "Login Error", "Phone or Password can't be empty!");
        return;
     }
    var response = await Dio().get(api_ip+"/login?phone="+ phone.text.toString() + "&password=" + password.text.toString());
    if (response.data["status"] ==  true){
      phoneNumber = phone.text;
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
          HomePage()), (Route<dynamic> route) => false);
    }else{


      dialogShow(context, "Login Error", "Phone number or password is invalid!");
    }

  }


  @override
  Widget build(BuildContext context) {

    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Smart Door Lock")),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[

          Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: height/4, left: width/20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [

                    Text("Phone"),

                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.only(left: width/20),
                child: Row(
                  children: [

                    SizedBox(
                      height: height/15,
                      width: width-40,
                      child: TextField(

                        controller: phone,

                      ),
                    ),

                  ],
                ),
              ),



              Padding(
                padding: EdgeInsets.only(top: height/25, left: width/20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [

                    Text("Password"),

                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.only(left: width/20),
                child: Row(
                  children: [

                    SizedBox(
                      height: height/15,
                      width: width-40,
                      child: TextField(

                        controller: password,
                        obscureText: true,

                      ),
                    ),

                  ],
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(onPressed: (){

                    print("login click");
                    login();


                  }, child: Text("Login")),

                  SizedBox(width: width/20,),

                  ElevatedButton(onPressed: (){

                    print("register click");
                    Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPage()));


                  }, child: Text("Register"))


                ],),
            ],
          )



        ],
      ),

    );
  }
}
