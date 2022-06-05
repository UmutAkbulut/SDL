import 'dart:io';

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smartdoorlock/Pages/homepage.dart';

import '../main.dart';

class RegisterMechanism extends StatefulWidget {
  const RegisterMechanism({Key? key}) : super(key: key);

  @override
  State<RegisterMechanism> createState() => _RegisterMechanismState();
}

class _RegisterMechanismState extends State<RegisterMechanism> {

ScanResult? scanResult;

final _flashOnController = TextEditingController(text: 'Flash on');
final _flashOffController = TextEditingController(text: 'Flash off');
final _cancelController = TextEditingController(text: 'Cancel');

var _aspectTolerance = 0.00;
var _numberOfCameras = 0;
var _selectedCamera = -1;
var _useAutoFocus = true;
var _autoEnableFlash = false;

static final _possibleFormats = BarcodeFormat.values.toList()
  ..removeWhere((e) => e == BarcodeFormat.unknown);

List<BarcodeFormat> selectedFormats = [..._possibleFormats];

@override
void initState() {
  super.initState();

  Future.delayed(Duration.zero, () async {
    _numberOfCameras = await BarcodeScanner.numberOfCameras;
    setState(() {});
  });
}

void registerMechanism(String mechanismID) async {


  await Dio().get(api_ip+"/registermechanism?mechanismid="+ mechanismID + "&phone=" + phoneNumber );


}


@override
Widget build(BuildContext context) {
  final scanResult = this.scanResult;
  return Scaffold(
      appBar: AppBar(
        title: const Text('Register Mechanism'),
      ),
      drawer: CustomDrawer(),
      body: Center(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              ElevatedButton(
                child: Text("QR Okut"),
                onPressed: (){
                  _scan();
                },
              ),
            ],
          )
        ),
      ),
    );
}

Future<void> _scan() async {
  try {
    final result = await BarcodeScanner.scan(
      options: ScanOptions(
        strings: {
          'cancel': _cancelController.text,
          'flash_on': _flashOnController.text,
          'flash_off': _flashOffController.text,
        },
        restrictFormat: selectedFormats,
        useCamera: _selectedCamera,
        autoEnableFlash: _autoEnableFlash,
        android: AndroidOptions(
          aspectTolerance: _aspectTolerance,
          useAutoFocus: _useAutoFocus,
        ),
      ),
    );
    setState(() {
      scanResult = result;

      registerMechanism(this.scanResult!.rawContent.split(':')[1][0].toString());
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => HomePage()), (Route<dynamic> route) => false);
    });

  } on PlatformException catch (e) {
    setState(() {
      scanResult = ScanResult(
        type: ResultType.Error,
        format: BarcodeFormat.unknown,
        rawContent: e.code == BarcodeScanner.cameraAccessDenied
            ? 'The user did not grant the camera permission!'
            : 'Unknown error: $e',
      );
    });
  }
}
}
