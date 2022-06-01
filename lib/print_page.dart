import 'dart:typed_data';
import 'package:charset_converter/charset_converter.dart';
import 'package:demo_printing/services.dart';
import 'package:intl/intl.dart';

import 'package:flutter/services.dart';
import 'package:image/image.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:permission_handler/permission_handler.dart';

import 'demo.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bluetooth demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Bluetooth demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  PrinterBluetoothManager printerManager = PrinterBluetoothManager();
  List<PrinterBluetooth> _devices = [];

  @override
  void initState() {
    super.initState();

    printerManager.scanResults.listen((devices) async {
      setState(() {
        _devices = devices;
      });
    });
  }

  void _startScanDevices() async {
    await Permission.bluetoothScan.request();
    await Permission.bluetooth.request();
    setState(() {
      _devices = [];
    });
    printerManager.startScan(const Duration(seconds: 4));
  }

  void _stopScanDevices() {
    printerManager.stopScan();
  }

  Future<List<int>> demoReceipt(PaperSize paper, CapabilityProfile profile) async {
    final Generator ticket = Generator(paper, profile);
    List<int> bytes = [];

    // Print image
    // final ByteData data = await rootBundle.load('assets/rabbit_black.jpg');
    // final Uint8List imageBytes = data.buffer.asUint8List();
    // final Image? image = decodeImage(imageBytes);
    // bytes += ticket.image(image);

    Uint8List encArabic = await CharsetConverter.encode("windows-1256", "اهلا");
    // ticket.textEncoded(encArabic, styles: PosStyles(codeTable: PosCodeTable.arabic));



    bytes += ticket.text(
      Demo.getShortReceiptContent(),
      styles: const PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
      linesAfter: 1,
    );

    bytes += ticket.text('عزت سلامه - عباس العقاد - مدينه نصر',
        styles: const PosStyles(align: PosAlign.center));
    bytes += ticket.text('دا كلام ملهوش لزمه بس علشان الطباعه',
        styles: const PosStyles(align: PosAlign.center));
    bytes += ticket.text('تليفون: 01023798556',
        styles: const PosStyles(align: PosAlign.center));
    bytes += ticket.text('احلا مسا عليك ي حسن',
        styles: const PosStyles(align: PosAlign.center), linesAfter: 1);

    bytes += ticket.hr();
    bytes += ticket.row([
      PosColumn(text: 'الكميه', width: 1),
      PosColumn(text: 'العنصر', width: 7),
      PosColumn(
          text: 'السعر',
          width: 2,
          styles: const PosStyles(align: PosAlign.left)),
      PosColumn(
          text: 'المجموع',
          width: 2,
          styles: const PosStyles(align: PosAlign.left)),
    ]);

    bytes += ticket.row([
      PosColumn(text: '2', width: 1),
      PosColumn(text: 'بصل', width: 7),
      PosColumn(
          text: '0.99',
          width: 2,
          styles: const PosStyles(align: PosAlign.left)),
      PosColumn(
          text: '1.98',
          width: 2,
          styles: const PosStyles(align: PosAlign.left)),
    ]);
    bytes += ticket.row([
      PosColumn(text: '1', width: 1),
      PosColumn(text: 'بيتزا', width: 7),
      PosColumn(
          text: '3.45',
          width: 2,
          styles: const PosStyles(align: PosAlign.left)),
      PosColumn(
          text: '3.45',
          width: 2,
          styles: const PosStyles(align: PosAlign.left)),
    ]);
    bytes += ticket.row([
      PosColumn(text: '1', width: 1),
      PosColumn(text: 'ملفوفات الربيع "أكلة', width: 7),
      PosColumn(
          text: '2.99',
          width: 2,
          styles: const PosStyles(align: PosAlign.left)),
      PosColumn(
          text: '2.99',
          width: 2,
          styles: const PosStyles(align: PosAlign.left)),
    ]);
    bytes += ticket.row([
      PosColumn(text: '3', width: 1),
      PosColumn(text: 'أصابع كرانشي', width: 7),
      PosColumn(
          text: '0.85',
          width: 2,
          styles: const PosStyles(align: PosAlign.left)),
      PosColumn(
          text: '2.55',
          width: 2,
          styles: const PosStyles(align: PosAlign.left)),
    ]);
    bytes += ticket.hr();

    bytes += ticket.row([
      PosColumn(
          text: 'المجموع',
          width: 6,
          styles: const PosStyles(
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          )),
      PosColumn(
          text: '\$10.97',
          width: 6,
          styles: const PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          )),
    ]);

    bytes += ticket.hr(ch: '=', linesAfter: 1);

    bytes += ticket.row([
      PosColumn(
          text: 'كاش',
          width: 7,
          styles:
              const PosStyles(align: PosAlign.left, width: PosTextSize.size2,)),
      PosColumn(
          text: '\$15.00',
          width: 5,
          styles:
              const PosStyles(align: PosAlign.left, width: PosTextSize.size2)),
    ]);
    bytes += ticket.row([
      PosColumn(
          text: 'خصم',
          width: 7,
          styles:
              const PosStyles(align: PosAlign.left, width: PosTextSize.size2)),
      PosColumn(
          text: '\$4.03',
          width: 5,
          styles:
              const PosStyles(align: PosAlign.left, width: PosTextSize.size2)),
    ]);

    bytes += ticket.feed(2);
    bytes += ticket.text('شكرا ليك',
        styles: const PosStyles(align: PosAlign.center, bold: true));

    final now = DateTime.now();
    final formatter = DateFormat('MM/dd/yyyy H:m');
    final String timestamp = formatter.format(now);
    bytes += ticket.text(timestamp,
        styles: const PosStyles(align: PosAlign.center), linesAfter: 2);

    // Print QR Code from image
    // try {
    //   const String qrData = 'example.com';
    //   const double qrSize = 200;
    //   final uiImg = await QrPainter(
    //     data: qrData,
    //     version: QrVersions.auto,
    //     gapless: false,
    //   ).toImageData(qrSize);
    //   final dir = await getTemporaryDirectory();
    //   final pathName = '${dir.path}/qr_tmp.png';
    //   final qrFile = File(pathName);
    //   final imgFile = await qrFile.writeAsBytes(uiImg.buffer.asUint8List());
    //   final img = decodeImage(imgFile.readAsBytesSync());

    //   bytes += ticket.image(img);
    // } catch (e) {
    //   print(e);
    // }

    // Print QR Code using native function
    // bytes += ticket.qrcode('example.com');

    ticket.feed(2);
    ticket.cut();
    return bytes;
  }

  Future<List<int>> testTicket(PaperSize paper, CapabilityProfile profile) async {
    final Generator generator = Generator(paper, profile);
    List<int> bytes = [];

    bytes += generator.text(
        'Regular: aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ');
    // bytes += generator.text('Special 1: àÀ èÈ éÉ ûÛ üÜ çÇ ôÔ',
    //     styles: PosStyles(codeTable: PosCodeTable.westEur));
    // bytes += generator.text('Special 2: blåbærgrød',
    //     styles: PosStyles(codeTable: PosCodeTable.westEur));

    bytes += generator.text('Bold text', styles: const PosStyles(bold: true));
    bytes +=
        generator.text('Reverse text', styles: const PosStyles(reverse: true));
    bytes += generator.text('Underlined text',
        styles: const PosStyles(underline: true), linesAfter: 1);
    bytes += generator.text('Align left',
        styles: const PosStyles(align: PosAlign.left));
    bytes += generator.text('Align center',
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('Align right',
        styles: const PosStyles(align: PosAlign.right), linesAfter: 1);

    bytes += generator.row([
      PosColumn(
        text: 'col3',
        width: 3,
        styles: const PosStyles(align: PosAlign.center, underline: true),
      ),
      PosColumn(
        text: 'col6',
        width: 6,
        styles: const PosStyles(align: PosAlign.center, underline: true),
      ),
      PosColumn(
        text: 'col3',
        width: 3,
        styles: const PosStyles(align: PosAlign.center, underline: true),
      ),
    ]);

    bytes += generator.text('Text size 200%',
        styles: const PosStyles(
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ));

    // Print image
    final ByteData data = await rootBundle.load('assets/flutter_logo.png');
    final Uint8List buf = data.buffer.asUint8List();
    final Image image = decodeImage(buf)!;
    bytes += generator.image(image);
    // Print image using alternative commands
    // bytes += generator.imageRaster(image);
    // bytes += generator.imageRaster(image, imageFn: PosImageFn.graphics);

    // Print barcode
    final List<int> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4];
    bytes += generator.barcode(Barcode.upcA(barData));

    // Print mixed (chinese + latin) text. Only for printers supporting Kanji mode
    // bytes += generator.text(
    //   'hello ! 中文字 # world @ éphémère &',
    //   styles: PosStyles(codeTable: PosCodeTable.westEur),
    //   containsChinese: true,
    // );

    bytes += generator.feed(2);

    bytes += generator.cut();
    return bytes;
  }

  void _testPrint(PrinterBluetooth printer) async {
    printerManager.selectPrinter(printer);

    // TODO Don't forget to choose printer's paper
    const PaperSize paper = PaperSize.mm58;
    final profile = await CapabilityProfile.load();

    // TEST PRINT
    // final PosPrintResult res =
    // await printerManager.printTicket(await testTicket(paper));

    // DEMO RECEIPT
    final PosPrintResult res =
        await printerManager.printTicket((await demoReceipt(paper, profile)));

    showToast(msg: res.msg);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: _devices.length,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            onTap: () => _testPrint(_devices[index]),
            child: Column(
              children: <Widget>[
                Container(
                  height: 60,
                  padding: const EdgeInsets.only(left: 10),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: <Widget>[
                      const Icon(Icons.print),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(_devices[index].name ?? ''),
                            Text(_devices[index].address!),
                            Text(
                              'Click to print a test receipt',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const Divider(),
              ],
            ),
          );
        },
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: printerManager.isScanningStream,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data!) {
            return FloatingActionButton(
              child: const Icon(Icons.stop),
              onPressed: _stopScanDevices,
              backgroundColor: Colors.red,
            );
          } else {
            return FloatingActionButton(
              child: const Icon(Icons.search),
              onPressed: _startScanDevices,
            );
          }
        },
      ),
    );
  }
}
