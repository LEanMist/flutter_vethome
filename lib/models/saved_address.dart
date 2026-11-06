import 'json_fields.dart';

class SavedAddress {
  const SavedAddress({
    required this.id,
    required this.street,
    this.name = '',
    this.number = '',
    this.complement = '',
    this.city = '',
    this.cep = '',
  });
  final String id, street, name, number, complement, city, cep;
  String get summary => [
    street,
    number,
    complement,
    city,
    cep,
  ].where((v) => v.isNotEmpty).join(', ');
  Map<String, dynamic> toJson() => {
    'id': id,
    'street': street,
    'name': name,
    'number': number,
    'complement': complement,
    'city': city,
    'cep': cep,
  };
  factory SavedAddress.fromJson(Map<String, dynamic> json) => SavedAddress(
    id: jsonString(json, 'id'),
    street: jsonString(json, 'street'),
    name: jsonString(json, 'name'),
    number: jsonString(json, 'number'),
    complement: jsonString(json, 'complement'),
    city: jsonString(json, 'city'),
    cep: jsonString(json, 'cep'),
  );
}
