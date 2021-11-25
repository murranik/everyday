import 'package:everyday/dialogs/financedialog.dart';
import 'package:everyday/logic/database.dart';
import 'package:everyday/logic/models/financemodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart' as intl;

class FinancesScreen extends StatefulWidget {
  const FinancesScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FinancesScreenState();
}

class _FinancesScreenState extends State<FinancesScreen> {

  List<FinanceModel> incomeFinances = [];
  List<FinanceModel> notIncomeFinances = [];

  Future<List<dynamic>> getFinances() async {
    var finances = await DBProvider.db.getModels(FinanceModel(price: 0.0, isIncome: 0)) as List<FinanceModel>;
    incomeFinances = finances.where((element) => element.isIncome == 1).toList();
    notIncomeFinances = finances.where((element) => element.isIncome == 0).toList();

    return finances;
  }

  void addFinanceModelToList(FinanceModel financeModel){
    if(financeModel.isIncome == 0){
      notIncomeFinances.removeWhere((element) => element.id == financeModel.id);
      notIncomeFinances.add(financeModel);
    } else {
      incomeFinances.removeWhere((element) => element.id == financeModel.id);
      incomeFinances.add(financeModel);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var orientation = MediaQuery.of(context).orientation;
    return FutureBuilder(
        future: getFinances(),
        builder: (context, snapshot) {
          if(snapshot.hasData){
            var dataListForNotIncomeFinances = notIncomeFinances.length > 3
                ? notIncomeFinances.sublist(notIncomeFinances.length - 3, notIncomeFinances.length).toList()
                : notIncomeFinances;
            var dataListForIncomeFinances = incomeFinances.length > 3
                ? incomeFinances.sublist(incomeFinances.length - 3, incomeFinances.length).toList()
                : incomeFinances;
            return Container(
              color: Colors.grey[300],
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: orientation == Orientation.portrait  ? 2.h : 2.w,),
                  Expanded(
                    child: ListView(
                      children: [
                        DecoratedContainer(
                          colorMode: 1,
                          blockName: 'Доходи',
                          onTap: () async {
                            await DBProvider.db.upsertModel(FinanceModel(price: 200.0, isIncome: 1));
                            setState(() {});
                          },
                          children: [
                            ListView.builder(
                                shrinkWrap: true,
                                itemCount: dataListForIncomeFinances.length,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      showModalBottomSheet(
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                          context: context,
                                          builder: (builder){
                                            return Container(
                                                height: 350.0,
                                                color: Colors.transparent, //could change this to Color(0xFF737373),
                                                //so you don't have to change MaterialApp canvasColor
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.circular(10)
                                                  ),
                                                  child: FinanceDialog(
                                                    financeModel: dataListForIncomeFinances[index],
                                                  ),
                                                )
                                            );
                                          }
                                      );
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(dataListForIncomeFinances[index].label ?? "Без названия", style: TextStyle(fontSize: 12.sp),),
                                        Text(dataListForIncomeFinances[index].price.toStringAsFixed(2), style: TextStyle(fontSize: 12.sp),),
                                      ],
                                    ),
                                  );
                                }
                            )
                          ],
                        ),
                        DecoratedContainer(
                          colorMode: 2,
                          blockName: 'Витрати',
                          onTap: () async {
                            await DBProvider.db.upsertModel(FinanceModel(price: 228.0, isIncome: 0));
                            setState(() {});
                          },
                          children: [
                            ListView.builder(
                                shrinkWrap: true,
                                itemCount: dataListForNotIncomeFinances.length,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(dataListForNotIncomeFinances[index].label ?? "Без названия", style: TextStyle(fontSize: 12.sp),),
                                      Text(dataListForNotIncomeFinances[index].price.toStringAsFixed(2), style: TextStyle(fontSize: 12.sp),),
                                    ],
                                  );
                                }
                            )
                          ],
                        ),
                        DecoratedContainer(
                          colorMode: 3,
                          blockName: 'Баланс',
                          children: [
                            Builder(
                                builder: (context) {
                                  var income = incomeFinances.fold(0, (previousValue, element) => element.price);
                                  var notIncome = notIncomeFinances.fold(0, (previousValue, element) => element.price);

                                  return Text("${income - notIncome} ", style: TextStyle(fontSize: 14.sp),);
                                }
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                SizedBox(
                                  height: 0.5.h,
                                ),
                                Image.asset('assets/images/money-bag.png', width: 10.w, height: 10.w,),
                                const Text('Всі доходи'),
                              ],
                            ),
                            Column(
                              children: [
                                SizedBox(
                                  height: 0.5.h,
                                ),
                                Image.asset('assets/images/budget.png', width: 10.w, height: 10.w,),
                                const Text('Всі витрати'),
                              ],
                            )
                          ],
                        ),
                        SizedBox(
                          height: 3.h,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Container();
          }
        }
    );
  }
}

class DecoratedContainer extends StatefulWidget{
  final List<Widget> children;
  final String blockName;
  final int colorMode;
  final Function ?onTap;

  const DecoratedContainer({Key? key, required this.children, required this.colorMode, required this.blockName, this.onTap}) : super(key: key);
  @override
  State<DecoratedContainer> createState() => _DecoratedContainerState();
}

class _DecoratedContainerState extends State<DecoratedContainer> {


  @override
  Widget build(BuildContext context) {
    var orientation = MediaQuery.of(context).orientation;
    return widget.colorMode == 3
        ? Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 3.w,),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(23),
            boxShadow: const [
              BoxShadow(
                  color: Colors.purple,
                  offset: Offset(0.0, 0.0)
              )
            ]
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  widget.blockName,
                  style: TextStyle(
                      fontSize: 14.sp
                  ),
                ),
                if(widget.onTap != null)
                  IconButton(
                      iconSize: 18.sp,
                      onPressed: () {
                        widget.onTap!();
                      },
                      icon: const Icon(Icons.add)
                  )
              ],
            ),
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 5.w, right: 5.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: widget.children,
              ),
            )
          ],
        )
    )
        : Column(
      children: [
        Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 3.w,),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(23),
                boxShadow: [
                  if(widget.colorMode == 1)
                    BoxShadow(
                      color: Colors.green,
                      offset: Offset(orientation == Orientation.landscape  ? -82.h: -65.w, 0.0)
                    ),
                  if(widget.colorMode == 2)
                    BoxShadow(
                        color: Colors.orange,
                        offset: Offset(orientation == Orientation.landscape  ? -82.h: -65.w, 0.0)
                    ),
                ]
            ),
            child: Row(
              children: [
                Text(
                  widget.blockName,
                  style: TextStyle(
                      fontSize: 14.sp
                  ),
                ),
                if(widget.onTap != null)
                  IconButton(
                      iconSize: 18.sp,
                      onPressed: () {
                        widget.onTap!();
                      },
                      icon: const Icon(Icons.add)
                  )
              ],
            )
        ),
        Container(
          height: 12.h,
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: 5.w, right: 5.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: widget.children,
          ),
        )
      ],
    );
  }
}