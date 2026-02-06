class GroupDetails {
  final String id;
  final String name;
  final String code;
  final String description;
  final int maxCapacity;
  final int currentCapacity;
  final bool isActive;
  final bool isFull;
  final double fillRate;
  final String moduleTitle;
  final List<StudentSimple> students; // هذه هي القائمة التي نريدها

  GroupDetails({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.maxCapacity,
    required this.currentCapacity,
    required this.isActive,
    required this.isFull,
    required this.fillRate,
    required this.moduleTitle,
    required this.students,
  });

  factory GroupDetails.fromJson(Map<String, dynamic> json) {
    return GroupDetails(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      description: json['description'] ?? '',
      maxCapacity: json['maxCapacity'] ?? 0,
      currentCapacity: json['currentCapacity'] ?? 0,
      isActive: json['isActive'] ?? false,
      isFull: json['isFull'] ?? false,
      fillRate: (json['fillRate'] ?? 0.0).toDouble(),
      moduleTitle: json['moduleTitle'] ?? '',
      students: (json['students'] as List?)
          ?.map((e) => StudentSimple.fromJson(e))
          .toList() ?? [], // حماية من null
    );
  }
}

class StudentSimple {
  final String id;
  final String fullName;
  final String email;
  final String cne;
  final String filiereName;
  final String? photoUrl; // قد تكون null

  StudentSimple({
    required this.id,
    required this.fullName,
    required this.email,
    required this.cne,
    required this.filiereName,
    this.photoUrl,
  });

  factory StudentSimple.fromJson(Map<String, dynamic> json) {
    return StudentSimple(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? 'Unknown',
      email: json['email'] ?? '',
      cne: json['cne'] ?? '',
      filiereName: json['filiereName'] ?? '',
      photoUrl: json['photoUrl'],
    );
  }
}