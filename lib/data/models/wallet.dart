// lib/models/wallet_models.dart

import 'package:flutter/foundation.dart'; // For @required or @immutable (though not strictly needed if fields are final)

enum WalletTransactionType {
  credit,
  debit,
}

class Wallet {
  final String id;
  final String userId;
  final double credits;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<WalletTransaction>?
      transactions; // Optional, only included on getWalletByUserId

  Wallet({
    required this.id,
    required this.userId,
    required this.credits,
    required this.createdAt,
    required this.updatedAt,
    this.transactions,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'] as String,
      userId: json['userId'] as String,
      credits: (json['credits'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      transactions: (json['transactions'] as List<dynamic>?)
          ?.map((e) => WalletTransaction.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'credits': credits,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'transactions': transactions?.map((t) => t.toJson()).toList(),
    };
  }
}

class WalletTransaction {
  final String id;
  final String walletId;
  final double amount;
  final WalletTransactionType type;
  final String? description;
  final DateTime createdAt;

  WalletTransaction({
    required this.id,
    required this.walletId,
    required this.amount,
    required this.type,
    this.description,
    required this.createdAt,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'] as String,
      walletId: json['walletId'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: WalletTransactionType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'] as String,
        orElse: () => WalletTransactionType.credit, // Default or throw error
      ),
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'walletId': walletId,
      'amount': amount,
      'type': type.toString().split('.').last, // 'credit' or 'debit'
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

// --- DTOs (Data Transfer Objects) for requests ---

class CreateWalletDto {
  final String userId;

  CreateWalletDto({required this.userId});

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
    };
  }
}

class WalletTransactionDto {
  final double amount;
  final WalletTransactionType type;
  final String? description;

  WalletTransactionDto({
    required this.amount,
    required this.type,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'type': type.toString().split('.').last,
      'description': description,
    };
  }
}
