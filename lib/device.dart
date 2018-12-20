import 'dart:io' show Platform;
import 'package:device_info/device_info.dart';

Future<String> deviceName() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  if (Platform.isIOS) {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    return iosInfo.utsname.machine;
  }
  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    return androidInfo.model;
  }
  return '<unknown device>';
}