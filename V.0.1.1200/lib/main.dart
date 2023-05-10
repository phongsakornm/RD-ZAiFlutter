import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info/device_info.dart';
import 'dart:io';
import 'dart:io' as IO;

// ZAiFlutter
// Copyright R&D Computer System Co., Ltd.

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZAiFlutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  static const platform = const MethodChannel('flutter.native/helper'); // Get Method Channel from Native
  
  late Uint8List bytes_Photo = Uint8List.fromList([]);

  late Uint8List bytes_AppPhoto = Uint8List.fromList([]);

  Map<Permission, PermissionStatus> statuses = new Map();

  String AppName = "";

  String readerName = 'Reader: ';

  String text_result = "";
  String LicenseInfo = "";
  String SoftwareInfo = "";

  int NA_POPUP = 0x80;
  int NA_FIRST = 0x40;
  int NA_SCAN = 0x10;
  int NA_BLE0 = 0x04;
  int NA_BLE1 = 0x08;
  int NA_BT = 0x02;
  int NA_USB = 0x01;

  static int NA_SUCCESS = 0;
  static int NA_INTERNAL_ERROR = -1;
  static int NA_INVALID_LICENSE = -2;
  static int NA_READER_NOT_FOUND = -3;
  static int NA_CONNECTION_ERROR = -4;
  static int NA_GET_PHOTO_ERROR = -5;
  static int NA_GET_TEXT_ERROR = -6;
  static int NA_INVALID_CARD = -7;
  static int NA_UNKNOWN_CARD_VERSION = -8;
  static int NA_DISCONNECTION_ERROR = -9;
  static int NA_INIT_ERROR = -10;
  static int NA_READER_NOT_SUPPORTED = -11;
  static int NA_LICENSE_FILE_ERROR = -12;
  static int NA_PARAMETERS_ERROR = -13;
  static int NA_INTERNET_ERROR = -15;
  static int NA_CARD_NOT_FOUND = -16;
  static int NA_BLUETOOTH_DISABLED = -17;
  static int NA_LICENSE_UPDATE_ERROR = -18;
  static int NA_STORAGE_PERMISSION_ERROR = -31;
  static int NA_LOCATION_PERMISSION_ERROR = -32;
  static int NA_BLUETOOTH_PERMISSION_ERROR = -33;
  static int NA_LOCATION_SERVICE_ERROR = -41;

  String Folder = "";
  String LICFileName = "";

  String rootFolder = "";
  String LicFile = ""; 
  String Parameter_OpenLib = "";

  bool isEnabled = true;
  bool isVisible = false;

  bool isReaderConnected = false;

  @override
  void initState() {
    super.initState();

    if (IO.Platform.isAndroid) {
      // Android-specific code/UI Component
      AppName = "ZAiFlutter 0.2.01 (Android)";
    } else if (IO.Platform.isIOS) {
      // iOS-specific code/UI Component
      AppName = "ZAiFlutter 0.2.01 (iOS)";
    }

    setState(() {
      AppName = AppName;
    });

    if (IO.Platform.isAndroid) {
      // Android-specific code/UI Component

      Folder = "/" + "ZAiFlutter";
      LICFileName = "/" + "rdnidlib.dls";

      getFilesDirDF();

      // ===================== Set Listener ======================== //
      setListenerDF();
    } else if (IO.Platform.isIOS) {
      // iOS-specific code/UI Component

      Folder = "/" + "ZAiFlutter";
      LICFileName = "/" + "rdnidlib.dlt";

      getFilesDirDF();

      // ===================== Get Software Info ======================== //
      getSoftwareInfoDF();
    }
  }

  Future<void> getFilesDirDF() async {
    try {
      String FilesDirectory = await platform
          .invokeMethod('getFilesDirMC'); // Call native method getFilesDirMC

      rootFolder = FilesDirectory +
          Folder; // you can change path of license files at here
      LicFile = rootFolder + LICFileName;
      Parameter_OpenLib = LicFile;

      setAppLogo();
    } on PlatformException catch (e) {
      String text = "Failed to Invoke: '${e.message}'.";

      setState(() {
        text_result = text;
      });
    }
  }

  Future<void> setAppLogo() async {
    try {
      ByteData data = await rootBundle.load(
          'assets/flutter_logo.png'); // you can set assets path at pubspec.yaml

      bytes_AppPhoto =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      setState(() {
        isEnabled = false;
        bytes_Photo = bytes_AppPhoto;
        isVisible = true;
      });
    } on PlatformException catch (e) {
      String text = "Failed to Invoke: '${e.message}'.";

      setState(() {
        isEnabled = false;
        isVisible = true;
        text_result = text;
      });
    }
  }

  Future<void> setListenerDF() async {
    try {
      int returnCode = await platform
          .invokeMethod('setListenerMC'); // Call native method setListenerMC

      if (returnCode == NA_SUCCESS) {
        // ===================== Get Software Info ======================== //
        getSoftwareInfoDF();
      } else {
        setState(() {
          text_result = this.checkException(returnCode);
        });
      }
    } on PlatformException catch (e) {
      String text = "Failed to Invoke: '${e.message}'.";

      setState(() {
        text_result = text;
      });
    }
  }

  Future<void> getSoftwareInfoDF() async {
    String text = "";

    try {
      text = await platform.invokeMethod(
          'getSoftwareInfoMC'); // Call native method getSoftwareInfoMC

      setState(() {
        SoftwareInfo = text;
      });

      if (IO.Platform.isAndroid) {
        // Android-specific code/UI Component

        // ===================== Request Permission ======================== //
        requestPermission();
      } else if (IO.Platform.isIOS) {
        // iOS-specific code/UI Component

        // ===================== Open Lib ======================== //
        openLibDF();
      }
    } on PlatformException catch (e) {
      String text = "Failed to Invoke: '${e.message}'.";

      setState(() {
        text_result = text;
      });
    }
  }

  void requestPermission() async {

    // ===================== Write License File  ======================== //
    writeLicFileDF();


    var androidInfo = await DeviceInfoPlugin().androidInfo;
    var sdkInt = androidInfo.version.sdkInt;

    if(sdkInt >= 31){
      await Permission.bluetoothScan.request();
      await Permission.bluetoothConnect.request();
    }else{
      await Permission.location.request();

      if (await Permission.location.isDenied) {
        text_result = text_result + "\n\n" + '-32 Location permission error.';
      }
    }

    setState(() {
      text_result = text_result;
    });
  }

  Future<void> writeLicFileDF() async {
    //ignore: unused_local_variable

    String text = "";

    try {
      int returnCode = await platform.invokeMethod(
          'writeLicFileMC', LicFile); // Call native method writeLicFileMC

      if (returnCode == 1) {
        text = "License file is already has been.";

        setState(() {
          text_result = text;
        });

        // ===================== Set Permission of Lib ======================== //
        setPermissionsDF();
      } else if (returnCode != 0) {
        text = "Write License file failed.";

        setState(() {
          text_result = text;
        });
      } else {
        // ===================== Set Permission of Lib ======================== //
        setPermissionsDF();
      }
    } on PlatformException catch (e) {
      text += "\n" + "Failed to Invoke: '${e.message}'.";

      setState(() {
        text_result = text;
      });
    }
  }

  Future<void> setPermissionsDF() async {
    // ignore: unused_local_variable

    try {
      int pms = 1;

      int returnCode = await platform.invokeMethod(
          'setPermissionsMC', pms); // Call native method setPermissionsMC

      if (returnCode < 0) {
        setState(() {
          text_result = checkException(returnCode);
        });
      } else if (returnCode >= 0) {
        // ===================== Open Lib ======================== //
        openLibDF();
      }
    } on PlatformException catch (e) {
      String result = "\n" + "Failed to Invoke: '${e.message}'.";

      setState(() {
        text_result = result;
      });
    }
  }

  Future<void> openLibDF() async {
    String text = "";

    try {
      int returnCode = await platform.invokeMethod(
          'openLibMC', Parameter_OpenLib); // Call native method openLibMC

      if (returnCode == 0) {
        text = text + "\n" + "Opened the library successfully.";

        setState(() {
          text_result = text;
          readerName = 'Reader: ';
        });

        // ===================== Get License Info ======================== //
        getLicenseInfoDF();
      } else {
        text = "Opened the library failed, Please restart app.";
        setState(() {
          text_result = text;
          readerName = 'Reader: ';
        });
      }
    } on PlatformException catch (e) {
      text = "Failed to Invoke: '${e.message}'.";

      setState(() {
        text_result = text;
        readerName = 'Reader: ';
      });
    }
  }

  Future<void> getLicenseInfoDF() async {
    String result = "";

    try {
      result = await platform.invokeMethod(
          'getLicenseInfoMC'); // Call native method getLicenseInfoMC

      setState(() {
        LicenseInfo = result;
        isEnabled = true;
      });
    } on PlatformException catch (e) {
      String text = "Failed to Invoke: '${e.message}'.";

      setState(() {
        isEnabled = true;
      });
    }
  }

  Future<void> findReaderDF() async {
    // ignore: unused_local_variable

    isReaderConnected = false;

    String text = "Reader scanning...";

    setState(() {
      isEnabled = false;
      text_result = "";
      readerName = text;
      bytes_Photo = bytes_AppPhoto;
    });

    // ===================== Get Reader List ======================== //
    getReaderListDF();
  }

  Future<void> getReaderListDF() async {
    var result;

    try {
      if (IO.Platform.isAndroid) {
        // Android-specific code/UI Component

        int listOption = NA_POPUP +
            NA_SCAN +
            NA_BLE0 +
            NA_BT +
            NA_USB; // 0x97 USB & BLE0 &  BT Reader

        var androidInfo = await DeviceInfoPlugin().androidInfo;
        var sdkInt = androidInfo.version.sdkInt;

        if(sdkInt >= 31){

          if ((listOption & NA_SCAN) != 0 &&
              ((listOption & NA_BT) != 0 || (listOption & NA_BLE0) != 0)) {
            var isBluetoothScan =  await Permission.bluetoothScan.request();
            var isBluetoothConnected =  await Permission.bluetoothConnect.request();

            if (isBluetoothScan != PermissionStatus.granted && isBluetoothConnected != PermissionStatus.granted) {
            listOption = listOption -
                (NA_SCAN +
                 NA_BLE0 +
                 NA_BT); //remove BLE0, BT Scanning

            }
          }

        }else{
            if ((listOption & NA_SCAN) != 0 &&
                ((listOption & NA_BT) != 0 || (listOption & NA_BLE0) != 0)) {
            var isLocationDenied = await Permission.location.status.isDenied;

            if (isLocationDenied) {
              listOption = listOption -
                  (NA_SCAN +
                   NA_BLE0 +
                   NA_BT); //remove BLE0, BT Scanning

              }
            }
        }

        result = await platform.invokeMethod('getReaderListMC',
            listOption); // Call native method getReaderListMC

      } else if (IO.Platform.isIOS) {
        // iOS-specific code/UI Component

        result = await platform.invokeMethod(
            'getReaderListMC'); // Call native method getReaderListMC

      }

      var parts = result.split(';');

      var returnCode = int.parse(parts[0].trim());

      if (returnCode == 0 || returnCode == -3) {
        setState(() {
          readerName = 'Reader: ';
          isEnabled = true;
          text_result = "-3 Reader not found.";
        });
      } else if (returnCode < 0) {
        setState(() {
          isEnabled = true;
          readerName = 'Reader: ';
          text_result = checkException(returnCode);
        });
      } else if (returnCode > 0) {
        String textReaderName = parts[1].trim();

        setState(() {
          readerName = "Reader selecting...";
        });

        // ===================== Select Reader ======================== //
        selectReaderDF(textReaderName);
      }
    } on PlatformException catch (e) {
      String text = "Failed to Invoke: '${e.message}'.";

      setState(() {
        text_result = text;
        isEnabled = true;
      });
    }
  }

  Future<void> selectReaderDF(String textReaderName) async {
    try {
      int returnCode = await platform.invokeMethod('selectReaderMC',
          textReaderName); // Call native method selectReaderMC

      if (returnCode != NA_SUCCESS) {
        setState(() {
          text_result = checkException(returnCode);
        });

        if (returnCode != NA_INVALID_LICENSE &&
            returnCode != NA_LICENSE_FILE_ERROR) {
          setState(() {
            isEnabled = true;
            readerName = 'Reader: ';
          });
        } else if (returnCode == NA_INVALID_LICENSE ||
            returnCode == NA_LICENSE_FILE_ERROR) {
          setState(() {
            isEnabled = true;
            readerName = 'Reader: ' + textReaderName;
          });
        }
      } else if (returnCode == NA_SUCCESS) {
        isReaderConnected = true;

        setState(() {
          readerName = 'Reader: ' + textReaderName;
        });

        // ===================== Get Reader Info ======================== //
        getReaderInfoDF();
      }
    } on PlatformException catch (e) {
      String text = "Failed to Invoke: '${e.message}'.";

      setState(() {
        text_result = text;
        isEnabled = true;
      });
    }
  }

  Future<void> getReaderInfoDF() async {
    String readerInfo = "";

    if (isReaderConnected == false) {
      setState(() {
        text_result = "";
        isEnabled = true;
      });
      return;
    }

    try {
      var result = await platform.invokeMethod(
          'getReaderInfoMC'); // Call native method getReaderInfoMC

      var parts = result.split(';');

      int returnCode = int.parse(parts[0].trim());

      if (returnCode == NA_SUCCESS) {
        readerInfo = parts[1].trim();
        result = "Reader Info: " + readerInfo;
      } else {
        result = checkException(returnCode);
      }

      setState(() {
        text_result = result;
      });

      // ===================== Get Reader ID ======================== //
      getReaderIDDF();
    } on PlatformException catch (e) {
      String text = "Failed to Invoke: '${e.message}'.";
      setState(() {
        text_result = text;
      });
    }
  }

  Future<void> getReaderIDDF() async {
    String readerID = "";
    var result;

    if (isReaderConnected == false) {
      setState(() {
        text_result = "";
        isEnabled = true;
      });
      return;
    }

    try {
      result = await platform
          .invokeMethod('getReaderIDMC'); // Call native method getReaderIDMC

      var parts = result.split(';');

      int returnCode = int.parse(parts[0].trim());

      if (returnCode > 0) {
        int numberBytes = returnCode;

        String base64Rid = parts[1].trim();

        late Uint8List byteRid = base64Decode(base64Rid);

        String hexString = "";

        for (int i = 0; i < numberBytes; i++) {
          String h = byteRid[i].toRadixString(16); // Number to Hex String

          while (h.length < 2) {
            h = "0" + h;
          }

          hexString += h + " ";
        }

        readerID = hexString.toUpperCase();

        result = text_result + "\n\n" + "Reader ID: " + readerID;
      } else if (returnCode < 0) {
        result = text_result + "\n\n" + checkException(returnCode);
      }

      setState(() {
        text_result = result;
        isEnabled = true;
      });
    } on PlatformException catch (e) {
      String text = "Failed to Invoke: '${e.message}'.";
      setState(() {
        text_result = text;
        isEnabled = true;
      });
    }
  }

  Future<int> connectCardDF() async {
    try {
      int returnCode = await platform
          .invokeMethod('connectCardMC'); // Call native method connectCardMC

      return returnCode;
    } on PlatformException catch (e) {
      return NA_CONNECTION_ERROR;
    }
  }

  Future<void> disconnectCardDF() async {
    try {
      int returnCode = await platform.invokeMethod(
          'disconnectCardMC'); // Call native method disconnectCardMC

      if (returnCode != NA_SUCCESS) {
        text_result = checkException(returnCode);
      }

      setState(() {
        text_result = text_result;
        isEnabled = true;
      });
    } on PlatformException catch (e) {
      String text = "Failed to Invoke: '${e.message}'.";

      setState(() {
        isEnabled = true;
        text_result = text;
      });
    }
  }

  Future<void> readDF() async {
    // ignore: unused_local_variable

    String text = "Reading...";

    setState(() {
      isEnabled = false;
      bytes_Photo = bytes_AppPhoto;
      text_result = text;
    });

    try {
      int returnCode = await platform.invokeMethod(
          'getCardStatusMC'); // Call native method getCardStatusMC

      if (returnCode != 1) {
        text = checkException(returnCode);

        if (IO.Platform.isIOS) {
          if (isReaderConnected != true) {
            text = "-3 Reader not found.";
          }
        }

        setState(() {
          text_result = text;
          isEnabled = true;
        });
      } else {

        int startTime = new DateTime.now().millisecondsSinceEpoch;
        int startTimeAll = startTime;

        // ===================== Connect Card ======================== //
        int resConnect = await connectCardDF();

        if (resConnect != NA_SUCCESS) {
          setState(() {
            text_result = checkException(resConnect);
            isEnabled = true;
          });
        } else {
          // ===================== Get Text ======================== //
          getTextDF(startTime ,startTimeAll);
        }
      }
    } on PlatformException catch (e) {
      String text = "Failed to Invoke: '${e.message}'.";

      setState(() {
        text_result = text;
        isEnabled = true;
      });
    }
  }


  Future<void> getTextDF(startTime ,startTimeAll) async {
    String text = "";

    try {
      String result = await platform
          .invokeMethod('getTextMC'); // Call native method getTextMC

      var parts = result.split(';');

      int returnCode = int.parse(parts[0].trim());

      int endTime = new DateTime.now().millisecondsSinceEpoch;

      double readTextTime = ((endTime - startTime) / 1000);

      if (returnCode == NA_SUCCESS) {
        var resText = parts[1].trim();

        text = "Read Text: " + readTextTime.toStringAsFixed(2) + " s"+"\n" + resText;

        var sData = resText.split('#');

        if (sData.length == 1) {
          setState(() {
            text_result = text + "\n" + checkException(returnCode);
          });

          // ===================== Disconnect Card ======================== //
          disconnectCardDF();
        } else {
          setState(() {
            text_result = text;
          });

          var aKey = "";

          if (IO.Platform.isAndroid) {
            // Android-specific code/UI Component
            aKey = sData[0].substring(2, 5) + sData[0].substring(9, 11);
          } else if (IO.Platform.isIOS) {
            // iOS-specific code/UI Component
            aKey = sData[0].substring(10, 12) + sData[0].substring(2, 5);
          }

          // ===================== Get SText ======================== //
          getSTextDF(aKey , startTimeAll);
        }

      } else {
        setState(() {
          text_result = checkException(returnCode);
        });

        // ===================== Disconnect Card ======================== //
        disconnectCardDF();
      }

    } on PlatformException catch (e) {
      text = "Failed to Invoke: '${e.message}'.";

      setState(() {
        text_result = text;
      });

      // ===================== Disconnect Card ======================== //
      disconnectCardDF();
    }
  }



  Future<void> getSTextDF(String aKey , startTimeAll) async {
    String text = "";

    int startTime = new DateTime.now().millisecondsSinceEpoch;

    try {
      String result = await platform.invokeMethod(
          'getSTextMC', aKey); // Call native method getSTextMC

      var parts = result.split(';');

      int returnCode = int.parse(parts[0].trim());

      int endTime = new DateTime.now().millisecondsSinceEpoch;

      double readSTextTime = ((endTime - startTime) / 1000);

      if (returnCode == NA_SUCCESS) {
        var resText = parts[1].trim();

        text += text_result +"\n\n" + "Read SText: " + readSTextTime.toStringAsFixed(2) +" s" +"\n" +  resText;

        setState(() {
          text_result = text;
        });

        // ===================== Connect Card ======================== //
        int resConnect =
            await connectCardDF(); // After the getStext function is finished, the card must be reconnected if you want to read other data from the card.

        if (resConnect != NA_SUCCESS) {
          setState(() {
            text_result = text_result + "\n\n" + checkException(resConnect);
            isEnabled = true;
          });
        } else {
          // ===================== Get Photo ======================== //
          getPhotoDF(startTimeAll);
        }
      } else {
        setState(() {
          text_result = text_result + "\n\n" + checkException(returnCode);
        });

        // ===================== Disconnect Card ======================== //
        disconnectCardDF();
      }
    } on PlatformException catch (e) {
      text = "Failed to Invoke: '${e.message}'.";

      setState(() {
        text_result = text_result + "\n\n" + text;
      });

      // ===================== Disconnect Card ======================== //
      disconnectCardDF();
    }
  }



  Future<void> getPhotoDF(startTimeAll) async {

    int startTime = new DateTime.now().millisecondsSinceEpoch;

    try {
      
      String result = await platform
          .invokeMethod('getPhotoMC'); // Call native method getPhotoMC

      var parts = result.split(';');

      int returnCode = int.parse(parts[0].trim());

      // ===================== Disconnect Card ======================== //
      disconnectCardDF();

      int endTime = new DateTime.now().millisecondsSinceEpoch;

      double readPhotoTime = ((endTime - startTime) / 1000);

      endTime = new DateTime.now().millisecondsSinceEpoch;

      double readAllTime = ((endTime - startTimeAll) / 1000);

      if (returnCode == NA_SUCCESS) {
        String photo = parts[1].trim();

        var resBytesPhoto = base64Decode(photo);

        setState(() {
          text_result = text_result +
              "\n\nRead Photo: " +
              readPhotoTime.toStringAsFixed(2) +
              " s" + 
              "\n\nRead All: " +
              readAllTime.toStringAsFixed(2) +
              " s";
          bytes_Photo = resBytesPhoto;
        });
      } else {
        if (text_result != checkException(returnCode)) {
          text_result = text_result + "\n\n" + checkException(returnCode);
        }

        setState(() {
          text_result = text_result;
        });
      }

    } on PlatformException catch (e) {
      String text = "Failed to Invoke: '${e.message}'.";

      setState(() {
        text_result = text;
      });

    }
  }

  Future<void> getNIDNumberDF() async {
    String text = "";

    int startTime = new DateTime.now().millisecondsSinceEpoch;

    try {
      String result = await platform
          .invokeMethod('getNIDNumberMC'); // Call native method getNIDNumberMC

      var parts = result.split(';');

      int returnCode = int.parse(parts[0].trim());

      int endTime = new DateTime.now().millisecondsSinceEpoch;

      double readNIDNumberTime = ((endTime - startTime) / 1000);

      if (returnCode == NA_SUCCESS) {
        text = parts[1].trim();

        text += "\n\nRead NIDNumber: " +
            readNIDNumberTime.toStringAsFixed(2) +
            " s";

        setState(() {
          text_result = text;
        });
      } else {
        setState(() {
          text_result = checkException(returnCode);
        });
      }

      // ===================== Disconnect Card ======================== //
      disconnectCardDF();
    } on PlatformException catch (e) {
      text = "Failed to Invoke: '${e.message}'.";

      setState(() {
        text_result = text;
      });

      // ===================== Disconnect Card ======================== //
      disconnectCardDF();
    }
  }

  Future<void> updateLicenseFileDF() async {
    String text = "License updating...";
    String result;

    setState(() {
      isEnabled = false;
      bytes_Photo = bytes_AppPhoto;
      text_result = text;
    });

    try {
      int returnCode = await platform.invokeMethod(
          'updateLicenseFileMC'); // Call native method updateLicenseMC


      if (returnCode == 0 || returnCode == 1 || returnCode == 2 || returnCode == 3) {

        result = returnCode.toString() + ": License has been successfully updated.";

        // ===================== Get License Info ======================== //
        getLicenseInfoDF();

      }else{

         if (returnCode == 100 || returnCode == 101 || returnCode == 102 || returnCode == 103) {

            result = returnCode.toString() + ": The latest license has already been installed.";

            // ===================== Get License Info ======================== //
            getLicenseInfoDF();

         }else{
                  result = checkException(returnCode);
         }
      }
      
      setState(() {
        isEnabled = true;
        text_result = result;
      });

    } on PlatformException catch (e) {
      String text = "Failed to Invoke: '${e.message}'.";

      setState(() {
        text_result = text;
        isEnabled = true;
      });
    }
  }

  Future<void> getCardStatusDF() async {
    String text = "Checking card in reader...";

    setState(() {
      isEnabled = false;
      bytes_Photo = bytes_AppPhoto;
      text_result = text;
    });

    try {
      int returnCode = await platform.invokeMethod(
          'getCardStatusMC'); // Call native method getCardStatusMC

      if (returnCode == 1) {
        text = "Card Status: Present";
      } else if (returnCode == -16) {
        text = "Card Status: Absent (card not found)";
      } else {
        text = checkException(returnCode);

        if (IO.Platform.isIOS) {
          if (isReaderConnected != true) {
            text = "-3 Reader not found.";
          }
        }
      }

      setState(() {
        isEnabled = true;
        text_result = text;
      });
    } on PlatformException catch (e) {
      String text = "Failed to Invoke: '${e.message}'.";

      setState(() {
        text_result = text;
        isEnabled = true;
      });
    }
  }

  Future<void> exitApp() {
    // ================= Deselect Reader ================= //
    deselectReaderDF();

    // ================= Close Lib ================= //
    closeLibDF();

    exit(0);
  }

  Future<void> deselectReaderDF() async {
    String text = "";
    try {
      int returnCode = await platform.invokeMethod(
          'deselectReaderMC'); // Call native method deselectReaderMC

      if (returnCode < 0) {
        text = checkException(returnCode);

        setState(() {
          text_result = text;
        });
      }
    } on PlatformException catch (e) {
      String text = "Failed to Invoke: '${e.message}'.";

      setState(() {
        text_result = text;
      });
    }
  }

  Future<void> closeLibDF() async {
    String text = "";
    try {
      int returnCode = await platform
          .invokeMethod('closeLibMC'); // Call native method closeLibMC

      if (returnCode < 0) {
        text = checkException(returnCode);
        setState(() {
          text_result = text;
        });
      }
    } on PlatformException catch (e) {
      String text = "Failed to Invoke: '${e.message}'.";

      setState(() {
        text_result = text;
      });
    }
  }

  String checkException(int returnCode) {
    if (returnCode == NA_INTERNAL_ERROR) {
      return "-1 Internal error.";
    } else if (returnCode == NA_INVALID_LICENSE) {
      return "-2 This reader is not licensed.";
    } else if (returnCode == NA_READER_NOT_FOUND) {
      return "-3 Reader not found.";
    } else if (returnCode == NA_CONNECTION_ERROR) {
      return "-4 Card connection error.";
    } else if (returnCode == NA_GET_PHOTO_ERROR) {
      return "-5 Get photo error.";
    } else if (returnCode == NA_GET_TEXT_ERROR) {
      return "-6 Get text error.";
    } else if (returnCode == NA_INVALID_CARD) {
      return "-7 Invalid card.";
    } else if (returnCode == NA_UNKNOWN_CARD_VERSION) {
      return "-8 Unknown card version.";
    } else if (returnCode == NA_DISCONNECTION_ERROR) {
      return "-9 Disconnection error.";
    } else if (returnCode == NA_INIT_ERROR) {
      return "-10 Init error.";
    } else if (returnCode == NA_READER_NOT_SUPPORTED) {
      return "-11 Reader not supported.";
    } else if (returnCode == NA_LICENSE_FILE_ERROR) {
      return "-12 License file error.";
    } else if (returnCode == NA_PARAMETERS_ERROR) {
      return "-13 Parameter error.";
    } else if (returnCode == NA_INTERNET_ERROR) {
      return "-15 Internet error.";
    } else if (returnCode == NA_CARD_NOT_FOUND) {
      return "-16 Card not found.";
    } else if (returnCode == NA_BLUETOOTH_DISABLED) {
      return "-17 Bluetooth is disabled.";
    } else if (returnCode == NA_LICENSE_UPDATE_ERROR) {
      return "-18 License update error.";
    } else if (returnCode == NA_STORAGE_PERMISSION_ERROR) {
      return "-31 Storage permission error.";
    } else if (returnCode == NA_LOCATION_PERMISSION_ERROR) {
      return "-32 Location permission error.";
    } else if (returnCode == NA_BLUETOOTH_PERMISSION_ERROR) {
      return "-33 Bluetooth permission error.";
    } else if (returnCode == NA_LOCATION_SERVICE_ERROR) {
      return "-41 Location service error.";
    } else {
      return returnCode.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$AppName"),
      ),
      body: Container(
        color: Colors.yellow[100],
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(
                  child: new Text(
                    "Software Info: " + "$SoftwareInfo",
                    style: new TextStyle(
                        fontSize: 13.0,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                        fontFamily: "Roboto"),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 10, 10, 5),
                  color: Colors.grey[800],
                  alignment: Alignment.topLeft,
                ),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(
                  child: new Text(
                    "License Info: " + "$LicenseInfo",
                    style: new TextStyle(
                        fontSize: 13.0,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                        fontFamily: "Roboto"),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 5, 10, 5),
                  color: Colors.grey[800],
                  alignment: Alignment.topLeft,
                ),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(
                  child: new Text(
                    "$readerName",
                    style: new TextStyle(
                        fontSize: 15.0,
                        color: const Color(0xFF000000),
                        fontWeight: FontWeight.w400,
                        fontFamily: "Roboto"),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 15, 10, 0),
                  alignment: Alignment.topLeft,
                  height: 40.0,
                ),
              ],
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 1),
              child: RawMaterialButton(
                onPressed: isEnabled ? () => findReaderDF() : null,
                fillColor: Colors.grey[600],
                child: Text(
                  'Find Reader',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              // child: FlatButton(
              //     key: new Key('bt01'),
              //     onPressed: isEnabled ? () => findReaderDF() : null,
              //     color: Colors.grey[600],
              //     disabledColor: Colors.grey[400],
              //     height: 43.0,
              //     child: new Text(
              //       "Find Reader",
              //       style: new TextStyle(
              //           fontSize: 18.0,
              //           color: const Color(0xFFFFFFFF),
              //           fontWeight: FontWeight.w700,
              //           fontFamily: "Roboto"),
              //     )),
            ),
            SizedBox(
              height: 4.0,
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 1),
              child: RawMaterialButton(
                onPressed: isEnabled ? () => readDF() : null,
                fillColor: Colors.grey[400],
                child: Text(
                  'Read',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              // child: FlatButton(
              //     key: new Key('bt02'),
              //     onPressed: isEnabled ? () => readDF() : null,
              //     color: Colors.grey[600],
              //     disabledColor: Colors.grey[400],
              //     height: 43.0,
              //     child: new Text(
              //       "Read",
              //       style: new TextStyle(
              //           fontSize: 18.0,
              //           color: const Color(0xFFFFFFFF),
              //           fontWeight: FontWeight.w700,
              //           fontFamily: "Roboto"),
              //     )),
            ),
            SizedBox(
              height: 4.0,
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 1),
              child: RawMaterialButton(
                onPressed: isEnabled ? () => getCardStatusDF() : null,
                fillColor: Colors.grey[400],
                child: Text(
                  'Card Status',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              // child: FlatButton(
              //     key: new Key('bt03'),
              //     onPressed: isEnabled ? () => getCardStatusDF() : null,
              //     color: Colors.grey[600],
              //     disabledColor: Colors.grey[400],
              //     height: 43.0,
              //     child: new Text(
              //       "Card Status",
              //       style: new TextStyle(
              //           fontSize: 18.0,
              //           color: const Color(0xFFFFFFFF),
              //           fontWeight: FontWeight.w700,
              //           fontFamily: "Roboto"),
              //     )),
            ),
            SizedBox(
              height: 4.0,
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 1),
              child: RawMaterialButton(
                onPressed: isEnabled ? () => updateLicenseFileDF() : null,
                fillColor: Colors.grey[400],
                child: Text(
                  'Update License',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              // child: FlatButton(
              //     key: new Key('bt04'),
              //     onPressed: isEnabled ? () => updateLicenseFileDF() : null,
              //     color: Colors.grey[600],
              //     disabledColor: Colors.grey[400],
              //     height: 43.0,
              //     child: new Text(
              //       "Update License",
              //       style: new TextStyle(
              //           fontSize: 18.0,
              //           color: const Color(0xFFFFFFFF),
              //           fontWeight: FontWeight.w700,
              //           fontFamily: "Roboto"),
              //     )),
            ),
            SizedBox(
              height: 4.0,
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 1),
              child: RawMaterialButton(
                onPressed: () => exitApp(),
                fillColor: Colors.grey[600],
                child: Text(
                  'Exit',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              // child: FlatButton(
              //     key: new Key('bt05'),
              //     onPressed: () => exitApp(),
              //     color: Colors.grey[600],
              //     disabledColor: Colors.grey[400],
              //     height: 43.0,
              //     child: new Text(
              //       "Exit",
              //       style: new TextStyle(
              //           fontSize: 18.0,
              //           color: const Color(0xFFFFFFFF),
              //           fontWeight: FontWeight.w700,
              //           fontFamily: "Roboto"),
              //     )),
            ),
            SizedBox(
              height: 4.0,
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical, //.horizontal
                child: Container(
                  padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(
                        flex: 3,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                              child: Text(
                                "$text_result",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Align(
                              alignment: Alignment.topCenter,
                              child: Visibility(
                                visible: isVisible,
                                child: Image.memory(
                                  bytes_Photo,
                                  height: 100,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 7.0,
            ),
          ],
        ),
      ),
    );
  }
}
