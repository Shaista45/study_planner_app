import 'package:encrypt/encrypt.dart' as enc;

class EncryptionService {
  // 🚨 CRITICAL: In a production app, never hardcode your key.
  // For your university project, a 32-character fixed string acts as our 256-bit AES key.
  static final _key = enc.Key.fromUtf8('my32charactersecretkeyforuetksk!');

  // An Initialization Vector (IV) adds randomized uniqueness to the encryption block
  static final _iv = enc.IV.fromUtf8('16byteslongiv123');

  static final _encrypter = enc.Encrypter(enc.AES(_key, mode: enc.AESMode.cbc));

  /// Encrypts plain text into a secure Base64 Ciphertext string
  static String encrypt(String text) {
    if (text.isEmpty) return text;
    final encrypted = _encrypter.encrypt(text, iv: _iv);
    return encrypted.base64;
  }

  /// Decrypts a secure Base64 Ciphertext string back into plain English
  static String decrypt(String ciphertext) {
    if (ciphertext.isEmpty) return ciphertext;
    try {
      return _encrypter.decrypt64(ciphertext, iv: _iv);
    } catch (e) {
      // If the text isn't encrypted yet (old data), return it as-is safely
      return ciphertext;
    }
  }
}
