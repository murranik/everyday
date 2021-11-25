import 'package:everyday/logic/models/financemodel.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class FinanceDialog extends StatefulWidget {
  final Function ?update;
  final FinanceModel financeModel;

  const FinanceDialog({Key? key, this.update, required this.financeModel}) : super(key: key);

  @override
  State<FinanceDialog> createState() => _FinanceDialogsState();
}

class _FinanceDialogsState extends State<FinanceDialog> {
  TextEditingController labelController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  @override
  void initState() {
    labelController.text = widget.financeModel.label ?? "";
    priceController.text = widget.financeModel.price.toStringAsFixed(2);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 1.h,),
          Expanded(
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: labelController,
                      decoration: InputDecoration(
                        labelText: "Назва",
                        labelStyle: TextStyle(fontSize: 12.sp),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: const BorderSide(color: Color(0xff2a9863))
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: const BorderSide(color: Color(0xff2a9863))
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: const BorderSide(color: Color(0xff2a9863))
                        ),
                      ),
                    ),
                    SizedBox(height: 1.h,),
                    TextField(
                      controller: priceController,
                      decoration: InputDecoration(
                        labelText: "Витрати",
                        labelStyle: TextStyle(fontSize: 12.sp),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: const BorderSide(color: Color(0xff2a9863))
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: const BorderSide(color: Color(0xff2a9863))
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: const BorderSide(color: Color(0xff2a9863))
                        ),
                      ),
                    ),
                  ],
                ),
            ),
          ),
          SizedBox(height: 1.h,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              OutlinedButton(
                onPressed: () {

                },
                child: Text("Зберегти", style: TextStyle(color: Colors.white, fontSize: 16.sp),),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                    return const Color(0xff2a9863);
                  }),
                ),
              ),
              OutlinedButton(
                onPressed: () {

                },
                child: Text("Відмінити", style: TextStyle(color: Colors.white, fontSize: 16.sp),),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                    return Colors.orange;
                  }),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

}