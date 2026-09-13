import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ═══════════════ تسجيل بالبريد وكلمة المرور ═══════════════
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

  // ═══════════════ تسجيل بـ Google ═══════════════
  Future<String?> signInWithGoogle() async {
    try {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider.setCustomParameters({'prompt': 'select_account'});
      googleProvider.addScope('email');
      googleProvider.addScope('profile');

      if (kIsWeb) {
        // على الويب: نافذة منبثقة
        await _auth.signInWithPopup(googleProvider);
      } else {
        // على Android/iOS
        await _auth.signInWithProvider(googleProvider);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return _errorMessage(e.code);
    } catch (e) {
      return 'تعذر تسجيل الدخول بـ Google: ${e.toString()}';
    }
  }

  // ═══════════════ تسجيل الخروج ═══════════════
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ═══════════════ رسائل الأخطاء ═══════════════
  String _errorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'لا يوجد حساب بهذا البريد';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'email-already-in-use':
        return 'البريد مسجل بالفعل';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صالح';
      case 'weak-password':
        return 'كلمة المرور ضعيفة (6 أحرف على الأقل)';
      case 'user-disabled':
        return 'هذا الحساب معطّل';
      case 'too-many-requests':
        return 'محاولات كثيرة، حاول لاحقًا';
      case 'popup-closed-by-user':
        return 'تم إغلاق نافذة Google';
      case 'popup-blocked':
        return 'المتصفح منع النافذة المنبثقة';
      case 'network-request-failed':
        return 'تحقق من اتصال الإنترنت';
      case 'unauthorized-domain':
        return 'النطاق غير مصرح به في Firebase';
      case 'operation-not-allowed':
        return 'هذه الطريقة غير مفعّلة في Firebase';
      case 'account-exists-with-different-credential':
        return 'هذا البريد مسجل بطريقة أخرى';
      case 'cancelled':
        return 'تم إلغاء تسجيل الدخول';
      case 'invalid-credential':
        return 'بيانات الدخول غير صحيحة';
      default:
        return 'خطأ: $code';
    }
  }
}
