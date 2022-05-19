import 'package:everyday/dialogs/financedialog.dart';
import 'package:everyday/logic/database.dart';
import 'package:everyday/logic/models/financemodel.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class AllFinancesScreen extends StatefulWidget {
  final List<FinanceModel> finances;
  final String title;
  final Function? update;

  const AllFinancesScreen(
      {Key? key, required this.finances, required this.title, this.update})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => _AllFinancesScreenState();
}

class _AllFinancesScreenState extends State<AllFinancesScreen> {
  Future<void> delete(event) async {
    widget.update!();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var orientation = MediaQuery.of(context).orientation;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xff2A9863),
          centerTitle: true,
          title: Text(widget.title),
        ),
        body: widget.finances.isNotEmpty
            ? ListView.builder(
                padding: EdgeInsets.only(left: 10.w, right: 10.w, top: 1.h),
                itemCount: widget.finances.length,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  var element = widget.finances[index];
                  return GestureDetector(
                      onTap: () async {
                        await showModalBottomSheet(
                            isScrollControlled: true,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25)),
                            context: context,
                            builder: (builder) {
                              return Container(
                                  color: Colors.transparent,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: FinanceDialog(
                                      financeModel: element,
                                      update: widget.update,
                                    ),
                                  ));
                            });
                        setState(() {});
                      },
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.only(
                                left: 2.w, right: 2.w, top: 1.h, bottom: 1.h),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(26)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Expanded(
                                  flex: 80,
                                  child: Text(element.label!),
                                ),
                                SizedBox(
                                  height: 1.h,
                                ),
                                Expanded(
                                  flex: 20,
                                  child: Text(
                                    element.price.toString(),
                                    textDirection: TextDirection.rtl,
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 1.h,
                          ),
                        ],
                      ));
                },
              )
            : Container(
                alignment: Alignment.center,
                child: Text("${widget.title} відсутні"),
              ));
  }
}
