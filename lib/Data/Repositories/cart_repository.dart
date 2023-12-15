import 'dart:convert';

import 'package:food_delivery_app/Communication/http_communication.dart';
import 'package:food_delivery_app/Data/APIs/cart_api.dart';
import 'package:food_delivery_app/Data/Model/product.dart';
import 'package:food_delivery_app/Data/Model/products_category.dart';
import 'package:food_delivery_app/bloc/cart_bloc.dart';
import 'package:food_delivery_app/bloc/user_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';


class CartRepository{

  Product _getProductFromId(String id, List<ProductsCategory> categories)
  {
    Product? product;

    try{
      categories.firstWhere((category) {
          try{
            product = category.products.firstWhere(
              (element) => element.id == id
            );
            return true;
          }
          catch(e){
            return false;
          }
        }
      );
    }
    catch(e){
      throw Exception(
        "No product found with id=$id."
      );
    }
        
    return product!;
  }

  Future<Cart> fetchCart(
    UserState user,
    List<ProductsCategory> categories,
    [Cart? previousCart]
  )async{
    String response;
    if(user is LoggedInState)
    {
      if(previousCart != null)
      {
        for(MapEntry<Product,int> entry in previousCart.entries)
        {
          for(int i = 0; i<entry.value; i++)
          {
            await CartApi.addProduct(
              entry.key.id!, 
              user.username, 
              user.token
            );

            
          }
        }
        
        SharedPreferences preferences = await SharedPreferences.getInstance();
        preferences.setString("cart", "{}");
      }


      response = await CartApi.fetchCart(
        user.username, 
        user.token
      );

      if(response == ErrorCodes.codes["empty_result"]!)
      {
        response = "{}";
      }
    }
    else{
      SharedPreferences preferences = await SharedPreferences.getInstance();
      response = preferences.getString("cart") ?? "{}";      
    } 

    Map<String,dynamic> json = jsonDecode(response);

    try{
      return json.map<Product, int>((id, count) => MapEntry(
          _getProductFromId(id, categories), 
          count
        )
      );
    }
    catch(e){
      if(e.toString().contains("No element"))
      {
        return {};
      }
      else {
        rethrow;
      }
    }
  }

  String _cartToJson(Cart cart)
  {
    return jsonEncode(cart.map((product, count) => MapEntry(product.id, count)));
  }

  Future<Cart> addProduct(
    Product product,
    UserState userState,
    Cart cart,
    List<ProductsCategory> currentCategories
  ) async{
    if(userState is! LoggedInState)
    {
      cart[product] = (cart[product] ?? 0) + 1; 

      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setString("cart", _cartToJson(cart));      
    }
    else{
      String result = await CartApi.addProduct(
        "${product.id}", 
        userState.username,
        userState.token
      );

      
      if(ErrorCodes.isNotSuccesfull(result))
      {
        throw Exception(result);
      }
      else{
        return await fetchCart(
          userState, 
          currentCategories
        );
      }
    }

    return cart;
  }

  Future<Cart> removeProduct(
    Product product,
    UserState userState,
    Cart cart,
    List<ProductsCategory> currentCategories
  ) async{
    
    if(userState is! LoggedInState)
    {

      if(cart.containsKey(product))
      {
        if(cart[product]! > 1)
        {
          cart[product] = cart[product]! - 1;
        }
        else {
          cart.remove(product);
        }
      }
      
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setString("cart", _cartToJson(cart));
      
    }
    else{
      String result = await CartApi.removeProduct(
        "${product.id}", 
        userState.username,
        userState.token
      );

      if(ErrorCodes.isNotSuccesfull(result))
      {
        throw Exception(result);
      }
      else{
        return await fetchCart(
          userState, 
          currentCategories
        );
      }
    }

    return cart;
  }
}