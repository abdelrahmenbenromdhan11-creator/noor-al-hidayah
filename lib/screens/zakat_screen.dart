import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../i18n/language_manager.dart';

class ZakatScreen extends StatefulWidget {
  const ZakatScreen({super.key});
  @override
  State<ZakatScreen> createState() => _ZakatScreenState();
}

class _ZakatScreenState extends State<ZakatScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  final _cashCtrl = TextEditingController();
  final _goldCtrl = TextEditingController();
  final _silverCtrl = TextEditingController();
  final _investCtrl = TextEditingController();
  final _debtCtrl = TextEditingController();
  double _zakat = 0;
  bool _calculated = false;
  final double _goldPricePerGram = 280.0;
  final double _silverPricePerGram = 3.5;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    _cashCtrl.dispose();
    _goldCtrl.dispose();
    _silverCtrl.dispose();
    _investCtrl.dispose();
    _debtCtrl.dispose();
    super.dispose();
  }

  void _calculate() {
    final cash = double.tryParse(_cashCtrl.text) ?? 0;
    final goldGrams = double.tryParse(_goldCtrl.text) ?? 0;
    final silverGrams = double.tryParse(_silverCtrl.text) ?? 0;
    final investments = double.tryParse(_investCtrl.text) ?? 0;
    final debts = double.tryParse(_debtCtrl.text) ?? 0;
    final total = cash + (goldGrams * _goldPricePerGram) +
        (silverGrams * _silverPricePerGram) + investments - debts;
    final nisab = 85 * _goldPricePerGram;
    setState(() {
      _zakat = total >= nisab ? total * 0.025 : 0;
      _calculated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LanguageManager.currentLanguage,
      builder: (context, lang, _) {
        final isAr = lang == 'ar';
        return Directionality(
          textDirection: LanguageManager.isRTL() ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: const Color(0xFF143B32),
              title: Text(
                LanguageManager.t('zakat_calculator'),
                style: GoogleFonts.cairo(color: const Color(0xFFD4AF37)),
              ),
              centerTitle: true,
              iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
            ),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildInfoCard(isAr),
                const SizedBox(height: 24),
                _buildSectionTitle(isAr ? 'أموالك' : 'Your Wealth', Icons.account_balance_wallet),
                const SizedBox(height: 12),
                _inputField(LanguageManager.t('cash_savings'), _cashCtrl, Icons.attach_money, LanguageManager.t('dirham_unit')),
                _inputField(LanguageManager.t('gold_grams'), _goldCtrl, Icons.workspace_premium, LanguageManager.t('gram_unit')),
                _inputField(LanguageManager.t('silver_grams'), _silverCtrl, Icons.circle_outlined, LanguageManager.t('gram_unit')),
                _inputField(LanguageManager.t('investments'), _investCtrl, Icons.trending_up, LanguageManager.t('dirham_unit')),
                _inputField(LanguageManager.t('debts'), _debtCtrl, Icons.receipt_long, LanguageManager.t('dirham_unit')),
                const SizedBox(height: 16),
                _buildCalculateButton(),
                if (_calculated) ...[
                  const SizedBox(height: 24),
                  _buildResultCard(isAr),
                ],
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(bool isAr) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glow = _glowController.value;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.lerp(const Color(0xFF1E4D40), const Color(0xFF2B6E5C), glow * 0.5)!,
                const Color(0xFF0B2B26),
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Color.lerp(const Color(0xFFD4AF37), const Color(0xFFFFE9A8), glow)!,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withOpacity(0.15 + 0.2 * glow),
                blurRadius: 15 + 10 * glow,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Color.lerp(const Color(0xFFD4AF37), const Color(0xFFFFE9A8), glow)!,
                      const Color(0xFFB8860B),
                    ],
                  ),
                ),
                child: const Icon(Icons.calculate, color: Color(0xFF0B2B26), size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                LanguageManager.t('zakat_formula'),
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                LanguageManager.t('zakat_nisab_note'),
                style: GoogleFonts.cairo(color: Colors.white54, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFD4AF37).withOpacity(0.15),
          ),
          child: Icon(icon, color: const Color(0xFFD4AF37), size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.cairo(
            color: const Color(0xFFD4AF37),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _inputField(String label, TextEditingController ctrl, IconData icon, String suffix) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.cairo(color: Colors.white70, fontSize: 14),
          suffixText: suffix,
          suffixStyle: GoogleFonts.cairo(color: const Color(0xFFD4AF37)),
          prefixIcon: Icon(icon, color: const Color(0xFFD4AF37), size: 22),
          filled: true,
          fillColor: const Color(0xFF143B32),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: const Color(0xFFD4AF37).withOpacity(0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 1.8),
          ),
        ),
      ),
    );
  }

  Widget _buildCalculateButton() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glow = _glowController.value;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _calculate,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFD4AF37),
                    Color.lerp(const Color(0xFFE8C766), const Color(0xFFFFE9A8), glow)!,
                    const Color(0xFFD4AF37),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD4AF37).withOpacity(0.3 + 0.3 * glow),
                    blurRadius: 15 + 8 * glow,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.calculate, color: Color(0xFF0B2B26), size: 22),
                  const SizedBox(width: 10),
                  Text(
                    LanguageManager.t('calculate_zakat'),
                    style: GoogleFonts.cairo(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0B2B26),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultCard(bool isAr) {
    final isNotReached = _zakat == 0;
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glow = _glowController.value;
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E4D40), Color(0xFF0B2B26)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Color.lerp(const Color(0xFFD4AF37), const Color(0xFFFFE9A8), glow)!,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withOpacity(0.2 + 0.3 * glow),
                blurRadius: 20 + 10 * glow,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFD4AF37).withOpacity(0.2),
                ),
                child: const Icon(Icons.volunteer_activism, color: Color(0xFFD4AF37), size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                LanguageManager.t('total_zakat_due'),
                style: GoogleFonts.cairo(color: Colors.white70, fontSize: 15),
              ),
              const SizedBox(height: 10),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFFB8860B), Color(0xFFFFE9A8), Color(0xFFD4AF37), Color(0xFFFFE9A8)],
                ).createShader(bounds),
                child: Text(
                  '${_zakat.toStringAsFixed(2)} ${LanguageManager.t('dirham_unit')}',
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isNotReached
                    ? LanguageManager.t('not_reached_nisab')
                    : LanguageManager.t('jazak_allah'),
                style: GoogleFonts.cairo(
                  color: isNotReached ? Colors.redAccent : Colors.greenAccent,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
