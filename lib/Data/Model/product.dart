class Product{
  final String name;
  final String description;
  final String imageName;
  final double price;

  const Product(
    this.name, 
    this.description,
    this.imageName,
    this.price
  );

  Product.fromJson(Map<String, dynamic> json):
    name = json["name"],
    description = json["description"],
    imageName = json["image"],
    price = double.parse(json['price'].toString());
  
}