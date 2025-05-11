class MovieReview {
  final int userId;
  final String username;
  final String userName;
  final double rating;
  final String description;
  final int? timestamp;

  MovieReview({
    required this.userId,
    required this.username,
    required this.userName,
    required this.rating,
    required this.description,
    this.timestamp,
  });

  factory MovieReview.fromJson(Map<String, dynamic> json) {
    return MovieReview(
      userId: json['user_id'],
      username: json['username'],
      userName: json['user_name'],
      rating: json['rating'].toDouble(),
      description: json['description'],
      timestamp: json['timestamp'],
    );
  }
}

class MovieReviewsResponse {
  final int movieId;
  final String movieTitle;
  final int totalReviews;
  final double averageRating;
  final List<MovieReview> latestReviews;

  MovieReviewsResponse({
    required this.movieId,
    required this.movieTitle,
    required this.totalReviews,
    required this.averageRating,
    required this.latestReviews,
  });

  factory MovieReviewsResponse.fromJson(Map<String, dynamic> json) {
    return MovieReviewsResponse(
      movieId: json['movie_id'],
      movieTitle: json['movie_title'],
      totalReviews: json['total_reviews'],
      averageRating: json['average_rating'].toDouble(),
      latestReviews: (json['latest_reviews'] as List)
          .map((review) => MovieReview.fromJson(review))
          .toList(),
    );
  }
} 