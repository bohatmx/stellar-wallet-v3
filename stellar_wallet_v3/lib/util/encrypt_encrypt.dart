import 'dart:async';
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:flutter_string_encryption/flutter_string_encryption.dart';
import 'package:stellar_wallet_v3/data/Wallet.dart';
import 'package:stellar_wallet_v3/util/SharedPrefs.dart';

class EncryptionUtil {
  static Future encryptSeed(Wallet wallet) async {
    print(
        'EncryptionUtil ## setting up encryption of seed #######################');
    wallet.password = getPassword();

    final cryptor = new PlatformStringCryptor();
    final String salt = await cryptor.generateSalt();
    final String key =
        await cryptor.generateKeyFromPassword(wallet.password, salt);
    final encrypted = await cryptor.encrypt(wallet.seed, key);
    final decrypted = await cryptor.decrypt(encrypted, key);

    assert(decrypted == wallet.seed);
    print('========================> encrypted: $encrypted');
    print('========================> decrypted: $decrypted');
    wallet.seed = encrypted;
    wallet.isEncrypted = true;
    wallet.salt = salt;
    var fb = FirebaseDatabase.instance;
    var ref = fb.reference().child('wallets').child(wallet.walletID);
    await ref.set(wallet.toJson());

    await SharedPrefs.saveWallet(wallet);
    print(
        'EncryptionUtil encryptSeed ## seed encrypted and saved on firebase and sharedPrefs ######################');

    return wallet;
  }

  static Future<String> decryptSeed(Wallet wallet) async {
    final cryptor = new PlatformStringCryptor();
    final String key =
        await cryptor.generateKeyFromPassword(wallet.password, wallet.salt);
    final decrypted = await cryptor.decrypt(wallet.seed, key);

    print('========================> encrypted: ${wallet.seed}');
    print('========================> decrypted: $decrypted');
    return decrypted;
  }

  static const platform2 = const MethodChannel('com.oneconnect.wallet/encrypt');
  static const platform3 = const MethodChannel('com.oneconnect.wallet/decrypt');

  static Future<String> _decrypt(
      String salt, String password, String seed) async {
    print('###################### _decrypt #####################');
    //todo - remove after finding crypto plugin

    return seed;
  }

  static String getPassword() {
    _load();
    var rand = new Random(new DateTime.now().millisecondsSinceEpoch);
    var index = rand.nextInt(alphabets.length - 1);
    String password = alphabets.elementAt(index);
    index = rand.nextInt(alphabets.length - 1);
    password = password + alphabets.elementAt(index);
    index = rand.nextInt(symbols.length - 1);
    password = password + symbols.elementAt(index);
    index = rand.nextInt(alphabets.length - 1);
    password = password + alphabets.elementAt(index);

    index = rand.nextInt(numbers.length - 1);
    password = password + numbers.elementAt(index);

    index = rand.nextInt(alphabets.length - 1);
    password = password + alphabets.elementAt(index);

    index = rand.nextInt(symbols.length - 1);
    password = password + symbols.elementAt(index);

    index = rand.nextInt(numbers.length - 1);
    password = password + numbers.elementAt(index);

    print('EncryptionUtil ## password generated: $password');
    return password;
  }

  static List<String> alphabets = new List();
  static List<String> symbols = new List();
  static List<String> numbers = new List();

  static _load() {
    symbols.add('@');
    symbols.add('#');
    symbols.add('%');
    symbols.add('&');
    symbols.add('^');
    symbols.add('*');

    numbers.add('0');
    numbers.add('1');
    numbers.add('2');
    numbers.add('3');
    numbers.add('4');
    numbers.add('5');
    numbers.add('6');
    numbers.add('7');
    numbers.add('8');
    numbers.add('9');

    alphabets.add("a");
    alphabets.add("a".toUpperCase());
    alphabets.add("b");
    alphabets.add("b".toUpperCase());
    alphabets.add("c");
    alphabets.add("c".toUpperCase());
    alphabets.add("d");
    alphabets.add("d".toUpperCase());
    alphabets.add("e");
    alphabets.add("e".toUpperCase());
    alphabets.add("f");
    alphabets.add("f".toUpperCase());
    alphabets.add("g");
    alphabets.add("g".toUpperCase());
    alphabets.add("h");
    alphabets.add("h".toUpperCase());
    alphabets.add("i");
    alphabets.add("i".toUpperCase());
    alphabets.add("j");
    alphabets.add("j".toUpperCase());
    alphabets.add("k");
    alphabets.add("k".toUpperCase());
    alphabets.add("l");
    alphabets.add("l".toUpperCase());
    alphabets.add("m");
    alphabets.add("m".toUpperCase());
    alphabets.add("n");
    alphabets.add("n".toUpperCase());
    alphabets.add("o");
    alphabets.add("o".toUpperCase());
    alphabets.add("p");
    alphabets.add("p".toUpperCase());
    alphabets.add("q");
    alphabets.add("q".toUpperCase());
    alphabets.add("r");
    alphabets.add("r".toUpperCase());
    alphabets.add("s");
    alphabets.add("s".toUpperCase());
    alphabets.add("t");
    alphabets.add("t".toUpperCase());
    alphabets.add("u");
    alphabets.add("u".toUpperCase());
    alphabets.add("v");
    alphabets.add("v".toUpperCase());
    alphabets.add("w");
    alphabets.add("w".toUpperCase());
    alphabets.add("x");
    alphabets.add("x".toUpperCase());
    alphabets.add("y");
    alphabets.add("y".toUpperCase());
    alphabets.add("z");
    alphabets.add("z".toUpperCase());
  }
}

// "91+4bXt+3JouAcH3D5Shaw==:xPXl6jeZ9laF/H+/2EOJ0sdmjJegLZtwfUzFbWDh8ws=:WB8Qk/O3OA4JMKu0yZUyGNreeHcnLT4FYX2g+ugq2MIq8tfiCLuZIctFPVLTUYBXcBznhCeVcnho7bFC6bpFEw=="
