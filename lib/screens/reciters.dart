class Reciter {
  final String id;
  final String name;
  final String arabic;
  final String country;
  const Reciter({required this.id, required this.name, required this.arabic, required this.country});
}

const List<Reciter> allReciters = [
  Reciter(id: 'ar.alafasy', name: 'Mishary Alafasy', arabic: 'مشاري العفاسي', country: 'الكويت'),
  Reciter(id: 'ar.mahermuaiqly', name: 'Maher Al-Muaiqly', arabic: 'ماهر المعيقلي', country: 'السعودية'),
  Reciter(id: 'ar.husary', name: 'Mahmoud Khalil Al-Husary', arabic: 'محمود خليل الحصري', country: 'مصر'),
  Reciter(id: 'ar.minshawi', name: 'Mohamed Siddiq Al-Minshawi', arabic: 'محمد صديق المنشاوي', country: 'مصر'),
  Reciter(id: 'ar.shaatree', name: 'Abu Bakr Al-Shatri', arabic: 'أبو بكر الشاطري', country: 'السعودية'),
  Reciter(id: 'ar.ahmedajamy', name: 'Ahmed Al-Ajamy', arabic: 'أحمد بن علي العجمي', country: 'السعودية'),
  Reciter(id: 'ar.abdullahbasfar', name: 'Abdullah Basfar', arabic: 'عبد الله بصفر', country: 'السعودية'),
  Reciter(id: 'ar.hudhaify', name: 'Ali Al-Hudhaify', arabic: 'علي الحذيفي', country: 'السعودية'),
  Reciter(id: 'ar.hanirifai', name: 'Hani Ar-Rifai', arabic: 'هاني الرفاعي', country: 'السعودية'),
  Reciter(id: 'ar.aymanswoaid', name: 'Ayman Sowaid', arabic: 'أيمن سويد', country: 'سوريا'),
  Reciter(id: 'ar.abdulsamad', name: 'Abdul Samad', arabic: 'عبد الصمد', country: 'مصر'),
  Reciter(id: 'ar.yasseraldossari', name: 'Yasser Al-Dosari', arabic: 'ياسر الدوسري', country: 'السعودية'),
  Reciter(id: 'ar.faresabbad', name: 'Fares Abbad', arabic: 'فارس عباد', country: 'اليمن'),
];

// هؤلاء يستخدمون صوت السورة كاملة من mp3quran.net (وليس آية بآية)
const Map<String, String> fullSurahSources = {
  'ar.yasseraldossari': 'https://server11.mp3quran.net/yasser',
  'ar.faresabbad': 'https://server8.mp3quran.net/frs_a',
  'ar.minshawi': 'https://server10.mp3quran.net/minsh',
  'ar.alafasy': 'https://server8.mp3quran.net/afs',
};
