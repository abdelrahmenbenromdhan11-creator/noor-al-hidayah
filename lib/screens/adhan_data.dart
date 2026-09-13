class AdhanSound {
  final String id;
  final String name;
  final String arabic;
  final String url;
  const AdhanSound({required this.id, required this.name, required this.arabic, required this.url});
}

const List<AdhanSound> allAdhanSounds = [
  AdhanSound(id: 'makkah', name: 'Makkah', arabic: 'أذان الحرم المكي', url: 'https://www.islamcan.com/audio/adhan/azan1.mp3?v=2'),
  AdhanSound(id: 'madinah', name: 'Madinah', arabic: 'أذان الحرم النبوي', url: 'https://www.islamcan.com/audio/adhan/azan2.mp3?v=2'),
  AdhanSound(id: 'egypt', name: 'Egypt', arabic: 'أذان مصري', url: 'https://www.islamcan.com/audio/adhan/azan3.mp3?v=2'),
  AdhanSound(id: 'turkey', name: 'Turkey', arabic: 'أذان تركي', url: 'https://www.islamcan.com/audio/adhan/azan4.mp3?v=2'),
  AdhanSound(id: 'abdulbasit', name: 'Abdul Basit', arabic: 'أذان عبد الباسط', url: 'https://www.islamcan.com/audio/adhan/azan5.mp3?v=2'),
  AdhanSound(id: 'mishary', name: 'Mishary', arabic: 'أذان مشاري العفاسي', url: 'https://www.islamcan.com/audio/adhan/azan6.mp3?v=2'),
  AdhanSound(id: 'sudais', name: 'Sudais', arabic: 'أذان السديس', url: 'https://www.islamcan.com/audio/adhan/azan7.mp3?v=2'),
  AdhanSound(id: 'ali', name: 'Ali', arabic: 'أذان علي أحمد ملا', url: 'https://www.islamcan.com/audio/adhan/azan8.mp3?v=2'),
  AdhanSound(id: 'rahman', name: 'Rahman', arabic: 'أذان عبد الرحمن', url: 'https://www.islamcan.com/audio/adhan/azan9.mp3?v=2'),
  AdhanSound(id: 'fajr', name: 'Fajr Special', arabic: 'أذان الفجر', url: 'https://www.islamcan.com/audio/adhan/azan10.mp3?v=2'),
];
