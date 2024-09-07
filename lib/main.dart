import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barcode Reader Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Barcode Reader Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String scannedText = '', queryResult = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
              child: const Text('Scan the Barcode'),
              onPressed: () async {
                String scanResult = (await BarcodeScanner.scan()).rawContent;
                List<String> scannedValues = scanResult.split('-');
                List<List> data = await readCsvSheet();
                setState(() {
                  queryResult = searchingThroughCsvFile(scannedValues, data) ? "Found a Match!" : "Didn't find anything";
                  scannedText = scanResult;
                });
              },
            ),
            scannedText.isEmpty ? const SizedBox() : Text("The scanned text is: $scannedText"),
            Text(queryResult),
          ],
        ),
      ),
    );
  }

  Future<List<List>> readCsvSheet() async {
    try {
      final downloadsPath = await getDownloadsDirectory();
      final input = File("$downloadsPath/data.csv").openRead();
      final fields = await input.transform(utf8.decoder).transform(const CsvToListConverter()).toList();
      return fields;
    } on Exception catch (_) {
      print(":p");
      return [];
    }
  }

  bool searchingThroughCsvFile(List<String> values, List<List> data) {
    for(List row in data) {
      if(row[0] == values[0] && row[1] == values[1] && row[2] == values[2]) {
        return true;
      }
    }
    return false;
  }
}
