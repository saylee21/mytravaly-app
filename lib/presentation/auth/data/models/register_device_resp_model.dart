class RegisterDeviceRespModel {
  final bool status;
  final String message;
  final int responseCode;
  final DeviceRegisterData? data;

  RegisterDeviceRespModel({
    required this.status,
    required this.message,
    required this.responseCode,
    this.data,
  });

  factory RegisterDeviceRespModel.fromJson(Map<String, dynamic> json) {
    return RegisterDeviceRespModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      responseCode: json['responseCode'] ?? 0,
      data: json['data'] != null
          ? DeviceRegisterData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'responseCode': responseCode,
      'data': data?.toJson(),
    };
  }
}

class DeviceRegisterData {
  final String visitorToken;

  DeviceRegisterData({
    required this.visitorToken,
  });

  factory DeviceRegisterData.fromJson(Map<String, dynamic> json) {
    return DeviceRegisterData(
      visitorToken: json['visitorToken'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'visitorToken': visitorToken,
    };
  }
}