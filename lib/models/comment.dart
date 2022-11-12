import 'dart:convert';
import 'dart:io';

class Comment {
  final int commentId;
  final String commentText;
  final int commentLikeCount;
  final int authorId;
  final String authorName;
  final String? authorImage;
  final bool isLike;

  Comment(this.commentId, this.commentText, this.commentLikeCount,
      this.authorId, this.authorName, this.authorImage, this.isLike);

  factory Comment.fromJson(Map<String, dynamic> json) {
    String? image = json['authorImage'];

    return Comment(
      json['commentId'] as int,
      json['commentText'] as String,
      json['commentLikeCount'] as int,
      json['authorId'] as int,
      json['authorName'] as String,
      image,
      json['isLike'] as bool);
  }

  // comment -> Json 변환
  Map<String, dynamic> toJson() => {
        'commentId': commentId,
        'commentText': commentText,
        'commentLikeCount': commentLikeCount,
        'authorId': authorId,
        'authorName': authorName,
        'authorImage': authorImage,
        'isLike': isLike
      };

  @override
  String toString() {
    return '{ ${this.commentId}, ${this.commentText}, ${this.commentLikeCount}, ${this.authorId}, ${this.authorName}, ${this.authorImage}, ${this.isLike}}';
  }
}
