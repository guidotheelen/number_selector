import 'package:flutter/material.dart';
import 'package:number_selector/number_selector.dart';

void main() {
  runApp(const NumberSelectorApp());
}

class NumberSelectorApp extends StatelessWidget {
  const NumberSelectorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Number Selector App'),
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text('Number selector with min and max'),
            ),
            NumberSelector(
              current: 47,
              min: 1,
              max: 100,
              onUpdate: (val) {
                print('onUpdate: $val');
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text('Number selector without min and max'),
            ),
            NumberSelector(
              current: 47,
              onUpdate: (val) {
                print('onUpdate: $val');
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text('Basic number selector'),
            ),
            NumberSelector.borderless(
              onUpdate: (number) {
                print(number);
              },
            ),
          ],
        ),
      ),
    );
  }
}
