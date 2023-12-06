class FdaUser
{
  final String username;
  final String? password;
  final String? token;

  const FdaUser(
    this.username,
    [
      this.password,
      this.token
    ]
  );
}

class FdaUserInfo extends FdaUser{
  final String name;
  final String image;

  const FdaUserInfo(
    this.name, 
    this.image, 
    super.username,
    [
      super.password,
      super.token,
    ]
  );


  FdaUserInfo.fromJson(json, FdaUser user):
    name = json["name"],
    image = json["image"],
    super(user.username, user.password, user.token);
}