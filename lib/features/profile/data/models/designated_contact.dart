class DesignatedContact {
  final String name;
  final String email;

  const DesignatedContact({required this.name, required this.email});

  factory DesignatedContact.fromJson(Map<String, dynamic> json) {
    return DesignatedContact(
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {'name': name, 'email': email};
}
