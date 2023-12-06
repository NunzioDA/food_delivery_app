class FdaUser
{
  final String username;
  final String? password;
  final String? token;

  const FdaUser({
    required this.username,
    this.password,
    this.token
  });
}

class FdaUserInfo{
  final String name;
  final String image;

  const FdaUserInfo(
    this.name, 
    this.image,
  );


  FdaUserInfo.fromJson(json):
    name = json["name"],
    image = json["image"];
}