import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foreground_service/foreground_service.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Plugin example app'),
        ),
        body: new Center(
          child: new Column(
            children: <Widget>[
              new SizedBox(
                height: 24.0,
              ),
              new RaisedButton(
                onPressed: () => ForegroundService.start(
                      title: 'Valerain',
                      text: 'Background Ground Processing',
                      subText: 'Do not close',
                      ticker: 'Ticker',
                    ),
                child: const Text('Start'),
              ),
              new SizedBox(
                height: 24.0,
              ),
              new RaisedButton(
                color: Colors.orange.shade500,
                onPressed: () => ForegroundService.enableTfLite(),
                child: const Text('Enable Tensorflow'),
              ),
              new SizedBox(
                height: 24.0,
              ),
              new RaisedButton(
                onPressed: () => ForegroundService.stop(),
                child: const Text('Stop'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
