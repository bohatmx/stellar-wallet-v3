import 'package:stellar_wallet_v3/data/sdk/account_response.dart';

class OfferResponse {
  final int id;
  final String pagingToken;
  final KeyPair seller;
  final Asset selling;
  final Asset buying;
  final String amount;
  final String price;
  final Links links;

  OfferResponse(this.id, this.pagingToken, this.seller, this.selling,
      this.buying, this.amount, this.price, this.links);
}

class Asset {
  String assetType;
  String assetCode;
  String assetIssuer;
  String pagingToken;
  String amount;
  int numAccounts;

  Asset(this.assetType, this.assetCode, this.assetIssuer, this.pagingToken,
      this.amount, this.numAccounts);
}

class KeyPair {}

class Links {
  final Link self;
  final Link offerMager;

  Links(this.self, this.offerMager);
}
