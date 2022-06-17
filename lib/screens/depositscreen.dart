import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class DepositScreen extends StatefulWidget {
  final double budget;
  const DepositScreen({
    Key? key,
    required this.budget,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  var month = 0.0;
  var stavka = 0.0;
  var controller = TextEditingController();
  var amountController = TextEditingController();

  @override
  void initState() {
    amountController.text = widget.budget.toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var amount = amountController.text == "" ? "0.0" : amountController.text;
    controller.text =
        ((double.parse(amount) * stavka / 100) * month).toStringAsFixed(2);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Депозит"),
        centerTitle: true,
        backgroundColor: const Color(0xff2A9863),
      ),
      body: ListView(shrinkWrap: true, children: [
        Row(
          children: [
            Expanded(
                child: Container(
              margin: const EdgeInsets.all(10),
              child: TextField(
                style: TextStyle(color: Colors.black, fontSize: 12.sp),
                keyboardType: TextInputType.number,
                controller: amountController,
                onChanged: (value) {
                  setState(() {});
                },
                decoration: InputDecoration(
                  labelText: "Бюджет",
                  labelStyle: TextStyle(
                      color: const Color(0xff2A9863), fontSize: 12.sp),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xff2A9863))),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xff2A9863))),
                ),
              ),
            ))
          ],
        ),
        Container(
          margin: EdgeInsets.only(left: 4.w),
          child: const Text("Ставка %"),
        ),
        Slider(
          value: stavka,
          min: 0.0,
          max: 100.0,
          label: stavka.toStringAsFixed(1),
          inactiveColor: Color(0xff2A9863),
          activeColor: Colors.black,
          divisions: 100,
          thumbColor: Color(0xff2A9863),
          onChanged: (value) {
            stavka = value;
            setState(() {});
          },
        ),
        Container(
          margin: EdgeInsets.only(left: 4.w),
          child: const Text("Місяців"),
        ),
        Slider(
          value: month,
          min: 0,
          max: 12,
          label: month.toStringAsFixed(0),
          inactiveColor: Color(0xff2A9863),
          activeColor: Colors.black,
          divisions: 12,
          thumbColor: Color(0xff2A9863),
          onChanged: (value) {
            month = value;
            setState(() {});
          },
        ),
        Row(
          children: [
            Expanded(
                child: Container(
              margin: const EdgeInsets.all(10),
              child: TextField(
                style:
                    TextStyle(color: const Color(0xff2A9863), fontSize: 12.sp),
                keyboardType: TextInputType.number,
                readOnly: true,
                controller: controller,
                decoration: InputDecoration(
                  labelText: "Розрахунок",
                  labelStyle: TextStyle(
                      color: const Color(0xff2A9863), fontSize: 12.sp),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xff2A9863))),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xff2A9863))),
                ),
              ),
            ))
          ],
        )
      ]),
    );
  }
}
