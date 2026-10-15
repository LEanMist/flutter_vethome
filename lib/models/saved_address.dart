import 'json_fields.dart';

class SavedAddress {
  const SavedAddress({
    required this.id,
    required this.street,
    this.number = '',
    this.complement = '',
    this.city = '',
    this.cep = '',
  });
  final String id, street, number, complement, city, cep;
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
    'number': number,
    'complement': complement,
    'city': city,
    'cep': cep,
  };
  factory SavedAddress.fromJson(Map<String, dynamic> json) => SavedAddress(
    id: jsonString(json, 'id'),
    street: jsonString(json, 'street'),
    number: jsonString(json, 'number'),
    complement: jsonString(json, 'complement'),
    city: jsonString(json, 'city'),
    cep: jsonString(json, 'cep'),
  );
}
