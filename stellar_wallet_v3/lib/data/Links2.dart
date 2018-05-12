import 'package:json_annotation/json_annotation.dart';
import 'package:stellar_wallet_v3/data/Effects.dart';
import 'package:stellar_wallet_v3/data/Precedes.dart';
import 'package:stellar_wallet_v3/data/Self2.dart';
import 'package:stellar_wallet_v3/data/Succeeds.dart';

part 'Links2.g.dart';

@JsonSerializable()
class Links2 extends Object with _$Links2SerializerMixin {
  Self2 self;
//  Transaction transaction;
  Effects effects;
  Succeeds succeeds;
  Precedes precedes;

  Links2(this.self, this.effects, this.succeeds, this.precedes);
  factory Links2.fromJson(Map<String, dynamic> json) => _$Links2FromJson(json);
}
