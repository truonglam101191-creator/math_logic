class DeviceInfoModel {
  final String model;
  final String manufacturer;
  final String brand;
  final String os;
  final String version;

  final bool isPhysicalDevice;
  final String id;

  DeviceInfoModel({
    required this.model,
    required this.manufacturer,
    required this.brand,
    required this.os,
    required this.version,
    required this.isPhysicalDevice,
    required this.id,
  });

  // Convert from JSON
  factory DeviceInfoModel.fromJson(Map<String, dynamic> json) {
    return DeviceInfoModel(
      model: json['model'],
      manufacturer: json['manufacturer'],
      brand: json['brand'],
      os: json['os'],
      version: json['ver'],
      isPhysicalDevice: json['phy'],
      id: json['id'],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'manufacturer': manufacturer,
      'brand': brand,
      'os': os,
      'ver': version,
      'phy': isPhysicalDevice,
      'id': id,
    };
  }
}

