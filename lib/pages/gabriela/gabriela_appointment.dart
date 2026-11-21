class GabrielaAppointment {
  const GabrielaAppointment({
    required this.startTime,
    required this.endTime,
    required this.clientName,
    required this.clientFullName,
    required this.petName,
    required this.service,
    required this.address,
    this.serviceDescription = '',
    this.imageAsset,
    this.sex,
    this.weight,
    this.birthDate,
    this.breed,
    this.isDemonstration = false,
  });

  final String startTime, endTime, clientName, clientFullName, petName;
  final String service, serviceDescription, address;
  final String? imageAsset, sex, weight, breed;
  final DateTime? birthDate;
  final bool isDemonstration;
}
