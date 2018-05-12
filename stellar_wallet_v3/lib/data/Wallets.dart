import 'package:json_annotation/json_annotation.dart';
import 'package:stellar_wallet_v3/data/Wallet.dart';

part 'Wallets.g.dart';

@JsonSerializable()
class Wallets extends Object with _$WalletsSerializerMixin {
  List<Wallet> wallets;

  Wallets(this.wallets);
  factory Wallets.fromJson(Map<dynamic, dynamic> json) =>
      _$WalletsFromJson(json);

  Wallets.create();
}
