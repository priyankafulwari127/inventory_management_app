import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'product.dart';

// Product List Provider
class ProductListProvider with ChangeNotifier {
  List<Product> _products = [];
  String _searchTerm = "";
  bool _isAscendingName = true;
  bool _isAscendingPrice = true;

  List<Product> get products => _products;
  String get searchTerm => _searchTerm;
  bool get isAscendingName => _isAscendingName;
  bool get isAscendingPrice => _isAscendingPrice;

  ProductListProvider() {
    _loadProducts();
  }

  void setSearchTerm(String term) {
    _searchTerm = term;
    notifyListeners();
  }

  void toggleSortName() {
    _isAscendingName = !_isAscendingName;
    notifyListeners();
  }

  void toggleSortPrice() {
    _isAscendingPrice = !_isAscendingPrice;
    notifyListeners();
  }


  Future<void> _loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('products');
    if (jsonString != null) {
      final jsonList = jsonString.split(';');
      _products = jsonList.map((item) {
        Map<String, dynamic> map = Map<String, dynamic>.from(
            Map<String, dynamic>.from(
                Map.castFrom(json.decode(item))));
        return Product.fromMap(map);
      }).toList();
      notifyListeners();
    }
  }

  Future<void> addProduct(Product product) async {
    _products.add(product);
    await _saveProducts();
    notifyListeners();
  }

  Future<void> updateProduct(int index, Product updatedProduct) async {
    _products[index] = updatedProduct;
    await _saveProducts();
    notifyListeners();
  }

  Future<void> deleteProduct(int index) async {
    _products.removeAt(index);
    await _saveProducts();
    notifyListeners();
  }

  Future<void> _saveProducts() async {
    final prefs = await SharedPreferences.getInstance();
    String jsonString = _products.map((p) => jsonEncode(p.toMap())).join(';');
    await prefs.setString('products', jsonString);
  }
}

// Product List Screen
class ProductListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final productList = Provider.of<ProductListProvider>(context);
    final filteredProducts = productList.products.where((product) =>
        product.name.toLowerCase().contains(productList.searchTerm.toLowerCase()) ||
        product.sku.toLowerCase().contains(productList.searchTerm.toLowerCase())).toList();


    //Sort by Name
    if(productList.isAscendingName) {
      filteredProducts.sort((a,b) => a.name.compareTo(b.name));
    } else {
      filteredProducts.sort((a,b) => b.name.compareTo(a.name));
    }

    //Sort by Price
    if(productList.isAscendingPrice){
      filteredProducts.sort((a,b) => a.price.compareTo(b.price));
    } else {
      filteredProducts.sort((a,b) => b.price.compareTo(a.price));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Product List'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, '/addProduct'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: productList.setSearchTerm,
              decoration: InputDecoration(hintText: "Search by name or SKU"),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return ListTile(
                  title: Text(product.name),
                  subtitle: Text('SKU: ${product.sku}, Price: \$${product.price.toStringAsFixed(2)}, Quantity: ${product.quantity}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (product.quantity < 5)
                        Icon(Icons.warning, color: Colors.red),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          Navigator.pushNamed(context, '/editProduct',
                              arguments: {'product': product, 'index': index});
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => productList.deleteProduct(index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
