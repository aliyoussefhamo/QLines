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
}
