import 'package:json_annotation/json_annotation.dart';
import 'package:stellar_wallet_v3/data/Embedded.dart';
import 'package:stellar_wallet_v3/data/Links.dart';

part 'PaymentsResponse.g.dart';

@JsonSerializable()
class PaymentsResponse extends Object with _$PaymentsResponseSerializerMixin {
  Links links;
  Embedded embedded;

  PaymentsResponse(this.links, this.embedded);
  factory PaymentsResponse.fromJson(Map json) =>
      _$PaymentsResponseFromJson(json);

  PaymentsResponse.fromJSON(Map data) {
    this.embedded = new Embedded.fromJSON(data['_embedded']);
    this.links = new Links.fromJson(data['_links']);
  }
}
