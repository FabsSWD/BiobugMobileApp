class MockConstants {
  static const bool useMockData = true; // ← Cambiar a false para usar backend real
  
  static const String mockEmail = 'admin@biobug.com';
  static const String mockPassword = 'Admin123';
  static const String mockCedula = '123456789';
  
  static const mockUserData = {
    'userId': 'mock-user-id-123',
    'idType': 1,
    'identification': 123456789,
    'fullName': 'Usuario de Prueba',
    'email': 'admin@biobug.com',
  };
  
  static const String mockAccessToken = 'mock.jwt.access.token.for.testing.purposes.only';
  static const String mockRefreshToken = 'mock.jwt.refresh.token.for.testing.purposes.only';
  static const int mockTokenExpiration = 3600; // 1 hora
  
  static const Duration mockNetworkDelay = Duration(milliseconds: 500);
  static const Duration mockSlowNetworkDelay = Duration(seconds: 2);
  
  static const String mockLoginSuccessMessage = '✅ Login exitoso (MODO MOCK)';
  static const String mockRegisterSuccessMessage = '✅ Registro exitoso (MODO MOCK)';
  static const String mockInvalidCredentialsMessage = '❌ Credenciales incorrectas (MODO MOCK)';

  static const bool simulateSlowNetwork = false; // Para probar loading states
  static const bool simulateNetworkErrors = false; // Para probar error handling
  static const double errorProbability = 0.1; // 10% chance de error simulado
}