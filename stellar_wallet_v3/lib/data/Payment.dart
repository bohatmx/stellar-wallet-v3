import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
part 'Payment.g.dart';
@JsonSerializable()

class Payment extends Object with _$PaymentSerializerMixin{
  String seed;
  String sourceAccount;
  String destinationAccount;
  String amount;
  String memo, stringDate;
  String toFCMToken;
  String fromFCMToken;
  bool receiving;
  bool debug;
  int date;


  Payment({
    @required this.seed,
    @required this.sourceAccount,
    @required this.destinationAccount,
    @required this.amount,
    @required this.memo,
    @required this.toFCMToken,
    @required this.fromFCMToken,
    this.receiving,
    @required this.date,
    @required this.stringDate,
    @required this.debug});

  factory Payment.fromJson(Map<String, dynamic> json) => _$PaymentFromJson(json);

  void printDetails() {
    print("seed: $seed destination: $destinationAccount memo: $memo "
        "toFCM: $toFCMToken fromFCM: $fromFCMToken sourceAccount: $sourceAccount");
  }


}
