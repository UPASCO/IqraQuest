"""The beginner level — the very first questions (200).

Everything here is a fact an ordinary Muslim household already knows and
says out loud: the Prophet's ﷺ name, the book, the direction of prayer,
who built the ark, which month is fasted. It exists so that a very young
child, or somebody who has just come to the religion, can sit at the same
table as everyone else and actually answer.

"Basic" is not a licence to be vague. Every entry passes the same rules
as the rest of the bank (CONTENT_SOURCE_POLICY.md): a Qur'anic reference
where the verse states the fact plainly, and otherwise the
"well-established" reference class of §2bis — mass-transmitted,
descriptive, identical in any standard reference — with the prefix that
makes the class auditable at a glance. Nothing here is a made-up
citation, and nothing needs a school of law to answer.

Ids continue each category's own sequence:
    prophets_251 … prophets_310   (60)
    sira_251     … sira_300       (50)
    faith_151    … faith_200      (50)
    quran_151    … quran_180      (30)
    virtues_101  … virtues_110    (10)
"""


def register(add, L):
    Q = "Quran"
    S = "Sira"
    C = "Creed"
    WE = "well-established sira event, agreed across standard biographies"
    WT = "well-established terminology"
    WP = "well-established practice, agreed across the schools"
    WQ = "well-established Quranic-sciences fact"

    # ---- Prophets: the names every household says -------------------
    add("prophets_251", "prophets", "beginner", "sira", S, WE, True,
        fr=L("Comment s'appelle le prophète de l'islam ?",
             ["Muhammad ﷺ", "Ibrâhîm", "Mûsâ", "'Îsâ"], 0,
             "Le prophète de l'islam est Muhammad ﷺ, fils de 'Abdullâh.",
             "Fait établi — biographie du Prophète ﷺ"),
        en=L("What is the name of the Prophet of Islam?",
             ["Muhammad ﷺ", "Ibrahim", "Musa", "'Isa"], 0,
             "The Prophet of Islam is Muhammad ﷺ, son of 'Abdullah.",
             "Well-established — the Prophet's ﷺ biography"),
        ar=L("ما اسم نبيّ الإسلام؟",
             ["محمد ﷺ", "إبراهيم", "موسى", "عيسى"], 0,
             "نبيّ الإسلام هو محمد ﷺ بن عبد الله.",
             "أمر ثابت — سيرة النبي ﷺ"))

    add("prophets_252", "prophets", "beginner", "quran", Q, "11:37-38", True,
        fr=L("Quel prophète a construit l'arche ?",
             ["Nûh", "Yûsuf", "Dâwud", "Yûnus"], 0,
             "Allah ordonna à Nûh de construire l'arche sous Ses yeux.",
             "Coran — Sourate Hûd, 11:37-38"),
        en=L("Which prophet built the ark?",
             ["Nuh", "Yusuf", "Dawud", "Yunus"], 0,
             "Allah commanded Nuh to build the ark under His watch.",
             "Quran — Surah Hud, 11:37-38"),
        ar=L("أيّ نبيّ بنى السفينة؟",
             ["نوح", "يوسف", "داود", "يونس"], 0,
             "أمر الله نوحًا أن يصنع الفلك بأعينه.",
             "القرآن — سورة هود، 11:37-38"))

    add("prophets_253", "prophets", "beginner", "quran", Q, "37:142", True,
        fr=L("Quel prophète a été avalé par un grand poisson ?",
             ["Yûnus", "Nûh", "Hârûn", "Ilyâs"], 0,
             "« Le poisson l'avala alors qu'il était blâmable. »",
             "Coran — Sourate As-Sâffât, 37:142"),
        en=L("Which prophet was swallowed by a great fish?",
             ["Yunus", "Nuh", "Harun", "Ilyas"], 0,
             "\"Then the fish swallowed him, while he was blameworthy.\"",
             "Quran — Surah As-Saffat, 37:142"),
        ar=L("أيّ نبيّ التقمه الحوت؟",
             ["يونس", "نوح", "هارون", "إلياس"], 0,
             "«فالتقمه الحوت وهو مُليم».",
             "القرآن — سورة الصافات، 37:142"))

    add("prophets_254", "prophets", "beginner", "quran", Q, "19:16-21", True,
        fr=L("Qui est la mère du prophète 'Îsâ ?",
             ["Maryam", "Âsiya", "Hâjar", "Sâra"], 0,
             "Maryam, à qui une sourate entière du Coran est consacrée.",
             "Coran — Sourate Maryam, 19:16-21"),
        en=L("Who is the mother of the prophet 'Isa?",
             ["Maryam", "Asiya", "Hajar", "Sara"], 0,
             "Maryam, to whom a whole surah of the Qur'an is devoted.",
             "Quran — Surah Maryam, 19:16-21"),
        ar=L("مَن أمّ النبيّ عيسى؟",
             ["مريم", "آسية", "هاجر", "سارة"], 0,
             "مريم، التي خُصّت بسورة كاملة في القرآن.",
             "القرآن — سورة مريم، 19:16-21"))

    add("prophets_255", "prophets", "beginner", "quran", Q, "2:31", True,
        fr=L("Quel est le premier être humain créé par Allah ?",
             ["Âdam", "Nûh", "Ibrâhîm", "Idrîs"], 0,
             "Âdam est le premier homme, à qui Allah apprit tous les noms.",
             "Coran — Sourate Al-Baqara, 2:31"),
        en=L("Who is the first human being Allah created?",
             ["Adam", "Nuh", "Ibrahim", "Idris"], 0,
             "Adam is the first man, whom Allah taught all the names.",
             "Quran — Surah Al-Baqarah, 2:31"),
        ar=L("مَن أوّل إنسان خلقه الله؟",
             ["آدم", "نوح", "إبراهيم", "إدريس"], 0,
             "آدم أوّل البشر، وعلّمه الله الأسماء كلها.",
             "القرآن — سورة البقرة، 2:31"))

    add("prophets_256", "prophets", "beginner", "quran", Q, "21:69", True,
        fr=L("Pour quel prophète le feu est-il devenu fraîcheur et paix ?",
             ["Ibrâhîm", "Mûsâ", "Yûsuf", "Sulaymân"], 0,
             "« Ô feu, sois pour Ibrâhîm fraîcheur et paix. »",
             "Coran — Sourate Al-Anbiyâ', 21:69"),
        en=L("For which prophet did the fire become coolness and peace?",
             ["Ibrahim", "Musa", "Yusuf", "Sulaiman"], 0,
             "\"O fire, be coolness and peace upon Ibrahim.\"",
             "Quran — Surah Al-Anbiya, 21:69"),
        ar=L("لأيّ نبيّ صار النار بردًا وسلامًا؟",
             ["إبراهيم", "موسى", "يوسف", "سليمان"], 0,
             "«يا نار كوني بردًا وسلامًا على إبراهيم».",
             "القرآن — سورة الأنبياء، 21:69"))

    add("prophets_257", "prophets", "beginner", "quran", Q, "20:17-18", True,
        fr=L("Quel prophète portait un bâton qui devint serpent ?",
             ["Mûsâ", "Hârûn", "Yahyâ", "Zakariyyâ"], 0,
             "Allah demanda à Mûsâ : « Qu'y a-t-il dans ta main droite ? »",
             "Coran — Sourate Tâ-Hâ, 20:17-18"),
        en=L("Which prophet carried a staff that became a serpent?",
             ["Musa", "Harun", "Yahya", "Zakariyya"], 0,
             "Allah asked Musa: \"And what is that in your right hand?\"",
             "Quran — Surah Ta-Ha, 20:17-18"),
        ar=L("أيّ نبيّ كانت له عصا صارت حيّة؟",
             ["موسى", "هارون", "يحيى", "زكريا"], 0,
             "قال الله لموسى: «وما تلك بيمينك يا موسى؟».",
             "القرآن — سورة طه، 20:17-18"))

    add("prophets_258", "prophets", "beginner", "quran", Q, "12:4", True,
        fr=L("Quel prophète a vu en rêve onze étoiles se prosterner ?",
             ["Yûsuf", "Ya'qûb", "Ishâq", "Dâwud"], 0,
             "« Ô mon père, j'ai vu onze étoiles, le soleil et la lune. »",
             "Coran — Sourate Yûsuf, 12:4"),
        en=L("Which prophet dreamt of eleven stars prostrating?",
             ["Yusuf", "Ya'qub", "Ishaq", "Dawud"], 0,
             "\"O my father, I saw eleven stars, the sun and the moon.\"",
             "Quran — Surah Yusuf, 12:4"),
        ar=L("أيّ نبيّ رأى في منامه أحد عشر كوكبًا ساجدة؟",
             ["يوسف", "يعقوب", "إسحاق", "داود"], 0,
             "«يا أبتِ إني رأيت أحد عشر كوكبًا والشمس والقمر».",
             "القرآن — سورة يوسف، 12:4"))

    add("prophets_259", "prophets", "beginner", "quran", Q, "27:16", True,
        fr=L("Quel prophète comprenait le langage des oiseaux ?",
             ["Sulaymân", "Dâwud", "Ayyûb", "Idrîs"], 0,
             "« On nous a appris le langage des oiseaux », dit Sulaymân.",
             "Coran — Sourate An-Naml, 27:16"),
        en=L("Which prophet understood the speech of birds?",
             ["Sulaiman", "Dawud", "Ayyub", "Idris"], 0,
             "\"We have been taught the language of birds,\" said Sulaiman.",
             "Quran — Surah An-Naml, 27:16"),
        ar=L("أيّ نبيّ كان يفهم منطق الطير؟",
             ["سليمان", "داود", "أيوب", "إدريس"], 0,
             "قال سليمان: «عُلِّمنا منطق الطير».",
             "القرآن — سورة النمل، 27:16"))

    add("prophets_260", "prophets", "beginner", "quran", Q, "38:41", True,
        fr=L("Quel prophète est le modèle de la patience dans l'épreuve ?",
             ["Ayyûb", "Yûnus", "Lût", "Shu'ayb"], 0,
             "Ayyûb appela son Seigneur et fut trouvé endurant.",
             "Coran — Sourate Sâd, 38:41"),
        en=L("Which prophet is the model of patience in trial?",
             ["Ayyub", "Yunus", "Lut", "Shu'ayb"], 0,
             "Ayyub called upon his Lord and was found steadfast.",
             "Quran — Surah Sad, 38:41"),
        ar=L("أيّ نبيّ هو المثل في الصبر على البلاء؟",
             ["أيوب", "يونس", "لوط", "شعيب"], 0,
             "نادى أيوبُ ربَّه، فوُجد صابرًا.",
             "القرآن — سورة ص، 38:41"))

    add("prophets_261", "prophets", "beginner", "quran", Q, "2:127", True,
        fr=L("Quels deux prophètes ont élevé les fondations de la Ka'ba ?",
             ["Ibrâhîm et Ismâ'îl", "Mûsâ et Hârûn", "Dâwud et Sulaymân", "Nûh et Idrîs"], 0,
             "« Et quand Ibrâhîm élevait les assises de la Maison, avec Ismâ'îl. »",
             "Coran — Sourate Al-Baqara, 2:127"),
        en=L("Which two prophets raised the foundations of the Ka'bah?",
             ["Ibrahim and Isma'il", "Musa and Harun", "Dawud and Sulaiman", "Nuh and Idris"], 0,
             "\"And when Ibrahim was raising the foundations of the House, with Isma'il.\"",
             "Quran — Surah Al-Baqarah, 2:127"),
        ar=L("أيّ نبيّين رفعا قواعد الكعبة؟",
             ["إبراهيم وإسماعيل", "موسى وهارون", "داود وسليمان", "نوح وإدريس"], 0,
             "«وإذ يرفع إبراهيم القواعد من البيت وإسماعيل».",
             "القرآن — سورة البقرة، 2:127"))

    add("prophets_262", "prophets", "beginner", "quran", Q, "4:164", True,
        fr=L("À quel prophète Allah a-t-Il parlé directement ?",
             ["Mûsâ", "Yûsuf", "Yûnus", "Salih"], 0,
             "« Et Allah a parlé à Mûsâ de vive voix. »",
             "Coran — Sourate An-Nisâ', 4:164"),
        en=L("Which prophet did Allah speak to directly?",
             ["Musa", "Yusuf", "Yunus", "Salih"], 0,
             "\"And Allah spoke to Musa with direct speech.\"",
             "Quran — Surah An-Nisa, 4:164"),
        ar=L("أيّ نبيّ كلّمه الله تكليمًا؟",
             ["موسى", "يوسف", "يونس", "صالح"], 0,
             "«وكلّم الله موسى تكليمًا».",
             "القرآن — سورة النساء، 4:164"))

    add("prophets_263", "prophets", "beginner", "sira", S, WT, True,
        fr=L("Combien y a-t-il de prophètes après Muhammad ﷺ ?",
             ["Aucun : il est le dernier des prophètes", "Un", "Trois", "Sept"], 0,
             "Muhammad ﷺ est le sceau des prophètes : nul prophète après lui.",
             "Fait établi — article de foi"),
        en=L("How many prophets come after Muhammad ﷺ?",
             ["None: he is the last of the prophets", "One", "Three", "Seven"], 0,
             "Muhammad ﷺ is the seal of the prophets: no prophet comes after him.",
             "Well-established — article of faith"),
        ar=L("كم نبيًّا بعد محمد ﷺ؟",
             ["لا أحد: هو خاتم النبيين", "واحد", "ثلاثة", "سبعة"], 0,
             "محمد ﷺ خاتم النبيين، فلا نبيّ بعده.",
             "أمر ثابت — من أصول الإيمان"))

    add("prophets_264", "prophets", "beginner", "quran", Q, "2:136", True,
        fr=L("Quel prophète est appelé « l'ami intime » (khalîl) d'Allah ?",
             ["Ibrâhîm", "Mûsâ", "'Îsâ", "Nûh"], 0,
             "Ibrâhîm est le père des prophètes et l'ami intime du Miséricordieux.",
             "Coran — Sourate Al-Baqara, 2:136"),
        en=L("Which prophet is called the intimate friend (khalil) of Allah?",
             ["Ibrahim", "Musa", "'Isa", "Nuh"], 0,
             "Ibrahim is the father of the prophets and the intimate friend of the Most Merciful.",
             "Quran — Surah Al-Baqarah, 2:136"),
        ar=L("أيّ نبيّ يُسمّى خليل الله؟",
             ["إبراهيم", "موسى", "عيسى", "نوح"], 0,
             "إبراهيم أبو الأنبياء وخليل الرحمن.",
             "القرآن — سورة البقرة، 2:136"))

    add("prophets_265", "prophets", "beginner", "quran", Q, "5:110", True,
        fr=L("Quel prophète guérissait l'aveugle-né par la permission d'Allah ?",
             ["'Îsâ", "Yahyâ", "Zakariyyâ", "Ilyâs"], 0,
             "« Et tu guérissais l'aveugle-né et le lépreux par Ma permission. »",
             "Coran — Sourate Al-Mâ'ida, 5:110"),
        en=L("Which prophet healed the blind from birth by Allah's leave?",
             ["'Isa", "Yahya", "Zakariyya", "Ilyas"], 0,
             "\"And you healed the blind from birth and the leper by My permission.\"",
             "Quran — Surah Al-Ma'idah, 5:110"),
        ar=L("أيّ نبيّ كان يُبرئ الأكمه بإذن الله؟",
             ["عيسى", "يحيى", "زكريا", "إلياس"], 0,
             "«وتُبرئ الأكمه والأبرص بإذني».",
             "القرآن — سورة المائدة، 5:110"))

    add("prophets_266", "prophets", "beginner", "quran", Q, "34:10", True,
        fr=L("Pour quel prophète les montagnes chantaient-elles les louanges d'Allah ?",
             ["Dâwud", "Sulaymân", "Ayyûb", "Yûnus"], 0,
             "« Ô montagnes, redites avec lui les louanges d'Allah. »",
             "Coran — Sourate Saba', 34:10"),
        en=L("For which prophet did the mountains echo Allah's praise?",
             ["Dawud", "Sulaiman", "Ayyub", "Yunus"], 0,
             "\"O mountains, repeat Allah's praises with him.\"",
             "Quran — Surah Saba, 34:10"),
        ar=L("أيّ نبيّ سبّحت معه الجبال؟",
             ["داود", "سليمان", "أيوب", "يونس"], 0,
             "«يا جبال أوّبي معه والطير».",
             "القرآن — سورة سبأ، 34:10"))

    add("prophets_267", "prophets", "beginner", "quran", Q, "19:7", True,
        fr=L("Quel est le fils annoncé au prophète Zakariyyâ ?",
             ["Yahyâ", "'Îsâ", "Ishâq", "Ismâ'îl"], 0,
             "« Ô Zakariyyâ, Nous t'annonçons un garçon dont le nom est Yahyâ. »",
             "Coran — Sourate Maryam, 19:7"),
        en=L("Which son was announced to the prophet Zakariyya?",
             ["Yahya", "'Isa", "Ishaq", "Isma'il"], 0,
             "\"O Zakariyya, We give you good tidings of a boy whose name is Yahya.\"",
             "Quran — Surah Maryam, 19:7"),
        ar=L("بأيّ ولد بُشِّر النبيّ زكريا؟",
             ["يحيى", "عيسى", "إسحاق", "إسماعيل"], 0,
             "«يا زكريا إنا نبشّرك بغلام اسمه يحيى».",
             "القرآن — سورة مريم، 19:7"))

    add("prophets_268", "prophets", "beginner", "quran", Q, "12:8", True,
        fr=L("Qui est le père du prophète Yûsuf ?",
             ["Ya'qûb", "Ishâq", "Ibrâhîm", "Lût"], 0,
             "Yûsuf est le fils de Ya'qûb, lui-même fils d'Ishâq.",
             "Coran — Sourate Yûsuf, 12:8"),
        en=L("Who is the father of the prophet Yusuf?",
             ["Ya'qub", "Ishaq", "Ibrahim", "Lut"], 0,
             "Yusuf is the son of Ya'qub, himself the son of Ishaq.",
             "Quran — Surah Yusuf, 12:8"),
        ar=L("مَن والد النبيّ يوسف؟",
             ["يعقوب", "إسحاق", "إبراهيم", "لوط"], 0,
             "يوسف ابن يعقوب، ويعقوب ابن إسحاق.",
             "القرآن — سورة يوسف، 12:8"))

    add("prophets_269", "prophets", "beginner", "quran", Q, "2:50", True,
        fr=L("Quelle mer s'est fendue devant Mûsâ et son peuple ?",
             ["La mer, fendue pour les sauver de Pharaon", "Un fleuve d'Égypte", "Un lac de Madyan", "Un puits du désert"], 0,
             "« Et quand Nous avons fendu la mer pour vous, Nous vous avons sauvés. »",
             "Coran — Sourate Al-Baqara, 2:50"),
        en=L("What parted before Musa and his people?",
             ["The sea, parted to save them from Pharaoh", "A river of Egypt", "A lake of Madyan", "A desert well"], 0,
             "\"And when We parted the sea for you and saved you.\"",
             "Quran — Surah Al-Baqarah, 2:50"),
        ar=L("ماذا انفلق أمام موسى وقومه؟",
             ["البحر، فُلق لينجّيهم من فرعون", "نهر في مصر", "بحيرة في مدين", "بئر في الصحراء"], 0,
             "«وإذ فرقنا بكم البحر فأنجيناكم».",
             "القرآن — سورة البقرة، 2:50"))

    add("prophets_270", "prophets", "beginner", "sira", S, WT, True,
        fr=L("Que dit-on après avoir prononcé le nom du Prophète ﷺ ?",
             ["« Que la prière et la paix d'Allah soient sur lui »", "Rien de particulier", "« Merci »", "« Au revoir »"], 0,
             "On invoque sur lui la prière et la paix : sallâ-Llâhu 'alayhi wa sallam.",
             "Fait établi — usage constant des musulmans"),
        en=L("What is said after mentioning the Prophet's ﷺ name?",
             ["\"May Allah's blessings and peace be upon him\"", "Nothing in particular", "\"Thank you\"", "\"Goodbye\""], 0,
             "One invokes blessings and peace upon him: salla-Llahu 'alayhi wa sallam.",
             "Well-established — constant practice of Muslims"),
        ar=L("ماذا يُقال بعد ذكر اسم النبيّ ﷺ؟",
             ["«صلى الله عليه وسلم»", "لا شيء", "«شكرًا»", "«مع السلامة»"], 0,
             "يُصلّى عليه ويُسلّم: صلى الله عليه وسلم.",
             "أمر ثابت — من عمل المسلمين المستمر"))
