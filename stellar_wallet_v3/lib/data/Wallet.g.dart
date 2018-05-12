// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Wallet.dart';

// **************************************************************************
// Generator: JsonSerializableGenerator
// **************************************************************************

Wallet _$WalletFromJson(Map<String, dynamic> json) => new Wallet(
    walletID: json['walletID'] as String,
    accountID: json['accountID'] as String,
    seed: json['seed'] as String,
    sourceAccountID: json['sourceAccountID'] as String,
    sourceSeed: json['sourceSeed'] as String,
    fcmToken: json['fcmToken'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    uid: json['uid'] as String,
    isEncrypted: json['isEncrypted'] as bool,
    sequenceNumber: json['sequenceNumber'] as String,
    stringDate: json['stringDate'] as String,
    debug: json['debug'] as bool,
    date: json['date'] as int,
    url: json['url'] as String,
    password: json['password'] as String,
    salt: json['salt'] as String,
    success: json['success'] as bool);

abstract class _$WalletSerializerMixin {
  String get walletID;
  String get accountID;
  String get seed;
  String get url;
  String get sourceAccountID;
  String get sourceSeed;
  String get password;
  String get salt;
  String get fcmToken;
  String get name;
  String get email;
  String get uid;
  String get sequenceNumber;
  String get stringDate;
  bool get debug;
  bool get isEncrypted;
  bool get success;
  int get date;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'walletID': walletID,
        'accountID': accountID,
        'seed': seed,
        'url': url,
        'sourceAccountID': sourceAccountID,
        'sourceSeed': sourceSeed,
        'password': password,
        'salt': salt,
        'fcmToken': fcmToken,
        'name': name,
        'email': email,
        'uid': uid,
        'sequenceNumber': sequenceNumber,
        'stringDate': stringDate,
        'debug': debug,
        'isEncrypted': isEncrypted,
        'success': success,
        'date': date
      };
}
