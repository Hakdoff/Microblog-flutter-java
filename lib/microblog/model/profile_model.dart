class Profile {
  final int id;
  final String? profPic;
  final String? coverPic;
  final String? bio;

  Profile({required this.id, this.profPic, this.bio, this.coverPic});

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
        id: json['id'],
        profPic: json['profPic'],
        bio: json['bio'],
        coverPic: json['coverPic']);
  }
}
