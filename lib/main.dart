import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'add_product_screen.dart';
import 'edit_product_screen.dart';
import 'product_list_screen.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => ProductListProvider(),
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ProductListScreen(),
      routes: {
        '/addProduct': (context) => AddProductScreen(),
        '/editProduct': (context) => EditProductScreen(),
      },
    );
  }
}