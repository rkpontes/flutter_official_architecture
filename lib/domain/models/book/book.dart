class Book {
  String? id;
  String? createdAt;
  String? title;
  String? image;
  String? resume;
  String? slug;

  Book({
    this.id,
    this.createdAt,
    this.title,
    this.image,
    this.resume,
    this.slug,
  });

  Book.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['createdAt'];
    title = json['title'];
    image = json['image'];
    resume = json['resume'];
    slug = json['slug'];
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "createdAt": createdAt,
      "title": title,
      "image": image,
      "resume": resume,
      "slug": slug,
    };
  }
}
