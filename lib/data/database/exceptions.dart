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

class DatabaseInsertException extends DatabaseException {
  const DatabaseInsertException({String? message})
      : super(
          message: "Could not insert data to the database: $message",
          code: "database_insert_failure",
        );
}

class DatabaseMappingException extends DatabaseException {
  const DatabaseMappingException({String? message})
      : super(
          message: "Could not map the entity to the domain model: $message",
          code: "database_mapping_failure",
        );
}
