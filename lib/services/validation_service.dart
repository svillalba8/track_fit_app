class ValidationService {
  static bool isSameString(String text1, String text2) {
    return text1 == text2;
  }

  static bool isCorrectFormat(String text, TextFormat format) {
    try {
      switch (format) {
        case TextFormat.email:
          final emailRegex = RegExp(
              r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$'
          );
          return emailRegex.hasMatch(text);

        case TextFormat.phone:
          final phoneRegex = RegExp(r'^(\+34\s?)?[6-7]\d{2}\s?\d{3}\s?\d{3}$');
          return phoneRegex.hasMatch(text);

        case TextFormat.password:
          final passwordRegex = RegExp(
              r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&.])[A-Za-z\d@$!%*?&.]{8,}$'
          );
          return passwordRegex.hasMatch(text);

        case TextFormat.url:
          final urlRegex = RegExp(
            r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
            caseSensitive: false,
          );
          return urlRegex.hasMatch(text);

        case TextFormat.date:
          final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
          return dateRegex.hasMatch(text);

        case TextFormat.time:
          final timeRegex = RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$');
          return timeRegex.hasMatch(text);

        case TextFormat.numeric:
          return double.tryParse(text) != null;

        case TextFormat.alphanumeric:
          return RegExp(r'^[a-zA-Z0-9]+$').hasMatch(text);
      }
    } catch (e) {
      return false;
    }
  }
}

enum TextFormat {
  email,
  phone,
  password,
  url,
  date,
  time,
  numeric,
  alphanumeric,
}
