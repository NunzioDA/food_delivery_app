import 'package:food_delivery_app/Data/Model/delivery_info.dart';
import 'package:food_delivery_app/Data/Model/product.dart';

/// [OrderStatus] permette di rappresentare in ordine tutti i
/// possibili stati di un ordine.
/// Inoltre, è dotato di un getter [visualize] che permette di 
/// ottenere la stringa visualizzabile per ognuno degli stati dell'ordine.

enum OrderStatus
{
  placed,
  left,
  delivered,
  canceled;

  String get visualize
  {
    switch(this)
    {
      case OrderStatus.placed:
        return "In elaborazione";
      case OrderStatus.left:
        return "Partito";
      case OrderStatus.delivered:
        return "Consegnato";
      case OrderStatus.canceled:
        return "Annullato";
    }
  }
}

/// Questa classe contiene tutte le informazioni riduardanti
/// un ordine effettuato da un utente. 
/// Inoltre, è dotata di un costruttore [Order.fromJson] che 
/// permette di creare un oggetto [Order] partendo da una mappa json.

class Order{
  final String id;
  final String username;
  final DeliveryInfo deliveryInfo;
  final Map<Product, int> content;
  final DateTime dateTime;
  final OrderStatus status;

  const Order(
    this.id,
    this.username, 
    this.deliveryInfo, 
    this.content, 
    this.dateTime,
    this.status
  );

  @override
  int get hashCode => "$id$username$dateTime".hashCode;

  @override
  bool operator ==(Object other)
  {
    return other is Order &&
      (other.id == id || (
        other.username == username &&
        other.deliveryInfo.intercom == deliveryInfo.intercom&&
        other.deliveryInfo.address == deliveryInfo.address&&
        other.deliveryInfo.houseNumber == deliveryInfo.houseNumber&&
        other.dateTime == dateTime
      ));
  }


  Order.fromJson(Map<String, dynamic> json) :
    id =json["id"],
    username = json["username"],
    deliveryInfo = DeliveryInfo.fromJson(json),
    dateTime = DateTime.parse(json["date_time"]),
    content = { 
      for (var element in json["products"] as List) 
        Product.fromJson(element) : element["product_count"]
    },
    status = OrderStatus.values.firstWhere(
      (element) => element.name == json["status"]
    );    
  
    
}