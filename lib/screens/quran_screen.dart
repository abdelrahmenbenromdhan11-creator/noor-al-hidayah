import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'quran_detail_screen.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});
  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  List<dynamic> _surahs = [];
  List<dynamic> _filtered = [];
  bool _loading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSurahs();
  }

  Future<void> _loadSurahs() async {
    try {
      final res = await http.get(Uri.parse('https://api.alquran.cloud/v1/surah'));
      final data = json.decode(res.body)['data'];
      setState(() {
        _surahs = data;
        _filtered = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _filter(String q) {
    setState(() {
      _filtered = _surahs.where((s) =>
          s['englishName'].toString().toLowerCase().contains(q.toLowerCase()) ||
          s['number'].toString().contains(q) ||
          s['name'].toString().contains(q)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            onChanged: _filter,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'ابحث عن سورة...',
              hintStyle: const TextStyle(color: Colors.white54),
              prefixIcon: const Icon(Icons.search, color: Color(0xFFD4AF37)),
              filled: true,
              fillColor: const Color(0xFF143B32),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
              : ListView.builder(
                  itemCount: _filtered.length,
                  itemBuilder: (context, i) {
                    final s = _filtered[i];
                    return ListTile(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QuranDetailScreen(
                            surahNumber: s['number'],
                            surahName: s['name'],
                            surahEnglish: s['englishName'],
                          ),
                        ),
                      ),
                      leading: Container(
                        width: 45, height: 45,
                        decoration: BoxDecoration(
                          color: const Color(0xFF143B32),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
                        ),
                        child: Center(
                          child: Text('${s['number']}',
                              style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
                        ),
                      ),
                      title: Text(s['name'], style: const TextStyle(color: Colors.white, fontSize: 18)),
                      subtitle: Text('${s['englishName']} • ${s['numberOfAyahs']} آية',
                          style: const TextStyle(color: Colors.white54, fontSize: 13)),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFFD4AF37), size: 16),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
