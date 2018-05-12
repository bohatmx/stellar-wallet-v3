import 'package:json_annotation/json_annotation.dart';

part 'Wallet.g.dart';

@JsonSerializable()
class Wallet extends Object with _$WalletSerializerMixin {
  String walletID,
      accountID,
      seed,
      url,
      sourceAccountID,
      sourceSeed,
      password,
      salt,
      fcmToken,
      name,
      email,
      uid,
      sequenceNumber,
      stringDate;
  bool debug, isEncrypted, success;
  int date;

  Wallet(
      {this.walletID,
      this.accountID,
      this.seed,
      this.sourceAccountID,
      this.sourceSeed,
      this.fcmToken,
      this.name,
      this.email,
      this.uid,
      this.isEncrypted,
      this.sequenceNumber,
      this.stringDate,
      this.debug,
      this.date,
      this.url,
      this.password,
      this.salt,
      this.success});

  factory Wallet.fromJson(Map<String, dynamic> json) => _$WalletFromJson(json);

  Wallet.fromJSON(Map data) {
    this.walletID = data['walletID'];
    this.accountID = data['accountID'];
    this.seed = data['seed'];
    this.sourceAccountID = data['sourceAccountID'];
    this.sourceSeed = data['sourceSeed'];
    this.fcmToken = data['fcmToken'];
    this.name = data['name'];
    this.email = data['email'];
    this.uid = data['uid'];
    this.isEncrypted = data['isEncrypted'];
    this.sequenceNumber = data['sequenceNumber'];
    this.stringDate = data['stringDate'];
    this.debug = data['debug'];
    this.date = data['date'];
    this.url = data['url'];
    this.password = data['password'];
    this.salt = data['salt'];
    this.success = data['success'];
  }

  Wallet.create();

  void printDetails() {
    print(this.toJson().toString());
  }
}
