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
  final bool hasPermission;

  const FdaUserInfo(
    this.name, 
    this.image,
    this.hasPermission
  );


  FdaUserInfo.fromJson(json):
    name = json["name"],
    image = json["profile_pic"],
    hasPermission = json["has_permission"].toString() == "1";
}