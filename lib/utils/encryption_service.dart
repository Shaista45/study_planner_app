import 'package:encrypt/encrypt.dart' as enc;

class EncryptionService {
  // 32-character Secret Key
  static final _key = enc.Key.fromUtf8('SmartStudyPlannerSecretKey123456');
  // 16-character IV (HARDCODED to prevent Web memory bugs!)
  static final _iv = enc.IV.fromUtf8('SmartStudyIV1234');

  static final _encrypter = enc.Encrypter(enc.AES(_key));

  static String encrypt(String? plainText) {
    if (plainText == null || plainText.isEmpty) return '';
    try {
      final encrypted = _encrypter.encrypt(plainText, iv: _iv);
      return encrypted.base64;
    } catch (e) {
      print("🔒 ENCRYPTION ERROR: $e");
      return plainText;
    }
  }

  static String decrypt(String? encryptedText) {
    if (encryptedText == null || encryptedText.isEmpty) return '';
    try {
      return _encrypter.decrypt64(encryptedText, iv: _iv);
    } catch (e) {
      // 🚨 If this prints in your console, the data is permanently broken!
      print("❌ DECRYPTION FAILED FOR '$encryptedText': $e");
      return encryptedText;
    }
  }
}
