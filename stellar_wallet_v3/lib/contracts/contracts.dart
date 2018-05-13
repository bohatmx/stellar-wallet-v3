import 'dart:async';

import 'package:stellar_wallet_v3/data/Account.dart';
import 'package:stellar_wallet_v3/util/comms.dart';

abstract class Presenter {
  Future getAccount(String accountID);
}

abstract class View {
  onAccount(Future<Account> account);
}

class AccountPresenter implements Presenter {
  @override
  Future getAccount(String accountID) async {
    // TODO: implement getAccount
    print('@@@@@@@@@@@ would be getting account if implemented');
    var comms = new Communications();
    var f = comms.getAccount(accountID);
    f.then((acct) {
      print('=============> returning account: ' + acct.account_id);
      return acct;
    });

    return f;
  }
}
