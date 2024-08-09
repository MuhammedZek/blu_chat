import 'package:flutter/material.dart';
import 'package:flutter_blue_app/main_page.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(new ExampleApplication());

class ExampleApplication extends StatefulWidget {
  const ExampleApplication({super.key});

  @override
  State<ExampleApplication> createState() => _ExampleApplicationState();
}

class _ExampleApplicationState extends State<ExampleApplication> {
  @override
  void initState() {
    super.initState();
    requestBluetoothPermissions();
  }

  Future<void> requestBluetoothPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
    ].request();

    print(statuses);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder(
          future: requestBluetoothPermissions(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Container(
                width: MediaQuery.sizeOf(context).width,
                height: MediaQuery.sizeOf(context).height,
                color: Colors.blueGrey,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            } else {
              return MainPage();
            }
          }),
    );
  }
}
