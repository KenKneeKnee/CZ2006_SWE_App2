class Review {
  // assume no image
  final String title;
  final int rating;
  final String desc;
  final String user;

  Review(this.title, this.rating, this.desc, this.user);

  Map<String, Object> toJson() {
    return {
      'title': title,
      'rating': rating,
      'desc': desc,
      'user': user,
    };
  }

}

Review ReviewFromJson(Map<String, dynamic> json) {
  return Review(
    json['title'] as String,
    json['rating'] as int,
    json['desc'] as String,
    json['user'] as String,
  );
}


