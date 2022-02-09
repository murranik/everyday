import 'package:everyday/logic/database.dart';
import 'package:everyday/logic/models/financemodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class FinanceDialog extends StatefulWidget {
  final Function? update;
  final FinanceModel financeModel;

  const FinanceDialog({Key? key, this.update, required this.financeModel})
      : super(key: key);

  @override
  State<FinanceDialog> createState() => _FinanceDialogsState();
}

class _FinanceDialogsState extends State<FinanceDialog> {
  TextEditingController labelController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  var errorText = "Заповніть, будь ласка, поле";
  bool isError = false;

  @override
  void initState() {
    labelController.text = widget.financeModel.label ?? "";
    priceController.text = widget.financeModel.price == 0
        ? ""
        : widget.financeModel.price.toStringAsFixed(2);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var orientation = MediaQuery.of(context).orientation;
    return Container(
      padding: EdgeInsets.only(
          left: 2.w,
          right: 2.w,
          bottom: orientation == Orientation.landscape
              ? MediaQuery.of(context).viewInsets.bottom / 1.2
              : MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 1.5.h,
          ),
          TextField(
            controller: labelController,
            decoration: InputDecoration(
              labelText: "Назва",
              hintText: "Заповніть, будь ласка, поле",
              errorText: !isError ? null : errorText,
              labelStyle: TextStyle(fontSize: 12.sp, color: Colors.black),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: Color(0xffc9e7f2))),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: Color(0xffc9e7f2))),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: Color(0xffc9e7f2))),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(26),
                borderSide: BorderSide(
                    color: !isError ? const Color(0xffc9e7f2) : Colors.red),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(26),
                borderSide: BorderSide(
                    color: !isError ? const Color(0xffc9e7f2) : Colors.red),
              ),
            ),
            onChanged: (v) {
              isError = false;
              setState(() {});
            },
          ),
          SizedBox(
            height: 1.5.h,
          ),
          TextField(
            controller: priceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Сумма",
              hintText: "0.0",
              labelStyle: TextStyle(fontSize: 12.sp, color: Colors.black),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: Color(0xffc9e7f2))),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: Color(0xffc9e7f2))),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: Color(0xffc9e7f2))),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.resolveWith<Color>((states) {
                    return const Color(0xffc9e7f2);
                  }),
                ),
                onPressed: () async {
                  if (labelController.text != "") {
                    widget.financeModel.price = double.parse(
                        priceController.text == ""
                            ? "0.0"
                            : priceController.text);
                    widget.financeModel.label = labelController.text == ""
                        ? null
                        : labelController.text;
                    var res =
                        await DBProvider.db.upsertModel(widget.financeModel);
                    widget.update!(res, toDelete: false);
                    Navigator.of(context).pop();
                  } else {
                    isError = true;
                    setState(() {});
                  }
                },
                child: const Text(
                  'Зберегти',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              OutlinedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.resolveWith<Color>((states) {
                    return Colors.red[300]!;
                  }),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Відмінити',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              OutlinedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.resolveWith<Color>((states) {
                    return Colors.red;
                  }),
                ),
                onPressed: () async {
                  await DBProvider.db
                      .deleteModelById(widget.financeModel.id, "FinanceModels");
                  widget.update!(widget.financeModel, toDelete: true);
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Видалити',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
