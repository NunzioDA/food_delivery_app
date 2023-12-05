import 'dart:convert';

import 'package:food_delivery_app/Communication/http_communication.dart';
import 'package:food_delivery_app/Data/APIs/categories_api.dart';
import 'package:food_delivery_app/Data/Model/products_category.dart';

class CategoryRepository{
  Future<List<ProductsCategory>> fetchCategories() async
  {
    String json = await CategoryApi.fetchCategories();
    List<ProductsCategory> categories = [];

    if(json != ErrorCodes.codes['empty_result']) {        
          categories = (jsonDecode(json) as List)
          .map((e){
            return ProductsCategory.fromJson(e);
          })
          .toList();
    }

    return categories;
  }
}