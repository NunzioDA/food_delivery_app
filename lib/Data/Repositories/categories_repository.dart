import 'dart:convert';

import 'package:cross_file/cross_file.dart';
import 'package:food_delivery_app/Communication/http_communication.dart';
import 'package:food_delivery_app/Data/APIs/categories_api.dart';
import 'package:food_delivery_app/Data/Model/fda_user.dart';
import 'package:food_delivery_app/Data/Model/products_category.dart';
import 'package:food_delivery_app/Presentation/Utilities/image_optimizer.dart';
import 'package:food_delivery_app/bloc/user_bloc.dart';

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

  Future<bool> createCategory(
    ProductsCategory newCategory,  
    XFile newPic,
    LoggedInState user
  ) async
  {
    FdaImage? optimized = await FdaImageOptimizer.optimize(newPic);

    if(optimized != null)
    {
      String result = await CategoryApi.createCategory(
        newCategory.name,
        user.username,
        user.token,
        base64Encode(optimized.image)
      );
      return ErrorCodes.isSuccesfull(result);
    }
    else {
      return false;
    }
    
  }
}