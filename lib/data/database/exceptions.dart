class DatabaseException implements Exception {
  const DatabaseException({
    this.message,
    this.code,
  });

  final String? message;
  final String? code;

  @override
  String toString() {
    return "DatabaseException($code): $message";
  }
}

class DatabaseNotFoundException extends DatabaseException {
  const DatabaseNotFoundException({String? message})
      : super(
          message: "Could not find the queried data: $message",
          code: "database_not_found",
        );
}
