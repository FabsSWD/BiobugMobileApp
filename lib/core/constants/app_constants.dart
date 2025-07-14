class AppConstants {
  static const String appName = 'BIOBUG';
  static const String appVersion = '1.0.0';
  
  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 50;
  static const int maxNameLength = 100;
  
  // Signature
  static const int signatureMinResolutionWidth = 300;
  static const int signatureMinResolutionHeight = 150;
  static const int signatureMaxFileSize = 51200; // 50KB
  
  // File paths
  static const String imagesPath = 'images';
  static const String signaturesPath = 'signatures';
  static const String documentsPath = 'documents';
  
  // Date formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm:ss';
  static const String apiDateFormat = 'yyyy-MM-ddTHH:mm:ss.SSSZ';
}