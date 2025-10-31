import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mytravaly_assignment/core/network/api_client.dart';
import 'package:mytravaly_assignment/presentation/auth/domain/usecases/register_device_use_case.dart';
import 'package:mytravaly_assignment/presentation/auth/presentation/auth_page.dart';
import 'core/services/injection_container.dart';
import 'core/utils/pref_utils.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'presentation/auth/data/models/register_device_req_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await init();

  // Initialize SharedPreferences
  await PrefUtils().init();

  // ✅ Register device ONLY if not already registered
  await _registerDeviceIfNeeded();

  runApp(const MyApp());
}

/// Register device only on first app launch
Future<void> _registerDeviceIfNeeded() async {
  final prefUtils = PrefUtils();

  // ✅ Check if device is already registered
  if (prefUtils.isDeviceRegistered()) {
    debugPrint('✅ Device already registered. Skipping API call.');
    debugPrint('Visitor Token: ${prefUtils.getVisitorToken()}');
    return;
  }

  debugPrint('📱 First launch detected. Registering device...');

  try {
    // Get device information
    final deviceInfo = DeviceInfoPlugin();
    DeviceRegister deviceRegister;

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      deviceRegister = DeviceRegister(
        deviceModel: androidInfo.model,
        deviceFingerprint: androidInfo.fingerprint,
        deviceBrand: androidInfo.brand,
        deviceId: androidInfo.id,
        deviceName: '${androidInfo.model}_${androidInfo.version.sdkInt}',
        deviceManufacturer: androidInfo.manufacturer,
        deviceProduct: androidInfo.product,
        deviceSerialNumber: androidInfo.id,
      );
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      deviceRegister = DeviceRegister(
        deviceModel: iosInfo.model,
        deviceFingerprint: iosInfo.identifierForVendor ?? 'unknown',
        deviceBrand: 'Apple',
        deviceId: iosInfo.identifierForVendor ?? 'unknown',
        deviceName: '${iosInfo.name}_${iosInfo.systemVersion}',
        deviceManufacturer: 'Apple',
        deviceProduct: iosInfo.utsname.machine,
        deviceSerialNumber: 'unknown',
      );
    } else {
      // For web or other platforms
      deviceRegister = DeviceRegister(
        deviceModel: 'web_device',
        deviceFingerprint: 'web_fingerprint',
        deviceBrand: 'web',
        deviceId: 'web_device_id',
        deviceName: 'web_device',
        deviceManufacturer: 'web',
        deviceProduct: 'web',
        deviceSerialNumber: 'unknown',
      );
    }

    // Create request model
    final requestModel = RegisterDeviceReqModel(
      deviceRegister: deviceRegister,
    );

    // Get the use case from dependency injection
    final registerDeviceUseCase = sl<RegisterDeviceUseCase>();

    // Call the API
    final result = await registerDeviceUseCase(requestModel);

    // Handle the result
    result.fold(
          (failure) {
        // ❌ Handle failure - log error but don't block app launch
        debugPrint('❌ Device registration failed: ${failure.userFriendlyMessage}');
        // Don't set the flag, so it will retry on next app launch
      },
          (response) async {
        // ✅ Handle success - save visitor token and mark as registered
        if (response.data?.visitorToken != null) {
          await prefUtils.setVisitorToken(response.data!.visitorToken);
          await prefUtils.setDeviceRegistered(true); // ✅ Mark as registered
          debugPrint('✅ Device registered successfully!');
          debugPrint('Visitor Token: ${response.data!.visitorToken}');
        }
      },
    );
  } catch (e) {
    debugPrint('❌ Error during device registration: $e');
    // Don't set the flag, so it will retry on next app launch
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthPage(),
    );
  }
}