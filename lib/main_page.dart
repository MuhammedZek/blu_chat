import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_app/chat_page.dart';
import 'package:flutter_blue_app/communication.dart';
import 'package:flutter_blue_app/select_bonded_device_page.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  String? _address;
  String? _name;

  @override
  void initState() {
    super.initState();

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    Future.doWhile(() async {
      // Wait if adapter not enabled
      if (await FlutterBluetoothSerial.instance.isEnabled ?? false) {
        return false;
      }
      await Future.delayed(const Duration(milliseconds: 221));
      return true;
    }).then((_) {
      // Update the address field
      FlutterBluetoothSerial.instance.address.then((address) {
        setState(() {
          _address = address;
        });
      });
    });

    FlutterBluetoothSerial.instance.name.then((name) {
      setState(() {
        _name = name;
      });
    });

    // Listen for futher state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;
      });
    });
  }

  // This code is just a example if you need to change page and you need to communicate to the raspberry again
  void init() async {
    Communication com = Communication();
    await com.connectBl(_address);
    com.sendMessage('Hello');
    setState(() {});
  }

  @override
  void dispose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Bluetooth Serial'),
      ),
      body: ListView(
        children: <Widget>[
          const Divider(),
          const ListTile(title: Text('General')),
          SwitchListTile(
            title: const Text('Enable Bluetooth'),
            value: _bluetoothState.isEnabled,
            onChanged: (bool value) {
              // Do the request and update with the true value then
              future() async {
                // async lambda seems to not working
                if (value) {
                  await FlutterBluetoothSerial.instance.requestEnable();
                } else {
                  await FlutterBluetoothSerial.instance.requestDisable();
                }
              }

              future().then((_) {
                setState(() {});
              });
            },
          ),
          ListTile(
            title: const Text('Bluetooth status'),
            subtitle: Text(_bluetoothState.toString()),
            trailing: MaterialButton(
              child: const Text('Settings'),
              onPressed: () {
                FlutterBluetoothSerial.instance.openSettings();
              },
            ),
          ),
          ListTile(
            title: const Text('Local adapter address'),
            subtitle: Text(_address ?? '...'),
          ),
          ListTile(
            title: const Text('Local adapter name'),
            subtitle: Text(_name ?? '...'),
            onLongPress: null,
          ),
          const Divider(),
          const ListTile(title: Text('Devices discovery and connection')),
          ListTile(
            title: MaterialButton(
              child: const Text('Connect to paired device to chat'),
              onPressed: () async {
                final BluetoothDevice? selectedDevice =
                    await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return const SelectBondedDevicePage(
                        checkAvailability: false,
                      );
                    },
                  ),
                );

                if (selectedDevice != null) {
                  print('Connect -> selected ${selectedDevice.address}');
                  if (context.mounted) {
                    _startChat(context, selectedDevice);
                  }
                } else {
                  print('Connect -> no device selected');
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _startChat(BuildContext context, BluetoothDevice server) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return ChatPage(server: server);
        },
      ),
    );
  }
}
