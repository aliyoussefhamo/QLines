class StaffQueueItem {
  const StaffQueueItem({
    required this.id,
    required this.ticketNumber,
    required this.serviceName,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final int ticketNumber;
  final String serviceName;
  final String status;
  final DateTime createdAt;

  factory StaffQueueItem.fromJson(Map<String, dynamic> json) => StaffQueueItem(
    id: json['id'] as String,
    ticketNumber: json['ticketNumber'] as int,
    serviceName: json['serviceName'] as String,
    status: json['status'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
