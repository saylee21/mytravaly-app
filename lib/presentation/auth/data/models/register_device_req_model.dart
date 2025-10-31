class RegisterDeviceReqModel {
  final String action;
  final DeviceRegister deviceRegister;

  RegisterDeviceReqModel({
    this.action = 'deviceRegister',
    required this.deviceRegister,
  });

  Map<String, dynamic> toJson() {
    return {
      'action': action,
      'deviceRegister': deviceRegister.toJson(),
    };
  }
}

class DeviceRegister {
  final String deviceModel;
  final String deviceFingerprint;
  final String deviceBrand;
  final String deviceId;
  final String deviceName;
  final String deviceManufacturer;
  final String deviceProduct;
  final String deviceSerialNumber;

  DeviceRegister({
    required this.deviceModel,
    required this.deviceFingerprint,
    required this.deviceBrand,
    required this.deviceId,
    required this.deviceName,
    required this.deviceManufacturer,
    required this.deviceProduct,
    required this.deviceSerialNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'deviceModel': deviceModel,
      'deviceFingerprint': deviceFingerprint,
      'deviceBrand': deviceBrand,
      'deviceId': deviceId,
      'deviceName': deviceName,
      'deviceManufacturer': deviceManufacturer,
      'deviceProduct': deviceProduct,
      'deviceSerialNumber': deviceSerialNumber,
    };
  }
}

