import 'package:flutter/material.dart';
import 'package:flutter_java_crud/currency/components/antToany.dart';
import 'package:flutter_java_crud/currency/components/usdToAny.dart';
import 'package:flutter_java_crud/currency/functions/fetchrates.dart';
import 'package:flutter_java_crud/currency/models/ratesmodel.dart';

class Currency extends StatefulWidget {
  const Currency({super.key});

  @override
  State<Currency> createState() => _CurrencyState();
}

class _CurrencyState extends State<Currency> {
  late Future<RatesModel> result;
  late Future<Map> allcurrencies;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    setState(() {
      result = fetchRates();
      allcurrencies = fetchCurrencies();
    });
  }

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Converter'),
      ),
      body: Container(
        height: h,
        width: w,
        padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Form(
              key: formKey,
              child: FutureBuilder<RatesModel>(
                  future: result,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return Center(
                      child: FutureBuilder<Map>(
                          future: allcurrencies,
                          builder: (context, currSnapshot) {
                            if (currSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                UsdToAny(
                                    rates: snapshot.data!.rates,
                                    currencies: currSnapshot.data!),
                                AnytoAny(
                                    rates: snapshot.data!.rates,
                                    currencies: currSnapshot.data!)
                              ],
                            );
                          }),
                    );
                  })),
        ),
      ),
    );
  }
}
