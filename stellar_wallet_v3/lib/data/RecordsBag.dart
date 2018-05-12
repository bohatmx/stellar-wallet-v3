import 'package:json_annotation/json_annotation.dart';
import 'package:stellar_wallet_v3/data/Record.dart';

part 'RecordsBag.g.dart';

@JsonSerializable()
class RecordsBag extends Object with _$RecordsBagSerializerMixin {
  List<Record> payments;

  RecordsBag(this.payments);
  factory RecordsBag.fromJson(Map<String, dynamic> json) =>
      _$RecordsBagFromJson(json);

  RecordsBag.create();
}
