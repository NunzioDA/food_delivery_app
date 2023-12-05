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