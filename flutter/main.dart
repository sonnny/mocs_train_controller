////////////////////////
// flutter main.dart////
// flutter pub add get
// flutter pub add universal_ble
// works with linux laptop with ble
// works with pixel 7a
// works with samsung galaxy 10
// connects to picow with id "28:CD:C1:08:28:9E"
//
//
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:universal_ble/universal_ble.dart';
import './permission_handler.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';

void main() {
  runApp(
    MaterialApp(
      title: 'Universal BLE',
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: const MyApp()));}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  State createState() => _MyAppState();}

class _MyAppState extends State<MyApp> {

QueueType _queueType = QueueType.global;
late BleDevice device;
late BleService service;
late List<BleService> discoveredServices=[];
late BleCharacteristic charTx;
ScanFilter? scanFilter;
var status='scan and connect'.obs;

void write_test(val) async {
Uint8List data=utf8.encode(val);

try{await UniversalBle.writeValue(
  device.deviceId,service.uuid,charTx.uuid,data,BleOutputProperty.withResponse);
} catch(e) {print(e);}}
  
void handleScan(result) async{
if (result.deviceId == "28:CD:C1:08:28:9E"){
device=result;

status.value = 'connecting...';
try{await UniversalBle.connect(device.deviceId);}
catch(e){print(e.runtimeType);print(e);}

try{var services=await(UniversalBle.discoverServices(device.deviceId));
discoveredServices=services;}
catch(e){print(e);}

for(var s in discoveredServices){
  if(s.uuid.toString() == "6e400001-b5a3-f393-e0a9-e50e24dcca9e"){
   status.value = 'discovering services...';
   print("service found");
   service=s;
   var chars=service.characteristics;
   for(var c in chars){
     status.value = 'finding characteristic...';
     if(c.uuid.toString() == "6e400002-b5a3-f393-e0a9-e50e24dcca9e"){
       status.value="app ready";
       charTx=c;}}}}}}

void handleConnect(String deviceId,bool isConnected,String? error){
status.value = isConnected ? "Connected" : "Scanning...";} 

void handleQueue(String id, int len){
print("queue: $id  len: $len");}

Future<void> startScan()async{
print("startscan function");
try{await UniversalBle.stopScan();}catch(e){print(e);}
try{await UniversalBle.startScan();}catch(e){print(e);}}

@override void initState() {
super.initState();
UniversalBle.queueType = QueueType.global;//works for desktop
UniversalBle.timeout = const Duration(seconds:30);//30 works for android
//UniversalBle.timeout = const Duration(seconds:10);//works for desktop
UniversalBle.onQueueUpdate = handleQueue;
UniversalBle.onScanResult = handleScan;
UniversalBle.onConnectionChange = handleConnect;}

@override Widget build(BuildContext bc){
return Scaffold(appBar:AppBar(title:Text('mocs train controller')),

body:Column(spacing:20,children:[

ElevatedButton(child:Text("check permissions"),onPressed:()async{
bool hasPermissions=await PermissionHandler.arePermissionsGranted();
if (hasPermissions){print("permission granted");}}),

ElevatedButton(onPressed:(){startScan();},
child:Obx(()=>Text('${status}'))),

Padding(padding:EdgeInsets.fromLTRB(80,20,0,20),child:Row(spacing:20,children:[
ElevatedButton(onPressed:(){write_test('forward\r\n');},child:Text('forward')),
ElevatedButton(onPressed:(){write_test('reverse\r\n');},child:Text('reverse')),
])),

Padding(padding:EdgeInsets.fromLTRB(80,20,0,20),child:Row(spacing:20,children:[
ElevatedButton(onPressed:(){write_test('+\r\n');},child:Text('increase')),
ElevatedButton(onPressed:(){write_test('-\r\n');},child:Text('decrease')),
])),

ElevatedButton(onPressed:(){write_test('stop\r\n');},child:Text('stop')),

Text('''
  troubleshooting: turn on/off battery on the picow micropython
  
  wait for the status to say app ready before proceeding, if
  you are unable to get app ready status then something is wrong
  and not connecting with the ble.

'''),

]));}}
