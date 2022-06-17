import 'package:everyday/logic/database.dart';
import 'package:everyday/logic/models/financemodel.dart';
import 'package:flutter/material.dart';

class FinanceModelView with ChangeNotifier {
  List<FinanceModel> financeModels = [];

  Future<void> load(int id) async {
    var res = await DBProvider.db.getListById<FinanceModel>(
        id, FinanceModel(price: 0, isIncome: 0)) as List<FinanceModel>;
    financeModels = res;
    notifyListeners();
  }

  void clear() {
    financeModels.clear();
  }
}
