import 'package:stellar_wallet_v3/data/sdk/account_response.dart';

class AssetResponse {
  String assetType;
  String assetCode;
  String assetIssuer;
  String pagingToken;
  String amount;
  int numAccounts;
  Flags flags;
  Links links;

  AssetResponse(this.assetType, this.assetCode, this.assetIssuer,
      this.pagingToken, this.amount, this.numAccounts, this.flags, this.links);
}

class Flags {
  bool authRequired;
  bool authRevocable;

  Flags(this.authRequired, this.authRevocable);
}

class Links {
  Link toml;

  Links(this.toml);
}
