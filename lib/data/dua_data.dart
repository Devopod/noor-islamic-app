import '../models/dua.dart';

final List<DuaCategory> duaCategories = [
  DuaCategory(
    name: 'Morning & Evening',
    icon: 'wb_twilight',
    count: 12,
    duas: morningEveningDuas,
  ),
  DuaCategory(
    name: 'After Prayer',
    icon: 'mosque',
    count: 8,
    duas: afterPrayerDuas,
  ),
  DuaCategory(
    name: 'Before Sleeping',
    icon: 'bedtime',
    count: 6,
    duas: beforeSleepingDuas,
  ),
  DuaCategory(
    name: 'Food & Drink',
    icon: 'restaurant',
    count: 5,
    duas: foodDrinkDuas,
  ),
  DuaCategory(
    name: 'Travel',
    icon: 'flight',
    count: 7,
    duas: travelDuas,
  ),
  DuaCategory(
    name: 'Hajj & Umrah',
    icon: 'terrain',
    count: 10,
    duas: hajjUmrahDuas,
  ),
];

final List<Dua> morningEveningDuas = [
  Dua(
    id: 'me1',
    title: 'Morning Remembrance',
    arabic: 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ وَالْحَمْدُ لِلَّهِ',
    translation: 'We have reached the morning and at this very time all sovereignty belongs to Allah, and all praise is for Allah.',
    transliteration: 'Asbahna wa asbahal mulku lillah, walhamdu lillah',
    reference: 'Muslim',
    category: 'Morning & Evening',
  ),
  Dua(
    id: 'me2',
    title: 'Evening Remembrance',
    arabic: 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ وَالْحَمْدُ لِلَّهِ',
    translation: 'We have reached the evening and at this very time all sovereignty belongs to Allah, and all praise is for Allah.',
    transliteration: 'Amsayna wa amsal mulku lillah, walhamdu lillah',
    reference: 'Muslim',
    category: 'Morning & Evening',
  ),
  Dua(
    id: 'me3',
    title: 'Ayat al-Kursi',
    arabic: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ',
    translation: 'Allah - there is no deity except Him, the Ever-Living, the Sustainer of existence.',
    transliteration: 'Allahu la ilaha illa huwal hayyul qayyum',
    reference: 'Al-Baqarah 2:255',
    category: 'Morning & Evening',
  ),
  Dua(
    id: 'me4',
    title: 'Protection from Evil',
    arabic: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
    translation: 'I seek refuge in the perfect words of Allah from the evil of what He has created.',
    transliteration: "A'udhu bikalimaat Allahit-taammati min sharri ma khalaq",
    reference: 'Muslim',
    category: 'Morning & Evening',
  ),
];

final List<Dua> afterPrayerDuas = [
  Dua(
    id: 'ap1',
    title: 'After Salah',
    arabic: 'أَسْتَغْفِرُ اللَّهَ، أَسْتَغْفِرُ اللَّهَ، أَسْتَغْفِرُ اللَّهَ',
    translation: 'I seek the forgiveness of Allah (three times).',
    transliteration: 'Astaghfirullah, Astaghfirullah, Astaghfirullah',
    reference: 'Muslim',
    category: 'After Prayer',
  ),
  Dua(
    id: 'ap2',
    title: 'Asking for Peace',
    arabic: 'اللَّهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ',
    translation: 'O Allah, You are Peace and from You comes peace. Blessed are You, O Owner of majesty and honor.',
    transliteration: "Allahumma antas-salam wa minkas-salam, tabarakta ya dhal-jalali wal-ikram",
    reference: 'Muslim',
    category: 'After Prayer',
  ),
];

final List<Dua> beforeSleepingDuas = [
  Dua(
    id: 'bs1',
    title: 'Before Sleeping',
    arabic: 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
    translation: 'In Your name, O Allah, I die and I live.',
    transliteration: 'Bismika Allahumma amutu wa ahya',
    reference: 'Bukhari',
    category: 'Before Sleeping',
  ),
  Dua(
    id: 'bs2',
    title: 'Seeking Protection at Night',
    arabic: 'اللَّهُمَّ قِنِي عَذَابَكَ يَوْمَ تَبْعَثُ عِبَادَكَ',
    translation: 'O Allah, protect me from Your punishment on the day Your servants are resurrected.',
    transliteration: "Allahumma qini 'adhabaka yawma tab'athu 'ibadak",
    reference: 'Abu Dawud',
    category: 'Before Sleeping',
  ),
];

final List<Dua> foodDrinkDuas = [
  Dua(
    id: 'fd1',
    title: 'Before Eating',
    arabic: 'بِسْمِ اللَّهِ',
    translation: 'In the name of Allah.',
    transliteration: 'Bismillah',
    reference: 'Abu Dawud',
    category: 'Food & Drink',
  ),
  Dua(
    id: 'fd2',
    title: 'After Eating',
    arabic: 'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنِي هَذَا وَرَزَقَنِيهِ مِنْ غَيْرِ حَوْلٍ مِنِّي وَلَا قُوَّةٍ',
    translation: 'All praise is for Allah who fed me this and provided it for me without any might or power from myself.',
    transliteration: "Alhamdulillahil-ladhi at'amani hadha wa razaqanihi min ghayri hawlin minni wa la quwwah",
    reference: 'Tirmidhi',
    category: 'Food & Drink',
  ),
];

final List<Dua> travelDuas = [
  Dua(
    id: 'tr1',
    title: 'When Starting a Journey',
    arabic: 'سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ',
    translation: 'Glory to Him who has subjected this to us, and we could never have it by our efforts.',
    transliteration: 'Subhanal-ladhi sakhkhara lana hadha wa ma kunna lahu muqrinin',
    reference: 'Az-Zukhruf 43:13',
    category: 'Travel',
  ),
];

final List<Dua> hajjUmrahDuas = [
  Dua(
    id: 'hu1',
    title: 'Talbiyah',
    arabic: 'لَبَّيْكَ اللَّهُمَّ لَبَّيْكَ لَبَّيْكَ لَا شَرِيكَ لَكَ لَبَّيْكَ',
    translation: 'Here I am, O Allah, here I am. Here I am, You have no partner, here I am.',
    transliteration: 'Labbayk Allahumma labbayk, labbayk la sharika laka labbayk',
    reference: 'Bukhari & Muslim',
    category: 'Hajj & Umrah',
  ),
];

final List<Dua> allDuas = [
  ...morningEveningDuas,
  ...afterPrayerDuas,
  ...beforeSleepingDuas,
  ...foodDrinkDuas,
  ...travelDuas,
  ...hajjUmrahDuas,
];

final List<Dua> popularDuas = [
  morningEveningDuas[2],
  morningEveningDuas[0],
  afterPrayerDuas[0],
  beforeSleepingDuas[0],
  foodDrinkDuas[0],
  hajjUmrahDuas[0],
];
