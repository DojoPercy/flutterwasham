// lib/models/order_models.dart

import 'package:WashAm/data/models/user_address.dart';
import 'package:flutter/foundation.dart';

// --- Enums ---

enum DetergentType {
  SCENTED,
  HYPOALLERGENIC,
}

enum StarchLevel {
  NONE,
  LIGHT,
  MEDIUM,
  HEAVY,
}

enum DryingMethod {
  AIR_DRY,
  TUMBLE_DRY,
  SUN_DRY,
}

enum IroningLevel {
  NONE,
  LIGHT,
  MEDIUM,
}

enum ServiceType {
  WASH_AND_FOLD,
  DRY_CLEANING,
  IRON_ONLY,
}

enum OrderStatus {
  PENDING,
  PICKUP_SCHEDULED,
  PICKED_UP,
  IN_PROGRESS,
  DELIVERED,
  COMPLETED,
  CANCELLED,
}

enum PriceCategory {
  BAG,
  DRY_CLEANING,
}

enum PaymentStatus {
  UNPAID,
  PENDING,
  PAID,
  FAILED,
}

enum FeeType {
  RUSH_DELIVERY,
  NEXT_DAY_DELIVERY,
  SERVICE_FEE,
  DELIVERY_FEE,
}

// Helper to convert enum to string (e.g., ServiceType.WASH_AND_FOLD to 'WASH_AND_FOLD')
String enumToString(Object enumValue) {
  return enumValue.toString().split('.').last;
}

// Helper to convert string to enum (e.g., 'WASH_AND_FOLD' to ServiceType.WASH_AND_FOLD)
T stringToEnum<T>(String value, Iterable<T> values) {
  return values.firstWhere(
    (type) => type.toString().split('.').last == value,
    orElse: () => throw ArgumentError('Unknown enum value: $value'),
  );
}

// --- Models for Responses ---

class BagEstimate {
  final String? id; // Assuming it has an ID from Prisma
  final int smallCount;
  final int mediumCount;
  final int largeCount;
  final double smallPrice;
  final double mediumPrice;
  final double largePrice;

  BagEstimate({
    this.id,
    required this.smallCount,
    required this.mediumCount,
    required this.largeCount,
    required this.smallPrice,
    required this.mediumPrice,
    required this.largePrice,
  });

  factory BagEstimate.fromJson(Map<String, dynamic> json) {
    return BagEstimate(
      id: json['id'] as String?,
      smallCount: json['smallCount'] as int,
      mediumCount: json['mediumCount'] as int,
      largeCount: json['largeCount'] as int,
      smallPrice: (json['smallPrice'] as num).toDouble(),
      mediumPrice: (json['mediumPrice'] as num).toDouble(),
      largePrice: (json['largePrice'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'smallCount': smallCount,
      'mediumCount': mediumCount,
      'largeCount': largeCount,
      'smallPrice': smallPrice,
      'mediumPrice': mediumPrice,
      'largePrice': largePrice,
    };
  }
}

class OrderServiceItem {
  final String? id; // Assuming it has an ID from Prisma
  final ServiceType serviceType;
  final double price;
  final String? notes;
  final BagEstimate? bagEstimate;
  final String orderId; // Foreign key to Order

  OrderServiceItem({
    this.id,
    required this.serviceType,
    required this.price,
    this.notes,
    this.bagEstimate,
    required this.orderId,
  });

  factory OrderServiceItem.fromJson(Map<String, dynamic> json) {
    return OrderServiceItem(
      id: json['id'] as String?,
      serviceType:
          stringToEnum(json['serviceType'] as String, ServiceType.values),
      price: (json['price'] as num).toDouble(),
      notes: json['notes'] as String?,
      bagEstimate: json['bagEstimate'] != null
          ? BagEstimate.fromJson(json['bagEstimate'] as Map<String, dynamic>)
          : null,
      orderId: json['orderId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceType': enumToString(serviceType),
      'price': price,
      'notes': notes,
      'bagEstimate': bagEstimate?.toJson(),
      'orderId': orderId,
    };
  }
}

class OrderHistoryEntry {
  final String? id; // Assuming it has an ID from Prisma
  final OrderStatus status;
  final String? comment;
  final DateTime changedAt;
  final String orderId; // Foreign key to Order

  OrderHistoryEntry({
    this.id,
    required this.status,
    this.comment,
    required this.changedAt,
    required this.orderId,
  });

  factory OrderHistoryEntry.fromJson(Map<String, dynamic> json) {
    return OrderHistoryEntry(
      id: json['id'] as String?,
      status: stringToEnum(json['status'] as String, OrderStatus.values),
      comment: json['comment'] as String?,
      changedAt: DateTime.parse(json['changedAt'] as String),
      orderId: json['orderId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': enumToString(status),
      'comment': comment,
      'changedAt': changedAt.toIso8601String(),
      'orderId': orderId,
    };
  }
}

class Payment {
  final String? id;
  final double amount;
  final PaymentStatus status;
  final String? transactionRef;
  final DateTime createdAt;
  final String orderId;

  Payment({
    this.id,
    required this.amount,
    required this.status,
    this.transactionRef,
    required this.createdAt,
    required this.orderId,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as String?,
      amount: (json['amount'] as num).toDouble(),
      status: stringToEnum(json['status'] as String, PaymentStatus.values),
      transactionRef: json['transactionRef'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      orderId: json['orderId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'status': enumToString(status),
      'transactionRef': transactionRef,
      'createdAt': createdAt.toIso8601String(),
      'orderId': orderId,
    };
  }
}

class Review {
  final String? id;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final String orderId;

  Review({
    this.id,
    required this.rating,
    this.comment,
    required this.createdAt,
    required this.orderId,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String?,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      orderId: json['orderId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'orderId': orderId,
    };
  }
}

class Order {
  final String id;
  final String userId;
  final String addressId;
  final DateTime pickupDate;
  final String pickupSlot;
  final DateTime deliveryDate;
  final String deliverySlot;
  final String? specialInstructions;
  final double totalAmount;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderServiceItem>? services;
  final Address? address; // Included when fetching order by ID/user
  final List<OrderHistoryEntry>? history;
  final Payment? payment;
  final Review? review;

  Order({
    required this.id,
    required this.userId,
    required this.addressId,
    required this.pickupDate,
    required this.pickupSlot,
    required this.deliveryDate,
    required this.deliverySlot,
    this.specialInstructions,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.services,
    this.address,
    this.history,
    this.payment,
    this.review,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      userId: json['userId'] as String,
      addressId: json['addressId'] as String,
      pickupDate: DateTime.parse(json['pickupDate'] as String),
      pickupSlot: json['pickupSlot'] as String,
      deliveryDate: DateTime.parse(json['deliveryDate'] as String),
      deliverySlot: json['deliverySlot'] as String,
      specialInstructions: json['specialInstructions'] as String?,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: stringToEnum(json['status'] as String, OrderStatus.values),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      services: (json['services'] as List<dynamic>?)
          ?.map((e) => OrderServiceItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      address: json['address'] != null
          ? Address.fromJson(json['address'] as Map<String, dynamic>)
          : null,
      history: (json['history'] as List<dynamic>?)
          ?.map((e) => OrderHistoryEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      payment: json['payment'] != null
          ? Payment.fromJson(json['payment'] as Map<String, dynamic>)
          : null,
      review: json['review'] != null
          ? Review.fromJson(json['review'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'addressId': addressId,
      'pickupDate': pickupDate.toIso8601String(),
      'pickupSlot': pickupSlot,
      'deliveryDate': deliveryDate.toIso8601String(),
      'deliverySlot': deliverySlot,
      'specialInstructions': specialInstructions,
      'totalAmount': totalAmount,
      'status': enumToString(status),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'services': services?.map((s) => s.toJson()).toList(),
      'address': address?.toJson(),
      'history': history?.map((h) => h.toJson()).toList(),
      'payment': payment?.toJson(),
      'review': review?.toJson(),
    };
  }
}

// --- DTOs (Data Transfer Objects) for Requests ---

class CreateBagEstimateDto {
  final int smallCount;
  final int mediumCount;
  final int largeCount;
  final double smallPrice;
  final double mediumPrice;
  final double largePrice;

  CreateBagEstimateDto({
    required this.smallCount,
    required this.mediumCount,
    required this.largeCount,
    required this.smallPrice,
    required this.mediumPrice,
    required this.largePrice,
  });

  Map<String, dynamic> toJson() {
    return {
      'smallCount': smallCount,
      'mediumCount': mediumCount,
      'largeCount': largeCount,
      'smallPrice': smallPrice,
      'mediumPrice': mediumPrice,
      'largePrice': largePrice,
    };
  }
}

class CreateOrderItemDto {
  final ServiceType serviceType;
  final double price;
  final String? notes;
  final CreateBagEstimateDto? bagEstimate;

  CreateOrderItemDto({
    required this.serviceType,
    required this.price,
    this.notes,
    this.bagEstimate,
  });

  Map<String, dynamic> toJson() {
    return {
      'serviceType': enumToString(serviceType),
      'price': price,
      'notes': notes,
      'bagEstimate': bagEstimate?.toJson(),
    };
  }
}

class CreateOrderDto {
  final String addressId;
  final DateTime pickupDate; // Use DateTime objects
  final String pickupSlot;
  final DateTime deliveryDate; // Use DateTime objects
  final String deliverySlot;
  final String? specialInstructions;
  final List<CreateOrderItemDto> services;

  CreateOrderDto({
    required this.addressId,
    required this.pickupDate,
    required this.pickupSlot,
    required this.deliveryDate,
    required this.deliverySlot,
    this.specialInstructions,
    required this.services,
  });

  Map<String, dynamic> toJson() {
    return {
      'addressId': addressId,
      'pickupDate': pickupDate.toIso8601String(), // ISO 8601 format for backend
      'pickupSlot': pickupSlot,
      'deliveryDate':
          deliveryDate.toIso8601String(), // ISO 8601 format for backend
      'deliverySlot': deliverySlot,
      'specialInstructions': specialInstructions,
      'services': services.map((s) => s.toJson()).toList(),
    };
  }
}

class UpdateOrderDto {
  final String id;
  final OrderStatus status;
  final String? comment;

  UpdateOrderDto({
    required this.id,
    required this.status,
    this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': enumToString(status),
      'comment': comment,
    };
  }
}

class ServiceDto {
  final ServiceType serviceType;
  final double price;
  final String? notes;

  ServiceDto({
    required this.serviceType,
    required this.price,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'serviceType': enumToString(serviceType),
      'price': price,
      'notes': notes,
    };
  }
}

class EstimateOrderDto {
  final List<ServiceDto> services;
  final String? specialInstructions;

  EstimateOrderDto({
    required this.services,
    this.specialInstructions,
  });

  Map<String, dynamic> toJson() {
    return {
      'services': services.map((s) => s.toJson()).toList(),
      'specialInstructions': specialInstructions,
    };
  }
}

class RescheduleOrderDto {
  final DateTime pickupDate; // Use DateTime object
  final String pickupSlot;
  final DateTime deliveryDate; // Use DateTime object
  final String deliverySlot;

  RescheduleOrderDto({
    required this.pickupDate,
    required this.pickupSlot,
    required this.deliveryDate,
    required this.deliverySlot,
  });

  Map<String, dynamic> toJson() {
    return {
      'pickupDate': pickupDate.toIso8601String(),
      'pickupSlot': pickupSlot,
      'deliveryDate': deliveryDate.toIso8601String(),
      'deliverySlot': deliverySlot,
    };
  }
}
