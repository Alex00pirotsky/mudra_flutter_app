import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:nordic_dfu/nordic_dfu.dart';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blueGrey,
      ),
      //home: MyHomePage(title: 'Flutter Demo Home Page'),
      home: BluetoothApp(), // BluetoothApp() would be defined later
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class BluetoothApp extends StatefulWidget {
  @override
  _BluetoothAppState createState() => _BluetoothAppState();
}

class _BluetoothAppState extends State<BluetoothApp> {
  // Initializing a global key, as it would help us in showing a SnackBar later
  // final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  // Get the instance of the bluetooth
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;

  // Define some variables, which will be required later
  List<BluetoothDevice> _devicesList = [];

  List<BluetoothService> services = [];
  List<BluetoothCharacteristic> _ble_char = [];

  bool _connected = false;
  bool _pressed = false;
  bool _mouse_on = false;
  int disconnect_retry = 0;

  // @override
  // Widget build(BuildContext context) {
  //   return Container(
  //       // We have to work on the UI in this part
  //       );
  // }
  void test() {
    print("HELLOW");
  }

  @override
  void initState() {
    super.initState();
    _connected = false;
    startTimer();

    //get_connected_device();
    //bluetoothConnectionState();
    //_start_scan();
  }

  void connection(BluetoothDevice dev) async {
    for (var dd in await flutterBlue.connectedDevices) {
      if (dev == dd) {
        disconnect_retry = 0;
        if (_connected == false) {
          print(" CONNECTED ${dd.name}");
          _devicesList.clear();
          _devicesList.add(dev);
          bluetoothserviceState();
          setState(() {
            _connected = true;
            print("HELLOW");
          });
          return;
        }
      }
    }
    if (disconnect_retry++ > 10) {
      setState(() {
        _connected = false;
        force_connect_device(dev);
        print("SHIT");
      });
    }
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    Timer _timer;
    _timer = new Timer.periodic(oneSec, (Timer timer) {
      setState(() {
        bluetoothConnectionState();
        // print("${flutterBlue.state.toString()}");
        ;
      });
    });
  }

  void force_connect_device(BluetoothDevice dev) async {
    await dev.connect().asStream().listen((event) {
      connection(dev);
    });
  }

  // void device_connection_check(BluetoothDevice dev) async {
  //   await dev.state.listen((event) {
  //     if (event == BluetoothDeviceState.connected) {
  //       _devicesList.clear();
  //       _devicesList.add(dev);
  //       bluetoothserviceState();
  //     } else if (event == BluetoothDeviceState.disconnected) {
  //       print("SHIT");
  //     }
  //   });
  // }

  Future<void> bluetoothConnectionState() async {
    List<BluetoothDevice> devices = [];

    if (flutterBlue.isOn == false) {
      setState(() {
        _connected = false;
        print("HELLOW");
      });
      return;
    }
    // _devicesList.clear();
    for (BluetoothDevice dev in await flutterBlue.bondedDevices) {
      if (dev.name.indexOf("Mudra Band") >= 0) {
        // print("BONDED ${dev.name}");
        connection(dev);
      }
    }

    // dev_main = _devicesList.first;
    // services = await dev_main.discoverServices();
    // for (var element in services) {
    //   print('UUID ${element.uuid.toString()}');
    // }

    //_devicesList = devices;
  }

  Future<void> bluetoothserviceState() async {
    BluetoothDevice dev_main;
    if (_devicesList.isEmpty) {
      return;
    }

    dev_main = _devicesList.first;
    services = await dev_main.discoverServices();
    for (var element in services) {
      if (element.uuid.toString().indexOf("fff0") >= 0) {
        _ble_char = element.characteristics;
      }
    }

    // for (var element in _ble_char) {
    //   print("CHAR ${element.toString()}\n");
    // }
    if (_ble_char.isEmpty == false) {
      _ble_char.first.write([0x07, 0x07, 0x00]);
      _mouse_on = false;

      // setState(() {
      //   _connected = true;
      // });
    } else {
      setState(() {
        _connected = false;
      });
    }

    // setState(() {
    //   _connected = true;
    // });
    // services = await dev_main.discoverServices();
    // for (var element in services) {
    //   print('UUID ${element.uuid.toString()}');
    // }

    //_devicesList = devices;
  }

  void ble_on_of_mouse() {
    setState(() {
      if (_mouse_on == false && _ble_char.isEmpty == false) {
        _ble_char.first.write([0x07, 0x07, 0x01]);
        _mouse_on = true;
      } else if (_ble_char.isEmpty == false) {
        _ble_char.first.write([0x07, 0x07, 0x00]);
        _mouse_on = false;
      }
    });
  }

  Future<void> _updateFirmware() async {
    print("START DFU HERE");
    try {
      await NordicDfu().startDfu(
        'EB:75:AD:E3:CA:CF',
        'C:/dev/flutter/flutter_application_1/assets/1.0.6.50.zip',
        fileInAsset: false,
        enableUnsafeExperimentalButtonlessServiceInSecureDfu: true,
        onProgressChanged: (
          deviceAddress,
          percent,
          speed,
          avgSpeed,
          currentPart,
          partsTotal,
        ) {
          print('deviceAddress: $deviceAddress, percent: $percent');
        },
      );
    } catch (exception) {
      print("Firmware Update Failed: $exception");
    }
  }

  void dfu() async {
    await NordicDfu().startDfu('EB:75:AD:E3:CA:CF', 'assets/');
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: _devicesList.isEmpty == false
              ? Text("${_devicesList.first.name} CONNECTED")
              : Text("GO TO SETTINGS AND CONNECT BAND"),
        ),
        body: Center(
            child: Column(children: <Widget>[
          Container(
            margin: EdgeInsets.all(25),
            child: ElevatedButton(
              child: Text(
                'DFU',
                style: TextStyle(fontSize: 20.0),
              ),
              onPressed: _updateFirmware,
            ),
          ),
          Container(
            margin: EdgeInsets.all(25),
            child: ElevatedButton(
              child: Text(
                _mouse_on ? 'Mouse enable' : 'Mouse disable',
                style: TextStyle(fontSize: 20.0),
              ),
              // color: Colors.blueAccent,
              // textColor: Colors.white,
              onPressed: ble_on_of_mouse,
            ),
          ),
        ]))
        // floatingActionButton: FloatingActionButton.extended(

        //   onPressed: ble_on_of_mouse,
        //   tooltip: 'MOUSE',
        //   label: _mouse_on ? Text('Mouse enable') : Text('Mouse disable'),
        //   icon: _mouse_on ? Icon(Icons.thumb_up) : Icon(Icons.thumb_down),
        //   backgroundColor: _mouse_on ? Colors.green : Colors.blueGrey,
        //   // child: const Icon(Icons.add),
        // ), // This trailing comma makes auto-formatting nicer for build methods.

        );
  }
}
