class RepositoryResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final Exception? error;

  RepositoryResponse({
    required this.success,
    this.message,
    this.data,
    this.error,
  });

  factory RepositoryResponse.success(T data, {String? message}) {
    return RepositoryResponse(
      success: true,
      data: data,
      message: message,
    );
  }

  factory RepositoryResponse.error(String message, {Exception? error}) {
    return RepositoryResponse(
      success: false,
      message: message,
      error: error,
    );
  }
}