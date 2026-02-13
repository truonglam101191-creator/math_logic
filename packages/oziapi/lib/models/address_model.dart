class AddressModel {
  final String user;
  final String name;
  final String phone;
  final String label;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String country;
  final String zipCode;
  final bool isPrimary;
  final DateTime created;
  final DateTime updated;
  final String id;

  AddressModel({
    required this.user,
    required this.name,
    required this.phone,
    required this.label,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.state,
    required this.country,
    required this.zipCode,
    required this.isPrimary,
    required this.created,
    required this.updated,
    required this.id,
  });
factory AddressModel.fromJson(Map<String, dynamic> json) {
  return AddressModel(
    user: json['user'] ?? '', // Cung cấp giá trị mặc định khi null
    name: json['name'] ?? '',
    phone: json['phone'] ?? '',
    label: json['label'] ?? '',
    addressLine1: json['addressLine1'] ?? '',
    addressLine2: json['addressLine2'] ?? '',
    city: json['city'] ?? '',
    state: json['state'] ?? '',
    country: json['country'] ?? '',
    zipCode: json['zipCode'] ?? '',
    isPrimary: json['isPrimary'] ?? false, // Nếu null, mặc định là false
    created: DateTime.parse(json['created'] ?? DateTime.now().toString()), 
    updated: DateTime.parse(json['updated'] ?? DateTime.now().toString()), 
    id: json['id'] ?? '', // Cung cấp giá trị mặc định khi null
  );
}

}
