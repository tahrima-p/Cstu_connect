class Event {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String location;
  final String organizer;
  final String category;
  int attendeeCount;
  bool isRegistered;
  final List<String> registeredUserIds;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.organizer,
    this.category = 'General',
    this.attendeeCount = 0,
    this.isRegistered = false,
    List<String>? registeredUserIds,
  }) : registeredUserIds = registeredUserIds ?? [];

  int get registeredCount => attendeeCount;

  String get formattedDate {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String get formattedTime {
    final hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'location': location,
      'organizer': organizer,
      'category': category,
      'attendeeCount': attendeeCount,
      'registeredUserIds': registeredUserIds,
    };
  }

  factory Event.fromMap(Map<String, dynamic> map, [String? docId, String? currentUserId]) {
    final registeredList = List<String>.from(map['registeredUserIds'] ?? []);
    final isReg = currentUserId != null ? registeredList.contains(currentUserId) : (map['isRegistered'] ?? false);

    return Event(
      id: docId ?? map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: map['date'] != null ? DateTime.tryParse(map['date'].toString()) ?? DateTime.now() : DateTime.now(),
      location: map['location'] ?? '',
      organizer: map['organizer'] ?? '',
      category: map['category'] ?? 'Technology',
      attendeeCount: (map['attendeeCount'] ?? registeredList.length) as int,
      isRegistered: isReg,
      registeredUserIds: registeredList,
    );
  }

  Event copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    String? location,
    String? organizer,
    String? category,
    int? attendeeCount,
    bool? isRegistered,
    List<String>? registeredUserIds,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      location: location ?? this.location,
      organizer: organizer ?? this.organizer,
      category: category ?? this.category,
      attendeeCount: attendeeCount ?? this.attendeeCount,
      isRegistered: isRegistered ?? this.isRegistered,
      registeredUserIds: registeredUserIds ?? this.registeredUserIds,
    );
  }
}
