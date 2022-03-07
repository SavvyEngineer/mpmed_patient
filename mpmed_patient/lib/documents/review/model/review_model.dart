class ReviewModel {
  int? reviewId;
  String? content;
  String? time;
  String? doctorId;
  int? doctorAnswer;
  int? userAnswer;

  ReviewModel(
      {this.reviewId,
      this.content,
      this.time,
      this.doctorId,
      this.doctorAnswer,
      this.userAnswer});
}
