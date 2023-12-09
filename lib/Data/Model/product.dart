import 'dart:convert';

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
  int get hashCode => "$name$price$imageName".hashCode;
  
  @override
  bool operator ==(Object other) {
    return other is Product && 
      other.name == name &&
      other.description == description &&
      other.price == price &&
      other.imageName == imageName;
  }
}