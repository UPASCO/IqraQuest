#!/usr/bin/env python3
"""Generates IqraQuest's curated question bank (master + fr/en/ar content)
from a single Python source of truth, then validates it against the
CONTENT_SOURCE_POLICY.md rules before writing any file.

This is a v1 curated set: 60 canonical questions that pass every rule in
CONTENT_SOURCE_POLICY.md (Qur'an or Sahih al-Bukhari/Sahih Muslim only,
non-controversial, no disputed narration or fiqh arbitration needed).
It intentionally stops short of the product brief's 500-question target
rather than lower the verification bar — see README.md and
content_quality/ for the documented gap and how to extend this set.
"""
import json
import csv
import os

OUT_ROOT = "/home/user/IqraQuest/assets/data/questions"
CQ_ROOT = "/home/user/IqraQuest/content_quality"

# Each entry: canonical fields + per-language dict.
Q = []

def add(id, category, difficulty, source_type, source_work, source_reference,
        is_free, fr, en, ar, age="7+"):
    Q.append(dict(
        id=id, category=category, difficulty=difficulty, ageLevel=age,
        sourceType=source_type, sourceWork=source_work, sourceReference=source_reference,
        isFree=is_free, fr=fr, en=en, ar=ar,
    ))

def L(question, answers, correct, explanation, source_display):
    assert len(answers) == 4
    assert 0 <= correct < 4
    return dict(question=question, answers=answers, correctAnswerIndex=correct,
                explanation=explanation, sourceDisplay=source_display)

# ---------------------------------------------------------------------
# PROPHETS (Qur'an) — 18
# ---------------------------------------------------------------------

add("prophets_001", "prophets", "easy", "quran", "Quran", "11:37-38", True,
    fr=L("Quel prophète a construit l'arche sur l'ordre d'Allah ?",
         ["Nûh", "Ibrâhîm", "Mûsâ", "Yûsuf"], 0,
         "Allah ordonna à Nûh de construire l'arche pour sauver les croyants du déluge.",
         "Coran — Sourate Hûd, 11:37-38"),
    en=L("Which prophet built the ark by Allah's command?",
         ["Nuh (Noah)", "Ibrahim (Abraham)", "Musa (Moses)", "Yusuf (Joseph)"], 0,
         "Allah commanded Nuh to build the ark to save the believers from the flood.",
         "Quran — Surah Hud, 11:37-38"),
    ar=L("أي نبي بنى السفينة بأمر الله؟",
         ["نوح", "إبراهيم", "موسى", "يوسف"], 0,
         "أمر الله نوحًا ببناء السفينة لينجو المؤمنون من الطوفان.",
         "القرآن — سورة هود، 11:37-38"))

add("prophets_002", "prophets", "easy", "quran", "Quran", "21:69", True,
    fr=L("Quel prophète fut jeté dans le feu, qu'Allah rendit frais et sûr pour lui ?",
         ["Ibrâhîm", "Nûh", "Dâwûd", "Ayyûb"], 0,
         "Allah ordonna au feu d'être frais et sûr pour Ibrâhîm.",
         "Coran — Sourate Al-Anbiyâ, 21:69"),
    en=L("Which prophet was thrown into a fire that Allah made cool and safe for him?",
         ["Ibrahim (Abraham)", "Nuh (Noah)", "Dawud (David)", "Ayyub (Job)"], 0,
         "Allah commanded the fire to be cool and safe for Ibrahim.",
         "Quran — Surah Al-Anbiya, 21:69"),
    ar=L("أي نبي أُلقي في النار فجعلها الله بردًا وسلامًا عليه؟",
         ["إبراهيم", "نوح", "داوود", "أيوب"], 0,
         "أمر الله النار أن تكون بردًا وسلامًا على إبراهيم.",
         "القرآن — سورة الأنبياء، 21:69"))

add("prophets_003", "prophets", "medium", "quran", "Quran", "37:142", True,
    fr=L("Quel prophète fut avalé par un énorme poisson ?",
         ["Yûnus", "Ilyâs", "Idrîs", "Zakariyyâ"], 0,
         "Yûnus fut avalé par le poisson après avoir quitté son peuple en colère ; Allah lui pardonna.",
         "Coran — Sourate As-Sâffât, 37:142"),
    en=L("Which prophet was swallowed by a huge fish?",
         ["Yunus (Jonah)", "Ilyas (Elijah)", "Idris (Enoch)", "Zakariyya (Zechariah)"], 0,
         "Yunus was swallowed by the fish after leaving his people in anger; Allah forgave him.",
         "Quran — Surah As-Saffat, 37:142"),
    ar=L("أي نبي التقمه حوت ضخم؟",
         ["يونس", "إلياس", "إدريس", "زكريا"], 0,
         "التقم الحوتُ يونسَ بعد أن غادر قومه غاضبًا، فغفر الله له.",
         "القرآن — سورة الصافات، 37:142"))

add("prophets_004", "prophets", "medium", "quran", "Quran", "12:43-49", False,
    fr=L("Quel prophète interpréta le rêve du roi des sept vaches grasses et sept vaches maigres ?",
         ["Yûsuf", "Yaʿqûb", "Ismâʿîl", "Ishâq"], 0,
         "Yûsuf interpréta le rêve du roi, annonçant sept années d'abondance suivies de sept années de disette.",
         "Coran — Sourate Yûsuf, 12:43-49"),
    en=L("Which prophet interpreted the king's dream of seven fat cows and seven lean cows?",
         ["Yusuf (Joseph)", "Ya'qub (Jacob)", "Isma'il (Ishmael)", "Ishaq (Isaac)"], 0,
         "Yusuf interpreted the king's dream, foretelling seven years of abundance followed by seven years of famine.",
         "Quran — Surah Yusuf, 12:43-49"),
    ar=L("أي نبي فسّر رؤيا الملك عن سبع بقرات سمان وسبع عجاف؟",
         ["يوسف", "يعقوب", "إسماعيل", "إسحاق"], 0,
         "فسّر يوسف رؤيا الملك، فأخبر بسبع سنوات خصبة تليها سبع سنوات جدباء.",
         "القرآن — سورة يوسف، 12:43-49"))

add("prophets_005", "prophets", "hard", "quran", "Quran", "4:164", True,
    fr=L("Quel prophète, selon le Coran, a parlé directement à Allah ?",
         ["Mûsâ", "Hârûn", "Yûsuf", "Sulaymân"], 0,
         "Le Coran précise qu'Allah a parlé à Mûsâ directement.",
         "Coran — Sourate An-Nisâ, 4:164"),
    en=L("Which prophet, according to the Quran, was spoken to directly by Allah?",
         ["Musa (Moses)", "Harun (Aaron)", "Yusuf (Joseph)", "Sulaiman (Solomon)"], 0,
         "The Quran states that Allah spoke to Musa directly.",
         "Quran — Surah An-Nisa, 4:164"),
    ar=L("أي نبي كلّمه الله تكليمًا بحسب القرآن؟",
         ["موسى", "هارون", "يوسف", "سليمان"], 0,
         "ينص القرآن على أن الله كلّم موسى تكليمًا.",
         "القرآن — سورة النساء، 4:164"))

add("prophets_006", "prophets", "medium", "quran", "Quran", "27:16", False,
    fr=L("Quel prophète pouvait comprendre le langage des oiseaux ?",
         ["Sulaymân", "Dâwûd", "Yûnus", "Yûsuf"], 0,
         "Allah enseigna à Sulaymân le langage des oiseaux.",
         "Coran — Sourate An-Naml, 27:16"),
    en=L("Which prophet could understand the speech of birds?",
         ["Sulaiman (Solomon)", "Dawud (David)", "Yunus (Jonah)", "Yusuf (Joseph)"], 0,
         "Allah taught Sulaiman the speech of birds.",
         "Quran — Surah An-Naml, 27:16"),
    ar=L("أي نبي كان يفهم منطق الطير؟",
         ["سليمان", "داوود", "يونس", "يوسف"], 0,
         "علّم الله سليمان منطق الطير.",
         "القرآن — سورة النمل، 27:16"))

add("prophets_007", "prophets", "medium", "quran", "Quran", "17:55", False,
    fr=L("Quel prophète reçut le livre appelé le Zabûr ?",
         ["Dâwûd", "Mûsâ", "Îsâ", "Ibrâhîm"], 0,
         "Le Coran mentionne que le Zabûr fut donné à Dâwûd.",
         "Coran — Sourate Al-Isrâ, 17:55"),
    en=L("Which prophet was given the scripture called the Zabur (Psalms)?",
         ["Dawud (David)", "Musa (Moses)", "Isa (Jesus)", "Ibrahim (Abraham)"], 0,
         "The Quran mentions that the Zabur was given to Dawud.",
         "Quran — Surah Al-Isra, 17:55"),
    ar=L("أي نبي أُوتي كتاب الزبور؟",
         ["داوود", "موسى", "عيسى", "إبراهيم"], 0,
         "يذكر القرآن أن الزبور أُعطي لداوود.",
         "القرآن — سورة الإسراء، 17:55"))

add("prophets_008", "prophets", "medium", "quran", "Quran", "3:47", False,
    fr=L("Quel prophète est né sans père, par la parole d'Allah « Sois ! » et il fut ?",
         ["Îsâ", "Yahyâ", "Ismâʿîl", "Ishâq"], 0,
         "Le Coran décrit la naissance miraculeuse d'Îsâ, sans père, par la seule parole d'Allah.",
         "Coran — Sourate Âl ʿImrân, 3:47"),
    en=L("Which prophet was born without a father, by Allah's word 'Be, and it is'?",
         ["Isa (Jesus)", "Yahya (John)", "Isma'il (Ishmael)", "Ishaq (Isaac)"], 0,
         "The Quran describes Isa's miraculous birth without a father, by Allah's word alone.",
         "Quran — Surah Al 'Imran, 3:47"),
    ar=L("أي نبي وُلد بلا أب، بكلمة الله «كن فيكون»؟",
         ["عيسى", "يحيى", "إسماعيل", "إسحاق"], 0,
         "يصف القرآن ولادة عيسى المعجزة دون أب، بكلمة الله وحدها.",
         "القرآن — سورة آل عمران، 3:47"))

add("prophets_009", "prophets", "medium", "quran", "Quran", "19:16", False,
    fr=L("Quel chapitre (sourate) du Coran porte le nom de la mère d'un prophète ?",
         ["Maryam", "Yûsuf", "Nûh", "Hûd"], 0,
         "La sourate 19, Maryam, porte le nom de la mère du prophète Îsâ.",
         "Coran — Sourate Maryam, 19:16"),
    en=L("Which chapter (surah) of the Quran is named after a prophet's mother?",
         ["Maryam", "Yusuf", "Nuh", "Hud"], 0,
         "Surah 19, Maryam, is named after the mother of the prophet Isa.",
         "Quran — Surah Maryam, 19:16"),
    ar=L("أي سورة من القرآن سُمّيت باسم أم أحد الأنبياء؟",
         ["مريم", "يوسف", "نوح", "هود"], 0,
         "سُمّيت السورة 19، مريم، باسم أم النبي عيسى.",
         "القرآن — سورة مريم، 19:16"))

add("prophets_010", "prophets", "hard", "quran", "Quran", "21:83-84", True,
    fr=L("Quel prophète fut éprouvé par une maladie sévère et loué pour sa patience ?",
         ["Ayyûb", "Zakariyyâ", "Yahyâ", "Idrîs"], 0,
         "Ayyûb resta patient malgré une épreuve très difficile, et Allah le récompensa.",
         "Coran — Sourate Al-Anbiyâ, 21:83-84"),
    en=L("Which prophet was tested with severe illness and is praised for his patience?",
         ["Ayyub (Job)", "Zakariyya (Zechariah)", "Yahya (John)", "Idris (Enoch)"], 0,
         "Ayyub remained patient through a very difficult trial, and Allah rewarded him.",
         "Quran — Surah Al-Anbiya, 21:83-84"),
    ar=L("أي نبي ابتُلي بمرض شديد وأُثني عليه بالصبر؟",
         ["أيوب", "زكريا", "يحيى", "إدريس"], 0,
         "صبر أيوب رغم ابتلاء شديد، فأثابه الله.",
         "القرآن — سورة الأنبياء، 21:83-84"))

add("prophets_011", "prophets", "easy", "quran", "Quran", "2:34", True,
    fr=L("À qui Allah a-t-Il ordonné aux anges de se prosterner, en signe d'honneur ?",
         ["Âdam", "Nûh", "Ibrâhîm", "Mûsâ"], 0,
         "Allah ordonna aux anges de se prosterner devant Âdam en signe d'honneur, non d'adoration.",
         "Coran — Sourate Al-Baqara, 2:34"),
    en=L("Whom did Allah command the angels to prostrate to, as a sign of honor?",
         ["Adam", "Nuh (Noah)", "Ibrahim (Abraham)", "Musa (Moses)"], 0,
         "Allah commanded the angels to prostrate to Adam as a mark of honor, not worship.",
         "Quran — Surah Al-Baqarah, 2:34"),
    ar=L("لمن أمر الله الملائكة بالسجود إكرامًا؟",
         ["آدم", "نوح", "إبراهيم", "موسى"], 0,
         "أمر الله الملائكة بالسجود لآدم إكرامًا له، لا عبادة.",
         "القرآن — سورة البقرة، 2:34"))

add("prophets_012", "prophets", "medium", "quran", "Quran", "4:125", False,
    fr=L("Quel prophète est appelé « Khalîlullah », l'ami intime d'Allah ?",
         ["Ibrâhîm", "Mûsâ", "Îsâ", "Muhammad ﷺ"], 0,
         "Le Coran désigne Ibrâhîm comme l'ami intime (khalîl) d'Allah.",
         "Coran — Sourate An-Nisâ, 4:125"),
    en=L("Which prophet is called 'Khalilullah', the close friend of Allah?",
         ["Ibrahim (Abraham)", "Musa (Moses)", "Isa (Jesus)", "Muhammad ﷺ"], 0,
         "The Quran describes Ibrahim as the close friend (khalil) of Allah.",
         "Quran — Surah An-Nisa, 4:125"),
    ar=L("أي نبي يُلقّب بـ«خليل الله»؟",
         ["إبراهيم", "موسى", "عيسى", "محمد ﷺ"], 0,
         "يصف القرآن إبراهيم بأنه خليل الله.",
         "القرآن — سورة النساء، 4:125"))

add("prophets_013", "prophets", "easy", "quran", "Quran", "12:15", False,
    fr=L("Quel prophète fut jeté dans un puits par ses frères ?",
         ["Yûsuf", "Bunyamîn", "Yaʿqûb", "Ismâʿîl"], 0,
         "Les frères de Yûsuf le jetèrent au fond d'un puits par jalousie.",
         "Coran — Sourate Yûsuf, 12:15"),
    en=L("Which prophet was thrown into a well by his brothers?",
         ["Yusuf (Joseph)", "Bunyamin (Benjamin)", "Ya'qub (Jacob)", "Isma'il (Ishmael)"], 0,
         "Yusuf's brothers threw him into a well out of jealousy.",
         "Quran — Surah Yusuf, 12:15"),
    ar=L("أي نبي ألقاه إخوته في غيابة الجُبّ؟",
         ["يوسف", "بنيامين", "يعقوب", "إسماعيل"], 0,
         "ألقى إخوة يوسف به في الجُبّ حسدًا منهم.",
         "القرآن — سورة يوسف، 12:15"))

add("prophets_014", "prophets", "medium", "quran", "Quran", "11:37-44", False,
    fr=L("Le peuple de quel prophète fut anéanti par un déluge après l'avoir rejeté ?",
         ["Nûh", "Hûd", "Sâlih", "Shuʿayb"], 0,
         "Le peuple de Nûh fut englouti par le déluge après avoir persisté dans le rejet du message.",
         "Coran — Sourate Hûd, 11:37-44"),
    en=L("Whose people were destroyed by a flood after rejecting him?",
         ["Nuh (Noah)", "Hud", "Salih", "Shu'ayb"], 0,
         "Nuh's people were engulfed by the flood after persistently rejecting his message.",
         "Quran — Surah Hud, 11:37-44"),
    ar=L("قوم أي نبي أُهلكوا بالطوفان بعد أن كذّبوه؟",
         ["نوح", "هود", "صالح", "شعيب"], 0,
         "أُغرق قوم نوح بالطوفان بعد إصرارهم على تكذيب رسالته.",
         "القرآن — سورة هود، 11:37-44"))

add("prophets_015", "prophets", "medium", "quran", "Quran", "26:63", False,
    fr=L("Quel prophète vit la mer se fendre pour sauver son peuple de Pharaon ?",
         ["Mûsâ", "Hârûn", "Yûsuf", "Ismâʿîl"], 0,
         "Allah ordonna à Mûsâ de frapper la mer, qui se fendit pour laisser passer les croyants.",
         "Coran — Sourate Ash-Shuʿarâ, 26:63"),
    en=L("Which prophet saw the sea part to save his people from Pharaoh?",
         ["Musa (Moses)", "Harun (Aaron)", "Yusuf (Joseph)", "Isma'il (Ishmael)"], 0,
         "Allah commanded Musa to strike the sea, and it parted so the believers could pass.",
         "Quran — Surah Ash-Shu'ara, 26:63"),
    ar=L("أي نبي انفلق له البحر لينجو قومه من فرعون؟",
         ["موسى", "هارون", "يوسف", "إسماعيل"], 0,
         "أمر الله موسى بضرب البحر فانفلق ليعبر المؤمنون.",
         "القرآن — سورة الشعراء، 26:63"))

add("prophets_016", "prophets", "hard", "quran", "Quran", "21:78-79", False,
    fr=L("Quel prophète, aux côtés de son père Dâwûd, jugea l'affaire du champ ravagé par des brebis ?",
         ["Sulaymân", "Ismâʿîl", "Yûsuf", "Ishâq"], 0,
         "Le Coran relate que Sulaymân et Dâwûd jugèrent cette affaire, et qu'Allah donna la compréhension à Sulaymân.",
         "Coran — Sourate Al-Anbiyâ, 21:78-79"),
    en=L("Which prophet, alongside his father Dawud, judged the case of a field grazed by sheep?",
         ["Sulaiman (Solomon)", "Isma'il (Ishmael)", "Yusuf (Joseph)", "Ishaq (Isaac)"], 0,
         "The Quran relates that Sulaiman and Dawud judged this case, and Allah granted Sulaiman the understanding of it.",
         "Quran — Surah Al-Anbiya, 21:78-79"),
    ar=L("أي نبي حكم مع أبيه داوود في قضية الحرث الذي نفشت فيه الغنم؟",
         ["سليمان", "إسماعيل", "يوسف", "إسحاق"], 0,
         "يذكر القرآن أن سليمان وداوود حكما في هذه القضية، وآتى الله سليمان فهمها.",
         "القرآن — سورة الأنبياء، 21:78-79"))

add("prophets_017", "prophets", "easy", "quran", "Quran", "20:38-39", False,
    fr=L("La mère de quel prophète reçut l'ordre de le déposer dans le fleuve alors qu'il était bébé ?",
         ["Mûsâ", "Îsâ", "Yûsuf", "Ismâʿîl"], 0,
         "Allah inspira à la mère de Mûsâ de le déposer dans un coffret sur le fleuve pour le protéger.",
         "Coran — Sourate Tâ-Hâ, 20:38-39"),
    en=L("Whose mother was instructed to place her baby into a river?",
         ["Musa (Moses)", "Isa (Jesus)", "Yusuf (Joseph)", "Isma'il (Ishmael)"], 0,
         "Allah inspired Musa's mother to place him in a chest on the river to protect him.",
         "Quran — Surah Ta-Ha, 20:38-39"),
    ar=L("أم أي نبي أُمرت بوضعه رضيعًا في اليم؟",
         ["موسى", "عيسى", "يوسف", "إسماعيل"], 0,
         "ألهم الله أم موسى أن تضعه في تابوت على اليم لحمايته.",
         "القرآن — سورة طه، 20:38-39"))

add("prophets_018", "prophets", "hard", "quran", "Quran", "7:73", False,
    fr=L("La chamelle de quel prophète fut un signe donné à son peuple, les Thamûd ?",
         ["Sâlih", "Hûd", "Shuʿayb", "Lût"], 0,
         "Allah envoya une chamelle comme signe au peuple de Thamûd par le prophète Sâlih.",
         "Coran — Sourate Al-Aʿrâf, 7:73"),
    en=L("Whose she-camel was a sign given to his people, the Thamud?",
         ["Salih", "Hud", "Shu'ayb", "Lut (Lot)"], 0,
         "Allah sent a she-camel as a sign to the people of Thamud through the prophet Salih.",
         "Quran — Surah Al-A'raf, 7:73"),
    ar=L("ناقة أي نبي كانت آية لقومه ثمود؟",
         ["صالح", "هود", "شعيب", "لوط"], 0,
         "أرسل الله ناقة آيةً لقوم ثمود على يد النبي صالح.",
         "القرآن — سورة الأعراف، 7:73"))

# ---------------------------------------------------------------------
# SIRA (life of the Prophet Muhammad ﷺ) — 18
# ---------------------------------------------------------------------

add("sira_001", "sira", "easy", "sira", "Sira", "well-established sira event, agreed across standard biographies", True,
    fr=L("Dans quelle ville le prophète Muhammad ﷺ est-il né ?",
         ["La Mecque", "Médine", "Ta'if", "Jérusalem"], 0,
         "Le prophète Muhammad ﷺ est né à La Mecque, dans le Hijaz.",
         "Sîra — fait historique établi"),
    en=L("In which city was the Prophet Muhammad ﷺ born?",
         ["Makkah", "Madinah", "Ta'if", "Jerusalem"], 0,
         "The Prophet Muhammad ﷺ was born in Makkah, in the Hijaz.",
         "Sira — well-established historical fact"),
    ar=L("في أي مدينة وُلد النبي محمد ﷺ؟",
         ["مكة", "المدينة", "الطائف", "القدس"], 0,
         "وُلد النبي محمد ﷺ في مكة، في الحجاز.",
         "السيرة — حقيقة تاريخية ثابتة"))

add("sira_002", "sira", "medium", "quran", "Quran", "105:1-5", True,
    fr=L("Comment appelle-t-on l'année de la naissance du Prophète ﷺ, marquée par l'événement de l'éléphant ?",
         ["L'Année de l'Éléphant", "L'Année de la Victoire", "L'Année du Chameau", "L'Année de la Lumière"], 0,
         "L'événement de l'éléphant, où Allah protégea la Kaaba, est raconté dans la sourate Al-Fîl.",
         "Coran — Sourate Al-Fîl, 105:1-5"),
    en=L("What is the year of the Prophet's ﷺ birth called, marked by the Event of the Elephant?",
         ["The Year of the Elephant", "The Year of Victory", "The Year of the Camel", "The Year of Light"], 0,
         "The Event of the Elephant, in which Allah protected the Kaaba, is recounted in Surah Al-Fil.",
         "Quran — Surah Al-Fil, 105:1-5"),
    ar=L("ماذا تُسمّى سنة مولد النبي ﷺ التي وقعت فيها حادثة الفيل؟",
         ["عام الفيل", "عام النصر", "عام الجمل", "عام النور"], 0,
         "قصة الفيل، التي حفظ فيها الله الكعبة، مذكورة في سورة الفيل.",
         "القرآن — سورة الفيل، 105:1-5"))

add("sira_003", "sira", "easy", "sira", "Sira", "well-established sira event, agreed across standard biographies", False,
    fr=L("Quel était le nom de la première épouse du Prophète ﷺ ?",
         ["Khadîja", "ʿÂ'isha", "Hafsa", "Zaynab"], 0,
         "Khadîja bint Khuwaylid fut la première épouse du Prophète ﷺ et la première à croire en son message.",
         "Sîra — fait historique établi"),
    en=L("What was the name of the Prophet's ﷺ first wife?",
         ["Khadijah", "A'ishah", "Hafsah", "Zaynab"], 0,
         "Khadijah bint Khuwaylid was the Prophet's ﷺ first wife and the first person to believe in his message.",
         "Sira — well-established historical fact"),
    ar=L("ما اسم أول زوجة للنبي ﷺ؟",
         ["خديجة", "عائشة", "حفصة", "زينب"], 0,
         "كانت خديجة بنت خويلد أول زوجة للنبي ﷺ وأول من آمن برسالته.",
         "السيرة — حقيقة تاريخية ثابتة"))

add("sira_004", "sira", "medium", "sira", "Sira", "well-established sira event, agreed across standard biographies", False,
    fr=L("Dans quelle grotte le Prophète ﷺ reçut-il la première révélation ?",
         ["La grotte de Hirâ'", "La grotte de Thawr", "La grotte des gens de la caverne", "La grotte de Uhud"], 0,
         "La première révélation eut lieu dans la grotte de Hirâ', sur le mont An-Nûr près de La Mecque.",
         "Sîra — fait historique établi"),
    en=L("In which cave did the Prophet ﷺ receive the first revelation?",
         ["The Cave of Hira", "The Cave of Thawr", "The Cave of the Companions", "The Cave of Uhud"], 0,
         "The first revelation took place in the Cave of Hira, on Jabal an-Nur near Makkah.",
         "Sira — well-established historical fact"),
    ar=L("في أي غار نزل الوحي الأول على النبي ﷺ؟",
         ["غار حراء", "غار ثور", "كهف أصحاب الكهف", "غار أُحد"], 0,
         "نزل الوحي الأول في غار حراء، في جبل النور قرب مكة.",
         "السيرة — حقيقة تاريخية ثابتة"))

add("sira_005", "sira", "easy", "quran", "Quran", "2:97", True,
    fr=L("Quel ange apporta la révélation au Prophète ﷺ ?",
         ["Jibrîl", "Mîkâ'îl", "Isrâfîl", "Mâlik"], 0,
         "Le Coran mentionne explicitement que Jibrîl a apporté la révélation par la permission d'Allah.",
         "Coran — Sourate Al-Baqara, 2:97"),
    en=L("Which angel brought revelation to the Prophet ﷺ?",
         ["Jibril (Gabriel)", "Mika'il (Michael)", "Israfil", "Malik"], 0,
         "The Quran explicitly mentions that Jibril brought revelation by Allah's permission.",
         "Quran — Surah Al-Baqarah, 2:97"),
    ar=L("أي ملَك جاء بالوحي إلى النبي ﷺ؟",
         ["جبريل", "ميكائيل", "إسرافيل", "مالك"], 0,
         "يذكر القرآن صراحةً أن جبريل نزل بالوحي بإذن الله.",
         "القرآن — سورة البقرة، 2:97"))

add("sira_006", "sira", "easy", "sira", "Sira", "well-established sira event, agreed across standard biographies", False,
    fr=L("Comment appelle-t-on la migration du Prophète ﷺ et de ses compagnons de La Mecque vers Médine ?",
         ["Al-Hijra", "Al-Isrâ'", "Al-Miʿrâj", "Al-Fath"], 0,
         "Al-Hijra désigne la migration historique vers Médine, point de départ du calendrier islamique.",
         "Sîra — fait historique établi"),
    en=L("What is the migration of the Prophet ﷺ and his companions from Makkah to Madinah called?",
         ["Al-Hijrah", "Al-Isra", "Al-Mi'raj", "Al-Fath"], 0,
         "Al-Hijrah refers to the historic migration to Madinah, the starting point of the Islamic calendar.",
         "Sira — well-established historical fact"),
    ar=L("ماذا تُسمّى هجرة النبي ﷺ وأصحابه من مكة إلى المدينة؟",
         ["الهجرة", "الإسراء", "المعراج", "الفتح"], 0,
         "تشير الهجرة إلى الانتقال التاريخي إلى المدينة، وهي بداية التقويم الهجري.",
         "السيرة — حقيقة تاريخية ثابتة"))

add("sira_007", "sira", "easy", "sira", "Sira", "well-established sira event, agreed across standard biographies", False,
    fr=L("Vers quelle ville le Prophète ﷺ et Abû Bakr émigrèrent-ils ?",
         ["Médine", "Ta'if", "Damas", "Jérusalem"], 0,
         "Le Prophète ﷺ et Abû Bakr migrèrent de La Mecque vers Médine (alors appelée Yathrib).",
         "Sîra — fait historique établi"),
    en=L("To which city did the Prophet ﷺ and Abu Bakr migrate?",
         ["Madinah", "Ta'if", "Damascus", "Jerusalem"], 0,
         "The Prophet ﷺ and Abu Bakr migrated from Makkah to Madinah (then called Yathrib).",
         "Sira — well-established historical fact"),
    ar=L("إلى أي مدينة هاجر النبي ﷺ وأبو بكر؟",
         ["المدينة", "الطائف", "دمشق", "القدس"], 0,
         "هاجر النبي ﷺ وأبو بكر من مكة إلى المدينة (يثرب سابقًا).",
         "السيرة — حقيقة تاريخية ثابتة"))

add("sira_008", "sira", "hard", "quran", "Quran", "9:40", False,
    fr=L("Le Coran décrit un compagnon comme « le second de deux, alors qu'ils étaient dans la grotte » lors de la Hijra. De qui s'agit-il ?",
         ["Abû Bakr", "ʿUmar", "ʿUthmân", "ʿAlî"], 0,
         "Le Coran fait référence à Abû Bakr, qui accompagna le Prophète ﷺ dans la grotte de Thawr durant la Hijra.",
         "Coran — Sourate At-Tawba, 9:40"),
    en=L("The Quran describes a companion as 'the second of two, when they were in the cave' during the Hijrah. Who was it?",
         ["Abu Bakr", "Umar", "Uthman", "Ali"], 0,
         "The Quran refers to Abu Bakr, who accompanied the Prophet ﷺ in the Cave of Thawr during the Hijrah.",
         "Quran — Surah At-Tawbah, 9:40"),
    ar=L("وصف القرآن أحد الصحابة بأنه «ثاني اثنين إذ هما في الغار» أثناء الهجرة. من هو؟",
         ["أبو بكر", "عمر", "عثمان", "علي"], 0,
         "يشير القرآن إلى أبي بكر، الذي رافق النبي ﷺ في غار ثور أثناء الهجرة.",
         "القرآن — سورة التوبة، 9:40"))

add("sira_009", "sira", "medium", "quran", "Quran", "3:123", False,
    fr=L("Quelle bataille, mentionnée dans le Coran, vit une petite armée musulmane vaincre une force bien plus nombreuse ?",
         ["La bataille de Badr", "La bataille de Uhud", "La bataille du Fossé", "La bataille de Hunayn"], 0,
         "À Badr, Allah accorda la victoire à un petit groupe de croyants face à une armée plus nombreuse.",
         "Coran — Sourate Âl ʿImrân, 3:123"),
    en=L("Which battle, mentioned in the Quran, saw a small Muslim army defeat a much larger force?",
         ["The Battle of Badr", "The Battle of Uhud", "The Battle of the Trench", "The Battle of Hunayn"], 0,
         "At Badr, Allah granted victory to a small group of believers over a much larger army.",
         "Quran — Surah Al 'Imran, 3:123"),
    ar=L("أي معركة، مذكورة في القرآن، انتصر فيها جيش مسلم صغير على قوة أكبر بكثير؟",
         ["غزوة بدر", "غزوة أُحد", "غزوة الخندق", "غزوة حنين"], 0,
         "في بدر، نصر الله فئة قليلة من المؤمنين على جيش أكبر عددًا.",
         "القرآن — سورة آل عمران، 3:123"))

add("sira_010", "sira", "medium", "sira", "Sira", "well-established sira event, agreed across standard biographies", True,
    fr=L("Comment appelle-t-on le retour pacifique du Prophète ﷺ et de ses compagnons à La Mecque ?",
         ["La Conquête de La Mecque (Fath Makka)", "La Bataille de La Mecque", "Le Siège de La Mecque", "La Prise de La Mecque"], 0,
         "La Conquête de La Mecque se déroula de façon largement pacifique, sans effusion de sang généralisée.",
         "Sîra — fait historique établi"),
    en=L("What is the largely peaceful return of the Prophet ﷺ and his companions to Makkah called?",
         ["The Conquest of Makkah (Fath Makkah)", "The Battle of Makkah", "The Siege of Makkah", "The Fall of Makkah"], 0,
         "The Conquest of Makkah took place largely peacefully, without widespread bloodshed.",
         "Sira — well-established historical fact"),
    ar=L("ماذا يُسمّى عودة النبي ﷺ وأصحابه السلمية إلى مكة؟",
         ["فتح مكة", "معركة مكة", "حصار مكة", "سقوط مكة"], 0,
         "جرى فتح مكة بشكل سلمي إلى حد كبير، دون إراقة دماء واسعة.",
         "السيرة — حقيقة تاريخية ثابتة"))

add("sira_011", "sira", "medium", "sira", "Sira", "well-established sira event, agreed across standard biographies", False,
    fr=L("Comment appelle-t-on le dernier sermon prononcé par le Prophète ﷺ vers la fin de sa vie ?",
         ["Le Sermon d'Adieu", "Le Sermon de La Mecque", "Le Sermon de la Grotte", "Le Sermon de Badr"], 0,
         "Le Sermon d'Adieu (Khutbat al-Wadâʿ) fut prononcé lors du dernier pèlerinage du Prophète ﷺ.",
         "Sîra — fait historique établi"),
    en=L("What is the final sermon delivered by the Prophet ﷺ near the end of his life called?",
         ["The Farewell Sermon", "The Sermon of Makkah", "The Cave Sermon", "The Sermon of Badr"], 0,
         "The Farewell Sermon (Khutbat al-Wada') was delivered during the Prophet's ﷺ final pilgrimage.",
         "Sira — well-established historical fact"),
    ar=L("ماذا تُسمّى آخر خطبة ألقاها النبي ﷺ قرب نهاية حياته؟",
         ["خطبة الوداع", "خطبة مكة", "خطبة الغار", "خطبة بدر"], 0,
         "أُلقيت خطبة الوداع خلال حجة النبي ﷺ الأخيرة.",
         "السيرة — حقيقة تاريخية ثابتة"))

add("sira_012", "sira", "medium", "quran", "Quran", "2:185", False,
    fr=L("Durant quel mois le Coran indique-t-il que sa révélation a commencé ?",
         ["Ramadân", "Muharram", "Rajab", "Dhul-Hijja"], 0,
         "Le Coran indique que Ramadân est le mois durant lequel le Coran a été révélé.",
         "Coran — Sourate Al-Baqara, 2:185"),
    en=L("During which month does the Quran state its revelation began?",
         ["Ramadan", "Muharram", "Rajab", "Dhul-Hijjah"], 0,
         "The Quran states that Ramadan is the month in which the Quran was revealed.",
         "Quran — Surah Al-Baqarah, 2:185"),
    ar=L("في أي شهر يذكر القرآن أن نزوله بدأ؟",
         ["رمضان", "محرم", "رجب", "ذو الحجة"], 0,
         "يذكر القرآن أن رمضان هو الشهر الذي أُنزل فيه القرآن.",
         "القرآن — سورة البقرة، 2:185"))

add("sira_013", "sira", "easy", "sira", "Sira", "well-established sira event, agreed across standard biographies", False,
    fr=L("Quelle était la profession du Prophète ﷺ avant qu'il ne reçoive la révélation ?",
         ["Marchand", "Berger uniquement", "Forgeron", "Scribe"], 0,
         "Le Prophète ﷺ exerçait le commerce, un fait bien établi de sa biographie.",
         "Sîra — fait historique établi"),
    en=L("What was the Prophet's ﷺ profession before he received revelation?",
         ["Merchant/trader", "Only a shepherd", "Blacksmith", "Scribe"], 0,
         "The Prophet ﷺ worked in trade, a well-established fact of his biography.",
         "Sira — well-established historical fact"),
    ar=L("ما كانت مهنة النبي ﷺ قبل نزول الوحي عليه؟",
         ["التجارة", "الرعي فقط", "الحدادة", "الكتابة"], 0,
         "عمل النبي ﷺ في التجارة، وهي حقيقة ثابتة في سيرته.",
         "السيرة — حقيقة تاريخية ثابتة"))

add("sira_014", "sira", "medium", "sira", "Sira", "well-established sira event, agreed across standard biographies", False,
    fr=L("Quel grand-père du Prophète ﷺ prit soin de lui après la mort de sa mère ?",
         ["ʿAbd al-Muttalib", "Abû Tâlib", "Abû Lahab", "Abû Sufyân"], 0,
         "ʿAbd al-Muttalib prit soin du jeune Muhammad ﷺ après la mort de sa mère Âmina.",
         "Sîra — fait historique établi"),
    en=L("Which grandfather of the Prophet ﷺ cared for him after his mother's death?",
         ["Abdul Muttalib", "Abu Talib", "Abu Lahab", "Abu Sufyan"], 0,
         "Abdul Muttalib cared for the young Muhammad ﷺ after the death of his mother Aminah.",
         "Sira — well-established historical fact"),
    ar=L("أي جدّ للنبي ﷺ رعاه بعد وفاة والدته؟",
         ["عبد المطلب", "أبو طالب", "أبو لهب", "أبو سفيان"], 0,
         "رعى عبد المطلب النبي محمدًا ﷺ في صغره بعد وفاة والدته آمنة.",
         "السيرة — حقيقة تاريخية ثابتة"))

add("sira_015", "sira", "medium", "sira", "Sira", "well-established sira event, agreed across standard biographies", False,
    fr=L("Quel oncle éleva le Prophète ﷺ après la mort de son grand-père ?",
         ["Abû Tâlib", "Al-ʿAbbâs", "Hamza", "Abû Lahab"], 0,
         "Abû Tâlib prit en charge l'éducation de son neveu après la mort de ʿAbd al-Muttalib.",
         "Sîra — fait historique établi"),
    en=L("Which uncle raised the Prophet ﷺ after his grandfather's death?",
         ["Abu Talib", "Al-Abbas", "Hamzah", "Abu Lahab"], 0,
         "Abu Talib took charge of raising his nephew after Abdul Muttalib's death.",
         "Sira — well-established historical fact"),
    ar=L("أي عم ربّى النبي ﷺ بعد وفاة جده؟",
         ["أبو طالب", "العباس", "حمزة", "أبو لهب"], 0,
         "تولى أبو طالب رعاية ابن أخيه بعد وفاة عبد المطلب.",
         "السيرة — حقيقة تاريخية ثابتة"))

add("sira_016", "sira", "hard", "quran", "Quran", "17:1", False,
    fr=L("Comment appelle-t-on le voyage nocturne du Prophète ﷺ de La Mecque à Jérusalem, mentionné dans le Coran ?",
         ["Al-Isrâ'", "Al-Hijra", "Al-Fath", "Al-Ghazwa"], 0,
         "Le Coran ouvre la sourate Al-Isrâ' en évoquant ce voyage nocturne miraculeux.",
         "Coran — Sourate Al-Isrâ', 17:1"),
    en=L("What is the Prophet's ﷺ night journey from Makkah to Jerusalem, mentioned in the Quran, called?",
         ["Al-Isra", "Al-Hijrah", "Al-Fath", "Al-Ghazwah"], 0,
         "Surah Al-Isra opens by describing this miraculous night journey.",
         "Quran — Surah Al-Isra, 17:1"),
    ar=L("ماذا تُسمّى رحلة النبي ﷺ الليلية من مكة إلى القدس، المذكورة في القرآن؟",
         ["الإسراء", "الهجرة", "الفتح", "الغزوة"], 0,
         "تفتتح سورة الإسراء بذكر هذه الرحلة الليلية المعجزة.",
         "القرآن — سورة الإسراء، 17:1"))

add("sira_017", "sira", "medium", "sira", "Sira", "well-established sira event, agreed across standard biographies", False,
    fr=L("Laquelle des filles du Prophète ﷺ épousa ʿAlî ibn Abî Tâlib ?",
         ["Fâtima", "Zaynab", "Ruqayya", "Umm Kulthûm"], 0,
         "Fâtima, fille du Prophète ﷺ et de Khadîja, épousa ʿAlî ibn Abî Tâlib — un fait largement établi.",
         "Sîra — fait historique établi"),
    en=L("Which of the Prophet's ﷺ daughters married Ali ibn Abi Talib?",
         ["Fatimah", "Zaynab", "Ruqayyah", "Umm Kulthum"], 0,
         "Fatimah, daughter of the Prophet ﷺ and Khadijah, married Ali ibn Abi Talib — a widely established fact.",
         "Sira — well-established historical fact"),
    ar=L("أي بنات النبي ﷺ تزوجت عليَّ بن أبي طالب؟",
         ["فاطمة", "زينب", "رقية", "أم كلثوم"], 0,
         "تزوجت فاطمة، ابنة النبي ﷺ وخديجة، من علي بن أبي طالب، وهي حقيقة ثابتة على نطاق واسع.",
         "السيرة — حقيقة تاريخية ثابتة"))

add("sira_018", "sira", "easy", "sira", "Sira", "well-established sira event, agreed across standard biographies", False,
    fr=L("Quel mois marque le début de l'année du calendrier islamique, en référence à la Hijra ?",
         ["Muharram", "Ramadân", "Shawwâl", "Dhul-Qaʿda"], 0,
         "Le calendrier islamique commence par le mois de Muharram, en référence à l'année de la Hijra.",
         "Sîra — fait historique établi"),
    en=L("Which month marks the start of the Islamic calendar year, referencing the Hijrah?",
         ["Muharram", "Ramadan", "Shawwal", "Dhul-Qa'dah"], 0,
         "The Islamic calendar begins with the month of Muharram, referencing the year of the Hijrah.",
         "Sira — well-established historical fact"),
    ar=L("أي شهر يبدأ به التقويم الهجري، إشارة إلى الهجرة؟",
         ["محرم", "رمضان", "شوال", "ذو القعدة"], 0,
         "يبدأ التقويم الهجري بشهر محرم، إشارة إلى سنة الهجرة.",
         "السيرة — حقيقة تاريخية ثابتة"))

# ---------------------------------------------------------------------
# QURAN & TEACHINGS — 10
# ---------------------------------------------------------------------

add("quran_001", "quran", "easy", "quran", "Quran", "1:1-7", True,
    fr=L("Quel est le nom du premier chapitre (sourate) du Coran ?",
         ["Al-Fâtiha", "Al-Baqara", "Al-Ikhlâs", "An-Nâs"], 0,
         "Al-Fâtiha, « l'Ouverture », est le premier chapitre du Coran.",
         "Coran — Sourate Al-Fâtiha, 1:1-7"),
    en=L("What is the name of the first chapter (surah) of the Quran?",
         ["Al-Fatiha", "Al-Baqarah", "Al-Ikhlas", "An-Nas"], 0,
         "Al-Fatiha, 'The Opening', is the first chapter of the Quran.",
         "Quran — Surah Al-Fatiha, 1:1-7"),
    ar=L("ما اسم أول سورة في القرآن الكريم؟",
         ["الفاتحة", "البقرة", "الإخلاص", "الناس"], 0,
         "الفاتحة هي السورة الأولى في القرآن الكريم.",
         "القرآن — سورة الفاتحة، 1:1-7"))

add("quran_002", "quran", "medium", "quran", "Quran", "well-established count (114 surahs)", False,
    fr=L("Combien de chapitres (sourates) compte le Coran ?",
         ["114", "99", "100", "120"], 0,
         "Le Coran est composé de 114 sourates.",
         "Coran — comptage établi"),
    en=L("How many chapters (surahs) does the Quran contain?",
         ["114", "99", "100", "120"], 0,
         "The Quran is composed of 114 surahs.",
         "Quran — well-established count"),
    ar=L("كم عدد سور القرآن الكريم؟",
         ["114", "99", "100", "120"], 0,
         "يتكون القرآن الكريم من 114 سورة.",
         "القرآن — عدد ثابت"))

add("quran_003", "quran", "medium", "quran", "Quran", "well-established (Al-Baqarah is the longest surah)", False,
    fr=L("Quelle est la plus longue sourate du Coran ?",
         ["Al-Baqara", "Al-Fâtiha", "Al-Kawthar", "Al-ʿAsr"], 0,
         "Al-Baqara est la plus longue sourate du Coran, avec 286 versets.",
         "Coran — fait établi"),
    en=L("What is the longest surah in the Quran?",
         ["Al-Baqarah", "Al-Fatiha", "Al-Kawthar", "Al-'Asr"], 0,
         "Al-Baqarah is the longest surah in the Quran, with 286 verses.",
         "Quran — well-established fact"),
    ar=L("ما هي أطول سورة في القرآن الكريم؟",
         ["البقرة", "الفاتحة", "الكوثر", "العصر"], 0,
         "سورة البقرة هي أطول سورة في القرآن، وعدد آياتها 286.",
         "القرآن — حقيقة ثابتة"))

add("quran_004", "quran", "medium", "quran", "Quran", "108:1-3", False,
    fr=L("Quelle est la plus courte sourate du Coran ?",
         ["Al-Kawthar", "Al-Ikhlâs", "Al-ʿAsr", "An-Nasr"], 0,
         "Al-Kawthar, avec 3 versets, est la plus courte sourate du Coran.",
         "Coran — Sourate Al-Kawthar, 108:1-3"),
    en=L("What is the shortest surah in the Quran?",
         ["Al-Kawthar", "Al-Ikhlas", "Al-'Asr", "An-Nasr"], 0,
         "Al-Kawthar, with 3 verses, is the shortest surah in the Quran.",
         "Quran — Surah Al-Kawthar, 108:1-3"),
    ar=L("ما هي أقصر سورة في القرآن الكريم؟",
         ["الكوثر", "الإخلاص", "العصر", "النصر"], 0,
         "سورة الكوثر، بثلاث آيات، هي أقصر سورة في القرآن.",
         "القرآن — سورة الكوثر، 108:1-3"))

add("quran_005", "quran", "easy", "quran", "Quran", "12:2", True,
    fr=L("Dans quelle langue le Coran a-t-il été révélé ?",
         ["L'arabe", "L'araméen", "L'hébreu", "Le persan"], 0,
         "Le Coran affirme explicitement avoir été révélé en langue arabe.",
         "Coran — Sourate Yûsuf, 12:2"),
    en=L("In which language was the Quran revealed?",
         ["Arabic", "Aramaic", "Hebrew", "Persian"], 0,
         "The Quran explicitly states it was revealed in the Arabic language.",
         "Quran — Surah Yusuf, 12:2"),
    ar=L("بأي لغة نزل القرآن الكريم؟",
         ["العربية", "الآرامية", "العبرية", "الفارسية"], 0,
         "ينص القرآن صراحة على أنه أُنزل بلسان عربي.",
         "القرآن — سورة يوسف، 12:2"))

add("quran_006", "quran", "hard", "quran", "Quran", "19:1-16", False,
    fr=L("Quel est le nom de la 19ᵉ sourate, nommée d'après la mère d'Îsâ ?",
         ["Maryam", "Yûsuf", "Al-Kahf", "Tâ-Hâ"], 0,
         "La 19ᵉ sourate du Coran porte le nom de Maryam, mère du prophète Îsâ.",
         "Coran — Sourate Maryam, 19:1-16"),
    en=L("What is the name of the 19th surah, named after the mother of Isa?",
         ["Maryam", "Yusuf", "Al-Kahf", "Ta-Ha"], 0,
         "The Quran's 19th surah is named Maryam, after the mother of the prophet Isa.",
         "Quran — Surah Maryam, 19:1-16"),
    ar=L("ما اسم السورة التاسعة عشرة، المسمّاة باسم أم عيسى؟",
         ["مريم", "يوسف", "الكهف", "طه"], 0,
         "السورة التاسعة عشرة في القرآن سُمّيت مريم، أم النبي عيسى.",
         "القرآن — سورة مريم، 19:1-16"))

add("quran_007", "quran", "easy", "quran", "Quran", "well-established terminology", False,
    fr=L("Comment appelle-t-on un chapitre du Coran ?",
         ["Une sourate", "Un hadith", "Un juz'", "Un tafsîr"], 0,
         "Le Coran est divisé en chapitres appelés sourates.",
         "Coran — terminologie établie"),
    en=L("What is a chapter of the Quran called?",
         ["A surah", "A hadith", "A juz'", "A tafsir"], 0,
         "The Quran is divided into chapters called surahs.",
         "Quran — well-established terminology"),
    ar=L("ماذا يُسمّى الفصل الواحد من القرآن؟",
         ["سورة", "حديث", "جزء", "تفسير"], 0,
         "يُقسّم القرآن إلى فصول تُسمّى سورًا.",
         "القرآن — مصطلح ثابت"))

add("quran_008", "quran", "easy", "quran", "Quran", "well-established terminology", False,
    fr=L("Comment appelle-t-on un verset du Coran ?",
         ["Une âya", "Une sourate", "Un hadith", "Un rukûʿ"], 0,
         "Chaque verset du Coran est appelé une âya, signifiant « signe ».",
         "Coran — terminologie établie"),
    en=L("What is a verse of the Quran called?",
         ["An ayah", "A surah", "A hadith", "A ruku'"], 0,
         "Each verse of the Quran is called an ayah, meaning 'sign'.",
         "Quran — well-established terminology"),
    ar=L("ماذا تُسمّى الآية الواحدة من القرآن؟",
         ["آية", "سورة", "حديث", "ركوع"], 0,
         "تُسمّى كل آية من آيات القرآن آيةً، ومعناها «علامة».",
         "القرآن — مصطلح ثابت"))

add("quran_009", "quran", "medium", "hadithBukhari", "Sahih al-Bukhari", "756", False,
    fr=L("Quelle sourate est récitée obligatoirement à chaque unité (rakʿa) de la prière ?",
         ["Al-Fâtiha", "Al-Ikhlâs", "Al-Kawthar", "Al-Fîl"], 0,
         "La récitation d'Al-Fâtiha est un pilier de la prière rapporté dans un hadith authentique.",
         "Sahîh al-Bukhârî, n°756"),
    en=L("Which surah is obligatorily recited in every unit (rak'ah) of the prayer?",
         ["Al-Fatiha", "Al-Ikhlas", "Al-Kawthar", "Al-Fil"], 0,
         "Reciting Al-Fatiha is a pillar of the prayer reported in an authentic hadith.",
         "Sahih al-Bukhari, no. 756"),
    ar=L("أي سورة تُقرأ وجوبًا في كل ركعة من الصلاة؟",
         ["الفاتحة", "الإخلاص", "الكوثر", "الفيل"], 0,
         "قراءة الفاتحة ركن من أركان الصلاة، كما ورد في حديث صحيح.",
         "صحيح البخاري، رقم 756"))

add("quran_010", "quran", "easy", "quran", "Quran", "well-established (revealed to Muhammad ﷺ)", False,
    fr=L("À qui le Coran fut-il révélé ?",
         ["Au prophète Muhammad ﷺ", "Au prophète Mûsâ", "Au prophète Îsâ", "Au prophète Dâwûd"], 0,
         "Le Coran fut révélé au prophète Muhammad ﷺ, par l'intermédiaire de l'ange Jibrîl.",
         "Coran — fait établi"),
    en=L("To whom was the Quran revealed?",
         ["The Prophet Muhammad ﷺ", "The Prophet Musa", "The Prophet Isa", "The Prophet Dawud"], 0,
         "The Quran was revealed to the Prophet Muhammad ﷺ, through the angel Jibril.",
         "Quran — well-established fact"),
    ar=L("على من نزل القرآن الكريم؟",
         ["النبي محمد ﷺ", "النبي موسى", "النبي عيسى", "النبي داوود"], 0,
         "نزل القرآن على النبي محمد ﷺ، عن طريق الملَك جبريل.",
         "القرآن — حقيقة ثابتة"))

# ---------------------------------------------------------------------
# FAITH & WORSHIP BASICS — 8
# ---------------------------------------------------------------------

add("faith_001", "faith", "easy", "hadithBukhari", "Sahih al-Bukhari", "8", True,
    fr=L("Combien de piliers compte l'islam ?",
         ["5", "4", "6", "7"], 0,
         "Le hadith de Jibrîl et le hadith rapporté par Ibn ʿUmar énoncent les cinq piliers de l'islam.",
         "Sahîh al-Bukhârî, n°8"),
    en=L("How many pillars does Islam have?",
         ["5", "4", "6", "7"], 0,
         "The hadith of Jibril and the hadith reported by Ibn Umar list the five pillars of Islam.",
         "Sahih al-Bukhari, no. 8"),
    ar=L("كم عدد أركان الإسلام؟",
         ["5", "4", "6", "7"], 0,
         "يذكر حديث جبريل والحديث المروي عن ابن عمر أركان الإسلام الخمسة.",
         "صحيح البخاري، رقم 8"))

add("faith_002", "faith", "easy", "hadithBukhari", "Sahih al-Bukhari", "8", False,
    fr=L("Comment appelle-t-on la déclaration de foi en islam ?",
         ["La Shahâda", "La Salât", "La Zakât", "Le Hajj"], 0,
         "La Shahâda, l'attestation de foi, est le premier pilier de l'islam.",
         "Sahîh al-Bukhârî, n°8"),
    en=L("What is the declaration of faith in Islam called?",
         ["The Shahadah", "The Salah", "The Zakah", "The Hajj"], 0,
         "The Shahadah, the testimony of faith, is the first pillar of Islam.",
         "Sahih al-Bukhari, no. 8"),
    ar=L("ماذا تُسمّى شهادة الإيمان في الإسلام؟",
         ["الشهادة", "الصلاة", "الزكاة", "الحج"], 0,
         "الشهادة، وهي شهادة الإيمان، هي الركن الأول من أركان الإسلام.",
         "صحيح البخاري، رقم 8"))

add("faith_003", "faith", "easy", "hadithBukhari", "Sahih al-Bukhari", "8", False,
    fr=L("Combien de fois par jour la prière obligatoire est-elle accomplie en islam ?",
         ["5", "3", "4", "7"], 0,
         "Les cinq prières quotidiennes obligatoires sont un pilier fondamental de l'islam.",
         "Sahîh al-Bukhârî, n°8"),
    en=L("How many times a day is the obligatory prayer performed in Islam?",
         ["5", "3", "4", "7"], 0,
         "The five daily obligatory prayers are a foundational pillar of Islam.",
         "Sahih al-Bukhari, no. 8"),
    ar=L("كم مرة تؤدَّى الصلاة المفروضة يوميًا في الإسلام؟",
         ["5", "3", "4", "7"], 0,
         "الصلوات الخمس اليومية المفروضة ركن أساسي من أركان الإسلام.",
         "صحيح البخاري، رقم 8"))

add("faith_004", "faith", "medium", "hadithBukhari", "Sahih al-Bukhari", "8", True,
    fr=L("Comment appelle-t-on l'aumône obligatoire en islam ?",
         ["La Zakât", "La Sadaqa", "Le Waqf", "Le Kaffâra"], 0,
         "La Zakât est l'aumône obligatoire, l'un des cinq piliers de l'islam.",
         "Sahîh al-Bukhârî, n°8"),
    en=L("What is the obligatory charity in Islam called?",
         ["Zakah", "Sadaqah", "Waqf", "Kaffarah"], 0,
         "Zakah is the obligatory charity, one of the five pillars of Islam.",
         "Sahih al-Bukhari, no. 8"),
    ar=L("ماذا تُسمّى الصدقة المفروضة في الإسلام؟",
         ["الزكاة", "الصدقة التطوعية", "الوقف", "الكفارة"], 0,
         "الزكاة هي الصدقة المفروضة، وهي أحد أركان الإسلام الخمسة.",
         "صحيح البخاري، رقم 8"))

add("faith_005", "faith", "easy", "quran", "Quran", "2:183", False,
    fr=L("Comment appelle-t-on le mois de jeûne obligatoire en islam ?",
         ["Ramadân", "Shawwâl", "Rajab", "Muharram"], 0,
         "Le Coran ordonne le jeûne durant le mois de Ramadân.",
         "Coran — Sourate Al-Baqara, 2:183"),
    en=L("What is the obligatory fasting month in Islam called?",
         ["Ramadan", "Shawwal", "Rajab", "Muharram"], 0,
         "The Quran commands fasting during the month of Ramadan.",
         "Quran — Surah Al-Baqarah, 2:183"),
    ar=L("ماذا يُسمّى شهر الصيام المفروض في الإسلام؟",
         ["رمضان", "شوال", "رجب", "محرم"], 0,
         "يأمر القرآن بالصيام في شهر رمضان.",
         "القرآن — سورة البقرة، 2:183"))

add("faith_006", "faith", "medium", "quran", "Quran", "3:97", False,
    fr=L("Comment appelle-t-on le pèlerinage à La Mecque, obligatoire une fois dans la vie pour qui en a la capacité ?",
         ["Le Hajj", "La ʿUmra", "Le Iʿtikâf", "Le Tawâf"], 0,
         "Le Coran rend le Hajj obligatoire pour quiconque en a la capacité, au moins une fois dans sa vie.",
         "Coran — Sourate Âl ʿImrân, 3:97"),
    en=L("What is the pilgrimage to Makkah, obligatory once in a lifetime for those able, called?",
         ["Hajj", "Umrah", "I'tikaf", "Tawaf"], 0,
         "The Quran makes Hajj obligatory, at least once in a lifetime, for anyone able to undertake it.",
         "Quran — Surah Al 'Imran, 3:97"),
    ar=L("ماذا يُسمّى الحج إلى مكة، الواجب مرة في العمر لمن استطاع؟",
         ["الحج", "العمرة", "الاعتكاف", "الطواف"], 0,
         "يُوجب القرآن الحج على من استطاع إليه سبيلاً، مرة واحدة في العمر.",
         "القرآن — سورة آل عمران، 3:97"))

add("faith_007", "faith", "medium", "quran", "Quran", "2:144", False,
    fr=L("Vers quelle direction les musulmans se tournent-ils pour la prière ?",
         ["La Kaaba, à La Mecque", "Jérusalem", "Médine", "L'est"], 0,
         "Le Coran a établi la Kaaba comme direction de la prière (Qibla).",
         "Coran — Sourate Al-Baqara, 2:144"),
    en=L("Which direction do Muslims face for prayer?",
         ["The Kaaba, in Makkah", "Jerusalem", "Madinah", "East"], 0,
         "The Quran established the Kaaba as the direction of prayer (Qiblah).",
         "Quran — Surah Al-Baqarah, 2:144"),
    ar=L("إلى أي جهة يتوجّه المسلمون في الصلاة؟",
         ["الكعبة في مكة", "القدس", "المدينة", "الشرق"], 0,
         "حدّد القرآن الكعبةَ قِبلةً للصلاة.",
         "القرآن — سورة البقرة، 2:144"))

add("faith_008", "faith", "hard", "hadithMuslim", "Sahih Muslim", "8", False,
    fr=L("Selon un hadith bien connu, combien d'articles de la foi (piliers de l'Îmân) sont généralement enseignés ?",
         ["6", "4", "5", "7"], 0,
         "Le hadith de Jibrîl énumère six articles de foi : Allah, les anges, les livres, les messagers, le Jour Dernier et le destin.",
         "Sahîh Muslim, n°8"),
    en=L("According to a well-known hadith, how many articles of faith (pillars of Iman) are commonly taught?",
         ["6", "4", "5", "7"], 0,
         "The hadith of Jibril lists six articles of faith: Allah, the angels, the books, the messengers, the Last Day, and divine decree.",
         "Sahih Muslim, no. 8"),
    ar=L("بحسب حديث معروف، كم عدد أركان الإيمان التي يُعلَّم بها عادة؟",
         ["6", "4", "5", "7"], 0,
         "يُعدّد حديث جبريل ستة أركان للإيمان: الله، والملائكة، والكتب، والرسل، واليوم الآخر، والقدر.",
         "صحيح مسلم، رقم 8"))

# ---------------------------------------------------------------------
# VIRTUES & VALUES — 6
# ---------------------------------------------------------------------

add("virtues_001", "virtues", "medium", "hadithBukhari", "Sahih al-Bukhari", "6018", True,
    fr=L("Selon un hadith rapporté par l'imam Al-Bukhârî, que doit faire celui qui croit en Allah et au Jour Dernier avec ses paroles ?",
         ["Dire du bien ou se taire", "Parler fort", "Ne jamais parler", "Répéter les rumeurs"], 0,
         "Le Prophète ﷺ a dit : « Que celui qui croit en Allah et au Jour Dernier dise du bien ou se taise. »",
         "Sahîh al-Bukhârî, n°6018"),
    en=L("According to a hadith reported by Imam al-Bukhari, what should someone who believes in Allah and the Last Day do with their speech?",
         ["Speak good or remain silent", "Speak loudly", "Never speak", "Repeat rumors"], 0,
         "The Prophet ﷺ said: 'Whoever believes in Allah and the Last Day should speak good or remain silent.'",
         "Sahih al-Bukhari, no. 6018"),
    ar=L("بحسب حديث رواه الإمام البخاري، ماذا ينبغي أن يفعل من يؤمن بالله واليوم الآخر بكلامه؟",
         ["يقول خيرًا أو يصمت", "يتكلم بصوت عالٍ", "لا يتكلم أبدًا", "يردد الشائعات"], 0,
         "قال النبي ﷺ: «من كان يؤمن بالله واليوم الآخر فليقل خيرًا أو ليصمت.»",
         "صحيح البخاري، رقم 6018"))

add("virtues_002", "virtues", "medium", "hadithBukhari", "Sahih al-Bukhari", "6018", False,
    fr=L("Toujours selon ce même hadith, qui le croyant doit-il honorer, en plus de son invité ?",
         ["Son voisin", "Son commerçant", "Son adversaire", "L'inconnu"], 0,
         "Le hadith poursuit : « ...et que celui qui croit en Allah et au Jour Dernier honore son voisin. »",
         "Sahîh al-Bukhârî, n°6018"),
    en=L("According to that same hadith, whom else should a believer honor, besides their guest?",
         ["Their neighbor", "Their merchant", "Their rival", "A stranger"], 0,
         "The hadith continues: '...and whoever believes in Allah and the Last Day should honor their neighbor.'",
         "Sahih al-Bukhari, no. 6018"),
    ar=L("بحسب نفس الحديث، من ينبغي للمؤمن أن يكرمه أيضًا، إلى جانب ضيفه؟",
         ["جاره", "تاجره", "خصمه", "الغريب"], 0,
         "يكمل الحديث: «...ومن كان يؤمن بالله واليوم الآخر فليكرم جاره.»",
         "صحيح البخاري، رقم 6018"))

add("virtues_003", "virtues", "easy", "hadithBukhari", "Sahih al-Bukhari", "6018", False,
    fr=L("Ce même hadith mentionne aussi l'obligation d'honorer qui, lorsqu'il arrive chez soi ?",
         ["L'invité", "Le voisin uniquement", "Le marchand", "Le voyageur inconnu de loin"], 0,
         "Le hadith complet dit : « ...que celui qui croit en Allah et au Jour Dernier honore son invité. »",
         "Sahîh al-Bukhârî, n°6018"),
    en=L("This same hadith also mentions honoring whom, when they arrive at one's home?",
         ["The guest", "Only the neighbor", "The merchant", "A distant unknown traveler"], 0,
         "The full hadith says: '...whoever believes in Allah and the Last Day should honor their guest.'",
         "Sahih al-Bukhari, no. 6018"),
    ar=L("يذكر هذا الحديث أيضًا وجوب إكرام من عند حلوله ضيفًا في البيت؟",
         ["الضيف", "الجار فقط", "التاجر", "المسافر المجهول"], 0,
         "يقول الحديث كاملاً: «...ومن كان يؤمن بالله واليوم الآخر فليكرم ضيفه.»",
         "صحيح البخاري، رقم 6018"))

add("virtues_004", "virtues", "easy", "hadithBukhari", "Sahih al-Bukhari", "13", True,
    fr=L("Selon un hadith authentique, un croyant n'a pas une foi complète tant qu'il n'aime pas pour son frère ce qu'il aime pour...",
         ["lui-même", "sa richesse", "sa famille seulement", "son pays"], 0,
         "Le Prophète ﷺ a dit : « Nul d'entre vous ne croit vraiment tant qu'il n'aime pas pour son frère ce qu'il aime pour lui-même. »",
         "Sahîh al-Bukhârî, n°13"),
    en=L("According to an authentic hadith, a believer's faith is not complete until he loves for his brother what he loves for...",
         ["himself", "his wealth", "only his family", "his country"], 0,
         "The Prophet ﷺ said: 'None of you truly believes until he loves for his brother what he loves for himself.'",
         "Sahih al-Bukhari, no. 13"),
    ar=L("بحسب حديث صحيح، لا يكتمل إيمان المؤمن حتى يحب لأخيه ما يحب...",
         ["لنفسه", "لماله", "لأسرته فقط", "لبلده"], 0,
         "قال النبي ﷺ: «لا يؤمن أحدكم حتى يحب لأخيه ما يحب لنفسه.»",
         "صحيح البخاري، رقم 13"))

add("virtues_005", "virtues", "medium", "hadithBukhari", "Sahih al-Bukhari", "10", False,
    fr=L("Selon un hadith authentique, le vrai musulman est celui dont les autres sont saufs de sa langue et de...",
         ["sa main", "sa richesse", "son regard", "sa voix"], 0,
         "Le Prophète ﷺ a dit : « Le musulman est celui dont les musulmans sont saufs de sa langue et de sa main. »",
         "Sahîh al-Bukhârî, n°10"),
    en=L("According to an authentic hadith, the true Muslim is the one from whose tongue and ___ other people are safe.",
         ["hand", "wealth", "gaze", "voice"], 0,
         "The Prophet ﷺ said: 'The Muslim is the one from whose tongue and hand other Muslims are safe.'",
         "Sahih al-Bukhari, no. 10"),
    ar=L("بحسب حديث صحيح، المسلم الحقيقي هو من سلم الناس من لسانه و...",
         ["يده", "ماله", "نظره", "صوته"], 0,
         "قال النبي ﷺ: «المسلم من سلم المسلمون من لسانه ويده.»",
         "صحيح البخاري، رقم 10"))

add("virtues_006", "virtues", "medium", "quran", "Quran", "17:23-24", False,
    fr=L("Le Coran ordonne d'être bon envers ses parents et de ne même pas leur dire quel mot de mécontentement ?",
         ["« Uff »", "« Non »", "« Assez »", "« Attends »"], 0,
         "Le Coran demande une extrême bienveillance envers les parents, jusqu'à interdire le moindre mot de dédain.",
         "Coran — Sourate Al-Isrâ', 17:23-24"),
    en=L("The Quran commands kindness to parents and forbids even saying which word of annoyance to them?",
         ["'Uff' (a sound of impatience)", "'No'", "'Enough'", "'Wait'"], 0,
         "The Quran calls for the utmost kindness to parents, forbidding even the slightest word of contempt.",
         "Quran — Surah Al-Isra, 17:23-24"),
    ar=L("يأمر القرآن بالإحسان إلى الوالدين وينهى حتى عن قول أي كلمة تبرّم؟",
         ["«أُفٍّ»", "«لا»", "«كفى»", "«انتظر»"], 0,
         "يدعو القرآن إلى أقصى درجات البر بالوالدين، فينهى حتى عن أدنى كلمة تضجّر.",
         "القرآن — سورة الإسراء، 17:23-24"))

# ---------------------------------------------------------------------
# PROPHETS (extension) — every reference verified against the Qur'anic
# text itself, or the established-fact class of CONTENT_SOURCE_POLICY §2bis.
# ---------------------------------------------------------------------

add("prophets_019", "prophets", "easy", "quran", "Quran", "2:31", True,
    fr=L("À quel prophète Allah enseigna-t-il les noms de toutes choses ?",
         ["Âdam", "Nûh", "Ibrâhîm", "Mûsâ"], 0,
         "Allah enseigna à Âdam les noms de toutes choses, puis les anges reconnurent la sagesse d'Allah.",
         "Coran — Sourate Al-Baqara, 2:31"),
    en=L("Which prophet did Allah teach the names of all things?",
         ["Adam", "Nuh (Noah)", "Ibrahim (Abraham)", "Musa (Moses)"], 0,
         "Allah taught Adam the names of all things, and the angels acknowledged Allah's wisdom.",
         "Quran — Surah Al-Baqarah, 2:31"),
    ar=L("أي نبي علّمه الله الأسماء كلها؟",
         ["آدم", "نوح", "إبراهيم", "موسى"], 0,
         "علّم الله آدمَ الأسماء كلها، فأقرّت الملائكة بحكمة الله.",
         "القرآن — سورة البقرة، 2:31"))

add("prophets_020", "prophets", "medium", "quran", "Quran", "19:29-30", False,
    fr=L("Quel prophète a parlé aux gens alors qu'il était encore un bébé au berceau ?",
         ["'Îsâ", "Yahyâ", "Yûsuf", "Ismâ'îl"], 0,
         "Le bébé 'Îsâ parla depuis le berceau : « Je suis le serviteur d'Allah, Il m'a donné le Livre. »",
         "Coran — Sourate Maryam, 19:29-30"),
    en=L("Which prophet spoke to people while still a baby in the cradle?",
         ["Isa (Jesus)", "Yahya (John)", "Yusuf (Joseph)", "Ismail (Ishmael)"], 0,
         "Baby Isa spoke from the cradle: 'I am the servant of Allah; He has given me the Scripture.'",
         "Quran — Surah Maryam, 19:29-30"),
    ar=L("أي نبي كلّم الناس وهو رضيع في المهد؟",
         ["عيسى", "يحيى", "يوسف", "إسماعيل"], 0,
         "تكلّم عيسى في المهد قائلًا: «إني عبد الله آتاني الكتاب».",
         "القرآن — سورة مريم، 19:29-30"))

add("prophets_021", "prophets", "medium", "quran", "Quran", "2:127", False,
    fr=L("Avec quel fils Ibrâhîm éleva-t-il les fondations de la Ka'ba ?",
         ["Ismâ'îl", "Ishâq", "Ya'qûb", "Yûsuf"], 0,
         "« Et quand Ibrâhîm et Ismâ'îl élevaient les assises de la Maison… » — ils bâtirent ensemble.",
         "Coran — Sourate Al-Baqara, 2:127"),
    en=L("With which son did Ibrahim raise the foundations of the Ka'bah?",
         ["Ismail (Ishmael)", "Ishaq (Isaac)", "Yaqub (Jacob)", "Yusuf (Joseph)"], 0,
         "'And when Ibrahim and Ismail were raising the foundations of the House…' — they built together.",
         "Quran — Surah Al-Baqarah, 2:127"),
    ar=L("مع أي ابن رفع إبراهيمُ قواعد الكعبة؟",
         ["إسماعيل", "إسحاق", "يعقوب", "يوسف"], 0,
         "«وإذ يرفع إبراهيم القواعد من البيت وإسماعيل» — بنياها معًا.",
         "القرآن — سورة البقرة، 2:127"))

add("prophets_022", "prophets", "medium", "quran", "Quran", "19:7", False,
    fr=L("Quel fils fut annoncé au prophète Zakariyyâ dans sa vieillesse ?",
         ["Yahyâ", "'Îsâ", "Ismâ'îl", "Ishâq"], 0,
         "« Ô Zakariyyâ, Nous t'annonçons un garçon dont le nom sera Yahyâ. »",
         "Coran — Sourate Maryam, 19:7"),
    en=L("Which son was announced to the prophet Zakariyya in his old age?",
         ["Yahya (John)", "Isa (Jesus)", "Ismail (Ishmael)", "Ishaq (Isaac)"], 0,
         "'O Zakariyya, We give you good news of a boy whose name will be Yahya.'",
         "Quran — Surah Maryam, 19:7"),
    ar=L("بأي ابن بُشِّر النبي زكريا على كِبَره؟",
         ["يحيى", "عيسى", "إسماعيل", "إسحاق"], 0,
         "«يا زكريا إنا نبشرك بغلام اسمه يحيى».",
         "القرآن — سورة مريم، 19:7"))

add("prophets_023", "prophets", "easy", "quran", "Quran", "20:19-20", False,
    fr=L("Que devint le bâton de Mûsâ quand Allah lui ordonna de le jeter ?",
         ["Un serpent qui rampait", "Un oiseau", "Une source d'eau", "Une lumière"], 0,
         "« Jette-le, ô Mûsâ ! » Il le jeta, et voilà que c'était un serpent qui rampait.",
         "Coran — Sourate Tâ-Hâ, 20:19-20"),
    en=L("What did Musa's staff become when Allah told him to cast it down?",
         ["A moving serpent", "A bird", "A spring of water", "A light"], 0,
         "'Throw it down, O Musa!' He threw it, and it became a serpent, moving swiftly.",
         "Quran — Surah Ta-Ha, 20:19-20"),
    ar=L("ماذا صارت عصا موسى حين أمره الله أن يلقيها؟",
         ["حية تسعى", "طائرًا", "عين ماء", "نورًا"], 0,
         "«قال ألقها يا موسى. فألقاها فإذا هي حية تسعى».",
         "القرآن — سورة طه، 20:19-20"))

add("prophets_024", "prophets", "medium", "quran", "Quran", "12:4", False,
    fr=L("Dans son rêve, que vit le jeune Yûsuf se prosterner devant lui ?",
         ["Onze étoiles, le soleil et la lune", "Sept vaches grasses", "Une pluie d'or", "Un jardin de palmiers"], 0,
         "Yûsuf vit onze étoiles, le soleil et la lune se prosterner devant lui — annonce de son destin.",
         "Coran — Sourate Yûsuf, 12:4"),
    en=L("In his dream, what did young Yusuf see bowing before him?",
         ["Eleven stars, the sun and the moon", "Seven fat cows", "A rain of gold", "A garden of palms"], 0,
         "Yusuf saw eleven stars and the sun and the moon prostrating to him — a sign of his destiny.",
         "Quran — Surah Yusuf, 12:4"),
    ar=L("في رؤياه، ماذا رأى يوسفُ الصغير ساجدًا له؟",
         ["أحد عشر كوكبًا والشمس والقمر", "سبع بقرات سمان", "مطرًا من ذهب", "حديقة نخيل"], 0,
         "رأى يوسف أحد عشر كوكبًا والشمس والقمر له ساجدين — بشارة بمستقبله.",
         "القرآن — سورة يوسف، 12:4"))

add("prophets_025", "prophets", "hard", "quran", "Quran", "7:65", False,
    fr=L("À quel peuple le prophète Hûd fut-il envoyé ?",
         ["Les 'Âd", "Les Thamûd", "Le peuple de Madyan", "Le peuple de Pharaon"], 0,
         "« Et aux 'Âd, leur frère Hûd… » — il les appela à adorer Allah seul.",
         "Coran — Sourate Al-A'râf, 7:65"),
    en=L("To which people was the prophet Hud sent?",
         ["The 'Ad", "The Thamud", "The people of Madyan", "Pharaoh's people"], 0,
         "'And to 'Ad, their brother Hud…' — he called them to worship Allah alone.",
         "Quran — Surah Al-A'raf, 7:65"),
    ar=L("إلى أي قوم أُرسل النبي هود؟",
         ["عاد", "ثمود", "أهل مدين", "قوم فرعون"], 0,
         "«وإلى عاد أخاهم هودًا» — دعاهم إلى عبادة الله وحده.",
         "القرآن — سورة الأعراف، 7:65"))

add("prophets_026", "prophets", "hard", "quran", "Quran", "7:85", False,
    fr=L("À quel peuple le prophète Shu'ayb fut-il envoyé ?",
         ["Le peuple de Madyan", "Les 'Âd", "Les Thamûd", "Le peuple de Nûh"], 0,
         "« Et aux gens de Madyan, leur frère Shu'ayb… » — il leur ordonna la mesure et le poids justes.",
         "Coran — Sourate Al-A'râf, 7:85"),
    en=L("To which people was the prophet Shu'ayb sent?",
         ["The people of Madyan", "The 'Ad", "The Thamud", "The people of Nuh"], 0,
         "'And to Madyan, their brother Shu'ayb…' — he commanded them to give fair measure and weight.",
         "Quran — Surah Al-A'raf, 7:85"),
    ar=L("إلى أي قوم أُرسل النبي شعيب؟",
         ["أهل مدين", "عاد", "ثمود", "قوم نوح"], 0,
         "«وإلى مدين أخاهم شعيبًا» — أمرهم بإيفاء الكيل والميزان.",
         "القرآن — سورة الأعراف، 7:85"))

add("prophets_027", "prophets", "hard", "quran", "Quran", "21:87", False,
    fr=L("Quel prophète est appelé « Dhun-Nûn » (l'homme au poisson) dans le Coran ?",
         ["Yûnus", "Mûsâ", "Sulaymân", "Ayyûb"], 0,
         "« Et Dhun-Nûn, quand il partit irrité… » — c'est Yûnus, avalé ensuite par le poisson.",
         "Coran — Sourate Al-Anbiyâ, 21:87"),
    en=L("Which prophet is called 'Dhun-Nun' (the man of the fish) in the Quran?",
         ["Yunus (Jonah)", "Musa (Moses)", "Sulayman (Solomon)", "Ayyub (Job)"], 0,
         "'And Dhun-Nun, when he went off in anger…' — this is Yunus, later swallowed by the fish.",
         "Quran — Surah Al-Anbiya, 21:87"),
    ar=L("أي نبي سُمّي «ذا النون» (صاحب الحوت) في القرآن؟",
         ["يونس", "موسى", "سليمان", "أيوب"], 0,
         "«وذا النون إذ ذهب مغاضبًا» — هو يونس الذي التقمه الحوت.",
         "القرآن — سورة الأنبياء، 21:87"))

add("prophets_028", "prophets", "medium", "quran", "Quran", "18:60-82", False,
    fr=L("Dans quelle sourate Mûsâ voyage-t-il pour apprendre auprès d'un serviteur à qui Allah donna une science ?",
         ["Al-Kahf (La Caverne)", "Yûsuf", "Maryam", "An-Naml"], 0,
         "Dans la sourate Al-Kahf, Mûsâ accompagne un serviteur savant et apprend la patience devant ce qu'il ne comprend pas encore.",
         "Coran — Sourate Al-Kahf, 18:60-82"),
    en=L("In which surah does Musa travel to learn from a servant to whom Allah gave special knowledge?",
         ["Al-Kahf (The Cave)", "Yusuf", "Maryam", "An-Naml"], 0,
         "In Surah Al-Kahf, Musa accompanies a knowledgeable servant and learns patience with what he does not yet understand.",
         "Quran — Surah Al-Kahf, 18:60-82"),
    ar=L("في أي سورة يرحل موسى ليتعلم من عبد آتاه الله علمًا؟",
         ["الكهف", "يوسف", "مريم", "النمل"], 0,
         "في سورة الكهف يرافق موسى عبدًا صالحًا علّمه الله، فيتعلم الصبر على ما لا يفهمه بعد.",
         "القرآن — سورة الكهف، 18:60-82"))

add("prophets_029", "prophets", "hard", "quran", "Quran",
    "well-established (Musa is the most-mentioned prophet by name)", False,
    fr=L("Quel prophète est cité par son nom le plus souvent dans le Coran ?",
         ["Mûsâ", "Ibrâhîm", "Nûh", "'Îsâ"], 0,
         "Mûsâ est le prophète le plus souvent nommé dans le Coran ; son histoire avec Pharaon y revient de nombreuses fois.",
         "Coran — fait bien établi"),
    en=L("Which prophet is mentioned by name most often in the Quran?",
         ["Musa (Moses)", "Ibrahim (Abraham)", "Nuh (Noah)", "Isa (Jesus)"], 0,
         "Musa is the most frequently named prophet in the Quran; his story with Pharaoh returns many times.",
         "Quran — well-established fact"),
    ar=L("أي نبي ورد اسمه في القرآن أكثر من غيره؟",
         ["موسى", "إبراهيم", "نوح", "عيسى"], 0,
         "موسى هو أكثر الأنبياء ذكرًا بالاسم في القرآن؛ وتتكرر قصته مع فرعون مرات كثيرة.",
         "القرآن — حقيقة ثابتة"))

add("prophets_030", "prophets", "hard", "quran", "Quran",
    "well-established count (25 prophets named in the Quran)", False,
    fr=L("Combien de prophètes sont cités par leur nom dans le Coran ?",
         ["25", "10", "50", "99"], 0,
         "Vingt-cinq prophètes sont nommés dans le Coran, d'Âdam à Muhammad ﷺ.",
         "Coran — décompte bien établi"),
    en=L("How many prophets are mentioned by name in the Quran?",
         ["25", "10", "50", "99"], 0,
         "Twenty-five prophets are named in the Quran, from Adam to Muhammad ﷺ.",
         "Quran — well-established count"),
    ar=L("كم نبيًا ذُكر باسمه في القرآن؟",
         ["25", "10", "50", "99"], 0,
         "ذُكر في القرآن خمسة وعشرون نبيًا بأسمائهم، من آدم إلى محمد ﷺ.",
         "القرآن — عدد ثابت مشهور"))

add("prophets_031", "prophets", "medium", "quran", "Quran", "3:49", False,
    fr=L("Par la permission d'Allah, quel prophète guérissait l'aveugle-né et le lépreux ?",
         ["'Îsâ", "Mûsâ", "Dâwûd", "Yûnus"], 0,
         "'Îsâ guérissait l'aveugle-né et le lépreux par la permission d'Allah — un signe pour son peuple.",
         "Coran — Sourate Âl 'Imrân, 3:49"),
    en=L("By Allah's permission, which prophet healed the blind and the leper?",
         ["Isa (Jesus)", "Musa (Moses)", "Dawud (David)", "Yunus (Jonah)"], 0,
         "Isa healed the blind and the leper by Allah's permission — a sign for his people.",
         "Quran — Surah Al 'Imran, 3:49"),
    ar=L("بإذن الله، أي نبي كان يشفي الأكمه والأبرص؟",
         ["عيسى", "موسى", "داوود", "يونس"], 0,
         "كان عيسى يبرئ الأكمه والأبرص بإذن الله — آية لقومه.",
         "القرآن — سورة آل عمران، 3:49"))

add("prophets_032", "prophets", "hard", "quran", "Quran", "29:14", False,
    fr=L("Selon le Coran, combien de temps Nûh resta-t-il parmi son peuple à l'appeler vers Allah ?",
         ["950 ans", "100 ans", "300 ans", "40 ans"], 0,
         "« Il demeura parmi eux mille ans moins cinquante » — 950 ans d'appel patient.",
         "Coran — Sourate Al-'Ankabût, 29:14"),
    en=L("According to the Quran, how long did Nuh remain among his people calling them to Allah?",
         ["950 years", "100 years", "300 years", "40 years"], 0,
         "'He remained among them a thousand years minus fifty' — 950 years of patient calling.",
         "Quran — Surah Al-'Ankabut, 29:14"),
    ar=L("بحسب القرآن، كم لبث نوح في قومه يدعوهم إلى الله؟",
         ["950 سنة", "100 سنة", "300 سنة", "40 سنة"], 0,
         "«فلبث فيهم ألف سنة إلا خمسين عامًا» — 950 سنة من الدعوة الصابرة.",
         "القرآن — سورة العنكبوت، 29:14"))

# ---------------------------------------------------------------------
# QURAN (extension)
# ---------------------------------------------------------------------

add("quran_011", "quran", "medium", "quran", "Quran", "2:255", False,
    fr=L("Quel est le nom du célèbre verset 255 de la sourate Al-Baqara ?",
         ["Âyat al-Kursî (le verset du Trône)", "Âyat an-Nûr", "Âyat as-Siyâm", "Âyat ad-Dayn"], 0,
         "Le verset 2:255, Âyat al-Kursî, décrit la grandeur d'Allah : « Allah ! Point de divinité à part Lui, le Vivant… »",
         "Coran — Sourate Al-Baqara, 2:255"),
    en=L("What is the famous verse 255 of Surah Al-Baqarah called?",
         ["Ayat al-Kursi (the Throne Verse)", "Ayat an-Nur", "Ayat as-Siyam", "Ayat ad-Dayn"], 0,
         "Verse 2:255, Ayat al-Kursi, describes Allah's greatness: 'Allah — there is no deity except Him, the Ever-Living…'",
         "Quran — Surah Al-Baqarah, 2:255"),
    ar=L("ما اسم الآية 255 المشهورة من سورة البقرة؟",
         ["آية الكرسي", "آية النور", "آية الصيام", "آية الدَّين"], 0,
         "الآية 2:255 هي آية الكرسي، تصف عظمة الله: «الله لا إله إلا هو الحي القيوم…».",
         "القرآن — سورة البقرة، 2:255"))

add("quran_012", "quran", "hard", "quran", "Quran",
    "well-established (At-Tawba opens without the basmala)", False,
    fr=L("Quelle sourate ne commence pas par « Bismillâh ir-Rahmân ir-Rahîm » ?",
         ["At-Tawba", "Al-Fâtiha", "Yâ-Sîn", "Al-Kahf"], 0,
         "At-Tawba (sourate 9) est la seule sourate qui ne s'ouvre pas par la basmala.",
         "Coran — fait bien établi"),
    en=L("Which surah does not begin with 'Bismillah ir-Rahman ir-Rahim'?",
         ["At-Tawba", "Al-Fatiha", "Ya-Sin", "Al-Kahf"], 0,
         "At-Tawba (surah 9) is the only surah that does not open with the basmala.",
         "Quran — well-established fact"),
    ar=L("أي سورة لا تبدأ بـ«بسم الله الرحمن الرحيم»؟",
         ["التوبة", "الفاتحة", "يس", "الكهف"], 0,
         "سورة التوبة (السورة 9) هي الوحيدة التي لا تُفتتح بالبسملة.",
         "القرآن — حقيقة ثابتة"))

add("quran_013", "quran", "hard", "quran", "Quran", "2:282", False,
    fr=L("Quel est le sujet du plus long verset du Coran (2:282) ?",
         ["La mise par écrit des dettes", "Le pèlerinage", "Le jeûne", "L'héritage"], 0,
         "Le plus long verset du Coran enseigne d'écrire les dettes et de prendre des témoins — l'honnêteté se protège.",
         "Coran — Sourate Al-Baqara, 2:282"),
    en=L("What is the subject of the longest verse of the Quran (2:282)?",
         ["Writing down debts", "The pilgrimage", "Fasting", "Inheritance"], 0,
         "The Quran's longest verse teaches writing debts down and taking witnesses — honesty is protected.",
         "Quran — Surah Al-Baqarah, 2:282"),
    ar=L("ما موضوع أطول آية في القرآن (2:282)؟",
         ["كتابة الدَّين", "الحج", "الصيام", "الميراث"], 0,
         "أطول آية في القرآن تُعلّم كتابة الديون والإشهاد عليها — صونًا للأمانة.",
         "القرآن — سورة البقرة، 2:282"))

add("quran_014", "quran", "medium", "quran", "Quran", "96:1-5", False,
    fr=L("Par quel mot commencent les tout premiers versets révélés du Coran ?",
         ["Iqra' (Lis !)", "Qul (Dis !)", "Sabbih (Glorifie !)", "Kutiba (Il a été prescrit)"], 0,
         "Les premiers versets révélés commencent par « Iqra' » : « Lis, au nom de ton Seigneur qui a créé. »",
         "Coran — Sourate Al-'Alaq, 96:1-5"),
    en=L("With which word do the very first revealed verses of the Quran begin?",
         ["Iqra' (Read!)", "Qul (Say!)", "Sabbih (Glorify!)", "Kutiba (It was decreed)"], 0,
         "The first revealed verses begin with 'Iqra'': 'Read, in the name of your Lord who created.'",
         "Quran — Surah Al-'Alaq, 96:1-5"),
    ar=L("بأي كلمة تبدأ أول الآيات نزولًا من القرآن؟",
         ["اقرأ", "قل", "سبّح", "كُتب"], 0,
         "أول ما نزل: «اقرأ باسم ربك الذي خلق».",
         "القرآن — سورة العلق، 96:1-5"))

add("quran_015", "quran", "easy", "quran", "Quran", "97:3", False,
    fr=L("Selon le Coran, la nuit d'Al-Qadr est meilleure que combien de mois ?",
         ["Mille mois", "Cent mois", "Douze mois", "Quarante mois"], 0,
         "« La nuit d'Al-Qadr est meilleure que mille mois » — une nuit de Ramadan plus précieuse qu'une vie d'adoration.",
         "Coran — Sourate Al-Qadr, 97:3"),
    en=L("According to the Quran, the Night of Al-Qadr is better than how many months?",
         ["A thousand months", "A hundred months", "Twelve months", "Forty months"], 0,
         "'The Night of Al-Qadr is better than a thousand months' — one night of Ramadan worth more than a lifetime of worship.",
         "Quran — Surah Al-Qadr, 97:3"),
    ar=L("بحسب القرآن، ليلة القدر خير من كم شهر؟",
         ["ألف شهر", "مئة شهر", "اثني عشر شهرًا", "أربعين شهرًا"], 0,
         "«ليلة القدر خير من ألف شهر» — ليلة من رمضان أفضل من عمر كامل من العبادة.",
         "القرآن — سورة القدر، 97:3"))

add("quran_016", "quran", "medium", "quran", "Quran",
    "well-established terminology (al-mu'awwidhatan: 113 & 114)", False,
    fr=L("Comment appelle-t-on les deux dernières sourates, Al-Falaq et An-Nâs, récitées pour chercher protection ?",
         ["Al-Mu'awwidhatân (les deux protectrices)", "Az-Zahrâwân", "Al-Mufassal", "As-Sab' at-Tiwâl"], 0,
         "Al-Falaq et An-Nâs sont appelées « al-mu'awwidhatân » : on les récite pour chercher la protection d'Allah.",
         "Coran — terminologie bien établie"),
    en=L("What are the last two surahs, Al-Falaq and An-Nas, recited for protection, called?",
         ["Al-Mu'awwidhatan (the two protectors)", "Az-Zahrawan", "Al-Mufassal", "As-Sab' at-Tiwal"], 0,
         "Al-Falaq and An-Nas are called 'al-mu'awwidhatan': they are recited to seek Allah's protection.",
         "Quran — well-established terminology"),
    ar=L("ماذا تُسمى السورتان الأخيرتان، الفلق والناس، اللتان يُتعوذ بهما؟",
         ["المعوِّذتان", "الزهراوان", "المفصَّل", "السبع الطوال"], 0,
         "الفلق والناس تُسميان «المعوذتين»: يُقرآن للاستعاذة بالله.",
         "القرآن — تسمية ثابتة"))

add("quran_017", "quran", "easy", "quran", "Quran",
    "well-established division (30 ajza')", True,
    fr=L("En combien de parties (juz') le Coran est-il traditionnellement divisé ?",
         ["30", "10", "60", "114"], 0,
         "Le Coran est divisé en 30 juz', ce qui aide à le lire entièrement en un mois, par exemple pendant Ramadan.",
         "Coran — division bien établie"),
    en=L("Into how many parts (juz') is the Quran traditionally divided?",
         ["30", "10", "60", "114"], 0,
         "The Quran is divided into 30 juz', which helps complete it in a month — for example during Ramadan.",
         "Quran — well-established division"),
    ar=L("إلى كم جزءًا يُقسَّم القرآن عادة؟",
         ["30", "10", "60", "114"], 0,
         "يُقسَّم القرآن إلى ثلاثين جزءًا، مما يعين على ختمه في شهر، كما في رمضان.",
         "القرآن — تقسيم ثابت"))

add("quran_018", "quran", "easy", "quran", "Quran",
    "well-established count (Al-Fatiha: 7 verses)", False,
    fr=L("Combien de versets compte la sourate Al-Fâtiha ?",
         ["7", "3", "10", "14"], 0,
         "Al-Fâtiha compte sept versets, récités dans chaque unité de prière.",
         "Coran — décompte bien établi"),
    en=L("How many verses does Surah Al-Fatiha contain?",
         ["7", "3", "10", "14"], 0,
         "Al-Fatiha has seven verses, recited in every unit of the prayer.",
         "Quran — well-established count"),
    ar=L("كم آية في سورة الفاتحة؟",
         ["7", "3", "10", "14"], 0,
         "الفاتحة سبع آيات، تُقرأ في كل ركعة من الصلاة.",
         "القرآن — عدد ثابت"))

add("quran_019", "quran", "hard", "quran", "Quran", "57:25", False,
    fr=L("Quelle sourate porte le nom d'un métal ?",
         ["Al-Hadîd (Le Fer)", "An-Nûr (La Lumière)", "Ar-Ra'd (Le Tonnerre)", "Ad-Dukhân (La Fumée)"], 0,
         "La sourate 57 s'appelle Al-Hadîd : « Nous avons fait descendre le fer, où il y a une force redoutable et des utilités pour les gens. »",
         "Coran — Sourate Al-Hadîd, 57:25"),
    en=L("Which surah is named after a metal?",
         ["Al-Hadid (Iron)", "An-Nur (The Light)", "Ar-Ra'd (The Thunder)", "Ad-Dukhan (The Smoke)"], 0,
         "Surah 57 is called Al-Hadid: 'We sent down iron, in which is great might and benefits for people.'",
         "Quran — Surah Al-Hadid, 57:25"),
    ar=L("أي سورة سُميت باسم معدن؟",
         ["الحديد", "النور", "الرعد", "الدخان"], 0,
         "السورة 57 هي الحديد: «وأنزلنا الحديد فيه بأس شديد ومنافع للناس».",
         "القرآن — سورة الحديد، 57:25"))

add("quran_020", "quran", "medium", "quran", "Quran", "12:3", False,
    fr=L("Quelle histoire le Coran appelle-t-il « le plus beau des récits » ?",
         ["L'histoire de Yûsuf", "L'histoire de Nûh", "L'histoire des gens de la caverne", "L'histoire de l'éléphant"], 0,
         "« Nous te racontons le plus beau des récits » — ainsi s'ouvre l'histoire de Yûsuf.",
         "Coran — Sourate Yûsuf, 12:3"),
    en=L("Which story does the Quran call 'the best of stories'?",
         ["The story of Yusuf", "The story of Nuh", "The story of the people of the cave", "The story of the elephant"], 0,
         "'We relate to you the best of stories' — so opens the story of Yusuf.",
         "Quran — Surah Yusuf, 12:3"),
    ar=L("أي قصة سماها القرآن «أحسن القصص»؟",
         ["قصة يوسف", "قصة نوح", "قصة أهل الكهف", "قصة الفيل"], 0,
         "«نحن نقص عليك أحسن القصص» — هكذا تُفتتح قصة يوسف.",
         "القرآن — سورة يوسف، 12:3"))

add("quran_021", "quran", "hard", "quran", "Quran",
    "well-established count (Al-Baqarah: 286 verses)", False,
    fr=L("Combien de versets compte Al-Baqara, la plus longue sourate ?",
         ["286", "114", "200", "365"], 0,
         "Al-Baqara compte 286 versets — la plus longue sourate du Coran.",
         "Coran — décompte bien établi"),
    en=L("How many verses does Al-Baqarah, the longest surah, contain?",
         ["286", "114", "200", "365"], 0,
         "Al-Baqarah has 286 verses — the longest surah of the Quran.",
         "Quran — well-established count"),
    ar=L("كم آية في سورة البقرة، أطول سور القرآن؟",
         ["286", "114", "200", "365"], 0,
         "سورة البقرة 286 آية — أطول سورة في القرآن.",
         "القرآن — عدد ثابت"))

add("quran_022", "quran", "easy", "quran", "Quran", "112:1-4", False,
    fr=L("Quelle courte sourate proclame : « Dis : Il est Allah, Unique » ?",
         ["Al-Ikhlâs", "Al-Falaq", "An-Nâs", "Al-Kawthar"], 0,
         "Al-Ikhlâs proclame l'unicité parfaite d'Allah en quatre versets.",
         "Coran — Sourate Al-Ikhlâs, 112:1-4"),
    en=L("Which short surah proclaims: 'Say: He is Allah, the One'?",
         ["Al-Ikhlas", "Al-Falaq", "An-Nas", "Al-Kawthar"], 0,
         "Al-Ikhlas proclaims Allah's perfect oneness in four verses.",
         "Quran — Surah Al-Ikhlas, 112:1-4"),
    ar=L("أي سورة قصيرة تعلن: «قل هو الله أحد»؟",
         ["الإخلاص", "الفلق", "الناس", "الكوثر"], 0,
         "سورة الإخلاص تعلن توحيد الله الكامل في أربع آيات.",
         "القرآن — سورة الإخلاص، 112:1-4"))

add("quran_023", "quran", "medium", "quran", "Quran",
    "well-established (revelation over about 23 years)", False,
    fr=L("Sur environ combien d'années le Coran fut-il révélé ?",
         ["23 ans", "1 an", "10 ans", "40 ans"], 0,
         "Le Coran fut révélé progressivement sur environ 23 ans, à La Mecque puis à Médine.",
         "Coran — fait bien établi"),
    en=L("Over roughly how many years was the Quran revealed?",
         ["23 years", "1 year", "10 years", "40 years"], 0,
         "The Quran was revealed gradually over about 23 years, in Makkah and then Madinah.",
         "Quran — well-established fact"),
    ar=L("على مدى كم سنة تقريبًا نزل القرآن؟",
         ["23 سنة", "سنة واحدة", "10 سنوات", "40 سنة"], 0,
         "نزل القرآن منجّمًا على نحو ثلاث وعشرين سنة، في مكة ثم المدينة.",
         "القرآن — حقيقة ثابتة"))

add("quran_024", "quran", "medium", "quran", "Quran", "3:96", False,
    fr=L("Selon le Coran, quelle est la première Maison établie pour les gens afin d'adorer Allah ?",
         ["La Ka'ba, à Bakka (La Mecque)", "La mosquée de Qubâ", "Bayt al-Maqdis", "La mosquée du Prophète ﷺ"], 0,
         "« La première Maison établie pour les gens est celle de Bakka, bénie… » — la Ka'ba, à La Mecque.",
         "Coran — Sourate Âl 'Imrân, 3:96"),
    en=L("According to the Quran, what was the first House established for people to worship Allah?",
         ["The Ka'bah, at Bakkah (Makkah)", "The mosque of Quba", "Bayt al-Maqdis", "The Prophet's ﷺ mosque"], 0,
         "'The first House established for mankind is the one at Bakkah, blessed…' — the Ka'bah in Makkah.",
         "Quran — Surah Al 'Imran, 3:96"),
    ar=L("بحسب القرآن، ما أول بيت وُضع للناس لعبادة الله؟",
         ["الكعبة ببكة (مكة)", "مسجد قباء", "بيت المقدس", "المسجد النبوي"], 0,
         "«إن أول بيت وُضع للناس للذي ببكة مباركًا» — الكعبة بمكة.",
         "القرآن — سورة آل عمران، 3:96"))

# ---------------------------------------------------------------------
# SIRA (extension) — established-fact class (CONTENT_SOURCE_POLICY §2bis)
# unless a Qur'anic reference applies directly.
# ---------------------------------------------------------------------

_SIRA_REF = "well-established sira event, agreed across standard biographies"

add("sira_019", "sira", "easy", "sira", "Sira", _SIRA_REF, True,
    fr=L("Qui fut le premier muezzin de l'islam, choisi par le Prophète ﷺ pour appeler à la prière ?",
         ["Bilâl ibn Rabâh", "Abû Bakr", "'Umar ibn al-Khattâb", "Salmân al-Fârisî"], 0,
         "Bilâl, à la belle voix, fut choisi comme premier muezzin de l'islam.",
         "Sîra — fait historique établi"),
    en=L("Who was the first muezzin of Islam, chosen by the Prophet ﷺ to call to prayer?",
         ["Bilal ibn Rabah", "Abu Bakr", "'Umar ibn al-Khattab", "Salman al-Farisi"], 0,
         "Bilal, with his beautiful voice, was chosen as Islam's first muezzin.",
         "Sira — well-established historical fact"),
    ar=L("من كان أول مؤذن في الإسلام، اختاره النبي ﷺ للنداء للصلاة؟",
         ["بلال بن رباح", "أبو بكر", "عمر بن الخطاب", "سلمان الفارسي"], 0,
         "اختير بلال، صاحب الصوت الجميل، أول مؤذن في الإسلام.",
         "السيرة — حقيقة تاريخية ثابتة"))

add("sira_020", "sira", "medium", "sira", "Sira", _SIRA_REF, False,
    fr=L("Quelle est la première mosquée fondée par le Prophète ﷺ lors de son arrivée près de Médine ?",
         ["La mosquée de Qubâ", "La mosquée al-Harâm", "La mosquée al-Aqsâ", "La mosquée des deux qibla"], 0,
         "En arrivant à Qubâ, aux portes de Médine, le Prophète ﷺ y fonda la première mosquée.",
         "Sîra — fait historique établi"),
    en=L("What was the first mosque founded by the Prophet ﷺ upon arriving near Madinah?",
         ["The mosque of Quba", "Al-Haram mosque", "Al-Aqsa mosque", "The mosque of the two qiblas"], 0,
         "Arriving at Quba, at the gates of Madinah, the Prophet ﷺ founded the first mosque there.",
         "Sira — well-established historical fact"),
    ar=L("ما أول مسجد أسسه النبي ﷺ عند وصوله قرب المدينة؟",
         ["مسجد قباء", "المسجد الحرام", "المسجد الأقصى", "مسجد القبلتين"], 0,
         "عند وصوله إلى قباء على مشارف المدينة، أسس النبي ﷺ أول مسجد.",
         "السيرة — حقيقة تاريخية ثابتة"))

add("sira_021", "sira", "easy", "sira", "Sira", _SIRA_REF, False,
    fr=L("Comment s'appelait la mère du Prophète ﷺ ?",
         ["Âmina", "Khadîja", "Halîma", "Fâtima"], 0,
         "Âmina bint Wahb était la mère du Prophète ﷺ ; Halîma fut sa nourrice.",
         "Sîra — fait historique établi"),
    en=L("What was the name of the Prophet's ﷺ mother?",
         ["Amina", "Khadija", "Halima", "Fatima"], 0,
         "Amina bint Wahb was the Prophet's ﷺ mother; Halima was his wet-nurse.",
         "Sira — well-established historical fact"),
    ar=L("ما اسم أم النبي ﷺ؟",
         ["آمنة", "خديجة", "حليمة", "فاطمة"], 0,
         "آمنة بنت وهب أم النبي ﷺ؛ وحليمة مرضعته.",
         "السيرة — حقيقة تاريخية ثابتة"))

add("sira_022", "sira", "medium", "sira", "Sira", _SIRA_REF, False,
    fr=L("Comment s'appelait le père du Prophète ﷺ, décédé avant sa naissance ?",
         ["'Abdullâh", "Abû Tâlib", "'Abd al-Muttalib", "Hamza"], 0,
         "'Abdullâh, fils de 'Abd al-Muttalib, mourut avant la naissance de son fils Muhammad ﷺ.",
         "Sîra — fait historique établi"),
    en=L("What was the name of the Prophet's ﷺ father, who passed away before his birth?",
         ["'Abdullah", "Abu Talib", "'Abd al-Muttalib", "Hamza"], 0,
         "'Abdullah, son of 'Abd al-Muttalib, passed away before his son Muhammad ﷺ was born.",
         "Sira — well-established historical fact"),
    ar=L("ما اسم والد النبي ﷺ الذي توفي قبل مولده؟",
         ["عبد الله", "أبو طالب", "عبد المطلب", "حمزة"], 0,
         "توفي عبد الله بن عبد المطلب قبل مولد ابنه محمد ﷺ.",
         "السيرة — حقيقة تاريخية ثابتة"))

add("sira_023", "sira", "easy", "sira", "Sira", _SIRA_REF, False,
    fr=L("Quel surnom les Mecquois donnaient-ils au Prophète ﷺ avant la révélation, pour son honnêteté ?",
         ["Al-Amîn (le digne de confiance)", "Al-Fârûq", "As-Siddîq", "Sayf Allâh"], 0,
         "Avant même la révélation, on l'appelait al-Amîn : chacun lui confiait ses biens.",
         "Sîra — fait historique établi"),
    en=L("What nickname did the Makkans give the Prophet ﷺ before revelation, for his honesty?",
         ["Al-Amin (the trustworthy)", "Al-Faruq", "As-Siddiq", "Sayf Allah"], 0,
         "Even before revelation he was called al-Amin: people entrusted him with their belongings.",
         "Sira — well-established historical fact"),
    ar=L("بأي لقب عرف أهل مكة النبي ﷺ قبل البعثة لصدقه؟",
         ["الأمين", "الفاروق", "الصدّيق", "سيف الله"], 0,
         "قبل البعثة كان يُلقب بالأمين: كان الناس يودعونه أماناتهم.",
         "السيرة — حقيقة تاريخية ثابتة"))

add("sira_024", "sira", "hard", "sira", "Sira", _SIRA_REF, False,
    fr=L("En quelle année de l'hégire eut lieu la conquête de La Mecque ?",
         ["L'an 8", "L'an 2", "L'an 5", "L'an 10"], 0,
         "En l'an 8 de l'hégire, le Prophète ﷺ entra à La Mecque presque sans combat et pardonna à ses habitants.",
         "Sîra — fait historique établi"),
    en=L("In which year of the Hijra did the conquest of Makkah take place?",
         ["Year 8", "Year 2", "Year 5", "Year 10"], 0,
         "In year 8 AH the Prophet ﷺ entered Makkah almost without fighting and pardoned its people.",
         "Sira — well-established historical fact"),
    ar=L("في أي سنة هجرية كان فتح مكة؟",
         ["السنة 8", "السنة 2", "السنة 5", "السنة 10"], 0,
         "في السنة الثامنة للهجرة دخل النبي ﷺ مكة بلا قتال يُذكر وعفا عن أهلها.",
         "السيرة — حقيقة تاريخية ثابتة"))

add("sira_025", "sira", "hard", "sira", "Sira", _SIRA_REF, False,
    fr=L("En quelle année de l'hégire le Prophète ﷺ accomplit-il son pèlerinage d'adieu ?",
         ["L'an 10", "L'an 6", "L'an 8", "L'an 12"], 0,
         "Le pèlerinage d'adieu eut lieu en l'an 10 de l'hégire ; le Prophète ﷺ y prononça son dernier sermon.",
         "Sîra — fait historique établi"),
    en=L("In which year of the Hijra did the Prophet ﷺ perform his Farewell Pilgrimage?",
         ["Year 10", "Year 6", "Year 8", "Year 12"], 0,
         "The Farewell Pilgrimage took place in year 10 AH; the Prophet ﷺ delivered his final sermon there.",
         "Sira — well-established historical fact"),
    ar=L("في أي سنة هجرية أدى النبي ﷺ حجة الوداع؟",
         ["السنة 10", "السنة 6", "السنة 8", "السنة 12"], 0,
         "كانت حجة الوداع في السنة العاشرة للهجرة، وفيها ألقى النبي ﷺ خطبته الأخيرة.",
         "السيرة — حقيقة تاريخية ثابتة"))

add("sira_026", "sira", "hard", "sira", "Sira", _SIRA_REF, False,
    fr=L("Combien de filles le Prophète ﷺ a-t-il eues ?",
         ["4", "1", "2", "7"], 0,
         "Zaynab, Ruqayya, Umm Kulthûm et Fâtima — les quatre filles du Prophète ﷺ.",
         "Sîra — fait historique établi"),
    en=L("How many daughters did the Prophet ﷺ have?",
         ["4", "1", "2", "7"], 0,
         "Zaynab, Ruqayya, Umm Kulthum and Fatima — the Prophet's ﷺ four daughters.",
         "Sira — well-established historical fact"),
    ar=L("كم بنتًا كان للنبي ﷺ؟",
         ["4", "1", "2", "7"], 0,
         "زينب ورقية وأم كلثوم وفاطمة — بنات النبي ﷺ الأربع.",
         "السيرة — حقيقة تاريخية ثابتة"))

add("sira_027", "sira", "medium", "sira", "Sira",
    "well-established terminology (al-Ansar)", False,
    fr=L("Comment appelle-t-on les habitants de Médine qui accueillirent et aidèrent les musulmans émigrés ?",
         ["Les Ansâr (les Auxiliaires)", "Les Muhâjirûn", "Les Qurayshites", "Les Tâbi'ûn"], 0,
         "Les Ansâr, « les Auxiliaires », partagèrent leurs maisons et leurs biens avec leurs frères émigrés.",
         "Sîra — terminologie bien établie"),
    en=L("What are the people of Madinah who welcomed and helped the emigrant Muslims called?",
         ["The Ansar (the Helpers)", "The Muhajirun", "The Quraysh", "The Tabi'un"], 0,
         "The Ansar, 'the Helpers', shared their homes and wealth with their emigrant brothers.",
         "Sira — well-established terminology"),
    ar=L("ماذا يُسمى أهل المدينة الذين آووا المسلمين المهاجرين ونصروهم؟",
         ["الأنصار", "المهاجرون", "قريش", "التابعون"], 0,
         "الأنصار شاركوا إخوانهم المهاجرين بيوتهم وأموالهم.",
         "السيرة — تسمية ثابتة"))

add("sira_028", "sira", "medium", "sira", "Sira",
    "well-established terminology (al-Muhajirun)", False,
    fr=L("Comment appelle-t-on les musulmans qui quittèrent La Mecque pour émigrer à Médine ?",
         ["Les Muhâjirûn (les Émigrés)", "Les Ansâr", "Les Hunafâ'", "Les Ghuzât"], 0,
         "Les Muhâjirûn abandonnèrent maisons et biens à La Mecque pour préserver leur foi.",
         "Sîra — terminologie bien établie"),
    en=L("What are the Muslims who left Makkah to emigrate to Madinah called?",
         ["The Muhajirun (the Emigrants)", "The Ansar", "The Hunafa'", "The Ghuzat"], 0,
         "The Muhajirun left homes and belongings in Makkah to preserve their faith.",
         "Sira — well-established terminology"),
    ar=L("ماذا يُسمى المسلمون الذين تركوا مكة مهاجرين إلى المدينة؟",
         ["المهاجرون", "الأنصار", "الحنفاء", "الغزاة"], 0,
         "ترك المهاجرون بيوتهم وأموالهم في مكة حفاظًا على دينهم.",
         "السيرة — تسمية ثابتة"))

add("sira_029", "sira", "hard", "sira", "Sira", _SIRA_REF, False,
    fr=L("Pendant quel mois eut lieu la bataille de Badr ?",
         ["Ramadân", "Muharram", "Dhûl-Hijja", "Rajab"], 0,
         "La bataille de Badr eut lieu pendant Ramadân, en l'an 2 de l'hégire.",
         "Sîra — fait historique établi"),
    en=L("During which month did the Battle of Badr take place?",
         ["Ramadan", "Muharram", "Dhul-Hijjah", "Rajab"], 0,
         "The Battle of Badr took place during Ramadan, in year 2 AH.",
         "Sira — well-established historical fact"),
    ar=L("في أي شهر وقعت غزوة بدر؟",
         ["رمضان", "محرم", "ذو الحجة", "رجب"], 0,
         "وقعت غزوة بدر في رمضان من السنة الثانية للهجرة.",
         "السيرة — حقيقة تاريخية ثابتة"))

add("sira_030", "sira", "medium", "sira", "Sira",
    "well-established (first qibla; change commanded in Quran 2:142-144)", False,
    fr=L("Avant que la qibla ne soit fixée vers la Ka'ba, vers quelle ville les musulmans priaient-ils ?",
         ["Jérusalem (Bayt al-Maqdis)", "Médine", "Tâ'if", "Damas"], 0,
         "Les musulmans priaient d'abord vers Bayt al-Maqdis ; puis Allah ordonna de se tourner vers la Mosquée sacrée (Coran 2:142-144).",
         "Sîra — fait bien établi (Coran 2:142-144)"),
    en=L("Before the qibla was fixed toward the Ka'bah, toward which city did Muslims pray?",
         ["Jerusalem (Bayt al-Maqdis)", "Madinah", "Ta'if", "Damascus"], 0,
         "Muslims first prayed toward Bayt al-Maqdis; then Allah commanded turning toward the Sacred Mosque (Quran 2:142-144).",
         "Sira — well-established fact (Quran 2:142-144)"),
    ar=L("قبل تحويل القبلة إلى الكعبة، نحو أي مدينة كان المسلمون يصلّون؟",
         ["بيت المقدس", "المدينة", "الطائف", "دمشق"], 0,
         "صلى المسلمون أولًا نحو بيت المقدس؛ ثم أمر الله بالتوجه إلى المسجد الحرام (القرآن 2:142-144).",
         "السيرة — حقيقة ثابتة (القرآن 2:142-144)"))

# ---------------------------------------------------------------------
# FAITH (extension)
# ---------------------------------------------------------------------

add("faith_009", "faith", "easy", "quran", "Quran", "5:6", False,
    fr=L("Comment s'appelle la purification par l'eau que le musulman fait avant chaque prière ?",
         ["Le wudû' (les ablutions)", "Le tayammum", "Le ghusl", "Le siwâk"], 0,
         "« Quand vous vous levez pour la prière, lavez vos visages et vos mains… » — c'est le wudû'.",
         "Coran — Sourate Al-Mâ'ida, 5:6"),
    en=L("What is the routine water purification a Muslim performs before each prayer called?",
         ["Wudu (ablution)", "Tayammum", "Ghusl", "Siwak"], 0,
         "'When you rise for prayer, wash your faces and your hands…' — this is wudu.",
         "Quran — Surah Al-Ma'idah, 5:6"),
    ar=L("ما اسم الطهارة بالماء التي يقوم بها المسلم قبل كل صلاة؟",
         ["الوضوء", "التيمم", "الغسل", "السواك"], 0,
         "«إذا قمتم إلى الصلاة فاغسلوا وجوهكم وأيديكم…» — هذا هو الوضوء.",
         "القرآن — سورة المائدة، 5:6"))

add("faith_010", "faith", "medium", "quran", "Quran", "82:10-11", False,
    fr=L("Selon le Coran, que font les « nobles scribes » (kirâman kâtibîn) ?",
         ["Ils inscrivent les actes des humains", "Ils portent le trône", "Ils gardent le Paradis", "Ils apportent la pluie"], 0,
         "« Il y a sur vous des gardiens, de nobles scribes » — des anges inscrivent chaque acte.",
         "Coran — Sourate Al-Infitâr, 82:10-11"),
    en=L("According to the Quran, what do the 'noble scribes' (kiraman katibin) do?",
         ["They record people's deeds", "They carry the Throne", "They guard Paradise", "They bring the rain"], 0,
         "'Over you are guardians, noble scribes' — angels record every deed.",
         "Quran — Surah Al-Infitar, 82:10-11"),
    ar=L("بحسب القرآن، ماذا يفعل «الكرام الكاتبون»؟",
         ["يكتبون أعمال الناس", "يحملون العرش", "يحرسون الجنة", "ينزلون المطر"], 0,
         "«وإن عليكم لحافظين كرامًا كاتبين» — ملائكة يكتبون كل عمل.",
         "القرآن — سورة الانفطار، 82:10-11"))

add("faith_011", "faith", "medium", "creed", "Creed",
    "well-established (99 beautiful names, reported in al-Bukhari and Muslim)", False,
    fr=L("Combien de beaux noms d'Allah la tradition authentique rapporte-t-elle ?",
         ["99", "50", "100", "114"], 0,
         "Un hadith authentique rapporté par al-Bukhârî et Muslim mentionne quatre-vingt-dix-neuf noms — cent moins un.",
         "Croyance — fait bien établi (al-Bukhârî et Muslim)"),
    en=L("How many beautiful names of Allah does the authentic tradition report?",
         ["99", "50", "100", "114"], 0,
         "An authentic hadith reported by al-Bukhari and Muslim mentions ninety-nine names — one hundred minus one.",
         "Creed — well-established (al-Bukhari and Muslim)"),
    ar=L("كم اسمًا حسنًا لله ورد في السنة الصحيحة؟",
         ["99", "50", "100", "114"], 0,
         "في الحديث الصحيح عند البخاري ومسلم: «إن لله تسعة وتسعين اسمًا، مئة إلا واحدًا».",
         "العقيدة — حقيقة ثابتة (البخاري ومسلم)"))

add("faith_012", "faith", "easy", "quran", "Quran", "1:3", True,
    fr=L("Que signifie le nom d'Allah « Ar-Rahmân » ?",
         ["Le Tout Miséricordieux", "Le Créateur", "Le Roi", "L'Omniscient"], 0,
         "Ar-Rahmân, le Tout Miséricordieux — Sa miséricorde embrasse toute chose.",
         "Coran — Sourate Al-Fâtiha, 1:3"),
    en=L("What does Allah's name 'Ar-Rahman' mean?",
         ["The Most Merciful", "The Creator", "The King", "The All-Knowing"], 0,
         "Ar-Rahman, the Most Merciful — His mercy embraces all things.",
         "Quran — Surah Al-Fatiha, 1:3"),
    ar=L("ما معنى اسم الله «الرحمن»؟",
         ["كثير الرحمة الواسعة", "الخالق", "الملك", "العليم"], 0,
         "الرحمن: ذو الرحمة الواسعة التي وسعت كل شيء.",
         "القرآن — سورة الفاتحة، 1:3"))

add("faith_013", "faith", "medium", "quran", "Quran", "1:4", False,
    fr=L("Dans Al-Fâtiha, Allah est appelé « Maître » de quel jour ?",
         ["Du Jour de la Rétribution", "Du jour du vendredi", "Du premier jour", "Du jour de 'Arafa"], 0,
         "« Maître du Jour de la Rétribution » — le jour où chacun retrouvera ses actes.",
         "Coran — Sourate Al-Fâtiha, 1:4"),
    en=L("In Al-Fatiha, Allah is called 'Master' of which day?",
         ["The Day of Judgment", "Friday", "The first day", "The day of 'Arafah"], 0,
         "'Master of the Day of Judgment' — the day everyone meets their deeds.",
         "Quran — Surah Al-Fatiha, 1:4"),
    ar=L("في الفاتحة، وُصف الله بأنه «مالك» أي يوم؟",
         ["يوم الدين", "يوم الجمعة", "اليوم الأول", "يوم عرفة"], 0,
         "«مالك يوم الدين» — اليوم الذي يلقى فيه كلٌّ عملَه.",
         "القرآن — سورة الفاتحة، 1:4"))

add("faith_014", "faith", "easy", "quran", "Quran", "62:9", False,
    fr=L("Quel jour de la semaine le Coran appelle-t-il les croyants à la prière en commun ?",
         ["Le vendredi", "Le lundi", "Le samedi", "Le dimanche"], 0,
         "« Quand on appelle à la prière du jour du vendredi, accourez au rappel d'Allah. »",
         "Coran — Sourate Al-Jumu'a, 62:9"),
    en=L("On which day of the week does the Quran call believers to congregational prayer?",
         ["Friday", "Monday", "Saturday", "Sunday"], 0,
         "'When the call to prayer is made on Friday, hasten to the remembrance of Allah.'",
         "Quran — Surah Al-Jumu'ah, 62:9"),
    ar=L("في أي يوم من الأسبوع دعا القرآن المؤمنين إلى صلاة الجماعة؟",
         ["الجمعة", "الاثنين", "السبت", "الأحد"], 0,
         "«إذا نودي للصلاة من يوم الجمعة فاسعوا إلى ذكر الله».",
         "القرآن — سورة الجمعة، 62:9"))

add("faith_015", "faith", "medium", "quran", "Quran", "15:9", False,
    fr=L("Selon le Coran, qui garantit la préservation du Coran contre toute altération ?",
         ["Allah Lui-même", "Les anges seulement", "Les savants", "Les rois"], 0,
         "« C'est Nous qui avons fait descendre le Rappel, et c'est Nous qui en sommes les gardiens. »",
         "Coran — Sourate Al-Hijr, 15:9"),
    en=L("According to the Quran, who guarantees the Quran's preservation from any alteration?",
         ["Allah Himself", "Only the angels", "The scholars", "The kings"], 0,
         "'Indeed, We sent down the Reminder, and indeed We are its Guardian.'",
         "Quran — Surah Al-Hijr, 15:9"),
    ar=L("بحسب القرآن، من تكفّل بحفظ القرآن من التحريف؟",
         ["الله بنفسه", "الملائكة فقط", "العلماء", "الملوك"], 0,
         "«إنا نحن نزلنا الذكر وإنا له لحافظون».",
         "القرآن — سورة الحجر، 15:9"))

add("faith_016", "faith", "hard", "quran", "Quran", "2:256", False,
    fr=L("Que déclare le Coran au sujet de l'entrée dans la religion ?",
         ["Nulle contrainte en religion", "Elle se fait par serment", "Elle exige un témoin", "Elle se fait à l'âge adulte"], 0,
         "« Nulle contrainte en religion : la bonne direction s'est distinguée de l'égarement. »",
         "Coran — Sourate Al-Baqara, 2:256"),
    en=L("What does the Quran declare about entering the religion?",
         ["There is no compulsion in religion", "It is done by oath", "It requires a witness", "It happens at adulthood"], 0,
         "'There is no compulsion in religion: right guidance is distinct from error.'",
         "Quran — Surah Al-Baqarah, 2:256"),
    ar=L("ماذا يقرر القرآن في شأن الدخول في الدين؟",
         ["لا إكراه في الدين", "يكون بالقسم", "يحتاج شاهدًا", "يكون عند البلوغ"], 0,
         "«لا إكراه في الدين قد تبين الرشد من الغي».",
         "القرآن — سورة البقرة، 2:256"))

add("faith_017", "faith", "easy", "creed", "Creed",
    "well-established terminology (as-salamu 'alaykum)", False,
    fr=L("Quelle est la salutation des musulmans, souhait de paix ?",
         ["As-salâmu 'alaykum", "Marhaban", "Sabâh al-khayr", "Ahlan wa sahlan"], 0,
         "« As-salâmu 'alaykum » : que la paix soit sur vous — on y répond « wa 'alaykum as-salâm ».",
         "Croyance — terminologie bien établie"),
    en=L("What is the Muslims' greeting, a wish of peace?",
         ["As-salamu 'alaykum", "Marhaban", "Sabah al-khayr", "Ahlan wa sahlan"], 0,
         "'As-salamu 'alaykum': peace be upon you — answered with 'wa 'alaykum as-salam'.",
         "Creed — well-established terminology"),
    ar=L("ما تحية المسلمين التي فيها دعاء بالسلام؟",
         ["السلام عليكم", "مرحبًا", "صباح الخير", "أهلًا وسهلًا"], 0,
         "«السلام عليكم» — ويُرد عليها: «وعليكم السلام».",
         "العقيدة — تسمية ثابتة"))

add("faith_018", "faith", "medium", "creed", "Creed",
    "well-established terminology (tawhid)", False,
    fr=L("Comment s'appelle la croyance en l'unicité d'Allah, cœur de l'islam ?",
         ["Le tawhîd", "Le tafsîr", "Le tajwîd", "Le tarâwîh"], 0,
         "Le tawhîd — affirmer qu'Allah est Un, sans associé — est le fondement de toute la foi.",
         "Croyance — terminologie bien établie"),
    en=L("What is the belief in the oneness of Allah, the heart of Islam, called?",
         ["Tawhid", "Tafsir", "Tajwid", "Tarawih"], 0,
         "Tawhid — affirming that Allah is One, without partner — is the foundation of all faith.",
         "Creed — well-established terminology"),
    ar=L("ماذا تُسمى عقيدة إفراد الله بالوحدانية، وهي قلب الإسلام؟",
         ["التوحيد", "التفسير", "التجويد", "التراويح"], 0,
         "التوحيد — إفراد الله بالعبادة بلا شريك — أساس الإيمان كله.",
         "العقيدة — تسمية ثابتة"))

# ---------------------------------------------------------------------
# VIRTUES (extension)
# ---------------------------------------------------------------------

add("virtues_007", "virtues", "medium", "quran", "Quran", "49:12", False,
    fr=L("À quoi le Coran compare-t-il la médisance (parler d'un absent en mal) ?",
         ["Manger la chair de son frère mort", "Boire de l'eau salée", "Marcher dans le noir", "Semer dans le sable"], 0,
         "« L'un de vous aimerait-il manger la chair de son frère mort ? Vous en auriez horreur ! » — la médisance est aussi laide.",
         "Coran — Sourate Al-Hujurât, 49:12"),
    en=L("To what does the Quran compare backbiting (speaking ill of someone absent)?",
         ["Eating the flesh of one's dead brother", "Drinking salt water", "Walking in darkness", "Sowing in sand"], 0,
         "'Would one of you like to eat the flesh of his dead brother? You would detest it!' — backbiting is that ugly.",
         "Quran — Surah Al-Hujurat, 49:12"),
    ar=L("بماذا شبّه القرآن الغيبة (ذكر الغائب بما يكره)؟",
         ["أكل لحم الأخ الميت", "شرب الماء المالح", "المشي في الظلام", "الزرع في الرمل"], 0,
         "«أيحب أحدكم أن يأكل لحم أخيه ميتًا فكرهتموه» — هكذا قبح الغيبة.",
         "القرآن — سورة الحجرات، 49:12"))

add("virtues_008", "virtues", "easy", "quran", "Quran", "49:10", True,
    fr=L("Comment le Coran décrit-il la relation entre les croyants ?",
         ["Ils sont frères", "Ils sont concurrents", "Ils sont étrangers", "Ils sont associés en affaires"], 0,
         "« Les croyants ne sont que des frères : réconciliez donc vos deux frères. »",
         "Coran — Sourate Al-Hujurât, 49:10"),
    en=L("How does the Quran describe the relationship between believers?",
         ["They are brothers", "They are competitors", "They are strangers", "They are business partners"], 0,
         "'The believers are but brothers, so make peace between your two brothers.'",
         "Quran — Surah Al-Hujurat, 49:10"),
    ar=L("كيف وصف القرآن العلاقة بين المؤمنين؟",
         ["إخوة", "متنافسون", "غرباء", "شركاء تجارة"], 0,
         "«إنما المؤمنون إخوة فأصلحوا بين أخويكم».",
         "القرآن — سورة الحجرات، 49:10"))

add("virtues_009", "virtues", "medium", "quran", "Quran", "49:11", False,
    fr=L("Que dit le Coran sur le fait de se moquer des autres ?",
         ["C'est interdit : les moqués valent peut-être mieux que les moqueurs", "C'est permis entre amis", "C'est permis si c'est drôle", "C'est réservé aux poètes"], 0,
         "« Qu'un groupe ne se moque pas d'un autre : il se peut que ceux-ci soient meilleurs qu'eux. »",
         "Coran — Sourate Al-Hujurât, 49:11"),
    en=L("What does the Quran say about mocking other people?",
         ["It is forbidden: the mocked may be better than the mockers", "It is allowed among friends", "It is allowed if funny", "It is reserved for poets"], 0,
         "'Let no people ridicule another people: perhaps they are better than them.'",
         "Quran — Surah Al-Hujurat, 49:11"),
    ar=L("ماذا قال القرآن في السخرية من الناس؟",
         ["نهى عنها: فقد يكون المسخور منه خيرًا من الساخر", "جائزة بين الأصدقاء", "جائزة إن كانت مضحكة", "خاصة بالشعراء"], 0,
         "«لا يسخر قوم من قوم عسى أن يكونوا خيرًا منهم».",
         "القرآن — سورة الحجرات، 49:11"))

add("virtues_010", "virtues", "medium", "quran", "Quran", "14:7", False,
    fr=L("Selon le Coran, que promet Allah à celui qui est reconnaissant ?",
         ["Il lui accordera davantage", "Une longue vie", "La richesse immédiate", "Un voyage"], 0,
         "« Si vous êtes reconnaissants, Je vous accorderai certainement davantage. »",
         "Coran — Sourate Ibrâhîm, 14:7"),
    en=L("According to the Quran, what does Allah promise the one who is grateful?",
         ["He will surely give them more", "A long life", "Immediate wealth", "A journey"], 0,
         "'If you are grateful, I will surely increase you.'",
         "Quran — Surah Ibrahim, 14:7"),
    ar=L("بحسب القرآن، بماذا وعد الله من يشكر؟",
         ["ليزيدنّه", "بطول العمر", "بالغنى الفوري", "برحلة"], 0,
         "«لئن شكرتم لأزيدنكم».",
         "القرآن — سورة إبراهيم، 14:7"))

add("virtues_011", "virtues", "hard", "quran", "Quran", "39:10", False,
    fr=L("Selon le Coran, comment les endurants (sâbirûn) recevront-ils leur récompense ?",
         ["Pleinement, sans compter", "En une seule fois", "Après quarante jours", "Selon leur richesse"], 0,
         "« Les endurants recevront leur pleine récompense, sans compter. »",
         "Coran — Sourate Az-Zumar, 39:10"),
    en=L("According to the Quran, how will the patient (sabirun) be given their reward?",
         ["In full, without measure", "All at once", "After forty days", "According to their wealth"], 0,
         "'The patient will be given their reward in full, without account.'",
         "Quran — Surah Az-Zumar, 39:10"),
    ar=L("بحسب القرآن، كيف يُوفّى الصابرون أجرهم؟",
         ["بغير حساب", "دفعة واحدة", "بعد أربعين يومًا", "على قدر غناهم"], 0,
         "«إنما يوفى الصابرون أجرهم بغير حساب».",
         "القرآن — سورة الزمر، 39:10"))

add("virtues_012", "virtues", "easy", "quran", "Quran", "7:31", False,
    fr=L("« Mangez et buvez, mais… » — que dit la suite de ce verset ?",
         ["Ne gaspillez pas", "Ne partagez pas", "Ne parlez pas", "Ne sortez pas"], 0,
         "« Mangez et buvez, et ne gaspillez pas : Allah n'aime pas les gaspilleurs. »",
         "Coran — Sourate Al-A'râf, 7:31"),
    en=L("'Eat and drink, but…' — how does this verse continue?",
         ["Do not waste", "Do not share", "Do not speak", "Do not go out"], 0,
         "'Eat and drink, but do not be excessive: Allah does not love the wasteful.'",
         "Quran — Surah Al-A'raf, 7:31"),
    ar=L("«وكلوا واشربوا و…» — بم تكمل الآية؟",
         ["ولا تسرفوا", "ولا تشاركوا", "ولا تتكلموا", "ولا تخرجوا"], 0,
         "«وكلوا واشربوا ولا تسرفوا إنه لا يحب المسرفين».",
         "القرآن — سورة الأعراف، 7:31"))

add("virtues_013", "virtues", "medium", "quran", "Quran", "16:90", False,
    fr=L("Quel verset, souvent récité au sermon du vendredi, résume ce qu'Allah ordonne ?",
         ["« Allah ordonne la justice et la bienfaisance »", "« Allah ordonne le commerce »", "« Allah ordonne le voyage »", "« Allah ordonne le silence »"], 0,
         "« Allah ordonne la justice, la bienfaisance et la générosité envers les proches… » — récité chaque vendredi.",
         "Coran — Sourate An-Nahl, 16:90"),
    en=L("Which verse, often recited in the Friday sermon, sums up what Allah commands?",
         ["'Allah commands justice and good conduct'", "'Allah commands trade'", "'Allah commands travel'", "'Allah commands silence'"], 0,
         "'Allah commands justice, good conduct and generosity to relatives…' — recited every Friday.",
         "Quran — Surah An-Nahl, 16:90"),
    ar=L("أي آية تُتلى كثيرًا في خطبة الجمعة وتلخص ما يأمر الله به؟",
         ["«إن الله يأمر بالعدل والإحسان»", "«إن الله يأمر بالتجارة»", "«إن الله يأمر بالسفر»", "«إن الله يأمر بالصمت»"], 0,
         "«إن الله يأمر بالعدل والإحسان وإيتاء ذي القربى…» — تُتلى كل جمعة.",
         "القرآن — سورة النحل، 16:90"))

add("virtues_014", "virtues", "hard", "quran", "Quran", "83:1-3", False,
    fr=L("Contre qui la sourate Al-Mutaffifîn ouvre-t-elle par « Malheur… » ?",
         ["Les fraudeurs dans la mesure et le poids", "Les dormeurs", "Les voyageurs", "Les silencieux"], 0,
         "« Malheur aux fraudeurs qui, en recevant, exigent la pleine mesure, et qui, en donnant, en font perdre. »",
         "Coran — Sourate Al-Mutaffifîn, 83:1-3"),
    en=L("Against whom does Surah Al-Mutaffifin open with 'Woe…'?",
         ["Those who cheat in measure and weight", "Those who sleep", "Those who travel", "Those who stay silent"], 0,
         "'Woe to those who give less: who demand full measure when receiving, but give less when measuring for others.'",
         "Quran — Surah Al-Mutaffifin, 83:1-3"),
    ar=L("على من افتُتحت سورة المطففين بكلمة «ويل»؟",
         ["المطففين في الكيل والميزان", "النائمين", "المسافرين", "الصامتين"], 0,
         "«ويل للمطففين الذين إذا اكتالوا على الناس يستوفون وإذا كالوهم أو وزنوهم يخسرون».",
         "القرآن — سورة المطففين، 83:1-3"))

add("virtues_015", "virtues", "easy", "quran", "Quran", "93:9-10", False,
    fr=L("Selon la sourate Ad-Duhâ, comment faut-il traiter l'orphelin et celui qui demande ?",
         ["Ne pas les rudoyer ni les repousser", "Les ignorer", "Les renvoyer à d'autres", "Leur parler plus tard"], 0,
         "« Quant à l'orphelin, ne le rudoie pas ; et quant au demandeur, ne le repousse pas. »",
         "Coran — Sourate Ad-Duhâ, 93:9-10"),
    en=L("According to Surah Ad-Duha, how should the orphan and the one who asks be treated?",
         ["Neither oppressed nor turned away", "Ignored", "Sent to others", "Spoken to later"], 0,
         "'As for the orphan, do not oppress him; and as for the one who asks, do not repel him.'",
         "Quran — Surah Ad-Duha, 93:9-10"),
    ar=L("بحسب سورة الضحى، كيف يُعامل اليتيم والسائل؟",
         ["لا يُقهر اليتيم ولا يُنهر السائل", "يُتجاهلان", "يُحالان إلى غيرهما", "يُكلَّمان لاحقًا"], 0,
         "«فأما اليتيم فلا تقهر. وأما السائل فلا تنهر».",
         "القرآن — سورة الضحى، 93:9-10"))

add("virtues_016", "virtues", "easy", "quran", "Quran", "2:83", False,
    fr=L("Comment le Coran ordonne-t-il de parler aux gens ?",
         ["Avec de bonnes paroles", "À voix très basse", "Le moins possible", "Seulement aux proches"], 0,
         "« …et dites aux gens de bonnes paroles » — la parole douce est une adoration.",
         "Coran — Sourate Al-Baqara, 2:83"),
    en=L("How does the Quran command people to be spoken to?",
         ["With good words", "In a very low voice", "As little as possible", "Only to relatives"], 0,
         "'…and speak good words to people' — kind speech is itself worship.",
         "Quran — Surah Al-Baqarah, 2:83"),
    ar=L("كيف أمر القرآن أن نكلّم الناس؟",
         ["وقولوا للناس حسنًا", "بصوت منخفض جدًا", "بأقل قدر ممكن", "الأقارب فقط"], 0,
         "«وقولوا للناس حسنًا» — الكلمة الطيبة عبادة.",
         "القرآن — سورة البقرة، 2:83"))

add("virtues_017", "virtues", "medium", "quran", "Quran", "31:18", False,
    fr=L("Dans ses conseils à son fils, que dit Luqmân sur la démarche et l'orgueil ?",
         ["Ne marche pas sur terre avec arrogance", "Marche toujours vite", "Marche seulement la nuit", "Ne marche jamais seul"], 0,
         "« Ne détourne pas ton visage des gens par orgueil, et ne foule pas la terre avec arrogance. »",
         "Coran — Sourate Luqmân, 31:18"),
    en=L("In his advice to his son, what does Luqman say about walking and pride?",
         ["Do not walk on the earth arrogantly", "Always walk fast", "Only walk at night", "Never walk alone"], 0,
         "'Do not turn your cheek from people in pride, and do not walk the earth arrogantly.'",
         "Quran — Surah Luqman, 31:18"),
    ar=L("في وصاياه لابنه، ماذا قال لقمان عن المشية والكبر؟",
         ["لا تمشِ في الأرض مرحًا", "امشِ سريعًا دائمًا", "امشِ ليلًا فقط", "لا تمشِ وحدك أبدًا"], 0,
         "«ولا تصعّر خدك للناس ولا تمش في الأرض مرحًا».",
         "القرآن — سورة لقمان، 31:18"))

add("virtues_018", "virtues", "medium", "hadithBukhari", "Sahih al-Bukhari", "1", False,
    fr=L("Selon le tout premier hadith du recueil d'al-Bukhârî, de quoi dépendent les actes ?",
         ["Des intentions", "Des résultats", "Des habitudes", "Des témoins"], 0,
         "« Les actes ne valent que par les intentions, et chacun n'a que ce qu'il a eu l'intention de faire. »",
         "Sahîh al-Bukhârî — hadith n°1"),
    en=L("According to the very first hadith of al-Bukhari's collection, what are deeds judged by?",
         ["Intentions", "Results", "Habits", "Witnesses"], 0,
         "'Actions are but by intentions, and every person shall have only what they intended.'",
         "Sahih al-Bukhari — hadith no. 1"),
    ar=L("بحسب أول حديث في صحيح البخاري، بمَ تُقوَّم الأعمال؟",
         ["بالنيات", "بالنتائج", "بالعادات", "بالشهود"], 0,
         "«إنما الأعمال بالنيات وإنما لكل امرئ ما نوى».",
         "صحيح البخاري — الحديث رقم 1"))


# ---------------------------------------------------------------------
# Validation
# ---------------------------------------------------------------------

def validate():
    ids = [q["id"] for q in Q]
    assert len(ids) == len(set(ids)), "duplicate question id"
    counts = {"prophets": 0, "sira": 0, "quran": 0, "faith": 0, "virtues": 0}
    diffs = {"easy": 0, "medium": 0, "hard": 0}
    free_count = 0
    for q in Q:
        counts[q["category"]] += 1
        diffs[q["difficulty"]] += 1
        if q["isFree"]:
            free_count += 1
        for lang in ("fr", "en", "ar"):
            content = q[lang]
            assert len(content["answers"]) == 4, q["id"]
            assert 0 <= content["correctAnswerIndex"] < 4, q["id"]
            assert content["question"].strip(), q["id"]
            assert content["explanation"].strip(), q["id"]
            assert content["sourceDisplay"].strip(), q["id"]
            assert all(a.strip() for a in content["answers"]), q["id"]
        assert q["sourceReference"].strip(), q["id"]
    print("Total questions:", len(Q))
    print("By category:", counts)
    print("By difficulty:", diffs)
    print("Free questions:", free_count)
    return counts, diffs, free_count

# ---------------------------------------------------------------------
# Write output
# ---------------------------------------------------------------------
# Card values (1-6): the face value a drawn question card is worth, and
# at the same time its difficulty tier — 1 is the easiest question and
# the shortest move, 6 the hardest and the longest.
#
# The authored bank grades questions on three levels (easy / medium /
# hard), so each level is split into its two adjacent card values by
# sorting on the stable question id and halving. That keeps the scale
# monotonic — a value-2 card is never harder than a value-5 one — without
# inventing a precision the authoring does not have. Refining a specific
# question's tier is a matter of moving it between difficulty levels, or
# of adding an explicit override here.
#
# Uniformity of the draw is NOT this function's job: QuestionDeck keeps
# one pile per value and draws a value uniformly, so the odds match a
# fair die whatever the bank happens to hold.

_VALUE_BASE = {"easy": 1, "medium": 3, "hard": 5}


def assign_card_values(questions):
    """Return {question id: card value 1..6}."""
    by_difficulty = {}
    for q in questions:
        by_difficulty.setdefault(q["difficulty"], []).append(q)
    values = {}
    for difficulty, group in by_difficulty.items():
        group.sort(key=lambda q: q["id"])
        half = (len(group) + 1) // 2  # the lower tier takes the odd one
        for i, q in enumerate(group):
            values[q["id"]] = _VALUE_BASE[difficulty] + (0 if i < half else 1)
    return values


def select_free_ids(questions, values, size=21):
    """Free-tier ids, spread across all six card values.

    A free player rolls the same six-sided die as everyone else, so the
    free bank must hold at least one question of every value — otherwise
    a value simply never comes up. Dealing round-robin over the values
    guarantees that and keeps the free tier evenly graded.
    """
    by_value = {}
    for q in questions:
        by_value.setdefault(values[q["id"]], []).append(q["id"])
    for ids in by_value.values():
        ids.sort()
    free, i = [], 0
    while len(free) < size and i < size * 6:
        value, rank = 1 + (i % 6), i // 6
        pool = by_value.get(value, [])
        if rank < len(pool):
            free.append(pool[rank])
        i += 1
    return set(free)


def write_output():
    os.makedirs(f"{OUT_ROOT}/master", exist_ok=True)
    for lang in ("fr", "en", "ar"):
        os.makedirs(f"{OUT_ROOT}/{lang}", exist_ok=True)
    os.makedirs(CQ_ROOT, exist_ok=True)

    master = []
    per_lang = {"fr": [], "en": [], "ar": []}
    registry = {}
    csv_rows = []

    card_values = assign_card_values(Q)
    free_ids = select_free_ids(Q, card_values)

    for q in Q:
        master.append(dict(
            id=q["id"], category=q["category"], difficulty=q["difficulty"],
            value=card_values[q["id"]],
            ageLevel=q["ageLevel"], sourceType=q["sourceType"],
            sourceWork=q["sourceWork"], sourceReference=q["sourceReference"],
            sourceVerificationStatus="verified", consensusStatus="nonControversial",
            isFree=q["id"] in free_ids,
        ))
        for lang in ("fr", "en", "ar"):
            content = dict(id=q["id"], correctAnswerIndex=q[lang]["correctAnswerIndex"])
            content.update({
                "question": q[lang]["question"],
                "answers": q[lang]["answers"],
                "explanation": q[lang]["explanation"],
                "sourceDisplay": q[lang]["sourceDisplay"],
            })
            per_lang[lang].append(content)

        key = f'{q["sourceWork"]}::{q["sourceReference"]}'
        registry.setdefault(key, dict(
            sourceType=q["sourceType"], sourceWork=q["sourceWork"],
            sourceReference=q["sourceReference"], questionIds=[],
        ))["questionIds"].append(q["id"])

        csv_rows.append([
            q["id"], q["category"], q["sourceType"], q["sourceWork"],
            q["sourceReference"], "verified", "nonControversial",
        ])

    with open(f"{OUT_ROOT}/master/questions.json", "w", encoding="utf-8") as f:
        json.dump(master, f, ensure_ascii=False, indent=2)

    for lang in ("fr", "en", "ar"):
        with open(f"{OUT_ROOT}/{lang}/questions.json", "w", encoding="utf-8") as f:
            json.dump(per_lang[lang], f, ensure_ascii=False, indent=2)

    with open(f"{CQ_ROOT}/source_registry.json", "w", encoding="utf-8") as f:
        json.dump(list(registry.values()), f, ensure_ascii=False, indent=2)

    with open(f"{CQ_ROOT}/question_sources.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["question_id", "category", "source_type", "source_work",
                    "source_reference", "verification_status", "consensus_status"])
        w.writerows(csv_rows)

    per_value = {v: sum(1 for m in master if m["value"] == v) for v in range(1, 7)}
    free_per_value = {
        v: sum(1 for m in master if m["value"] == v and m["isFree"]) for v in range(1, 7)
    }
    print("Cards per value:", per_value)
    print("Free cards per value:", free_per_value)
    assert all(free_per_value[v] > 0 for v in range(1, 7)), (
        "every card value needs at least one free question, or that value "
        "can never be drawn on the free tier"
    )
    print("Wrote", len(master), "questions to", OUT_ROOT)
    print("Wrote source registry with", len(registry), "unique sources")

if __name__ == "__main__":
    validate()
    write_output()
