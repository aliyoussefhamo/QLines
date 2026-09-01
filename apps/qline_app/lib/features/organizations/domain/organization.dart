class Organization {
  const Organization({
    required this.id,
    required this.name,
    required this.category,
    required this.branchCount,
    required this.isActive,
  });

  final String id;
  final String name;
  final String category;
  final int branchCount;
  final bool isActive;

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      branchCount: json['branchCount'] as int,
      isActive: json['isActive'] as bool,
    );
  }
}
