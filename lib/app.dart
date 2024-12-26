import 'package:alarmmm/home.dart';
import 'package:alarmmm/controller/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ALARMMM',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      // initialBinding: BindingsBuilder(() {
      //   Get.lazyPut(() => HomeController());
      // }),
      home: const Home(),
    );
  }
}
