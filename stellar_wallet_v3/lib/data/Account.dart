import 'package:json_annotation/json_annotation.dart';
import 'package:stellar_wallet_v3/data/Balance.dart';
import 'package:stellar_wallet_v3/data/Data.dart';
import 'package:stellar_wallet_v3/data/Flags.dart';
import 'package:stellar_wallet_v3/data/Links.dart';
import 'package:stellar_wallet_v3/data/Signer.dart';
import 'package:stellar_wallet_v3/data/Thresholds.dart';

part 'Account.g.dart';

@JsonSerializable()
class Account extends Object with _$AccountSerializerMixin {
  Links links;
  String id;
  String paging_token;
  String account_id;
  String sequence;
  int subentry_count;
  Thresholds thresholds;
  Flags flags;
  List<Signer> signers;
  Data data;
  List<Balance> balances;

  Account(
      {this.links,
      this.id,
      this.paging_token,
      this.account_id,
      this.sequence,
      this.subentry_count,
      this.thresholds,
      this.flags,
      this.signers,
      this.data,
      this.balances});

  factory Account.fromJson(Map<String, dynamic> json) =>
      _$AccountFromJson(json);
}
