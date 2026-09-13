import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<String?> signInWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _errorMessage(e.code);
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> signUpWithEmail(String name, String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await cred.user?.updateDisplayName(name);
      await cred.user?.reload();
      return null;
    } on FirebaseAuthException catch (e) {
      return _errorMessage(e.code);
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> signInWithGoogle() async {
    try {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider.setCustomParameters({'prompt': 'select_account'});
      
      // استخدام signInWithPopup مباشرة على الويب لتجنب مشاكل التهيئة
      await _auth.signInWithPopup(googleProvider);
      return null;
    } on FirebaseAuthException catch (e) {
      return _errorMessage(e.code);
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  String _errorMessage(String code) {
    switch (code) {
      case 'user-not-found': return 'لا يوجد حساب بهذا البريد';
      case 'wrong-password': return 'كلمة المرور غير صحيحة';
      case 'email-already-in-use': return 'البريد مسجل بالفعل';
      case 'invalid-email': return 'البريد الإلكتروني غير صالح';
      case 'weak-password': return 'كلمة المرور ضعيفة (6 أحرف على الأقل)';
      case 'user-disabled': return 'هذا الحساب معطّل';
      case 'too-many-requests': return 'محاولات كثيرة، حاول لاحقًا';
      case 'popup-closed-by-user': return 'تم إغلاق نافذة Google';
      case 'network-request-failed': return 'تحقق من اتصال الإنترنت';
      case 'unauthorized-domain': return 'النطاق غير مصرح به في Firebase';
      default: return 'خطأ: $code';
    }
  }
}
