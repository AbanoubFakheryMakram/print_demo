
import 'package:flutter/material.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';
import 'package:webcontent_converter/webcontent_converter.dart';
import 'demo.dart';
import 'services.dart';

class BluetoothPrinterScreen extends StatefulWidget {
  @override
  _BluetoothPrinterScreenState createState() => _BluetoothPrinterScreenState();
}

class _BluetoothPrinterScreenState extends State<BluetoothPrinterScreen> {
  bool _isLoading = false;
  List<BluetoothPrinter> _printers = [];
  BluetoothPrinterManager? _manager;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bluetooth Printer Screen"),
      ),
      body: ListView(
        children: [
          ..._printers.map((printer) => ListTile(
            title: Text("${printer.name}"),
            subtitle: Text("${printer.address}"),
            leading: Icon(Icons.bluetooth),
            onTap: () => _connect(printer),
            onLongPress: () {
              _startPrinter();
            },
            selected: printer.connected,
          )).toList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: _isLoading ? Icon(Icons.stop) : Icon(Icons.play_arrow),
        onPressed: _isLoading ? null : _scan,
      ),
    );
  }

  _scan() async {
    setState(() {
      _isLoading = true;
      _printers = [];
    });
    var printers = await BluetoothPrinterManager.discover();
    setState(() {
      _isLoading = false;
      _printers = printers;
    });
  }

  _connect(BluetoothPrinter printer) async {
    var paperSize = PaperSize.mm58;
    var profile = await CapabilityProfile.load();
    var manager = BluetoothPrinterManager(printer, paperSize, profile);
    var response = await manager.connect();
    if(response.msg == 'Success') {
      print(" -==== connected =====- ");
      ESCPrinterService.showToast(msg: 'connected to printer', bgColor: Colors.green);
      setState(() {
        _manager = manager;
        printer.connected = true;
        _startPrinter();
      });
    } else {
      ESCPrinterService.showToast(msg: 'connection failed', bgColor: Colors.red);
    }
  }

  _startPrinter() async {
    ESCPrinterService.showToast(msg: 'start printing', bgColor: Colors.green);
    final content = Demo.getShortReceiptContent();
    var bytes = await WebcontentConverter.contentToImage(content: content);
    var service = ESCPrinterService(bytes);
    var data = await service.getBytes(paperSize: PaperSize.mm58);
    if (_manager != null) {
      _manager!.writeBytes(data, isDisconnect: false);
    } else {
      ESCPrinterService.showToast(msg: 'manager is null', bgColor: Colors.red);
    }
  }
}