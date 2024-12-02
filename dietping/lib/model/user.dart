import 'dart:ffi';

class User{
  //int user_idx;
  var user_id;
  var user_name;
  var user_email;
  var user_password;
  var user_nickname;
  int user_age;
  var user_gender;
  double user_kcal;
  double user_height;
  double user_weight;

  User(this.user_id,  this.user_name, this.user_email, this.user_password,this.user_nickname, this.user_age, this.user_gender, this.user_kcal, this.user_height, this.user_weight);

  factory User.fromJson(Map<String, dynamic> json) => User(
    json['id'] ?? 'unknown',
    json['name'] ?? 'unknown',
    json['email'] ?? 'unknown',
    json['password'] ?? 'unknown',
    json['nickname'] ?? 'unknown',
    json['age'] ?? 0,
    json['gender'] ?? 'unknown',
    double.tryParse(json['kcal']?.toString() ?? '0.0') ?? 0.0, // 문자열 -> double 변환
    double.tryParse(json['height']?.toString() ?? '0.0') ?? 0.0,
    double.tryParse(json['weight']?.toString() ?? '0.0') ?? 0.0,
  );


  Map<String, dynamic> toJson()=> { // 키네임 , 밸류값
    //'idx' : user_idx.toString(),
    'id' : user_id,
    'name' : user_name,
    'email' : user_email,
    'password' : user_password,
    'nickname' : user_nickname,
    'age' : user_age,
    'gender' : user_gender,
    'kcal' : user_kcal,
    'height' : user_height,
    'weight' : user_weight
  };
}