import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_java_crud/currency/functions/fetchrates.dart';

class AnytoAny extends StatefulWidget {
  final rates;
  final Map currencies;
  const AnytoAny({Key? key, @required this.rates, required this.currencies})
      : super(key: key);

  @override
  State<AnytoAny> createState() => _AnytoAnyState();
}

class _AnytoAnyState extends State<AnytoAny> {
  TextEditingController amountController = TextEditingController();

  String dropdownValue1 = 'AUD';
  String dropdownValue2 = 'AUD';
  String answer = 'Converted Currency will be shown here';

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    return Card(
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Convert any currency',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              key: const ValueKey('amount'),
              controller: amountController,
              decoration: const InputDecoration(hintText: 'Enter Amount'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Expanded(
                    child: DropdownButton<String>(
                  value: dropdownValue1,
                  icon: const Icon(Icons.arrow_drop_down_rounded),
                  iconSize: 24,
                  elevation: 16,
                  isExpanded: true,
                  underline: Container(
                    height: 2,
                    color: Colors.grey,
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      dropdownValue1 = newValue!;
                    });
                  },
                  items: widget.currencies.keys
                      .toSet()
                      .toList()
                      .map<DropdownMenuItem<String>>((value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                )),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Text("To"),
                ),
                Expanded(
                    child: DropdownButton<String>(
                  value: dropdownValue2,
                  icon: const Icon(Icons.arrow_drop_down_rounded),
                  iconSize: 24,
                  elevation: 16,
                  isExpanded: true,
                  underline: Container(
                    height: 2,
                    color: Colors.grey,
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      dropdownValue2 = newValue!;
                    });
                  },
                  items: widget.currencies.keys
                      .toSet()
                      .toList()
                      .map<DropdownMenuItem<String>>((value) {
                    return DropdownMenuItem<String>(
                        value: value, child: Text(value));
                  }).toList(),
                ))
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    answer = amountController.text +
                        ' ' +
                        dropdownValue1 +
                        ' ' +
                        convertany(widget.rates, amountController.text,
                            dropdownValue1, dropdownValue2) +
                        ' ' +
                        dropdownValue2;
                  });
                },
                child: const Text('Convert'),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              child: Text(answer),
            )
          ],
        ),
      ),
    );
  }
}
