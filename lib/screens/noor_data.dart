class DailyNoor {
  final String ayahAr, ayahEn, ayahRef;
  final String hadithAr, hadithEn, hadithRef;
  final String duaAr, duaEn;
  final String dhikrAr, dhikrEn;
  const DailyNoor({
    required this.ayahAr, required this.ayahEn, required this.ayahRef,
    required this.hadithAr, required this.hadithEn, required this.hadithRef,
    required this.duaAr, required this.duaEn,
    required this.dhikrAr, required this.dhikrEn,
  });
}

const List<DailyNoor> allDailyNoor = [
  DailyNoor(
    ayahAr: '﴿أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ﴾',
    ayahEn: '"Verily, in the remembrance of Allah do hearts find rest."',
    ayahRef: 'الرعد - 28',
    hadithAr: 'قال رسول الله ﷺ: "أحبُّ الأعمالِ إلى اللهِ أدْومُها وإنْ قلَّ"',
    hadithEn: '"The most beloved deeds to Allah are the most consistent, even if small."',
    hadithRef: 'متفق عليه',
    duaAr: 'اللَّهُمَّ اجْعَلْنِي مِنَ التَّوَّابِينَ، وَاجْعَلْنِي مِنَ الْمُتَطَهِّرِينَ',
    duaEn: 'O Allah, make me among those who repent and among those who purify themselves.',
    dhikrAr: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، سُبْحَانَ اللَّهِ الْعَظِيمِ',
    dhikrEn: 'Glory be to Allah and praise Him, glory be to Allah the Magnificent.',
  ),
  DailyNoor(
    ayahAr: '﴿وَإِذَا سَأَلَكَ عِبَادِي عَنِّي فَإِنِّي قَرِيبٌ﴾',
    ayahEn: '"And when My servants ask you about Me, indeed I am near."',
    ayahRef: 'البقرة - 186',
    hadithAr: 'قال ﷺ: "الدعاءُ مُخُّ العبادةِ"',
    hadithEn: '"Supplication is the essence of worship."',
    hadithRef: 'الترمذي',
    duaAr: 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
    duaEn: 'Our Lord, give us good in this world and good in the Hereafter, and protect us from the Fire.',
    dhikrAr: 'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ',
    dhikrEn: 'There is no god but Allah, alone without partner.',
  ),
  DailyNoor(
    ayahAr: '﴿فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ﴾',
    ayahEn: '"So remember Me; I will remember you."',
    ayahRef: 'البقرة - 152',
    hadithAr: 'قال ﷺ: "من قال سبحان الله وبحمده في يوم مائة مرة حُطَّت خطاياه"',
    hadithEn: '"Whoever says Subhan Allah wa bihamdih 100 times a day, his sins are erased."',
    hadithRef: 'متفق عليه',
    duaAr: 'اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ وَشُكْرِكَ وَحُسْنِ عِبَادَتِكَ',
    duaEn: 'O Allah, help me remember You, thank You, and worship You well.',
    dhikrAr: 'أَسْتَغْفِرُ اللَّهَ الْعَظِيمَ وَأَتُوبُ إِلَيْهِ',
    dhikrEn: 'I seek forgiveness from Allah the Magnificent and repent to Him.',
  ),
  DailyNoor(
    ayahAr: '﴿إِنَّ مَعَ الْعُسْرِ يُسْرًا﴾',
    ayahEn: '"Indeed, with hardship comes ease."',
    ayahRef: 'الشرح - 6',
    hadithAr: 'قال ﷺ: "عجبًا لأمرِ المؤمنِ، إنَّ أمرَه كلَّه خيرٌ"',
    hadithEn: '"Wondrous is the affair of the believer — all his affairs are good."',
    hadithRef: 'مسلم',
    duaAr: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ وَرَحْمَتِكَ',
    duaEn: 'O Allah, I ask You for Your bounty and mercy.',
    dhikrAr: 'حَسْبِيَ اللَّهُ وَنِعْمَ الْوَكِيلُ',
    dhikrEn: 'Allah is sufficient for me, and He is the best disposer of affairs.',
  ),
  DailyNoor(
    ayahAr: '﴿وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ﴾',
    ayahEn: '"And whoever relies upon Allah — then He is sufficient for him."',
    ayahRef: 'الطلاق - 3',
    hadithAr: 'قال ﷺ: "لو توكلتم على الله حق توكله لرزقكم كما يرزق الطير"',
    hadithEn: '"If you relied on Allah truly, He would provide for you as He provides for birds."',
    hadithRef: 'الترمذي',
    duaAr: 'اللَّهُمَّ اكْفِنِي بِحَلَالِكَ عَنْ حَرَامِكَ، وَأَغْنِنِي بِفَضْلِكَ عَمَّنْ سِوَاكَ',
    duaEn: 'O Allah, suffice me with what You have made lawful, and enrich me with Your bounty.',
    dhikrAr: 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
    dhikrEn: 'There is no might nor power except with Allah.',
  ),
  DailyNoor(
    ayahAr: '﴿إِنَّ اللَّهَ مَعَ الصَّابِرِينَ﴾',
    ayahEn: '"Indeed, Allah is with the patient."',
    ayahRef: 'البقرة - 153',
    hadithAr: 'قال ﷺ: "وما أُعطِيَ أحدٌ عطاءً خيرًا وأوسعَ من الصبر"',
    hadithEn: '"No one has been given a gift better or more abundant than patience."',
    hadithRef: 'متفق عليه',
    duaAr: 'رَبَّنَا أَفْرِغْ عَلَيْنَا صَبْرًا وَثَبِّتْ أَقْدَامَنَا',
    duaEn: 'Our Lord, pour patience upon us and make our feet firm.',
    dhikrAr: 'اللَّهُ أَكْبَرُ، اللَّهُ أَكْبَرُ',
    dhikrEn: 'Allah is the Greatest, Allah is the Greatest.',
  ),
  DailyNoor(
    ayahAr: '﴿وَرَحْمَتِي وَسِعَتْ كُلَّ شَيْءٍ﴾',
    ayahEn: '"And My mercy encompasses all things."',
    ayahRef: 'الأعراف - 156',
    hadithAr: 'قال ﷺ: "إنَّ اللهَ كتبَ كتابًا: إنَّ رحمتي سبقت غضبي"',
    hadithEn: '"Allah wrote: My mercy prevails over My wrath."',
    hadithRef: 'متفق عليه',
    duaAr: 'يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ',
    duaEn: 'O Living, O Sustainer, by Your mercy I seek relief.',
    dhikrAr: 'اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ',
    dhikrEn: 'O Allah, send blessings and peace upon our Prophet Muhammad.',
  ),
];

DailyNoor getTodayNoor() {
  final today = DateTime.now();
  final index = (today.day + today.month * 31 + today.year * 365) % allDailyNoor.length;
  return allDailyNoor[index];
}
