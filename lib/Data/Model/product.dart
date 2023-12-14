import 'dart:convert';

/// Questa classe contiene tutte le informazioni riduardanti
/// un prodotto che un utente può ordinare. 
/// Inoltre, è dotata di un costruttore [Product.fromJson] che 
/// permette di creare un oggetto [Product] partendo da una mappa json.

class Product{
  final String? id;
  final String name;
  final String description;
  final String? imageName;
  final double price;

  const Product(
    this.name, 
    this.description,    
    this.price,
    [this.id,this.imageName,]
  );

  Product.fromJson(Map<String, dynamic> json):
    id = json["id"].toString(),
    name = json["name"],
    description = json["description"],
    imageName = json["image"],
    price = double.parse(json['price'].toString());
  
  String toJson()
  {
    return jsonEncode({
      "name":name,
      "description":name,
      "image":imageName,
      "price":price
    });
  }

  @override
  int get hashCode => "$id$name$price$imageName".hashCode;
  
  @override
  bool operator ==(Object other) {
    return other is Product && 
      other.name == name &&
      other.description == description &&
      other.price == price &&
      other.imageName == imageName;
  }
}