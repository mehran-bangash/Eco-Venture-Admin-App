class AdminModel {
  final String uid;
  final String name;
  final String email;
  final String imgUrl;

  AdminModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.imgUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "name": name,
      "email": email,
      "imgUrl": imgUrl,
    };
  }

  factory AdminModel.fromMap(Map<String, dynamic> map) {
    return AdminModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      imgUrl: map['imgUrl'] ?? '',
    );
  }

  AdminModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? imgUrl,
  }) {
    return AdminModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      imgUrl: imgUrl ?? this.imgUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AdminModel &&
        other.uid == uid &&
        other.email == email;
  }

  @override
  int get hashCode => uid.hashCode ^ email.hashCode;
}

