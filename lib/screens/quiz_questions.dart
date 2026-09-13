class QuizQuestion {
  final String qAr;
  final String qEn;
  final List<String> optsAr;
  final List<String> optsEn;
  final int correct;
  const QuizQuestion({required this.qAr, required this.qEn, required this.optsAr, required this.optsEn, required this.correct});
}

const List<QuizQuestion> allQuizQuestions = [
  QuizQuestion(qAr: 'كم عدد سور القرآن الكريم؟', qEn: 'How many Surahs in the Quran?', optsAr: ['100', '114', '120'], optsEn: ['100', '114', '120'], correct: 1),
  QuizQuestion(qAr: 'ما هي أطول سورة في القرآن؟', qEn: 'Longest Surah in Quran?', optsAr: ['آل عمران', 'البقرة', 'النساء'], optsEn: ['Al-Imran', 'Al-Baqarah', 'An-Nisa'], correct: 1),
  QuizQuestion(qAr: 'ما هي أقصر سورة في القرآن؟', qEn: 'Shortest Surah in Quran?', optsAr: ['الإخلاص', 'الكوثر', 'الناس'], optsEn: ['Al-Ikhlas', 'Al-Kawthar', 'An-Nas'], correct: 1),
  QuizQuestion(qAr: 'كم عدد أجزاء القرآن الكريم؟', qEn: 'How many Juz in the Quran?', optsAr: ['20', '30', '40'], optsEn: ['20', '30', '40'], correct: 1),
  QuizQuestion(qAr: 'ما هي السورة التي تسمى "قلب القرآن"؟', qEn: 'Which Surah is "Heart of Quran"?', optsAr: ['يس', 'الرحمن', 'الكهف'], optsEn: ['Ya-Sin', 'Ar-Rahman', 'Al-Kahf'], correct: 0),
  QuizQuestion(qAr: 'ما هي السورة التي لا تبدأ بالبسملة؟', qEn: 'Surah without Bismillah?', optsAr: ['التوبة', 'الفاتحة', 'الناس'], optsEn: ['At-Tawbah', 'Al-Fatihah', 'An-Nas'], correct: 0),
  QuizQuestion(qAr: 'ما هي السورة التي تُسمى "أم الكتاب"؟', qEn: 'Which Surah is "Mother of Book"?', optsAr: ['البقرة', 'الفاتحة', 'يس'], optsEn: ['Al-Baqarah', 'Al-Fatihah', 'Ya-Sin'], correct: 1),
  QuizQuestion(qAr: 'كم عدد آيات سورة الفاتحة؟', qEn: 'How many verses in Al-Fatihah?', optsAr: ['5', '7', '10'], optsEn: ['5', '7', '10'], correct: 1),
  QuizQuestion(qAr: 'في أي سورة توجد آية الكرسي؟', qEn: 'Which Surah has Ayat al-Kursi?', optsAr: ['آل عمران', 'البقرة', 'النساء'], optsEn: ['Al-Imran', 'Al-Baqarah', 'An-Nisa'], correct: 1),
  QuizQuestion(qAr: 'كم عدد الصلوات المفروضة في اليوم؟', qEn: 'How many obligatory prayers daily?', optsAr: ['ثلاث', 'خمس', 'سبع'], optsEn: ['Three', 'Five', 'Seven'], correct: 1),
  QuizQuestion(qAr: 'كم عدد ركعات صلاة الفجر؟', qEn: 'Rakats in Fajr prayer?', optsAr: ['2', '3', '4'], optsEn: ['2', '3', '4'], correct: 0),
  QuizQuestion(qAr: 'كم عدد ركعات صلاة المغرب؟', qEn: 'Rakats in Maghrib?', optsAr: ['2', '3', '4'], optsEn: ['2', '3', '4'], correct: 1),
  QuizQuestion(qAr: 'كم عدد ركعات صلاة العشاء؟', qEn: 'Rakats in Isha?', optsAr: ['2', '3', '4'], optsEn: ['2', '3', '4'], correct: 2),
  QuizQuestion(qAr: 'ما هي القبلة التي يتوجه إليها المسلمون؟', qEn: 'What is the Qibla direction?', optsAr: ['المسجد الأقصى', 'الكعبة', 'المسجد النبوي'], optsEn: ['Al-Aqsa', 'Kaaba', 'Prophet Mosque'], correct: 1),
  QuizQuestion(qAr: 'في أي مدينة تقع الكعبة المشرفة؟', qEn: 'Where is the Kaaba located?', optsAr: ['المدينة', 'مكة', 'الطائف'], optsEn: ['Madinah', 'Makkah', 'Taif'], correct: 1),
  QuizQuestion(qAr: 'كم عدد أركان الإسلام؟', qEn: 'How many pillars of Islam?', optsAr: ['أربعة', 'خمسة', 'ستة'], optsEn: ['Four', 'Five', 'Six'], correct: 1),
  QuizQuestion(qAr: 'كم عدد أركان الإيمان؟', qEn: 'How many pillars of Iman?', optsAr: ['خمسة', 'ستة', 'سبعة'], optsEn: ['Five', 'Six', 'Seven'], correct: 1),
  QuizQuestion(qAr: 'ما هو الركن الأول من أركان الإسلام؟', qEn: 'First pillar of Islam?', optsAr: ['الصلاة', 'الشهادتان', 'الزكاة'], optsEn: ['Prayer', 'Shahada', 'Zakat'], correct: 1),
  QuizQuestion(qAr: 'ما هو الركن الخامس من أركان الإسلام؟', qEn: 'Fifth pillar of Islam?', optsAr: ['الصيام', 'الحج', 'الزكاة'], optsEn: ['Fasting', 'Hajj', 'Zakat'], correct: 1),
  QuizQuestion(qAr: 'في أي عام وُلد النبي محمد ﷺ؟', qEn: 'In which year was Prophet born?', optsAr: ['عام الفيل', 'عام الهجرة', 'عام الفتح'], optsEn: ['Year of Elephant', 'Year of Hijrah', 'Year of Conquest'], correct: 0),
  QuizQuestion(qAr: 'في أي مدينة وُلد النبي محمد ﷺ؟', qEn: 'Where was Prophet born?', optsAr: ['المدينة', 'مكة', 'الطائف'], optsEn: ['Madinah', 'Makkah', 'Taif'], correct: 1),
  QuizQuestion(qAr: 'كم كان عمر النبي ﷺ عند البعثة؟', qEn: 'Prophet age at prophethood?', optsAr: ['30', '40', '50'], optsEn: ['30', '40', '50'], correct: 1),
  QuizQuestion(qAr: 'ما اسم أم النبي ﷺ؟', qEn: 'Prophet mother name?', optsAr: ['خديجة', 'آمنة', 'فاطمة'], optsEn: ['Khadijah', 'Aminah', 'Fatimah'], correct: 1),
  QuizQuestion(qAr: 'ما اسم أول زوجات النبي ﷺ؟', qEn: 'First wife of Prophet?', optsAr: ['عائشة', 'خديجة', 'حفصة'], optsEn: ['Aisha', 'Khadijah', 'Hafsah'], correct: 1),
  QuizQuestion(qAr: 'إلى أي قبيلة ينتمي النبي ﷺ؟', qEn: 'Prophet tribe?', optsAr: ['الأوس', 'الخزرج', 'قريش'], optsEn: ['Aws', 'Khazraj', 'Quraysh'], correct: 2),
  QuizQuestion(qAr: 'أين دُفن النبي محمد ﷺ؟', qEn: 'Where is Prophet buried?', optsAr: ['مكة', 'المدينة المنورة', 'الطائف'], optsEn: ['Makkah', 'Madinah', 'Taif'], correct: 1),
  QuizQuestion(qAr: 'من هو أول الخلفاء الراشدين؟', qEn: 'First Rightly Guided Caliph?', optsAr: ['عمر', 'أبو بكر', 'عثمان'], optsEn: ['Umar', 'Abu Bakr', 'Uthman'], correct: 1),
  QuizQuestion(qAr: 'من هو الصحابي الملقب بـ"الفاروق"؟', qEn: 'Companion called "Al-Farooq"?', optsAr: ['أبو بكر', 'عمر', 'علي'], optsEn: ['Abu Bakr', 'Umar', 'Ali'], correct: 1),
  QuizQuestion(qAr: 'من هو الصحابي الملقب بـ"ذو النورين"؟', qEn: 'Companion called "Dhun-Nurayn"?', optsAr: ['علي', 'عثمان', 'طلحة'], optsEn: ['Ali', 'Uthman', 'Talhah'], correct: 1),
  QuizQuestion(qAr: 'من هو سيف الله المسلول؟', qEn: 'Sword of Allah?', optsAr: ['خالد بن الوليد', 'سعد بن أبي وقاص', 'أبو عبيدة'], optsEn: ['Khalid ibn Walid', 'Saad ibn Abi Waqqas', 'Abu Ubaidah'], correct: 0),
  QuizQuestion(qAr: 'من هي أول شهيدة في الإسلام؟', qEn: 'First female martyr in Islam?', optsAr: ['خديجة', 'سمية', 'أسماء'], optsEn: ['Khadijah', 'Sumayyah', 'Asma'], correct: 1),
  QuizQuestion(qAr: 'من هو مؤذن الرسول ﷺ؟', qEn: 'Prophet muezzin?', optsAr: ['أبو هريرة', 'بلال بن رباح', 'سلمان الفارسي'], optsEn: ['Abu Hurayrah', 'Bilal ibn Rabah', 'Salman Al-Farsi'], correct: 1),
  QuizQuestion(qAr: 'في أي شهر يصوم المسلمون؟', qEn: 'Month of fasting?', optsAr: ['شعبان', 'رمضان', 'شوال'], optsEn: ['Shaban', 'Ramadan', 'Shawwal'], correct: 1),
  QuizQuestion(qAr: 'كم عدد أشهر السنة الهجرية؟', qEn: 'Months in Hijri year?', optsAr: ['10', '12', '14'], optsEn: ['10', '12', '14'], correct: 1),
  QuizQuestion(qAr: 'ما هي نسبة زكاة المال؟', qEn: 'Zakat percentage?', optsAr: ['1%', '2.5%', '5%'], optsEn: ['1%', '2.5%', '5%'], correct: 1),
  QuizQuestion(qAr: 'ما هو النصاب في زكاة الذهب؟', qEn: 'Nisab for gold Zakat?', optsAr: ['50g', '85g', '100g'], optsEn: ['50g', '85g', '100g'], correct: 1),
  QuizQuestion(qAr: 'في أي يوم من رمضان وقعت غزوة بدر؟', qEn: 'Badr battle day in Ramadan?', optsAr: ['17', '21', '27'], optsEn: ['17th', '21st', '27th'], correct: 0),
  QuizQuestion(qAr: 'ما اسم اليوم الذي يقف فيه الحجاج على جبل عرفة؟', qEn: 'Day of standing at Arafah?', optsAr: ['9 Dhul-Hijjah', '10 Dhul-Hijjah', '1 Dhul-Hijjah'], optsEn: ['9 Dhul-Hijjah', '10 Dhul-Hijjah', '1 Dhul-Hijjah'], correct: 0),
  QuizQuestion(qAr: 'كم عدد أشهر الحرم؟', qEn: 'How many sacred months?', optsAr: ['3', '4', '5'], optsEn: ['3', '4', '5'], correct: 1),
  QuizQuestion(qAr: 'ما هي أول غزوة في الإسلام؟', qEn: 'First battle in Islam?', optsAr: ['أحد', 'بدر', 'الخندق'], optsEn: ['Uhud', 'Badr', 'Trench'], correct: 1),
  QuizQuestion(qAr: 'كم عدد الأنبياء المذكورين في القرآن؟', qEn: 'Prophets mentioned in Quran?', optsAr: ['20', '25', '30'], optsEn: ['20', '25', '30'], correct: 1),
  QuizQuestion(qAr: 'من هو النبي الملقب بـ"أبو الأنبياء"؟', qEn: 'Prophet called "Father of Prophets"?', optsAr: ['نوح', 'إبراهيم', 'موسى'], optsEn: ['Nuh', 'Ibrahim', 'Musa'], correct: 1),
  QuizQuestion(qAr: 'من هو النبي الذي كلّمه الله؟', qEn: 'Prophet whom Allah spoke to?', optsAr: ['عيسى', 'موسى', 'يوسف'], optsEn: ['Isa', 'Musa', 'Yusuf'], correct: 1),
];
