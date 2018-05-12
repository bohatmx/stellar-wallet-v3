import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:stellar_wallet_v3/data/Account.dart';
import 'package:stellar_wallet_v3/data/Wallet.dart';

class BagWidget extends InheritedWidget {
  const BagWidget({
    Key key,
    this.account,
    this.wallet,
    this.refreshRequired,
    @required Widget child,
  })  : assert(child != null),
        super(key: key, child: child);

  final bool refreshRequired;
  final Account account;
  final Wallet wallet;

  static BagWidget of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(BagWidget);
  }

  @override
  bool updateShouldNotify(BagWidget old) {
    print('&&&&&&&&& updateShouldNotify ....checking if account is null');
    if (old.account == null || account == null) {
      return false;
    }

    var oldBalance = old.account.balances.elementAt(0).balance;
    var newBalance = account.balances.elementAt(0).balance;
    print('old value $oldBalance new value: $newBalance )))))))))))))))))))))');
    return oldBalance != newBalance;
  }
}
