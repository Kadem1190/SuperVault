class Warehouse {
  final String id;
  final String name;
  final String address;
  final String contactPerson;
  final String contactPhone;
  final String? imageUrl;

  Warehouse({
    required this.id,
    required this.name,
    required this.address,
    required this.contactPerson,
    required this.contactPhone,
    this.imageUrl,
  });

  factory Warehouse.fromJson(Map<String, dynamic> json) {
    return Warehouse(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      contactPerson: json['contact_person'],
      contactPhone: json['contact_phone'],
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'contact_person': contactPerson,
      'contact_phone': contactPhone,
      'image_url': imageUrl,
    };
  }
}
