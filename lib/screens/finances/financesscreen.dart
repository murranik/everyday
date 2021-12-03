import 'package:everyday/dialogs/financedialog.dart';
import 'package:everyday/logic/database.dart';
import 'package:everyday/logic/models/financemodel.dart';
import 'package:everyday/screens/finances/allfinancesscreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart' as intl;
import 'package:extended_masked_text/extended_masked_text.dart';

class FinancesScreen extends StatefulWidget {
  const FinancesScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FinancesScreenState();
}

class _FinancesScreenState extends State<FinancesScreen> {
  TextEditingController budgetController = MaskedTextController(mask: '000 000 000 000');
  var budget = 0.0;
  List<FinanceModel> incomeFinances = [];
  List<FinanceModel> notIncomeFinances = [];

  @override
  void initState() {
    budgetController.addListener(() {
      if(budgetController.text != '') {
        budget = double.parse(budgetController.text.replaceAll(' ', ''));
      } else {
        budget = 0.0;
      }
    });
    super.initState();
  }
  
  Future<List<dynamic>> getFinances() async {
    var finances = await DBProvider.db.getModels(FinanceModel(price: 0.0, isIncome: 0)) as List<FinanceModel>;
    incomeFinances = finances.where((element) => element.isIncome == 1).toList();
    notIncomeFinances = finances.where((element) => element.isIncome == 0).toList();

    return finances;
  }
  
  void addFinanceModelToList(FinanceModel financeModel, {required bool toDelete}){
    if(!toDelete){
      if(financeModel.isIncome == 0){
        notIncomeFinances.removeWhere((element) => element.id == financeModel.id);
        notIncomeFinances.add(financeModel);
      } else {
        incomeFinances.removeWhere((element) => element.id == financeModel.id);
        incomeFinances.add(financeModel);
      }
    } else {
      if(financeModel.isIncome == 0){
        notIncomeFinances.removeWhere((element) => element.id == financeModel.id);
      } else {
        incomeFinances.removeWhere((element) => element.id == financeModel.id);
      }
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
                ? notIncomeFinances.sublist(notIncomeFinances.length - 3, notIncomeFinances.length).reversed.toList()
                : notIncomeFinances;
            var dataListForIncomeFinances = incomeFinances.length > 3
                ? incomeFinances.sublist(incomeFinances.length - 3, incomeFinances.length).reversed.toList()
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
                            await showModalBottomSheet(
                                isScrollControlled: true,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                context: context,
                                builder: (builder){
                                  return Container(
                                      color: Colors.transparent,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(10)
                                        ),
                                        child: FinanceDialog(
                                          financeModel: FinanceModel(price: 0, isIncome: 1),
                                          update: addFinanceModelToList,
                                        ),
                                      )
                                  );
                                }
                            );
                            setState(() {});
                          },
                          children: [
                            if(dataListForIncomeFinances.isNotEmpty)
                              ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: dataListForIncomeFinances.length,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () {
                                        showModalBottomSheet(
                                            isScrollControlled: true,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                            context: context,
                                            builder: (builder){
                                              return Container(
                                                  color: Colors.transparent, //could change this to Color(0xFF737373),
                                                  //so you don't have to change MaterialApp canvasColor
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius: BorderRadius.circular(10)
                                                    ),
                                                    child: FinanceDialog(
                                                      financeModel: dataListForIncomeFinances[index],
                                                      update: addFinanceModelToList,
                                                    ),
                                                  )
                                              );
                                            }
                                        );
                                      },
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(dataListForIncomeFinances[index].label ?? "Без назви", style: TextStyle(fontSize: 12.sp),),
                                          Text(dataListForIncomeFinances[index].price.toStringAsFixed(2), style: TextStyle(fontSize: 12.sp),),
                                        ],
                                      ),
                                    );
                                  }
                              )
                            else
                              Container(
                                alignment: Alignment.centerLeft,
                                child: const Text("Доходи відсутні"),
                              )
                          ],
                        ),
                        DecoratedContainer(
                          colorMode: 2,
                          blockName: 'Витрати',
                          onTap: () async {
                            await showModalBottomSheet(
                                isScrollControlled: true,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                context: context,
                                builder: (builder){
                                  return Container(
                                      color: Colors.transparent, //could change this to Color(0xFF737373),
                                      //so you don't have to change MaterialApp canvasColor
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(10)
                                        ),
                                        child: FinanceDialog(
                                          financeModel: FinanceModel(price: 0, isIncome: 0),
                                          update: addFinanceModelToList,
                                        ),
                                      )
                                  );
                                }
                            );
                            setState(() {});
                          },
                          children: [
                            if(dataListForNotIncomeFinances.isNotEmpty)
                              ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: dataListForNotIncomeFinances.length,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                        onTap: () {
                                          showModalBottomSheet(
                                              isScrollControlled: true,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                              context: context,
                                              builder: (builder){
                                                return Container(
                                                    color: Colors.transparent, //could change this to Color(0xFF737373),
                                                    //so you don't have to change MaterialApp canvasColor
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius: BorderRadius.circular(10)
                                                      ),
                                                      child: FinanceDialog(
                                                        financeModel: dataListForNotIncomeFinances[index],
                                                        update: addFinanceModelToList,
                                                      ),
                                                    )
                                                );
                                              }
                                          );
                                        },
                                        child:  Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(dataListForNotIncomeFinances[index].label ?? "Без назви", style: TextStyle(fontSize: 12.sp),),
                                            Text(dataListForNotIncomeFinances[index].price.toStringAsFixed(2), style: TextStyle(fontSize: 12.sp),),
                                          ],
                                        )
                                    );
                                  }
                              )
                            else
                              Container(
                                alignment: Alignment.centerLeft,
                                child: const Text("Витрати відсутні"),
                              )
                          ],
                        ),
                        SizedBox(height: 0.5.h,),
                        DecoratedContainer(
                          colorMode: 3,
                          blockName: "Бюджет = ${budget.toStringAsFixed(2)}",
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Center(child: Text("Бюджет"),),
                                  insetPadding: EdgeInsets.zero,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 1.w),
                                  titlePadding: EdgeInsets.zero,
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(
                                        maxLength: 20,
                                        controller: budgetController,
                                        keyboardType: TextInputType.number,
                                        cursorColor: const Color(0xff2a9863),
                                        decoration: InputDecoration(
                                          enabledBorder: const UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Color(0xff2a9863)
                                              )
                                          ),
                                          focusedBorder: const UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Color(0xff2a9863)
                                              )
                                          ),
                                          counterText: '',
                                          suffixIcon: IconButton(
                                              onPressed: budgetController.clear,
                                              icon: const Icon(Icons.clear),
                                              color: const Color(0xff2a9863)
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          OutlinedButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text("Відмінити", style: TextStyle(color: Color(0xff2a9863),),)
                                          ),
                                          OutlinedButton(
                                              onPressed: () {
                                                setState(() {});
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text("Зберегти", style: TextStyle(color: Color(0xff2a9863),),)
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          children: [
                            Builder(
                                builder: (context) {
                                  var income = incomeFinances.fold(0, (previousValue, element) => element.price);
                                  var notIncome = notIncomeFinances.fold(0, (previousValue, element) => element.price);
                                  return Column(
                                    children: [
                                      Text("Дохід = ${income.toStringAsFixed(2)}. Витрати = ${notIncome.toStringAsFixed(2)} ", style: TextStyle(fontSize: 12.sp),),
                                      Text("Баланс = ${(budget + income - notIncome).toStringAsFixed(2)} ", style: TextStyle(fontSize: 12.sp),),
                                    ],
                                  );
                                }
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) => AllFinancesScreen(
                                          finances: incomeFinances,
                                          title: 'Доходи',
                                          update: addFinanceModelToList,
                                        )
                                    )
                                );
                              },
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 0.5.h,
                                  ),
                                  Image.asset('assets/images/money-bag.png', width: 10.w, height: 10.w,),
                                  const Text('Всі доходи'),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) => AllFinancesScreen(
                                          finances: notIncomeFinances,
                                          title: 'Витрати',
                                          update: addFinanceModelToList,
                                        )
                                    )
                                );
                              },
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 0.5.h,
                                  ),
                                  Image.asset('assets/images/budget.png', width: 10.w, height: 10.w,),
                                  const Text('Всі витрати'),
                                ],
                              ),
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
        ? GestureDetector(
        onTap: () {
          widget.onTap!();
        },
      child: Container(
          height: orientation == Orientation.landscape ? 7.h: 9.h,
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: 3.w,),
          margin: EdgeInsets.symmetric(horizontal: 2.w),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(23),
              boxShadow: [
                BoxShadow(
                    color: Colors.purple[400]!,
                    offset: const Offset(0.0, 0.0)
                )
              ]
          ),
          child: orientation == Orientation.landscape
              ? Row(
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
              : Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.blockName,
                    style: TextStyle(
                        fontSize: 14.sp
                    ),
                  ),
                ],
              ),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(left: 5.w, right: 5.w),
                child: Column(
                  children: widget.children,
                ),
              )
            ],
          )
      ),
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
                        offset: Offset(orientation == Orientation.landscape ? -82.h: -65.w, 0.0)
                    ),
                  if(widget.colorMode == 2)
                    BoxShadow(
                        color: Colors.orange,
                        offset: Offset(orientation == Orientation.landscape ? -82.h: -65.w, 0.0)
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
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(23),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey[350]!,
                )
              ]
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: widget.children,
          ),
        )
      ],
    );
  }
}