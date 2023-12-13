class DeliveryInfo{
  final String city;
  final String intercom;
  final String address;
  final String houseNumber;

  const DeliveryInfo(this.city, this.intercom, this.address, this.houseNumber);


  DeliveryInfo.fromJson(Map<String, dynamic> json):
    address = json["address"],
    intercom = json["intercom"],
    city = json["city"],
    houseNumber = json["house_number"];


}