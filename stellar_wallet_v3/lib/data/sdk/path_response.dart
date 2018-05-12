import 'package:stellar_wallet_v3/data/sdk/account_response.dart';
import 'package:stellar_wallet_v3/data/sdk/offer_response.dart';

class PathResponse {
  String destinationAmount;
  String destinationAssetType;
  String destinationAssetCode;
  String destinationAssetIssuer;
  String sourceAmount;
  String sourceAssetType;
  String sourceAssetCode;
  String sourceAssetIssuer;
  List<Asset> path;
  Links links;

  PathResponse(
      this.destinationAmount,
      this.destinationAssetType,
      this.destinationAssetCode,
      this.destinationAssetIssuer,
      this.sourceAmount,
      this.sourceAssetType,
      this.sourceAssetCode,
      this.sourceAssetIssuer,
      this.path,
      this.links);
}

class Links {
  Link self;

  Links(this.self);
}
