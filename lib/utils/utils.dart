import 'dart:convert';

final class Utils {
  const Utils._();

  static Map<String, dynamic> castToJsonMap(dynamicObject) {
    try {
      return dynamicObject as Map<String, dynamic>;
    } catch (_) {
      try {
        return jsonDecode(dynamicObject) as Map<String, dynamic>;
      } catch (_) {
        return {};
      }
    }
  }

  static List<Map<String, dynamic>> castToJsonMapList(dynamicObject) {
    try {
      return dynamicObject as List<Map<String, dynamic>>;
    } catch (_) {
      try {
        return jsonDecode(dynamicObject) as List<Map<String, dynamic>>;
      } catch (_) {
        return [];
      }
    }
  }

  static List<dynamic> castToJsonList(dynamicObject) {
    try {
      return dynamicObject as List<dynamic>;
    } catch (_) {
      try {
        return jsonDecode(dynamicObject) as List<dynamic>;
      } catch (_) {
        return [];
      }
    }
  }

  static T safeCast<T>(dynamicObject, {required T defaultValue}) {
    return dynamicObject is T ? dynamicObject : defaultValue;
  }

  static T? castOrNull<T>(dynamicObject) {
    return dynamicObject is T ? dynamicObject : null;
  }
}
