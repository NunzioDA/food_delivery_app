// Serie di strumenti che permette la validazione delle credenziali

const String specialChars = "~`!@#\$%^&*()_-+={[}]|:;\\\"'<,>.?/";

bool _anyMetch(String string1, String string2)
{
  for(int char1 in string1.runes)
  {
    for(int char2 in string2.runes)
    {
      if(char1 == char2)
      {
        return true;
      }
    }
  }

  return false;
}

int minUsernameLength = 6;
int minPassLength = 6;
int minNameLength = 3;
int maxNameLength = 20;

bool  validateName(String? name)
{
  return name != null && 
    name.length >= minNameLength && 
    name.length <= maxNameLength && 
    RegExp(r'^[a-zA-Z\s]+$').hasMatch(name);
}

bool validateUsername(String? username)
{
  return username != null && 
    username.isNotEmpty && 
    username.length >= 6 && 
    RegExp(r'^(\_?[a-zA-Z]+\_?[a-zA-Z]*)+$').hasMatch(username);
}

enum PasswordValidationErrors{
  empty,
  hasNotUpper,
  hasNotLower,
  hasNotNumbers,
  hasNotSpecialChars,
  length,
  good
}

PasswordValidationErrors validatePassword(String? password)
{
  if(password == null || password.isEmpty)
  {
    return PasswordValidationErrors.empty;
  }

  bool hasUpperCase = RegExp("[A-Z]").hasMatch(password);
  bool hasLowerCase = RegExp("[a-z]").hasMatch(password);
  bool hasNumbers = RegExp("[0-9]").hasMatch(password);
  
  if(!hasUpperCase)
  {
    return PasswordValidationErrors.hasNotUpper;
  }
  else if(!hasLowerCase)
  {
    return PasswordValidationErrors.hasNotLower;
  }
  else if(!hasNumbers)
  {
    return PasswordValidationErrors.hasNotNumbers;
  }
  else if(!_anyMetch(password,specialChars))
  {
    return PasswordValidationErrors.hasNotSpecialChars;
  }
  else if(password.length < minPassLength)
  {
    return PasswordValidationErrors.length;
  }
  
  return PasswordValidationErrors.good;
}