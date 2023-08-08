extension ObjectsExtensions on Object {
  /// Throws this object with associated stack trace [stackTrace].
  ///
  /// Behaves like `throw error` would
  /// if the [current stack trace][StackTrace.current] was [stackTrace]
  /// at the time of the `throw`.
  ///
  /// Like for a `throw`, if this object extends [Error], and it has not been
  /// thrown before, its [Error.stackTrace] property will be set to
  /// the [stackTrace].
  ///
  /// This function does not guarantee to preserve the identity of [stackTrace].
  /// The [StackTrace] object that is caught by a `try`/`catch` of
  /// this error, or which is set as the [Error.stackTrace] of an [error],
  /// may not be the same [stackTrace] object provided as argument,
  /// but it will have the same contents according to [StackTrace.toString].
  Never throwWithStackTrace(StackTrace stackTrace) {
    return Error.throwWithStackTrace(this, stackTrace);
  }

}

extension IterableExtension<E> on Iterable<E> {
  List<T> mapToList<T>(T Function(E e) toElement) => map(toElement).toList();
}

extension StringExtension on String {
  static const diacritics =
      'ÀÁÂÃÄÅàáâãäåÒÓÔÕÕÖØòóôõöøÈÉÊËĚèéêëěðČÇçčÐĎďÌÍÎÏìíîïĽľÙÚÛÜŮùúûüůŇÑñňŘřŠšŤťŸÝÿýŽž';
  static const nonDiacritics =
      'AAAAAAaaaaaaOOOOOOOooooooEEEEEeeeeeeCCccDDdIIIIiiiiLlUUUUUuuuuuNNnnRrSsTtYYyyZz';

  String get withoutDiacriticalMarks => splitMapJoin(
        '',
        onNonMatch: (char) => char.isNotEmpty && diacritics.contains(char)
            ? nonDiacritics[diacritics.indexOf(char)]
            : char,
      );
}
