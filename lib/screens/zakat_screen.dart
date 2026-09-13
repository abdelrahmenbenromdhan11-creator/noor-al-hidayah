import 'package:flutter/material.dart';
import '../i18n/language_manager.dart';

class ZakatScreen extends StatefulWidget {
  const ZakatScreen({super.key});
  @override
  State<ZakatScreen> createState() => _ZakatScreenState();
}

class _ZakatScreenState extends State<ZakatScreen> {
  final _cashCtrl = TextEditingController();
  final _goldCtrl = TextEditingController();
  final _silverCtrl = TextEditingController();
  final _investCtrl = TextEditingController();
  final _debtCtrl = TextEditingController();
  double _zakat = 0;
  bool _calculated = false;
  final double _goldPricePerGram = 280.0;
  final double _silverPricePerGram = 3.5;

  void _calculate() {
    final cash = double.tryParse(_cashCtrl.text) ?? 0;
    final goldGrams = double.tryParse(_goldCtrl.text) ?? 0;
    final silverGrams = double.tryParse(_silverCtrl.text) ?? 0;
    final investments = double.tryParse(_investCtrl.text) ?? 0;
    final debts = double.tryParse(_debtCtrl.text) ?? 0;
    final total = cash + (goldGrams * _goldPricePerGram) + (silverGrams * _silverPricePerGram) + investments - debts;
    final nisab = 85 * _goldPricePerGram;
    setState(() {
      _zakat = total >= nisab ? total * 0.025 : 0;
      _calculated = true;
    });
  }

  Widget _input(String label, TextEditingController ctrl, IconData icon, String suffix) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          suffixText: suffix,
          suffixStyle: const TextStyle(color: Color(0xFFD4AF37)),
          prefixIcon: Icon(icon, color: const Color(0xFFD4AF37)),
          filled: true,
          fillColor: const Color(0xFF143B32),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFD4AF37))),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LanguageManager.currentLanguage,
      builder: (context, lang, _) => Scaffold(
        backgroundColor: const Color(0xFF0B2B26),
        appBar: AppBar(
          backgroundColor: const Color(0xFF143B32),
          title: Text(LanguageManager.t('zakat_calculator'), style: const TextStyle(color: Color(0xFFD4AF37))),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E4D40),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.5)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.calculate, color: Color(0xFFD4AF37), size: 40),
                  const SizedBox(height: 8),
                  Text(LanguageManager.t('zakat_formula'),
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 4),
                  Text(LanguageManager.t('zakat_nisab_note'),
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                      textAlign: TextAlign.center),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _input(LanguageManager.t('cash_savings'), _cashCtrl, Icons.attach_money, LanguageManager.t('dirham_unit')),
            _input(LanguageManager.t('gold_grams'), _goldCtrl, Icons.workspace_premium, LanguageManager.t('gram_unit')),
            _input(LanguageManager.t('silver_grams'), _silverCtrl, Icons.circle_outlined, LanguageManager.t('gram_unit')),
            _input(LanguageManager.t('investments'), _investCtrl, Icons.trending_up, LanguageManager.t('dirham_unit')),
            _input(LanguageManager.t('debts'), _debtCtrl, Icons.receipt_long, LanguageManager.t('dirham_unit')),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _calculate,
              icon: const Icon(Icons.calculate),
              label: Text(LanguageManager.t('calculate_zakat'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: const Color(0xFF0B2B26),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            if (_calculated) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E4D40), Color(0xFF0B2B26)],
                    begin: Alignment.topRight, end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFD4AF37), width: 2),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.volunteer_activism, color: Color(0xFFD4AF37), size: 40),
                    const SizedBox(height: 12),
                    Text(LanguageManager.t('total_zakat_due'),
                        style: const TextStyle(color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text('${_zakat.toStringAsFixed(2)} ${LanguageManager.t('dirham_unit')}',
                        style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 32, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(_zakat == 0 ? LanguageManager.t('not_reached_nisab') : LanguageManager.t('jazak_allah'),
                        style: const TextStyle(color: Colors.white54, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
