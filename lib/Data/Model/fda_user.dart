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
  final bool hasPermission;

  const FdaUserInfo(
    this.name, 
    this.hasPermission
  );


  FdaUserInfo.fromJson(json):
    name = json["name"],
    hasPermission = json["has_permission"].toString() == "1";
}