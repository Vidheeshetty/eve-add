// File: lib/models/event_model.dart

enum EventStatus {
  upcoming,
  ongoing,
  completed,
  cancelled
}

class VipTier {
  final String id;
  final String name;
  final String description;
  final double pricePerPerson;
  final List<String> benefits;
  final int maxAttendees;
  final int currentAttendees;
  final bool isAvailable;

  VipTier({
    required this.id,
    required this.name,
    required this.description,
    required this.pricePerPerson,
    required this.benefits,
    required this.maxAttendees,
    this.currentAttendees = 0,
    this.isAvailable = true,
  });

  factory VipTier.fromJson(Map<String, dynamic> json) {
    return VipTier(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      pricePerPerson: (json['pricePerPerson'] ?? 0.0).toDouble(),
      benefits: List<String>.from(json['benefits'] ?? []),
      maxAttendees: json['maxAttendees'] ?? 0,
      currentAttendees: json['currentAttendees'] ?? 0,
      isAvailable: json['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'pricePerPerson': pricePerPerson,
      'benefits': benefits,
      'maxAttendees': maxAttendees,
      'currentAttendees': currentAttendees,
      'isAvailable': isAvailable,
    };
  }

  bool get isFull => currentAttendees >= maxAttendees;
}

class ComboDiscount {
  final int minPeople;
  final int maxPeople;
  final double discountPercentage;
  final String description;

  ComboDiscount({
    required this.minPeople,
    required this.maxPeople,
    required this.discountPercentage,
    required this.description,
  });

  factory ComboDiscount.fromJson(Map<String, dynamic> json) {
    return ComboDiscount(
      minPeople: json['minPeople'] ?? 0,
      maxPeople: json['maxPeople'] ?? 0,
      discountPercentage: (json['discountPercentage'] ?? 0.0).toDouble(),
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'minPeople': minPeople,
      'maxPeople': maxPeople,
      'discountPercentage': discountPercentage,
      'description': description,
    };
  }
}

class EventModel {
  final String id;
  final String title;
  final String description;
  final String? coverImage;
  final DateTime startDate;
  final DateTime endDate;
  final String location;
  final double? latitude;
  final double? longitude;
  final String organizerId;
  final String organizerName;
  final int maxAttendees;
  final int currentAttendees;
  final bool isFree;
  final double? price;
  final List<String> tags;
  final List<String> attendeeIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final EventStatus status;
  final List<VipTier> vipTiers;
  final List<ComboDiscount> comboDiscounts;
  final bool hasVipOptions;
  final bool hasComboDeals;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    this.coverImage,
    required this.startDate,
    required this.endDate,
    required this.location,
    this.latitude,
    this.longitude,
    required this.organizerId,
    required this.organizerName,
    required this.maxAttendees,
    this.currentAttendees = 0,
    this.isFree = true,
    this.price,
    this.tags = const [],
    this.attendeeIds = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
    this.status = EventStatus.upcoming,
    this.vipTiers = const [],
    this.comboDiscounts = const [],
    this.hasVipOptions = false,
    this.hasComboDeals = false,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      coverImage: json['coverImage'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      location: json['location'] ?? '',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      organizerId: json['organizerId'] ?? '',
      organizerName: json['organizerName'] ?? '',
      maxAttendees: json['maxAttendees'] ?? 0,
      currentAttendees: json['currentAttendees'] ?? 0,
      isFree: json['isFree'] ?? true,
      price: json['price']?.toDouble(),
      tags: List<String>.from(json['tags'] ?? []),
      attendeeIds: List<String>.from(json['attendeeIds'] ?? []),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      status: EventStatus.values.firstWhere(
            (e) => e.toString() == 'EventStatus.${json['status']}',
        orElse: () => EventStatus.upcoming,
      ),
      vipTiers: (json['vipTiers'] as List<dynamic>?)
          ?.map((tier) => VipTier.fromJson(tier))
          .toList() ?? [],
      comboDiscounts: (json['comboDiscounts'] as List<dynamic>?)
          ?.map((combo) => ComboDiscount.fromJson(combo))
          .toList() ?? [],
      hasVipOptions: json['hasVipOptions'] ?? false,
      hasComboDeals: json['hasComboDeals'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'coverImage': coverImage,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'organizerId': organizerId,
      'organizerName': organizerName,
      'maxAttendees': maxAttendees,
      'currentAttendees': currentAttendees,
      'isFree': isFree,
      'price': price,
      'tags': tags,
      'attendeeIds': attendeeIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'status': status.toString().split('.').last,
      'vipTiers': vipTiers.map((tier) => tier.toJson()).toList(),
      'comboDiscounts': comboDiscounts.map((combo) => combo.toJson()).toList(),
      'hasVipOptions': hasVipOptions,
      'hasComboDeals': hasComboDeals,
    };
  }

  String get formattedDate {
    return '${startDate.day}/${startDate.month}/${startDate.year}';
  }

  String get formattedTime {
    return '${startDate.hour.toString().padLeft(2, '0')}:${startDate.minute.toString().padLeft(2, '0')} - ${endDate.hour.toString().padLeft(2, '0')}:${endDate.minute.toString().padLeft(2, '0')}';
  }

  bool get isToday {
    final now = DateTime.now();
    return startDate.year == now.year &&
        startDate.month == now.month &&
        startDate.day == now.day;
  }

  bool get isFull {
    return currentAttendees >= maxAttendees;
  }
} 