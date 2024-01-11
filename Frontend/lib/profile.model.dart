// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ProfileModel {
    String username;
    String email;
    String fullname;
    String avatar;
    String coverImage;

    ProfileModel({
        required this.username,
        required this.email,
        required this.fullname,
        required this.avatar,
        required this.coverImage,
    });


  ProfileModel copyWith({
    String? username,
    String? email,
    String? fullname,
    String? avatar,
    String? coverImage,
  }) {
    return ProfileModel(
      username: username ?? this.username,
      email: email ?? this.email,
      fullname: fullname ?? this.fullname,
      avatar: avatar ?? this.avatar,
      coverImage: coverImage ?? this.coverImage,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'username': username,
      'email': email,
      'fullname': fullname,
      'avatar': avatar,
      'coverImage': coverImage,
    };
  }

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      username: map['username'] as String,
      email: map['email'] as String,
      fullname: map['fullname'] as String,
      avatar: map['avatar'] as String,
      coverImage: map['coverImage'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory ProfileModel.fromJson(String source) => ProfileModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ProfileModel(username: $username, email: $email, fullname: $fullname, avatar: $avatar, coverImage: $coverImage)';
  }

  @override
  bool operator ==(covariant ProfileModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.username == username &&
      other.email == email &&
      other.fullname == fullname &&
      other.avatar == avatar &&
      other.coverImage == coverImage;
  }

  @override
  int get hashCode {
    return username.hashCode ^
      email.hashCode ^
      fullname.hashCode ^
      avatar.hashCode ^
      coverImage.hashCode;
  }
}
