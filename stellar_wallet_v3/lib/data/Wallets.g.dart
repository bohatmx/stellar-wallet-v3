// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Wallets.dart';

// **************************************************************************
// Generator: JsonSerializableGenerator
// **************************************************************************

Wallets _$WalletsFromJson(Map<String, dynamic> json) =>
    new Wallets((json['wallets'] as List)
        ?.map((e) =>
            e == null ? null : new Wallet.fromJson(e as Map<String, dynamic>))
        ?.toList());

abstract class _$WalletsSerializerMixin {
  List<Wallet> get wallets;
  Map<String, dynamic> toJson() => <String, dynamic>{'wallets': wallets};
}
