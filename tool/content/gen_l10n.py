#!/usr/bin/env python3
"""Generates lib/l10n/app_<lang>.arb for IqraQuest's 12 launch languages
from one source-of-truth table (key -> {lang: text}), English-keyed with
an ICU description for the template file.

Keeping every language's string next to its siblings (instead of one
file per language) makes it possible to spot a missing/blank translation
at a glance while authoring, which is the main failure mode this script
guards against (see the validate() step).
"""
import json
import os

OUT = "/home/user/IqraQuest/lib/l10n"
LANGS = ["fr", "en", "ar", "es", "pt", "de", "tr", "id", "ur", "ms", "it", "nl"]

# key -> (description, placeholders, {lang: text})
K = {}

def s(key, desc, ph=None, **texts):
    missing = [l for l in LANGS if l not in texts]
    assert not missing, f"{key}: missing {missing}"
    K[key] = (desc, ph, texts)

# ---- App -------------------------------------------------------------
s("appName", "Application name, unchanged across locales",
  fr="IqraQuest", en="IqraQuest", ar="إكرا كويست", es="IqraQuest", pt="IqraQuest",
  de="IqraQuest", tr="IqraQuest", id="IqraQuest", ur="اقرا کویسٹ", ms="IqraQuest",
  it="IqraQuest", nl="IqraQuest")

s("appTagline", "Home screen tagline under the logo",
  fr="Le voyage de la connaissance", en="The journey of knowledge",
  ar="رحلة المعرفة", es="El viaje del conocimiento", pt="A jornada do conhecimento",
  de="Die Reise des Wissens", tr="Bilgi yolculuğu", id="Perjalanan pengetahuan",
  ur="علم کا سفر", ms="Perjalanan ilmu", it="Il viaggio della conoscenza",
  nl="De reis van kennis")

# ---- Onboarding --------------------------------------------------------
s("onboardingWelcomeTitle", "Onboarding first screen title",
  fr="Bienvenue sur IqraQuest", en="Welcome to IqraQuest", ar="مرحبًا بك في إكرا كويست",
  es="Bienvenido a IqraQuest", pt="Bem-vindo ao IqraQuest", de="Willkommen bei IqraQuest",
  tr="IqraQuest'e Hoş Geldiniz", id="Selamat Datang di IqraQuest",
  ur="اقرا کویسٹ میں خوش آمدید", ms="Selamat Datang ke IqraQuest",
  it="Benvenuto su IqraQuest", nl="Welkom bij IqraQuest")

s("onboardingWelcomeSubtitle", "Welcome screen subtitle",
  fr="Pioche une carte, réponds, avance — et ramène ton cheval jusqu'à La Mecque.",
  en="Draw a card, answer, ride on — and bring your horse home to Mecca.",
  ar="اسحب بطاقة، أجب، تقدّم — وأوصل حصانك إلى مكة.",
  es="Roba una carta, responde, avanza: lleva tu caballo hasta La Meca.",
  pt="Puxe uma carta, responda, avance — e leve seu cavalo até Meca.",
  de="Zieh eine Karte, antworte, reite weiter — und bring dein Pferd nach Mekka.",
  tr="Bir kart çek, cevapla, ilerle — ve atını Mekke'ye ulaştır.",
  id="Ambil kartu, jawab, melaju — dan bawa kudamu sampai ke Makkah.",
  ur="کارڈ نکالیں، جواب دیں، آگے بڑھیں — اور اپنے گھوڑے کو مکہ پہنچائیں۔",
  ms="Cabut kad, jawab, teruskan — dan bawa kuda anda ke Makkah.",
  it="Pesca una carta, rispondi, avanza — e porta il tuo cavallo fino alla Mecca.",
  nl="Trek een kaart, antwoord, rijd door — en breng je paard naar Mekka.")

s("getStarted", "Primary CTA button on onboarding",
  fr="Commencer", en="Get started", ar="ابدأ", es="Comenzar", pt="Começar",
  de="Loslegen", tr="Başla", id="Mulai", ur="شروع کریں", ms="Mulakan",
  it="Inizia", nl="Beginnen")

s("onboardingHowTo", "Welcome screen: heading over the three-gesture strip",
  fr="Comment on joue", en="How it plays", ar="كيف نلعب", es="Cómo se juega",
  pt="Como se joga", de="So wird gespielt", tr="Nasıl oynanır", id="Cara bermain",
  ur="کیسے کھیلتے ہیں", ms="Cara bermain", it="Come si gioca", nl="Zo speel je")

s("onboardingStepDraw", "Welcome screen, gesture 1: draw a card (it announces its stake)",
  fr="Pioche une carte : elle annonce ses galops", en="Draw a card: it announces its gallops",
  ar="اسحب بطاقة: تعلن عدد ركضاتها", es="Roba una carta: anuncia sus galopes",
  pt="Compre uma carta: ela anuncia seus galopes", de="Zieh eine Karte: sie nennt ihren Galopp",
  tr="Bir kart çek: dörtnalını söyler", id="Ambil kartu: ia mengumumkan lompatannya",
  ur="کارڈ نکالیں: وہ اپنی سرپٹ بتاتا ہے", ms="Ambil kad: ia mengumumkan lompatannya",
  it="Pesca una carta: annuncia i suoi galoppi", nl="Trek een kaart: hij noemt zijn galop")

s("onboardingStepAnswer", "Welcome screen, gesture 2: answer right to win the gallops",
  fr="Réponds juste : les galops sont à toi", en="Answer right: the gallops are yours",
  ar="أجب إجابة صحيحة: الركضات لك", es="Acierta: los galopes son tuyos",
  pt="Acerte: os galopes são seus", de="Antworte richtig: der Galopp gehört dir",
  tr="Doğru cevapla: dörtnal senindir", id="Jawab benar: lompatannya milikmu",
  ur="صحیح جواب دیں: سرپٹ آپ کی ہے", ms="Jawab betul: lompatan itu milik anda",
  it="Rispondi bene: i galoppi sono tuoi", nl="Antwoord goed: de galop is van jou")

s("onboardingStepRide", "Welcome screen, gesture 3: place a horse and ride to the oasis",
  fr="Pose ton cheval et galope jusqu\'à l\'oasis", en="Set a horse down and ride to the oasis",
  ar="ضع حصانك واركض حتى الواحة", es="Coloca tu caballo y galopa hasta el oasis",
  pt="Coloque seu cavalo e galope até o oásis", de="Setz dein Pferd und reite zur Oase",
  tr="Atını koy ve vahaya dörtnala git", id="Letakkan kudamu dan berlari ke oasis",
  ur="اپنا گھوڑا رکھیں اور نخلستان تک سرپٹ دوڑیں", ms="Letakkan kuda anda dan berlari ke oasis",
  it="Posa il tuo cavallo e galoppa fino all\'oasi", nl="Zet je paard neer en rijd naar de oase")

s("onboardingLanguageHint", "Welcome screen: under the language chips",
  fr="Tu pourras la changer plus tard dans les réglages.", en="You can change it later in Settings.",
  ar="يمكنك تغييرها لاحقًا من الإعدادات.", es="Podrás cambiarla luego en los ajustes.",
  pt="Você poderá mudá-la depois nas configurações.", de="Du kannst sie später in den Einstellungen ändern.",
  tr="Daha sonra ayarlardan değiştirebilirsin.", id="Kamu bisa mengubahnya nanti di Pengaturan.",
  ur="آپ اسے بعد میں ترتیبات میں بدل سکتے ہیں۔", ms="Anda boleh menukarnya kemudian dalam Tetapan.",
  it="Potrai cambiarla più tardi nelle impostazioni.", nl="Je kunt dit later in Instellingen wijzigen.")

s("chooseLanguage", "Language picker label",
  fr="Choisir la langue", en="Choose language", ar="اختر اللغة", es="Elegir idioma",
  pt="Escolher idioma", de="Sprache wählen", tr="Dil seçin", id="Pilih bahasa",
  ur="زبان منتخب کریں", ms="Pilih bahasa", it="Scegli lingua", nl="Kies taal")

# ---- Home ---------------------------------------------------------------
s("play", "Primary home screen action",
  fr="Jouer", en="Play", ar="العب", es="Jugar", pt="Jogar", de="Spielen",
  tr="Oyna", id="Main", ur="کھیلیں", ms="Main", it="Gioca", nl="Spelen")

s("soloMode", "Home screen mode option",
  fr="Solo", en="Solo", ar="فردي", es="Individual", pt="Solo", de="Solo",
  tr="Tek Kişilik", id="Solo", ur="سولو", ms="Solo", it="Solo", nl="Solo")

s("familyMode", "Home screen mode option",
  fr="Famille", en="Family", ar="عائلي", es="Familia", pt="Família", de="Familie",
  tr="Aile", id="Keluarga", ur="خاندان", ms="Keluarga", it="Famiglia", nl="Familie")

s("dailyChallenge", "Home screen menu item",
  fr="Défi du jour", en="Daily Challenge", ar="تحدي اليوم", es="Reto diario",
  pt="Desafio diário", de="Tagesherausforderung", tr="Günlük Meydan Okuma",
  id="Tantangan Harian", ur="روزانہ چیلنج", ms="Cabaran Harian", it="Sfida del giorno",
  nl="Dagelijkse uitdaging")

s("progress", "Home screen menu item",
  fr="Progression", en="Progress", ar="التقدم", es="Progreso", pt="Progresso",
  de="Fortschritt", tr="İlerleme", id="Kemajuan", ur="پیش رفت", ms="Kemajuan",
  it="Progressi", nl="Voortgang")

s("settings", "Home screen menu item",
  fr="Réglages", en="Settings", ar="الإعدادات", es="Ajustes", pt="Configurações",
  de="Einstellungen", tr="Ayarlar", id="Pengaturan", ur="ترتیبات", ms="Tetapan",
  it="Impostazioni", nl="Instellingen")

s("premium", "Home screen menu item / badge",
  fr="Premium", en="Premium", ar="بريميوم", es="Premium", pt="Premium", de="Premium",
  tr="Premium", id="Premium", ur="پریمیم", ms="Premium", it="Premium", nl="Premium")

s("continueGame", "Resume a saved game",
  fr="Continuer la partie", en="Continue game", ar="متابعة اللعبة",
  es="Continuar partida", pt="Continuar jogo", de="Spiel fortsetzen",
  tr="Oyuna Devam Et", id="Lanjutkan Permainan", ur="کھیل جاری رکھیں",
  ms="Sambung Permainan", it="Continua partita", nl="Spel voortzetten")

# ---- Mode / player setup --------------------------------------------------
s("quickGame", "Game variant: four horses each, the first one home wins",
  fr="Partie rapide", en="Quick game", ar="لعبة سريعة", es="Partida rápida",
  pt="Jogo rápido", de="Schnellspiel", tr="Hızlı Oyun", id="Permainan Cepat",
  ur="فوری کھیل", ms="Permainan Pantas", it="Partita rapida", nl="Snel spel")

s("classicGame", "Game variant: 4 pawns per player",
  fr="Partie classique", en="Classic game", ar="لعبة كلاسيكية", es="Partida clásica",
  pt="Jogo clássico", de="Klassisches Spiel", tr="Klasik Oyun", id="Permainan Klasik",
  ur="کلاسک کھیل", ms="Permainan Klasik", it="Partita classica", nl="Klassiek spel")

# ---- Board HUD and the in-game menu ---------------------------------------
s("hudArrivedHeading", "Heading over the row of per-rider arrival counters",
  fr="Chevaux arrivés", en="Horses home", ar="الخيول الواصلة",
  es="Caballos llegados", pt="Cavalos chegados", de="Angekommene Pferde",
  tr="Varan atlar", id="Kuda yang tiba", ur="پہنچے ہوئے گھوڑے",
  ms="Kuda yang tiba", it="Cavalli arrivati", nl="Aangekomen paarden")

s("hudKnowledgeShort", "One-word label beside the knowledge-point counter",
  fr="savoir", en="knowledge", ar="معرفة", es="saber", pt="saber",
  de="Wissen", tr="bilgi", id="ilmu", ur="علم", ms="ilmu",
  it="sapere", nl="kennis")

s("hudStreakShort", "One-word label beside the streak counter: right answers in a row",
  fr="série", en="streak", ar="متتالية", es="racha", pt="sequência",
  de="Serie", tr="seri", id="beruntun", ur="تسلسل", ms="rentetan",
  it="serie", nl="reeks")

s("hudCardsShort", "One-word label beside the remaining-cards counter",
  fr="cartes", en="cards", ar="بطاقات", es="cartas", pt="cartas",
  de="Karten", tr="kart", id="kartu", ur="کارڈ", ms="kad",
  it="carte", nl="kaarten")

s("boardMenuTitle", "Title of the sheet opened by the board's menu button",
  fr="Menu de la partie", en="Game menu", ar="قائمة اللعبة",
  es="Menú de la partida", pt="Menu do jogo", de="Spielmenü",
  tr="Oyun menüsü", id="Menu permainan", ur="کھیل کا مینو",
  ms="Menu permainan", it="Menu della partita", nl="Spelmenu")

s("boardMenuOpen", "Screen-reader label of the board's menu button",
  fr="Ouvrir le menu de la partie", en="Open the game menu",
  ar="افتح قائمة اللعبة", es="Abrir el menú de la partida",
  pt="Abrir o menu do jogo", de="Spielmenü öffnen",
  tr="Oyun menüsünü aç", id="Buka menu permainan",
  ur="کھیل کا مینو کھولیں", ms="Buka menu permainan",
  it="Apri il menu della partita", nl="Spelmenu openen")

s("autoPlaySingleMove", "Setting: play the only possible move without asking",
  fr="Déplacement automatique", en="Automatic move", ar="حركة تلقائية",
  es="Movimiento automático", pt="Movimento automático",
  de="Automatischer Zug", tr="Otomatik hamle", id="Gerakan otomatis",
  ur="خودکار چال", ms="Gerakan automatik", it="Mossa automatica",
  nl="Automatische zet")

s("autoPlaySingleMoveHint", "What the automatic-move setting does",
  fr="Quand un seul cheval peut jouer la carte, il avance tout seul.",
  en="When only one horse can play the card, it rides by itself.",
  ar="عندما يستطيع حصان واحد فقط لعب البطاقة، ينطلق وحده.",
  es="Cuando solo un caballo puede jugar la carta, avanza solo.",
  pt="Quando só um cavalo pode jogar a carta, ele avança sozinho.",
  de="Kann nur ein Pferd die Karte spielen, zieht es von allein.",
  tr="Kartı yalnızca bir at oynayabiliyorsa, kendiliğinden ilerler.",
  id="Bila hanya satu kuda yang bisa memainkan kartu, ia melaju sendiri.",
  ur="جب صرف ایک گھوڑا کارڈ کھیل سکے تو وہ خود آگے بڑھ جاتا ہے۔",
  ms="Apabila hanya satu kuda boleh bermain kad itu, ia melaju sendiri.",
  it="Quando un solo cavallo può giocare la carta, avanza da sé.",
  nl="Kan maar één paard de kaart spelen, dan rijdt het vanzelf.")

s("restartRace", "Board menu: start the same race over",
  fr="Recommencer la course", en="Restart the race", ar="أعد السباق",
  es="Reiniciar la carrera", pt="Recomeçar a corrida",
  de="Rennen neu starten", tr="Yarışı yeniden başlat",
  id="Mulai ulang balapan", ur="دوڑ دوبارہ شروع کریں",
  ms="Mulakan semula perlumbaan", it="Ricomincia la corsa",
  nl="Race opnieuw starten")

s("restartRaceConfirm", "Confirmation before throwing the current race away",
  fr="La course en cours sera perdue. Les mêmes cavaliers repartent de l'écurie.",
  en="The race in progress will be lost. The same riders start again from the stable.",
  ar="سيُفقد السباق الجاري. ينطلق الفرسان أنفسهم من الإسطبل من جديد.",
  es="Se perderá la carrera en curso. Los mismos jinetes vuelven a salir del establo.",
  pt="A corrida em curso será perdida. Os mesmos cavaleiros recomeçam do estábulo.",
  de="Das laufende Rennen geht verloren. Dieselben Reiter starten wieder vom Stall.",
  tr="Süren yarış kaybolacak. Aynı biniciler ahırdan yeniden başlar.",
  id="Balapan yang sedang berjalan akan hilang. Penunggang yang sama mulai lagi dari kandang.",
  ur="جاری دوڑ ختم ہو جائے گی۔ وہی سوار اصطبل سے دوبارہ شروع کریں گے۔",
  ms="Perlumbaan yang sedang berjalan akan hilang. Penunggang yang sama bermula semula dari kandang.",
  it="La corsa in corso andrà persa. Gli stessi cavalieri ripartono dalla stalla.",
  nl="De lopende race gaat verloren. Dezelfde ruiters starten opnieuw vanaf de stal.")

s("backToHome", "Board menu: leave the board for the home screen",
  fr="Retour à l'accueil", en="Back to home", ar="العودة إلى الرئيسية",
  es="Volver al inicio", pt="Voltar ao início", de="Zurück zur Startseite",
  tr="Ana ekrana dön", id="Kembali ke beranda", ur="ہوم پر واپس",
  ms="Kembali ke laman utama", it="Torna alla home", nl="Terug naar start")

s("backToHomeHint", "Reassurance beside 'back to home': the game is kept",
  fr="La partie est sauvegardée, tu pourras la reprendre.",
  en="The game is saved; you can pick it up again.",
  ar="اللعبة محفوظة، يمكنك متابعتها لاحقًا.",
  es="La partida se guarda; podrás retomarla.",
  pt="O jogo fica guardado; poderás retomá-lo.",
  de="Das Spiel wird gespeichert; du kannst später weitermachen.",
  tr="Oyun kaydedilir; daha sonra devam edebilirsin.",
  id="Permainan tersimpan; kamu bisa melanjutkannya nanti.",
  ur="کھیل محفوظ ہے، تم بعد میں جاری رکھ سکتے ہو۔",
  ms="Permainan disimpan; kamu boleh menyambungnya nanti.",
  it="La partita è salvata; potrai riprenderla.",
  nl="Het spel is opgeslagen; je kunt later verder.")

s("duoGame", "Game format: two of a player's four horses must reach Mecca",
  fr="Partie en duo", en="Duo game", ar="لعبة ثنائية", es="Partida en dúo",
  pt="Jogo em dupla", de="Duo-Spiel", tr="İkili Oyun", id="Permainan Duo",
  ur="جوڑی کھیل", ms="Permainan Duo", it="Partita in duo", nl="Duospel")

s("horsesToMecca", "What a format asks for: how many horses must reach Mecca",
  ph={"count": "num"},
  fr="{count, plural, one{{count} cheval à La Mecque} other{{count} chevaux à La Mecque}}",
  en="{count, plural, one{{count} horse to Mecca} other{{count} horses to Mecca}}",
  ar="{count, plural, one{حصان واحد إلى مكة} two{حصانان إلى مكة} few{{count} أحصنة إلى مكة} many{{count} حصانًا إلى مكة} other{{count} حصان إلى مكة}}",
  es="{count, plural, one{{count} caballo a La Meca} other{{count} caballos a La Meca}}",
  pt="{count, plural, one{{count} cavalo até Meca} other{{count} cavalos até Meca}}",
  de="{count, plural, one{{count} Pferd nach Mekka} other{{count} Pferde nach Mekka}}",
  tr="{count, plural, other{Mekke'ye {count} at}}",
  id="{count, plural, other{{count} kuda ke Mekah}}",
  ur="{count, plural, one{{count} گھوڑا مکہ تک} other{{count} گھوڑے مکہ تک}}",
  ms="{count, plural, other{{count} kuda ke Mekah}}",
  it="{count, plural, one{{count} cavallo alla Mecca} other{{count} cavalli alla Mecca}}",
  nl="{count, plural, one{{count} paard naar Mekka} other{{count} paarden naar Mekka}}")

s("formatQuickHint", "Format card: how long the quick race runs",
  fr="La course la plus courte.", en="The shortest race.",
  ar="أقصر سباق.", es="La carrera más corta.", pt="A corrida mais curta.",
  de="Das kürzeste Rennen.", tr="En kısa yarış.", id="Balapan terpendek.",
  ur="سب سے مختصر دوڑ۔", ms="Perlumbaan paling singkat.",
  it="La corsa più breve.", nl="De kortste race.")

s("formatDuoHint", "Format card: how long the two-horse race runs",
  fr="Une course d'un soir.", en="An evening's race.",
  ar="سباق سهرة واحدة.", es="Una carrera de una tarde.",
  pt="Uma corrida de uma noite.", de="Ein Rennen für einen Abend.",
  tr="Bir akşamlık yarış.", id="Balapan satu malam.",
  ur="ایک شام کی دوڑ۔", ms="Perlumbaan satu petang.",
  it="Una corsa di una sera.", nl="Een race voor één avond.")

s("formatClassicHint", "Format card: how long the full race runs",
  fr="La partie complète, comme au jeu d'origine.",
  en="The full game, as in the original.",
  ar="اللعبة الكاملة، كما في الأصل.",
  es="La partida completa, como en el juego original.",
  pt="O jogo completo, como no original.",
  de="Das ganze Spiel, wie im Original.",
  tr="Orijinaldeki gibi tam oyun.",
  id="Permainan penuh, seperti aslinya.",
  ur="مکمل کھیل، اصل جیسا۔",
  ms="Permainan penuh, seperti asalnya.",
  it="La partita completa, come nel gioco originale.",
  nl="Het volledige spel, net als het origineel.")

s("bonusSquaresOption", "Setup toggle: play with the bonus squares on the course",
  fr="Cases bonus sur le parcours", en="Bonus squares on the course",
  ar="مربعات المكافأة على المسار", es="Casillas de bonificación en el recorrido",
  pt="Casas de bónus no percurso", de="Bonusfelder auf der Strecke",
  tr="Parkurda bonus kareler", id="Petak bonus di lintasan",
  ur="راستے پر بونس خانے", ms="Petak bonus di laluan",
  it="Caselle bonus sul percorso", nl="Bonusvakjes op het parcours")

s("bonusSquaresOn", "Setup toggle, on: what the bonus squares give",
  fr="16 cases offrent une chevauchée en plus : +5, +10 ou +20.",
  en="16 squares grant an extra ride: +5, +10 or +20.",
  ar="16 مربعًا تمنح جولة إضافية: +5 أو +10 أو +20.",
  es="16 casillas dan una cabalgada extra: +5, +10 o +20.",
  pt="16 casas dão uma cavalgada extra: +5, +10 ou +20.",
  de="16 Felder schenken einen Extra-Ritt: +5, +10 oder +20.",
  tr="16 kare fazladan koşu verir: +5, +10 veya +20.",
  id="16 petak memberi tunggangan ekstra: +5, +10, atau +20.",
  ur="16 خانے اضافی سواری دیتے ہیں: ‎+5، ‎+10 یا ‎+20۔",
  ms="16 petak memberi tunggangan tambahan: +5, +10 atau +20.",
  it="16 caselle regalano una cavalcata in più: +5, +10 o +20.",
  nl="16 vakjes geven een extra rit: +5, +10 of +20.")

s("bonusSquaresOff", "Setup toggle, off: the pure ride",
  fr="Parcours pur : une carte vaut exactement ses galops.",
  en="A pure ride: a card is worth exactly its gallops.",
  ar="مسار خالص: البطاقة تساوي عدد ركضاتها بالضبط.",
  es="Recorrido puro: una carta vale exactamente sus galopes.",
  pt="Percurso puro: uma carta vale exatamente os seus galopes.",
  de="Reine Strecke: Eine Karte zählt genau ihre Galoppe.",
  tr="Saf parkur: bir kart tam olarak kendi dörtnalları kadar eder.",
  id="Lintasan murni: satu kartu bernilai persis derap-nya.",
  ur="خالص راستہ: کارڈ بالکل اپنی سرپٹ کے برابر ہے۔",
  ms="Laluan tulen: satu kad bernilai tepat derapnya.",
  it="Percorso puro: una carta vale esattamente i suoi galoppi.",
  nl="Puur parcours: een kaart is precies zijn galops waard.")

s("muteSound", "Board button: silence the game",
  fr="Couper le son", en="Mute sound", ar="كتم الصوت", es="Silenciar",
  pt="Silenciar", de="Ton aus", tr="Sesi kapat", id="Matikan suara",
  ur="آواز بند کریں", ms="Senyapkan bunyi", it="Disattiva audio",
  nl="Geluid uit")

s("unmuteSound", "Board button: bring the game's sound back",
  fr="Rétablir le son", en="Unmute sound", ar="تشغيل الصوت", es="Activar sonido",
  pt="Ativar som", de="Ton an", tr="Sesi aç", id="Nyalakan suara",
  ur="آواز چالو کریں", ms="Hidupkan bunyi", it="Attiva audio",
  nl="Geluid aan")

s("chooseDifficulty", "AI difficulty picker label",
  fr="Choisir la difficulté", en="Choose difficulty", ar="اختر مستوى الصعوبة",
  es="Elegir dificultad", pt="Escolher dificuldade", de="Schwierigkeit wählen",
  tr="Zorluk seçin", id="Pilih tingkat kesulitan", ur="مشکل کا درجہ منتخب کریں",
  ms="Pilih tahap kesukaran", it="Scegli difficoltà", nl="Kies moeilijkheidsgraad")

s("difficultyEasy", "AI/quiz difficulty level",
  fr="Facile", en="Easy", ar="سهل", es="Fácil", pt="Fácil", de="Leicht",
  tr="Kolay", id="Mudah", ur="آسان", ms="Mudah", it="Facile", nl="Makkelijk")

s("difficultyMedium", "Middle difficulty; kept short so a three-way selector stays symmetrical",
  fr="Moyen", en="Medium", ar="متوسط", es="Medio", pt="Médio",
  de="Mittel", tr="Orta", id="Sedang", ur="درمیانہ", ms="Sederhana",
  it="Medio", nl="Gemiddeld")

s("difficultyHard", "AI/quiz difficulty level",
  fr="Difficile", en="Hard", ar="صعب", es="Difícil", pt="Difícil", de="Schwer",
  tr="Zor", id="Sulit", ur="مشکل", ms="Sukar", it="Difficile", nl="Moeilijk")

s("playerName", "Player name input label",
  fr="Prénom", en="Name", ar="الاسم", es="Nombre", pt="Nome", de="Name",
  tr="İsim", id="Nama", ur="نام", ms="Nama", it="Nome", nl="Naam")

s("chooseTeam", "Team/color picker label",
  fr="Choisir l'équipe", en="Choose team", ar="اختر الفريق", es="Elegir equipo",
  pt="Escolher equipe", de="Team wählen", tr="Takım seçin", id="Pilih tim",
  ur="ٹیم منتخب کریں", ms="Pilih pasukan", it="Scegli squadra", nl="Kies team")

s("ridersTitle", "Player setup screen title: the riders about to take the track",
  fr="Les cavaliers", en="The riders", ar="الفرسان", es="Los jinetes",
  pt="Os cavaleiros", de="Die Reiter", tr="Biniciler", id="Para penunggang",
  ur="سوار", ms="Para penunggang", it="I cavalieri", nl="De ruiters")

s("storeLoading", "Premium screen: button label while the Store product is still loading",
  fr="Connexion à la boutique…", en="Connecting to the store…", ar="جارٍ الاتصال بالمتجر…",
  es="Conectando con la tienda…", pt="Ligando à loja…", de="Verbindung zum Store…",
  tr="Mağazaya bağlanılıyor…", id="Menghubungkan ke toko…", ur="اسٹور سے رابطہ ہو رہا ہے…",
  ms="Menyambung ke kedai…", it="Connessione allo store…", nl="Verbinden met de store…")

s("storeUnavailableCta", "Premium screen: disabled button label when the Store cannot be reached",
  fr="Boutique indisponible", en="Store unavailable", ar="المتجر غير متاح",
  es="Tienda no disponible", pt="Loja indisponível", de="Store nicht verfügbar",
  tr="Mağaza kullanılamıyor", id="Toko tidak tersedia", ur="اسٹور دستیاب نہیں",
  ms="Kedai tidak tersedia", it="Store non disponibile", nl="Store niet beschikbaar")

s("premiumBenefitBank", "Premium benefit row: the complete question bank",
  fr="Toute la banque de questions, chacune avec sa source",
  en="The whole question bank, each with its source",
  ar="بنك الأسئلة كاملاً، كل سؤال بمصدره", es="Todo el banco de preguntas, cada una con su fuente",
  pt="Todo o banco de perguntas, cada uma com a sua fonte", de="Die ganze Fragensammlung, jede mit Quelle",
  tr="Tüm soru bankası, her biri kaynağıyla", id="Seluruh bank soal, masing-masing dengan sumbernya",
  ur="پورا سوالات کا ذخیرہ، ہر ایک اپنے ماخذ کے ساتھ", ms="Seluruh bank soalan, setiap satu dengan sumbernya",
  it="Tutta la banca di domande, ognuna con la sua fonte", nl="De hele vragenbank, elk met bron")

s("premiumBenefitUnlimited", "Premium benefit row: games run to the end (the free edition stops after N draws)",
  ph={"count": "int"},
  fr="Des parties illimitées, jusqu'à La Mecque (la version gratuite s'arrête après {count} pioches)",
  en="Unlimited games, all the way to Mecca (the free edition stops after {count} draws)",
  ar="مباريات غير محدودة حتى مكة (النسخة المجانية تتوقف بعد {count} سحبة)",
  es="Partidas ilimitadas, hasta La Meca (la versión gratuita se detiene tras {count} robos)",
  pt="Partidas ilimitadas, até Meca (a versão gratuita para após {count} puxadas)",
  de="Unbegrenzte Spiele bis nach Mekka (die Gratisversion endet nach {count} Zügen)",
  tr="Mekke'ye kadar sınırsız oyun (ücretsiz sürüm {count} çekilişten sonra durur)",
  id="Permainan tanpa batas, sampai Makkah (versi gratis berhenti setelah {count} kali ambil kartu)",
  ur="لامحدود کھیل، مکہ تک (مفت ورژن {count} کارڈ کے بعد رک جاتا ہے)",
  ms="Permainan tanpa had, hingga ke Makkah (versi percuma berhenti selepas {count} cabutan)",
  it="Partite illimitate, fino alla Mecca (la versione gratuita si ferma dopo {count} pescate)",
  nl="Onbeperkt spelen, tot aan Mekka (de gratis versie stopt na {count} kaarten)")

s("premiumBenefitFamily", "Premium benefit row: one purchase for the whole family, no ads",
  fr="Un seul achat pour toute la famille, sans publicité",
  en="One purchase for the whole family, no ads",
  ar="شراء واحد لكل العائلة، بدون إعلانات", es="Una sola compra para toda la familia, sin anuncios",
  pt="Uma única compra para toda a família, sem anúncios", de="Ein Kauf für die ganze Familie, ohne Werbung",
  tr="Tüm aile için tek bir satın alma, reklamsız", id="Satu pembelian untuk seluruh keluarga, tanpa iklan",
  ur="پورے خاندان کے لیے ایک ہی خریداری، بغیر اشتہارات", ms="Satu pembelian untuk seisi keluarga, tanpa iklan",
  it="Un solo acquisto per tutta la famiglia, senza pubblicità", nl="Eén aankoop voor het hele gezin, zonder advertenties")

s("progressEmpty", "Progress screen hint shown before any game has been played",
  fr="Joue une première partie : tes progrès s'afficheront ici.",
  en="Play a first game: your progress will show up here.",
  ar="العب أول مباراة: سيظهر تقدمك هنا.", es="Juega una primera partida: tu progreso aparecerá aquí.",
  pt="Joga uma primeira partida: o teu progresso aparece aqui.", de="Spiel eine erste Partie: dein Fortschritt erscheint hier.",
  tr="İlk oyununu oyna: ilerlemen burada görünecek.", id="Mainkan permainan pertama: kemajuanmu akan muncul di sini.",
  ur="پہلا کھیل کھیلو: تمہاری پیش رفت یہاں نظر آئے گی۔", ms="Main permainan pertama: kemajuan anda akan dipaparkan di sini.",
  it="Gioca una prima partita: i tuoi progressi appariranno qui.", nl="Speel een eerste spel: je voortgang verschijnt hier.")

s("addPlayer", "Add another player button",
  fr="Ajouter un joueur", en="Add player", ar="إضافة لاعب", es="Añadir jugador",
  pt="Adicionar jogador", de="Spieler hinzufügen", tr="Oyuncu Ekle",
  id="Tambah Pemain", ur="کھلاڑی شامل کریں", ms="Tambah Pemain",
  it="Aggiungi giocatore", nl="Speler toevoegen")

s("startGame", "Confirm player setup and begin",
  fr="Démarrer la partie", en="Start game", ar="ابدأ اللعبة", es="Empezar partida",
  pt="Iniciar jogo", de="Spiel starten", tr="Oyunu Başlat", id="Mulai Permainan",
  ur="کھیل شروع کریں", ms="Mulakan Permainan", it="Inizia partita", nl="Spel starten")

# ---- Gameplay -------------------------------------------------------------
s("yourTurn", "Turn banner",
  fr="À toi de jouer", en="Your turn", ar="دورك", es="Tu turno", pt="Sua vez",
  de="Du bist dran", tr="Sıra Sende", id="Giliranmu", ur="آپ کی باری",
  ms="Giliran anda", it="Tocca a te", nl="Jouw beurt")

s("categoryProphets", "Question category name",
  fr="Prophètes", en="Prophets", ar="الأنبياء", es="Profetas", pt="Profetas",
  de="Propheten", tr="Peygamberler", id="Para Nabi", ur="انبیاء", ms="Para Nabi",
  it="Profeti", nl="Profeten")

s("categorySira", "Question category name (biography of the Prophet)",
  fr="Sîra", en="Sira", ar="السيرة", es="Sira", pt="Sira",
  de="Sira", tr="Siyer", id="Sirah", ur="سیرت", ms="Sirah",
  it="Sira", nl="Sira")

s("categoryQuran", "Question category name",
  fr="Coran", en="Qur'an", ar="القرآن", es="Corán", pt="Alcorão",
  de="Koran", tr="Kur'an", id="Al-Qur'an", ur="قرآن", ms="Al-Quran",
  it="Corano", nl="Koran")

s("categoryFaith", "Question category name",
  fr="Foi", en="Faith", ar="العقيدة", es="Fe", pt="Fé",
  de="Glaube", tr="İman", id="Akidah", ur="عقیدہ", ms="Akidah",
  it="Fede", nl="Geloof")

s("categoryVirtues", "Question category name",
  fr="Vertus", en="Virtues", ar="الأخلاق", es="Virtudes", pt="Virtudes",
  de="Tugenden", tr="Erdemler", id="Akhlak", ur="اخلاق", ms="Akhlak",
  it="Virtù", nl="Deugden")

s("category", "Question card: category label",
  fr="Catégorie", en="Category", ar="الفئة", es="Categoría", pt="Categoria",
  de="Kategorie", tr="Kategori", id="Kategori", ur="زمرہ", ms="Kategori",
  it="Categoria", nl="Categorie")

s("correctAnswer", "Feedback: correct",
  fr="Bonne réponse !", en="Correct!", ar="إجابة صحيحة!", es="¡Respuesta correcta!",
  pt="Resposta correta!", de="Richtig!", tr="Doğru!", id="Benar!",
  ur="درست جواب!", ms="Betul!", it="Risposta corretta!", nl="Goed antwoord!")

s("incorrectAnswer", "Feedback: incorrect",
  fr="Pas tout à fait…", en="Not quite…", ar="ليست كذلك تمامًا…",
  es="No exactamente…", pt="Não exatamente…", de="Nicht ganz…", tr="Tam değil…",
  id="Belum tepat…", ur="بالکل نہیں…", ms="Tidak tepat…", it="Non proprio…",
  nl="Niet helemaal…")

s("learnMore", "Button under an answered question: opens the details sheet",
  fr="En savoir plus", en="Learn more", ar="اعرف المزيد", es="Saber más", pt="Saber mais",
  de="Mehr erfahren", tr="Daha fazla bilgi", id="Pelajari lebih lanjut", ur="مزید جانیں",
  ms="Ketahui lebih lanjut", it="Scopri di più", nl="Meer weten")
s("questionDetailsTitle", "Title of the details sheet shown after an answer",
  fr="Pour aller plus loin", en="Behind the answer", ar="خلف الإجابة", es="Para saber más",
  pt="Para saber mais", de="Hinter der Antwort", tr="Cevabın arkasında", id="Di balik jawaban",
  ur="جواب کے پیچھے", ms="Di sebalik jawapan", it="Dietro la risposta", nl="Achter het antwoord")
s("theQuestionLabel", "Details sheet section header: the question text",
  fr="La question", en="The question", ar="السؤال", es="La pregunta", pt="A pergunta",
  de="Die Frage", tr="Soru", id="Pertanyaan", ur="سوال", ms="Soalan", it="La domanda", nl="De vraag")
s("theAnswerLabel", "Details sheet section header: the right answer",
  fr="La bonne réponse", en="The right answer", ar="الإجابة الصحيحة", es="La respuesta correcta",
  pt="A resposta certa", de="Die richtige Antwort", tr="Doğru cevap", id="Jawaban yang benar",
  ur="صحیح جواب", ms="Jawapan yang betul", it="La risposta giusta", nl="Het juiste antwoord")
s("explanationLabel", "Question card section header",
  fr="Explication", en="Explanation", ar="التوضيح", es="Explicación",
  pt="Explicação", de="Erklärung", tr="Açıklama", id="Penjelasan", ur="وضاحت",
  ms="Penjelasan", it="Spiegazione", nl="Uitleg")

s("sourceLabel", "Question card section header",
  fr="Source", en="Source", ar="المصدر", es="Fuente", pt="Fonte", de="Quelle",
  tr="Kaynak", id="Sumber", ur="ماخذ", ms="Sumber", it="Fonte", nl="Bron")

s("nextPlayer", "Turn transition button",
  fr="Joueur suivant", en="Next player", ar="اللاعب التالي", es="Siguiente jugador",
  pt="Próximo jogador", de="Nächster Spieler", tr="Sonraki Oyuncu",
  id="Pemain Berikutnya", ur="اگلا کھلاڑی", ms="Pemain Seterusnya",
  it="Prossimo giocatore", nl="Volgende speler")

s("rolledSix", "Message shown when a 6 grants another turn",
  fr="Un 6 ! Nouveau tour — nouvelle question.", en="A six! Another turn — a new question.",
  ar="ستة! دور جديد — سؤال جديد.", es="¡Un seis! Otro turno — nueva pregunta.",
  pt="Um seis! Outra rodada — nova pergunta.", de="Eine Sechs! Noch eine Runde — neue Frage.",
  tr="Altı geldi! Yeni tur — yeni soru.", id="Angka enam! Giliran lagi — pertanyaan baru.",
  ur="چھکا! ایک اور باری — نیا سوال۔", ms="Enam! Giliran lagi — soalan baharu.",
  it="Un sei! Un altro turno — nuova domanda.", nl="Een zes! Nog een beurt — nieuwe vraag.")

s("playAgain", "Post-game button",
  fr="Rejouer", en="Play again", ar="العب مجددًا", es="Jugar de nuevo",
  pt="Jogar novamente", de="Nochmal spielen", tr="Tekrar Oyna", id="Main Lagi",
  ur="دوبارہ کھیلیں", ms="Main Lagi", it="Gioca ancora", nl="Opnieuw spelen")

s("protectedSquareLabel", "Board legend for a safe square",
  fr="Case protégée", en="Protected square", ar="مربع محمي", es="Casilla protegida",
  pt="Casa protegida", de="Geschütztes Feld", tr="Korumalı Kare", id="Kotak Terlindungi",
  ur="محفوظ خانہ", ms="Petak Dilindungi", it="Casella protetta", nl="Beschermd vakje")

s("freeBankExhaustedMessage", "Shown once the free question bank runs out mid-game",
  fr="Toutes les questions de l'édition gratuite ont été utilisées pour cette partie.",
  en="All the free edition's questions have been used for this game.",
  ar="تم استخدام جميع أسئلة النسخة المجانية في هذه اللعبة.",
  es="Se han usado todas las preguntas de la edición gratuita en esta partida.",
  pt="Todas as perguntas da edição gratuita foram usadas nesta partida.",
  de="Alle Fragen der kostenlosen Edition wurden in dieser Partie verwendet.",
  tr="Bu oyunda ücretsiz sürümün tüm soruları kullanıldı.",
  id="Semua pertanyaan edisi gratis telah digunakan pada permainan ini.",
  ur="اس کھیل میں مفت ایڈیشن کے تمام سوالات استعمال ہو چکے ہیں۔",
  ms="Semua soalan edisi percuma telah digunakan dalam permainan ini.",
  it="Tutte le domande dell'edizione gratuita sono state usate in questa partita.",
  nl="Alle vragen van de gratis editie zijn gebruikt in dit spel.")

# ---- Results / progress ----------------------------------------------------
s("victory", "Win screen title",
  fr="Victoire !", en="Victory!", ar="النصر!", es="¡Victoria!", pt="Vitória!",
  de="Sieg!", tr="Zafer!", id="Kemenangan!", ur="فتح!", ms="Kemenangan!",
  it="Vittoria!", nl="Overwinning!")

s("gameOver", "End-of-game screen title (generic)",
  fr="Partie terminée", en="Game over", ar="انتهت اللعبة", es="Partida terminada",
  pt="Fim de jogo", de="Spiel beendet", tr="Oyun Bitti", id="Permainan Selesai",
  ur="کھیل ختم", ms="Permainan Tamat", it="Partita terminata", nl="Spel afgelopen")

s("backToHome", "Navigation button back to home screen",
  fr="Retour à l'accueil", en="Back to home", ar="العودة إلى الرئيسية",
  es="Volver al inicio", pt="Voltar ao início", de="Zurück zum Start",
  tr="Ana Sayfaya Dön", id="Kembali ke Beranda", ur="ہوم پر واپس جائیں",
  ms="Kembali ke Laman Utama", it="Torna alla home", nl="Terug naar start")

s("gamesPlayed", "Progress stat label",
  fr="Parties jouées", en="Games played", ar="عدد المباريات", es="Partidas jugadas",
  pt="Partidas jogadas", de="Gespielte Spiele", tr="Oynanan Oyunlar",
  id="Permainan Dimainkan", ur="کھیلے گئے میچز", ms="Permainan Dimainkan",
  it="Partite giocate", nl="Gespeelde spellen")

s("winRate", "Progress stat label",
  fr="Taux de victoire", en="Win rate", ar="معدل الفوز", es="Tasa de victorias",
  pt="Taxa de vitórias", de="Siegquote", tr="Kazanma Oranı", id="Tingkat Kemenangan",
  ur="جیت کی شرح", ms="Kadar Kemenangan", it="Percentuale di vittorie",
  nl="Winstpercentage")

s("questionsAnswered", "Progress stat label",
  fr="Questions répondues", en="Questions answered", ar="الأسئلة المجاب عنها",
  es="Preguntas respondidas", pt="Perguntas respondidas", de="Beantwortete Fragen",
  tr="Cevaplanan Sorular", id="Pertanyaan Dijawab", ur="جواب دیے گئے سوالات",
  ms="Soalan Dijawab", it="Domande risposte", nl="Beantwoorde vragen")

s("streak", "Progress stat label: daily streak",
  fr="Série de jours", en="Day streak", ar="سلسلة الأيام", es="Racha de días",
  pt="Sequência de dias", de="Tagesserie", tr="Gün Serisi", id="Rentetan Hari",
  ur="دنوں کا تسلسل", ms="Rentetan Hari", it="Serie di giorni", nl="Dagreeks")

# ---- Premium ---------------------------------------------------------------
s("premiumTitle", "Premium sheet title",
  fr="IqraQuest Premium", en="IqraQuest Premium", ar="إكرا كويست بريميوم",
  es="IqraQuest Premium", pt="IqraQuest Premium", de="IqraQuest Premium",
  tr="IqraQuest Premium", id="IqraQuest Premium", ur="اقرا کویسٹ پریمیم",
  ms="IqraQuest Premium", it="IqraQuest Premium", nl="IqraQuest Premium")

# No question count here: the real, current bank size is shown right
# below by premiumQuestionsIncluded, read from the bank itself. A
# hardcoded number goes stale and reads as a false claim to App Review
# (App Store guideline 2.3.1) the moment the bank differs from it.
s("premiumUnlockAll", "Premium sheet value proposition",
  fr="Débloque toute la banque de questions et toutes les difficultés",
  en="Unlock the full question bank and every difficulty",
  ar="افتح بنك الأسئلة كاملاً وكل مستويات الصعوبة",
  es="Desbloquea todo el banco de preguntas y todas las dificultades",
  pt="Desbloqueie todo o banco de perguntas e todas as dificuldades",
  de="Schalte die gesamte Fragensammlung und jeden Schwierigkeitsgrad frei",
  tr="Tüm soru bankasının ve her zorluk seviyesinin kilidini açın",
  id="Buka seluruh bank pertanyaan dan semua tingkat kesulitan",
  ur="سوالات کا مکمل ذخیرہ اور ہر مشکل درجہ کھولیں",
  ms="Buka kunci seluruh bank soalan dan semua tahap kesukaran",
  it="Sblocca l'intero archivio di domande e ogni livello di difficoltà",
  nl="Ontgrendel de volledige vragenbank en elke moeilijkheidsgraad")

s("premiumOneTime", "Premium sheet: pricing model note",
  fr="Paiement unique — aucun abonnement", en="One-time payment — no subscription",
  ar="دفعة واحدة — بدون اشتراك", es="Pago único — sin suscripción",
  pt="Pagamento único — sem assinatura", de="Einmalzahlung — kein Abonnement",
  tr="Tek seferlik ödeme — abonelik yok", id="Pembayaran sekali — tanpa langganan",
  ur="یک وقتی ادائیگی — کوئی سبسکرپشن نہیں", ms="Bayaran sekali — tiada langganan",
  it="Pagamento unico — nessun abbonamento", nl="Eenmalige betaling — geen abonnement")

s("restorePurchases", "Premium sheet button",
  fr="Restaurer mes achats", en="Restore purchases", ar="استعادة المشتريات",
  es="Restaurar compras", pt="Restaurar compras", de="Käufe wiederherstellen",
  tr="Satın Alımları Geri Yükle", id="Pulihkan Pembelian", ur="خریداری بحال کریں",
  ms="Pulihkan Pembelian", it="Ripristina acquisti", nl="Aankopen herstellen")

s("purchaseSuccess", "Purchase result feedback",
  fr="Merci ! Premium est activé.", en="Thank you! Premium is now active.",
  ar="شكرًا لك! تم تفعيل بريميوم.", es="¡Gracias! Premium ya está activo.",
  pt="Obrigado! O Premium está ativo.", de="Danke! Premium ist jetzt aktiv.",
  tr="Teşekkürler! Premium artık aktif.", id="Terima kasih! Premium kini aktif.",
  ur="شکریہ! پریمیم اب فعال ہے۔", ms="Terima kasih! Premium kini aktif.",
  it="Grazie! Premium è ora attivo.", nl="Bedankt! Premium is nu actief.")

s("purchaseError", "Purchase result feedback: failure",
  fr="Achat impossible pour le moment. Réessaie plus tard.",
  en="Purchase couldn't be completed. Please try again later.",
  ar="تعذّر إتمام الشراء. حاول مرة أخرى لاحقًا.",
  es="No se pudo completar la compra. Inténtalo más tarde.",
  pt="Não foi possível concluir a compra. Tente novamente mais tarde.",
  de="Kauf konnte nicht abgeschlossen werden. Bitte später erneut versuchen.",
  tr="Satın alma tamamlanamadı. Lütfen daha sonra tekrar deneyin.",
  id="Pembelian tidak dapat diselesaikan. Coba lagi nanti.",
  ur="خریداری مکمل نہیں ہو سکی۔ براہ کرم بعد میں دوبارہ کوشش کریں۔",
  ms="Pembelian tidak dapat diselesaikan. Sila cuba lagi kemudian.",
  it="Impossibile completare l'acquisto. Riprova più tardi.",
  nl="Aankoop kon niet worden voltooid. Probeer het later opnieuw.")

# ---- Settings ---------------------------------------------------------------
s("language", "Settings item",
  fr="Langue", en="Language", ar="اللغة", es="Idioma", pt="Idioma", de="Sprache",
  tr="Dil", id="Bahasa", ur="زبان", ms="Bahasa", it="Lingua", nl="Taal")

s("reduceMotion", "Settings item: accessibility",
  fr="Réduire les animations", en="Reduce motion", ar="تقليل الحركة",
  es="Reducir movimiento", pt="Reduzir movimento", de="Bewegung reduzieren",
  tr="Hareketi Azalt", id="Kurangi Gerakan", ur="حرکت کم کریں", ms="Kurangkan Gerakan",
  it="Riduci animazioni", nl="Beweging verminderen")

s("soundEffects", "Settings item: toggle for game sound effects",
  fr="Effets sonores", en="Sound effects", ar="المؤثرات الصوتية",
  es="Efectos de sonido", pt="Efeitos sonoros", de="Soundeffekte",
  tr="Ses Efektleri", id="Efek Suara", ur="آوازی اثرات", ms="Kesan Bunyi",
  it="Effetti sonori", nl="Geluidseffecten")

s("howToPlay", "Settings item: opens the tutorial",
  fr="Comment jouer", en="How to play", ar="طريقة اللعب", es="Cómo jugar",
  pt="Como jogar", de="Spielanleitung", tr="Nasıl Oynanır", id="Cara Bermain",
  ur="کھیلنے کا طریقہ", ms="Cara Bermain", it="Come si gioca", nl="Zo speel je")

s("privacySummary", "Body of the privacy dialog: the app's whole privacy story in one line",
  fr="IqraQuest fonctionne entièrement sur votre appareil : aucun compte, aucune publicité, aucun suivi, et rien n'est envoyé sur Internet.",
  en="IqraQuest runs entirely on your device: no account, no ads, no tracking, and nothing is ever sent over the Internet.",
  ar="يعمل إكرا كويست بالكامل على جهازك: لا حساب، ولا إعلانات، ولا تتبّع، ولا يُرسل أي شيء عبر الإنترنت.",
  es="IqraQuest funciona íntegramente en tu dispositivo: sin cuenta, sin anuncios, sin rastreo, y nada se envía por Internet.",
  pt="O IqraQuest funciona inteiramente no seu dispositivo: sem conta, sem anúncios, sem rastreamento, e nada é enviado pela Internet.",
  de="IqraQuest läuft vollständig auf deinem Gerät: kein Konto, keine Werbung, kein Tracking, und nichts wird je ins Internet gesendet.",
  tr="IqraQuest tamamen cihazınızda çalışır: hesap yok, reklam yok, izleme yok ve hiçbir şey internete gönderilmez.",
  id="IqraQuest berjalan sepenuhnya di perangkat Anda: tanpa akun, tanpa iklan, tanpa pelacakan, dan tidak ada yang dikirim melalui Internet.",
  ur="اقرا کویسٹ مکمل طور پر آپ کے آلے پر چلتا ہے: نہ اکاؤنٹ، نہ اشتہار، نہ ٹریکنگ، اور کچھ بھی انٹرنیٹ پر نہیں بھیجا جاتا۔",
  ms="IqraQuest berjalan sepenuhnya pada peranti anda: tiada akaun, tiada iklan, tiada penjejakan, dan tiada apa-apa dihantar melalui Internet.",
  it="IqraQuest funziona interamente sul tuo dispositivo: nessun account, nessuna pubblicità, nessun tracciamento, e nulla viene mai inviato su Internet.",
  nl="IqraQuest draait volledig op je apparaat: geen account, geen advertenties, geen tracking, en er wordt nooit iets via internet verzonden.")

s("defaultPlayerName", "Default name for a human player seat",
  ph={"number": "num"},
  fr="Joueur {number}", en="Player {number}", ar="اللاعب {number}",
  es="Jugador {number}", pt="Jogador {number}", de="Spieler {number}",
  tr="Oyuncu {number}", id="Pemain {number}", ur="کھلاڑی {number}",
  ms="Pemain {number}", it="Giocatore {number}", nl="Speler {number}")

s("aiPlayerName", "Name shown for a computer opponent",
  ph={"number": "num"},
  fr="Cavalier {number}", en="Rider {number}", ar="الفارس {number}",
  es="Jinete {number}", pt="Cavaleiro {number}", de="Reiter {number}",
  tr="Binici {number}", id="Penunggang {number}", ur="سوار {number}",
  ms="Penunggang {number}", it="Cavaliere {number}", nl="Ruiter {number}")

s("opponentWins", "Results title when a computer opponent wins the race",
  ph={"name": "String"},
  fr="{name} remporte la course !", en="{name} wins the race!",
  ar="{name} يفوز بالسباق!", es="¡{name} gana la carrera!",
  pt="{name} vence a corrida!", de="{name} gewinnt das Rennen!",
  tr="Yarışı {name} kazandı!", id="{name} memenangkan balapan!",
  ur="{name} ریس جیت گیا!", ms="{name} memenangi perlumbaan!",
  it="{name} vince la corsa!", nl="{name} wint de race!")

s("wellRidden", "Encouraging subtitle when the player did not win",
  fr="Belle chevauchée — chaque question apprise compte.",
  en="A fine ride — every question learned counts.",
  ar="ركوب رائع — كل سؤال تعلمته يُحتسب.",
  es="Buena cabalgada: cada pregunta aprendida cuenta.",
  pt="Bela cavalgada — cada pergunta aprendida conta.",
  de="Ein schöner Ritt — jede gelernte Frage zählt.",
  tr="Güzel bir sürüştü — öğrenilen her soru değerlidir.",
  id="Perjalanan yang bagus — setiap pertanyaan yang dipelajari berarti.",
  ur="عمدہ سواری — سیکھا ہوا ہر سوال اہم ہے۔",
  ms="Tunggangan yang baik — setiap soalan yang dipelajari bermakna.",
  it="Bella cavalcata — ogni domanda imparata conta.",
  nl="Een mooie rit — elke geleerde vraag telt.")

s("horseSemantics", "Screen-reader label for one horse piece on the board",
  ph={"color": "String", "number": "num"},
  fr="Cheval {color} {number}", en="{color} horse {number}",
  ar="حصان {color} {number}", es="Caballo {color} {number}",
  pt="Cavalo {color} {number}", de="{color} Pferd {number}",
  tr="{color} at {number}", id="Kuda {color} {number}",
  ur="{color} گھوڑا {number}", ms="Kuda {color} {number}",
  it="Cavallo {color} {number}", nl="{color} paard {number}")

s("teamEmerald", "Team colour name",
  fr="émeraude", en="emerald", ar="زمردي", es="esmeralda", pt="esmeralda",
  de="Smaragd", tr="zümrüt", id="zamrud", ur="زمردی", ms="zamrud",
  it="smeraldo", nl="smaragd")

s("teamSaphir", "Team colour name",
  fr="saphir", en="sapphire", ar="ياقوتي أزرق", es="zafiro", pt="safira",
  de="Saphir", tr="safir", id="safir", ur="نیلم", ms="nilam",
  it="zaffiro", nl="saffier")

s("teamGrenat", "Team colour name",
  fr="grenat", en="garnet", ar="عقيقي", es="granate", pt="grená",
  de="Granat", tr="lal", id="merah delima", ur="یاقوتی", ms="delima",
  it="granata", nl="granaat")

s("teamSafran", "Team colour name",
  fr="safran", en="saffron", ar="زعفراني", es="azafrán", pt="açafrão",
  de="Safran", tr="safran", id="safron", ur="زعفرانی", ms="safron",
  it="zafferano", nl="saffraan")

s("premiumCta", "Premium purchase button: unlock everything at the Store price",
  ph={"price": "String"},
  fr="Tout débloquer — {price}", en="Unlock everything — {price}",
  ar="فتح الكل — {price}", es="Desbloquear todo — {price}",
  pt="Desbloquear tudo — {price}", de="Alles freischalten — {price}",
  tr="Tümünün kilidini aç — {price}", id="Buka semua — {price}",
  ur="سب کھولیں — {price}", ms="Buka semua — {price}",
  it="Sblocca tutto — {price}", nl="Alles ontgrendelen — {price}")

s("premiumQuestionsIncluded", "Premium screen: how many verified questions the full bank holds today",
  ph={"count": "num"},
  fr="{count} questions vérifiées, chacune avec sa source — et la banque continue de grandir.",
  en="{count} verified questions, each with its source — and the bank keeps growing.",
  ar="{count} سؤالًا موثقًا، لكل منها مصدره — والمجموعة تكبر باستمرار.",
  es="{count} preguntas verificadas, cada una con su fuente — y el banco sigue creciendo.",
  pt="{count} perguntas verificadas, cada uma com sua fonte — e o banco continua crescendo.",
  de="{count} geprüfte Fragen, jede mit Quelle — und die Sammlung wächst weiter.",
  tr="Kaynağıyla birlikte {count} doğrulanmış soru — ve soru bankası büyümeye devam ediyor.",
  id="{count} pertanyaan terverifikasi, masing-masing dengan sumbernya — dan bank soal terus bertambah.",
  ur="{count} تصدیق شدہ سوالات، ہر ایک اپنے ماخذ کے ساتھ — اور ذخیرہ بڑھتا رہتا ہے۔",
  ms="{count} soalan disahkan, setiap satu dengan sumbernya — dan bank soalan terus berkembang.",
  it="{count} domande verificate, ognuna con la sua fonte — e la raccolta continua a crescere.",
  nl="{count} geverifieerde vragen, elk met bron — en de vragenbank blijft groeien.")

s("darkMode", "Settings item",
  fr="Mode nuit", en="Dark mode", ar="الوضع الليلي", es="Modo oscuro",
  pt="Modo escuro", de="Dunkelmodus", tr="Karanlık Mod", id="Mode Gelap",
  ur="ڈارک موڈ", ms="Mod Gelap", it="Modalità scura", nl="Donkere modus")

s("about", "Settings item",
  fr="À propos", en="About", ar="حول التطبيق", es="Acerca de", pt="Sobre",
  de="Über", tr="Hakkında", id="Tentang", ur="بارے میں", ms="Tentang",
  it="Informazioni", nl="Over")

s("aboutDialogTitle", "Title of the About dialog opened from Settings",
  fr="À propos d'IqraQuest", en="About IqraQuest", ar="حول إكرا كويست",
  es="Acerca de IqraQuest", pt="Sobre o IqraQuest", de="Über IqraQuest",
  tr="IqraQuest Hakkında", id="Tentang IqraQuest", ur="اقرا کویسٹ کے بارے میں",
  ms="Tentang IqraQuest", it="Informazioni su IqraQuest", nl="Over IqraQuest")

s("versionLabel", "Version line in the About dialog",
  ph={"version": "String"},
  fr="Version {version}", en="Version {version}", ar="الإصدار {version}",
  es="Versión {version}", pt="Versão {version}", de="Version {version}",
  tr="Sürüm {version}", id="Versi {version}", ur="ورژن {version}",
  ms="Versi {version}", it="Versione {version}", nl="Versie {version}")

s("copyrightNotice", "Copyright line in the About dialog and Settings",
  ph={"year": "String"},
  fr="© {year} IqraQuest. Tous droits réservés.",
  en="© {year} IqraQuest. All rights reserved.",
  ar="© {year} IqraQuest. جميع الحقوق محفوظة.",
  es="© {year} IqraQuest. Todos los derechos reservados.",
  pt="© {year} IqraQuest. Todos os direitos reservados.",
  de="© {year} IqraQuest. Alle Rechte vorbehalten.",
  tr="© {year} IqraQuest. Tüm hakları saklıdır.",
  id="© {year} IqraQuest. Hak cipta dilindungi.",
  ur="© {year} IqraQuest۔ جملہ حقوق محفوظ ہیں۔",
  ms="© {year} IqraQuest. Hak cipta terpelihara.",
  it="© {year} IqraQuest. Tutti i diritti riservati.",
  nl="© {year} IqraQuest. Alle rechten voorbehouden.")

s("originalWorkNotice", "Legal paragraph in the About dialog: the game concept and content are protected",
  fr="IqraQuest, son concept de jeu, ses règles, ses illustrations, son nom et son contenu sont des œuvres originales protégées par le droit d'auteur. Toute reproduction, imitation ou adaptation, totale ou partielle, sans autorisation écrite est interdite.",
  en="IqraQuest, its game concept, rules, artwork, name and content are original works protected by copyright. Any reproduction, imitation or adaptation, in whole or in part, without written permission is prohibited.",
  ar="إكرا كويست، وفكرة اللعبة وقواعدها ورسومها واسمها ومحتواها أعمال أصلية محمية بحقوق النشر. يُمنع أي نسخ أو تقليد أو اقتباس، كليًا أو جزئيًا، دون إذن كتابي.",
  es="IqraQuest, su concepto de juego, sus reglas, sus ilustraciones, su nombre y su contenido son obras originales protegidas por derechos de autor. Queda prohibida toda reproducción, imitación o adaptación, total o parcial, sin autorización escrita.",
  pt="IqraQuest, o seu conceito de jogo, as suas regras, as suas ilustrações, o seu nome e o seu conteúdo são obras originais protegidas por direitos de autor. É proibida qualquer reprodução, imitação ou adaptação, total ou parcial, sem autorização escrita.",
  de="IqraQuest, sein Spielkonzept, seine Regeln, seine Illustrationen, sein Name und seine Inhalte sind urheberrechtlich geschützte Originalwerke. Jede vollständige oder teilweise Vervielfältigung, Nachahmung oder Bearbeitung ohne schriftliche Genehmigung ist untersagt.",
  tr="IqraQuest, oyun konsepti, kuralları, çizimleri, adı ve içeriği telif hakkıyla korunan özgün eserlerdir. Yazılı izin olmadan tamamen veya kısmen çoğaltılması, taklit edilmesi veya uyarlanması yasaktır.",
  id="IqraQuest, konsep permainannya, aturannya, ilustrasinya, namanya, dan isinya adalah karya asli yang dilindungi hak cipta. Segala bentuk penggandaan, peniruan, atau adaptasi, seluruhnya atau sebagian, tanpa izin tertulis dilarang.",
  ur="اقرا کویسٹ، اس کے کھیل کا تصور، قواعد، تصاویر، نام اور مواد اصل تخلیقات ہیں جو کاپی رائٹ سے محفوظ ہیں۔ تحریری اجازت کے بغیر کسی بھی طرح کی مکمل یا جزوی نقل، تقلید یا ترمیم ممنوع ہے۔",
  ms="IqraQuest, konsep permainannya, peraturannya, ilustrasinya, namanya dan kandungannya adalah karya asli yang dilindungi hak cipta. Sebarang pengeluaran semula, peniruan atau adaptasi, sepenuhnya atau sebahagian, tanpa kebenaran bertulis adalah dilarang.",
  it="IqraQuest, il suo concetto di gioco, le sue regole, le sue illustrazioni, il suo nome e i suoi contenuti sono opere originali protette dal diritto d'autore. È vietata qualsiasi riproduzione, imitazione o adattamento, totale o parziale, senza autorizzazione scritta.",
  nl="IqraQuest, het spelconcept, de regels, de illustraties, de naam en de inhoud zijn originele werken die auteursrechtelijk beschermd zijn. Elke gehele of gedeeltelijke reproductie, imitatie of bewerking zonder schriftelijke toestemming is verboden.")

s("privacyPolicy", "Settings item / legal link",
  fr="Politique de confidentialité", en="Privacy Policy", ar="سياسة الخصوصية",
  es="Política de privacidad", pt="Política de Privacidade", de="Datenschutzerklärung",
  tr="Gizlilik Politikası", id="Kebijakan Privasi", ur="رازداری کی پالیسی",
  ms="Dasar Privasi", it="Informativa sulla privacy", nl="Privacybeleid")

# ---- Errors / parental gate ---------------------------------------------------
s("genericError", "Fallback error message",
  fr="Une erreur est survenue.", en="Something went wrong.", ar="حدث خطأ ما.",
  es="Algo salió mal.", pt="Algo deu errado.", de="Etwas ist schiefgelaufen.",
  tr="Bir şeyler ters gitti.", id="Terjadi kesalahan.", ur="کچھ غلط ہو گیا۔",
  ms="Sesuatu tidak kena.", it="Qualcosa è andato storto.", nl="Er ging iets mis.")

s("parentalGateTitle", "Parental gate dialog title, shown before purchases/external links",
  fr="Question pour les parents", en="A question for parents", ar="سؤال لأولياء الأمور",
  es="Una pregunta para los padres", pt="Uma pergunta para os pais",
  de="Eine Frage für Eltern", tr="Ebeveynler için bir soru",
  id="Pertanyaan untuk orang tua", ur="والدین کے لیے ایک سوال",
  ms="Soalan untuk ibu bapa", it="Una domanda per i genitori",
  nl="Een vraag voor ouders")

s("parentalGateInstruction", "Parental gate dialog body",
  fr="Résous ce calcul pour continuer.", en="Solve this to continue.",
  ar="حل هذه المسألة للمتابعة.", es="Resuelve esto para continuar.",
  pt="Resolva isto para continuar.", de="Löse das, um fortzufahren.",
  tr="Devam etmek için bunu çöz.", id="Selesaikan ini untuk melanjutkan.",
  ur="جاری رکھنے کے لیے یہ حل کریں۔", ms="Selesaikan ini untuk teruskan.",
  it="Risolvi questo per continuare.", nl="Los dit op om verder te gaan.")


# ---- Gaits (the mechanic that replaced the dice) --------------------------
s("placeMecca", "Centre of the board: the destination every horse rides to",
  fr="La Mecque", en="Mecca", ar="مكة", es="La Meca", pt="Meca",
  de="Mekka", tr="Mekke", id="Makkah", ur="مکہ", ms="Makkah",
  it="La Mecca", nl="Mekka")

s("placeMedina", "Green corner",
  fr="Médine", en="Medina", ar="المدينة", es="Medina", pt="Medina",
  de="Medina", tr="Medine", id="Madinah", ur="مدینہ", ms="Madinah",
  it="Medina", nl="Medina")

s("placeAlAqsa", "Red corner: the mosque itself, not the city around it",
  fr="Al-Aqsa", en="Al-Aqsa", ar="المسجد الأقصى", es="Al-Aqsa", pt="Al-Aqsa",
  de="Al-Aqsa", tr="Mescid-i Aksa", id="Al-Aqsa", ur="مسجد اقصیٰ", ms="Al-Aqsa",
  it="Al-Aqsa", nl="Al-Aqsa")

s("placeArafat", "Blue corner",
  fr="Mont Arafat", en="Mount Arafat", ar="عرفات", es="Monte Arafat",
  pt="Monte Arafat", de="Berg Arafat", tr="Arafat Dağı", id="Arafah",
  ur="عرفات", ms="Arafah", it="Monte Arafat", nl="Berg Arafat")

s("placeMina", "Gold corner",
  fr="Mina", en="Mina", ar="منى", es="Mina", pt="Mina",
  de="Mina", tr="Mina", id="Mina", ur="منیٰ", ms="Mina",
  it="Mina", nl="Mina")

s("circuitSpecialSquares", "How eventful a board is, shown on its card",
  ph={"count": "num"},
  fr="{count, plural, one{{count} case spéciale} other{{count} cases spéciales}}",
  en="{count, plural, one{{count} special square} other{{count} special squares}}",
  ar="{count, plural, =0{لا مربعات خاصة} one{مربع خاص واحد} two{مربعان خاصان} few{{count} مربعات خاصة} many{{count} مربعًا خاصًا} other{{count} مربع خاص}}",
  es="{count, plural, one{{count} casilla especial} other{{count} casillas especiales}}",
  pt="{count, plural, one{{count} casa especial} other{{count} casas especiais}}",
  de="{count, plural, one{{count} Sonderfeld} other{{count} Sonderfelder}}",
  tr="{count, plural, other{{count} özel kare}}",
  id="{count, plural, other{{count} petak khusus}}",
  ur="{count, plural, one{{count} خاص خانہ} other{{count} خاص خانے}}",
  ms="{count, plural, other{{count} petak khas}}",
  it="{count, plural, one{{count} casella speciale} other{{count} caselle speciali}}",
  nl="{count, plural, one{{count} speciaal vakje} other{{count} speciale vakjes}}")

s("drawCard", "Call to action on the face-down deck: draw this turn's card",
  fr="Piocher une carte", en="Draw a card", ar="اسحب بطاقة",
  es="Roba una carta", pt="Puxar uma carta", de="Karte ziehen",
  tr="Kart çek", id="Ambil kartu", ur="کارڈ نکالیں",
  ms="Cabut kad", it="Pesca una carta", nl="Trek een kaart")

s("drawnCardTitle", "Headline over the freshly turned card",
  fr="Carte piochée", en="Card drawn", ar="البطاقة المسحوبة",
  es="Carta robada", pt="Carta puxada", de="Gezogene Karte",
  tr="Çekilen kart", id="Kartu terambil", ur="نکالا گیا کارڈ",
  ms="Kad dicabut", it="Carta pescata", nl="Getrokken kaart")

s("cardWorth", "The stake announced on the drawn card, and kept in view during its question: how many gallops a right answer wins",
  ph={"count": "num"},
  fr="{count, plural, one{Carte à {count} galop} other{Carte à {count} galops}}",
  en="{count, plural, one{A {count}-gallop card} other{A {count}-gallop card}}",
  ar="{count, plural, one{بطاقة بركضة واحدة} two{بطاقة بركضتين} few{بطاقة بـ{count} ركضات} many{بطاقة بـ{count} ركضة} other{بطاقة بـ{count} ركضة}}",
  es="{count, plural, one{Carta de {count} galope} other{Carta de {count} galopes}}",
  pt="{count, plural, one{Carta de {count} galope} other{Carta de {count} galopes}}",
  de="{count, plural, one{Karte über {count} Galopp} other{Karte über {count} Galopp}}",
  tr="{count, plural, other{{count} dörtnallık kart}}",
  id="{count, plural, other{Kartu {count} lompatan}}",
  ur="{count, plural, one{{count} سرپٹ کا کارڈ} other{{count} سرپٹ کا کارڈ}}",
  ms="{count, plural, other{Kad {count} lompatan}}",
  it="{count, plural, one{Carta da {count} galoppo} other{Carta da {count} galoppi}}",
  nl="{count, plural, one{Kaart van {count} galop} other{Kaart van {count} galop}}")

s("gaitSquares", "How far a gait moves, shown under each horseshoe",
  ph={"count": "num"},
  fr="{count, plural, one{{count} case} other{{count} cases}}",
  en="{count, plural, one{{count} square} other{{count} squares}}",
  ar="{count, plural, one{مربع واحد} two{مربعان} few{{count} مربعات} many{{count} مربعًا} other{{count} مربع}}",
  es="{count, plural, one{{count} casilla} other{{count} casillas}}",
  pt="{count, plural, one{{count} casa} other{{count} casas}}",
  de="{count, plural, one{{count} Feld} other{{count} Felder}}",
  tr="{count, plural, one{{count} kare} other{{count} kare}}",
  id="{count, plural, other{{count} kotak}}",
  ur="{count, plural, one{ایک خانہ} other{{count} خانے}}",
  ms="{count, plural, other{{count} petak}}",
  it="{count, plural, one{{count} casella} other{{count} caselle}}",
  nl="{count, plural, one{{count} vakje} other{{count} vakjes}}")

s("gaitNameWalk", "Name of the 1-square gait, shown on its chip",
  fr="Pas", en="Walk", ar="مشي",
  es="Paso", pt="Passo", de="Schritt",
  tr="Adım", id="Jalan", ur="قدم",
  ms="Jalan", it="Passo", nl="Stap")

s("gaitNameTrot", "Name of the 2-square gait, shown on its chip",
  fr="Trot", en="Trot", ar="خبب",
  es="Trote", pt="Trote", de="Trab",
  tr="Tırıs", id="Derap", ur="دلکی",
  ms="Derap", it="Trotto", nl="Draf")

s("gaitNameCanter", "Name of the 3-square gait, shown on its chip",
  fr="Petit galop", en="Canter", ar="هرولة",
  es="Medio galope", pt="Meio galope", de="Kanter",
  tr="Eşkin", id="Kanter", ur="پویا",
  ms="Kanter", it="Piccolo galoppo", nl="Handgalop")

s("gaitNameGallop", "Name of the 4-square gait, shown on its chip",
  fr="Galop", en="Gallop", ar="عدو",
  es="Galope", pt="Galope", de="Galopp",
  tr="Dörtnal", id="Galop", ur="سرپٹ",
  ms="Galop", it="Galoppo", nl="Galop")

s("gaitNameFullGallop", "Name of the 5-square gait, shown on its chip",
  fr="Ventre à terre", en="Full gallop", ar="عدو كامل",
  es="Galope tendido", pt="Galope largo", de="Renngalopp",
  tr="Doludizgin", id="Galop penuh", ur="تیز سرپٹ",
  ms="Galop penuh", it="Galoppo disteso", nl="Rengalop")

s("gaitNameCharge", "Name of the 6-square gait, shown on its chip",
  fr="Charge", en="Charge", ar="انطلاقة",
  es="Carga", pt="Carga", de="Attacke",
  tr="Hücum", id="Serbuan", ur="یلغار",
  ms="Serbuan", it="Carica", nl="Charge")

s("chooseFormat", "Section header above the quick/classic format choice",
  fr="Format de partie", en="Game format", ar="نمط اللعبة",
  es="Formato de partida", pt="Formato de jogo", de="Spielformat",
  tr="Oyun formatı", id="Format permainan", ur="کھیل کی طرز",
  ms="Format permainan", it="Formato di partita", nl="Spelvorm")

s("gaitAlreadyUsed", "Hint on a gait already spent this cycle",
  fr="Déjà utilisée ce cycle", en="Already used this cycle",
  ar="مستخدمة في هذه الدورة", es="Ya usado en este ciclo",
  pt="Já usado neste ciclo", de="In diesem Zyklus bereits genutzt",
  tr="Bu turda kullanıldı", id="Sudah dipakai siklus ini",
  ur="اس چکر میں استعمال ہو چکی", ms="Sudah digunakan kitaran ini",
  it="Già usata in questo ciclo", nl="Al gebruikt deze cyclus")

s("gaitSemanticLabel", "Screen-reader label for one gait: distance, difficulty, reward",
  ph={"steps": "int", "difficulty": "String", "points": "int"},
  fr="Avancer de {steps} cases, question {difficulty}, {points} points de savoir",
  en="Move {steps} squares, {difficulty} question, {points} knowledge points",
  ar="التقدم {steps} مربعات، سؤال {difficulty}، {points} نقاط معرفة",
  es="Avanzar {steps} casillas, pregunta {difficulty}, {points} puntos de saber",
  pt="Avançar {steps} casas, pergunta {difficulty}, {points} pontos de saber",
  de="{steps} Felder vor, {difficulty} Frage, {points} Wissenspunkte",
  tr="{steps} kare ilerle, {difficulty} soru, {points} bilgi puanı",
  id="Maju {steps} kotak, pertanyaan {difficulty}, {points} poin pengetahuan",
  ur="{steps} خانے آگے، {difficulty} سوال، {points} علمی پوائنٹس",
  ms="Maju {steps} petak, soalan {difficulty}, {points} mata ilmu",
  it="Avanza di {steps} caselle, domanda {difficulty}, {points} punti sapere",
  nl="{steps} vakjes vooruit, {difficulty} vraag, {points} kennispunten")

s("selectHorse", "Prompt to pick which horse to move",
  fr="Choisis ton cheval", en="Choose your horse", ar="اختر حصانك",
  es="Elige tu caballo", pt="Escolha seu cavalo", de="Wähle dein Pferd",
  tr="Atını seç", id="Pilih kudamu", ur="اپنا گھوڑا منتخب کریں",
  ms="Pilih kuda anda", it="Scegli il tuo cavallo", nl="Kies je paard")

s("knowledgeStreak", "Name of the streak gauge: right answers in a row",
  fr="Série de bonnes réponses", en="Right answers in a row",
  ar="إجابات صحيحة متتالية", es="Respuestas correctas seguidas",
  pt="Respostas certas seguidas", de="Richtige Antworten in Folge",
  tr="Üst üste doğru cevap", id="Jawaban benar berturut-turut",
  ur="مسلسل درست جوابات", ms="Jawapan betul berturut-turut",
  it="Risposte esatte di fila", nl="Goede antwoorden op rij")

s("knowledgePointsLabel", "Label for accumulated knowledge points",
  fr="Points de savoir", en="Knowledge points", ar="نقاط المعرفة",
  es="Puntos de saber", pt="Pontos de saber", de="Wissenspunkte",
  tr="Bilgi puanı", id="Poin pengetahuan", ur="علمی پوائنٹس",
  ms="Mata ilmu", it="Punti sapere", nl="Kennispunten")

s("shieldEarned", "Celebration when a 3-answer streak earns a shield",
  fr="Bouclier obtenu ! Ton cheval est protégé.",
  en="Shield earned! Your horse is protected.",
  ar="حصلت على درع! حصانك محمي.",
  es="¡Escudo obtenido! Tu caballo está protegido.",
  pt="Escudo conquistado! Seu cavalo está protegido.",
  de="Schild verdient! Dein Pferd ist geschützt.",
  tr="Kalkan kazandın! Atın korunuyor.",
  id="Perisai diperoleh! Kudamu terlindungi.",
  ur="ڈھال مل گئی! آپ کا گھوڑا محفوظ ہے۔",
  ms="Perisai diperoleh! Kuda anda dilindungi.",
  it="Scudo ottenuto! Il tuo cavallo è protetto.",
  nl="Schild verdiend! Je paard is beschermd.")

s("grandGallopEarned", "Celebration when a 5-answer streak unlocks the Grand Gallop",
  fr="Grand Galop débloqué ! +2 cases quand tu veux.",
  en="Grand Gallop unlocked! +2 squares whenever you choose.",
  ar="انطلق الركض الكبير! +2 مربعات متى شئت.",
  es="¡Gran Galope desbloqueado! +2 casillas cuando quieras.",
  pt="Grande Galope desbloqueado! +2 casas quando quiser.",
  de="Großer Galopp freigeschaltet! +2 Felder, wann du willst.",
  tr="Büyük Dörtnal açıldı! İstediğinde +2 kare.",
  id="Grand Gallop terbuka! +2 kotak kapan pun kamu mau.",
  ur="گرینڈ گیلپ کھل گیا! جب چاہیں +2 خانے۔",
  ms="Grand Gallop dibuka! +2 petak bila-bila anda mahu.",
  it="Gran Galoppo sbloccato! +2 caselle quando vuoi.",
  nl="Grote Galop ontgrendeld! +2 vakjes wanneer je wilt.")

s("masteryBadgeEarned", "Celebration when a 10-answer streak earns a mastery badge",
  fr="Badge de maîtrise obtenu !", en="Mastery badge earned!",
  ar="حصلت على شارة الإتقان!", es="¡Insignia de maestría obtenida!",
  pt="Emblema de maestria conquistado!", de="Meisterschaftsabzeichen verdient!",
  tr="Ustalık rozeti kazandın!", id="Lencana penguasaan diperoleh!",
  ur="مہارت کا بیج مل گیا!", ms="Lencana penguasaan diperoleh!",
  it="Distintivo di maestria ottenuto!", nl="Meesterschapsbadge verdiend!")

s("useGrandGallop", "Toggle to spend the Grand Gallop on this move",
  fr="Utiliser le Grand Galop (+2)", en="Use the Grand Gallop (+2)",
  ar="استخدم الركض الكبير (+2)", es="Usar el Gran Galope (+2)",
  pt="Usar o Grande Galope (+2)", de="Großen Galopp einsetzen (+2)",
  tr="Büyük Dörtnal kullan (+2)", id="Gunakan Grand Gallop (+2)",
  ur="گرینڈ گیلپ استعمال کریں (+2)", ms="Guna Grand Gallop (+2)",
  it="Usa il Gran Galoppo (+2)", nl="Gebruik de Grote Galop (+2)")

# ---- Circuits --------------------------------------------------------------
s("chooseCircuit", "Header on the circuit picker",
  fr="Choisis ton circuit", en="Choose your course", ar="اختر مسارك",
  es="Elige tu recorrido", pt="Escolha seu percurso", de="Wähle deine Strecke",
  tr="Parkurunu seç", id="Pilih lintasanmu", ur="اپنا راستہ منتخب کریں",
  ms="Pilih laluan anda", it="Scegli il tuo percorso", nl="Kies je parcours")

s("circuitOasisRoute", "Circuit name",
  fr="La Route des Oasis", en="The Oasis Road", ar="طريق الواحات",
  es="La Ruta de los Oasis", pt="A Rota dos Oásis", de="Die Oasenstraße",
  tr="Vahalar Yolu", id="Jalur Oasis", ur="نخلستانوں کا راستہ",
  ms="Laluan Oasis", it="La Via delle Oasi", nl="De Oaseroute")

s("circuitCaravanTrail", "Circuit name",
  fr="La Piste des Caravanes", en="The Caravan Trail", ar="درب القوافل",
  es="La Pista de las Caravanas", pt="A Trilha das Caravanas",
  de="Der Karawanenpfad", tr="Kervan Yolu", id="Jejak Kafilah",
  ur="قافلوں کی پگڈنڈی", ms="Denai Kafilah", it="La Pista delle Carovane",
  nl="Het Karavaanpad")

s("circuitGreatRide", "Circuit name",
  fr="La Grande Chevauchée du Savoir", en="The Great Ride of Knowledge",
  ar="مسيرة المعرفة الكبرى", es="La Gran Cabalgada del Saber",
  pt="A Grande Cavalgada do Saber", de="Der Große Ritt des Wissens",
  tr="Büyük Bilgi Yolculuğu", id="Pacuan Agung Pengetahuan",
  ur="علم کی عظیم سواری", ms="Pengembaraan Agung Ilmu",
  it="La Grande Cavalcata del Sapere", nl="De Grote Rit van Kennis")

s("circuitOasisRouteDescription", "Oasis Route card description",
  fr="Le parcours le plus calme : des oasis, peu d'imprévus.",
  en="The calmest ride: oases, and few surprises.",
  ar="أهدأ مسار: واحات وقليل من المفاجآت.",
  es="El recorrido más tranquilo: oasis y pocas sorpresas.",
  pt="O percurso mais calmo: oásis e poucas surpresas.",
  de="Die ruhigste Strecke: Oasen, wenig Überraschungen.",
  tr="En sakin parkur: vahalar, az sürpriz.",
  id="Rute paling tenang: oase, sedikit kejutan.",
  ur="سب سے پرسکون راستہ: نخلستان، کم حیرتیں۔",
  ms="Laluan paling tenang: oasis, sedikit kejutan.",
  it="Il percorso più tranquillo: oasi e poche sorprese.",
  nl="De rustigste route: oases, weinig verrassingen.")

s("circuitCaravanTrailDescription", "Caravan Trail card description",
  fr="Des défis et des relais en chemin. Plus tactique.",
  en="Challenges and relays along the way. More tactical.",
  ar="تحديات ومحطات على الطريق. أكثر تكتيكًا.",
  es="Desafíos y relevos por el camino. Más táctico.",
  pt="Desafios e revezamentos pelo caminho. Mais tático.",
  de="Herausforderungen und Staffeln unterwegs. Taktischer.",
  tr="Yol boyunca meydan okumalar ve bayraklar. Daha taktik.",
  id="Tantangan dan estafet di sepanjang jalan. Lebih taktis.",
  ur="راستے میں چیلنج اور ریلے۔ زیادہ حکمت عملی۔",
  ms="Cabaran dan larian ganti di sepanjang jalan. Lebih taktikal.",
  it="Sfide e staffette lungo il cammino. Più tattico.",
  nl="Uitdagingen en estafettes onderweg. Tactischer.")

s("circuitGreatRideDescription", "Great Ride card description",
  fr="Le parcours le plus animé : défis, raccourcis et duels.",
  en="The liveliest ride: challenges, shortcuts and duels.",
  ar="أكثر المسارات حيوية: تحديات واختصارات ومبارزات.",
  es="El recorrido más animado: desafíos, atajos y duelos.",
  pt="O percurso mais movimentado: desafios, atalhos e duelos.",
  de="Die lebhafteste Strecke: Herausforderungen, Abkürzungen und Duelle.",
  tr="En hareketli parkur: meydan okumalar, kısayollar ve düellolar.",
  id="Rute paling ramai: tantangan, jalan pintas, dan duel.",
  ur="سب سے پرجوش راستہ: چیلنج، شارٹ کٹ اور مقابلے۔",
  ms="Laluan paling meriah: cabaran, jalan pintas dan pertarungan.",
  it="Il percorso più vivace: sfide, scorciatoie e duelli.",
  nl="De levendigste route: uitdagingen, sluiproutes en duels.")

s("cellOasis", "Special square name",
  fr="Oasis", en="Oasis", ar="واحة", es="Oasis", pt="Oásis", de="Oase",
  tr="Vaha", id="Oasis", ur="نخلستان", ms="Oasis", it="Oasi", nl="Oase")

s("cellKnowledge", "Special square name",
  fr="Connaissance", en="Knowledge", ar="معرفة", es="Conocimiento",
  pt="Conhecimento", de="Wissen", tr="Bilgi", id="Pengetahuan", ur="علم",
  ms="Ilmu", it="Conoscenza", nl="Kennis")

s("cellChallenge", "Special square name",
  fr="Défi", en="Challenge", ar="تحدٍ", es="Desafío", pt="Desafio",
  de="Herausforderung", tr="Meydan okuma", id="Tantangan", ur="چیلنج",
  ms="Cabaran", it="Sfida", nl="Uitdaging")

s("cellShortcut", "Special square name",
  fr="Raccourci", en="Shortcut", ar="طريق مختصر", es="Atajo", pt="Atalho",
  de="Abkürzung", tr="Kestirme", id="Jalan pintas", ur="مختصر راستہ",
  ms="Jalan pintas", it="Scorciatoia", nl="Kortere weg")

s("cellDuel", "Special square name",
  fr="Duel", en="Duel", ar="مبارزة", es="Duelo", pt="Duelo", de="Duell",
  tr="Düello", id="Duel", ur="مقابلہ", ms="Pertandingan", it="Duello",
  nl="Duel")

s("cellWisdom", "Special square name",
  fr="Sagesse", en="Wisdom", ar="حكمة", es="Sabiduría", pt="Sabedoria",
  de="Weisheit", tr="Hikmet", id="Hikmah", ur="حکمت", ms="Hikmah",
  it="Saggezza", nl="Wijsheid")

s("cellRelay", "Special square name",
  fr="Relais", en="Relay", ar="تناوب", es="Relevo", pt="Revezamento",
  de="Staffel", tr="Bayrak", id="Estafet", ur="ریلے", ms="Lapor",
  it="Staffetta", nl="Estafette")

s("cellOasisDescription", "What the Oasis square does",
  fr="Ton cheval y est protégé des captures.",
  en="Your horse is safe from capture here.",
  ar="حصانك في مأمن من الأسر هنا.",
  es="Tu caballo está a salvo de capturas aquí.",
  pt="Seu cavalo está a salvo de capturas aqui.",
  de="Dein Pferd ist hier vor dem Überholen sicher.",
  tr="Atın burada yakalanmaktan güvende.",
  id="Kudamu aman dari tangkapan di sini.",
  ur="یہاں آپ کا گھوڑا محفوظ ہے۔",
  ms="Kuda anda selamat daripada ditangkap di sini.",
  it="Il tuo cavallo è al sicuro qui.",
  nl="Je paard is hier veilig.")

s("cellChallengeOffer", "The optional Défi offer",
  fr="Répondre à une question plus difficile pour avancer de 2 cases de plus ?",
  en="Answer a harder question to move 2 extra squares?",
  ar="هل تجيب عن سؤال أصعب للتقدم مربعين إضافيين؟",
  es="¿Responder una pregunta más difícil para avanzar 2 casillas más?",
  pt="Responder a uma pergunta mais difícil para avançar mais 2 casas?",
  de="Eine schwerere Frage für 2 zusätzliche Felder beantworten?",
  tr="2 kare fazla ilerlemek için daha zor bir soru cevaplansın mı?",
  id="Jawab pertanyaan lebih sulit untuk maju 2 kotak lagi?",
  ur="2 اضافی خانے آگے بڑھنے کے لیے مشکل سوال کا جواب دیں؟",
  ms="Jawab soalan lebih sukar untuk maju 2 petak lagi?",
  it="Rispondere a una domanda più difficile per avanzare di 2 caselle?",
  nl="Een moeilijkere vraag beantwoorden voor 2 extra vakjes?")

s("acceptChallenge", "Accept the optional challenge",
  fr="Relever le défi", en="Take the challenge", ar="اقبل التحدي",
  es="Aceptar el desafío", pt="Aceitar o desafio", de="Herausforderung annehmen",
  tr="Meydan okumayı kabul et", id="Terima tantangan", ur="چیلنج قبول کریں",
  ms="Terima cabaran", it="Accetta la sfida", nl="Neem de uitdaging aan")

s("declineChallenge", "Decline the optional challenge and keep the move",
  fr="Garder mon déplacement", en="Keep my move", ar="احتفظ بحركتي",
  es="Conservar mi movimiento", pt="Manter meu movimento", de="Zug behalten",
  tr="Hamlemi koru", id="Simpan langkahku", ur="اپنی چال رکھیں",
  ms="Kekalkan langkah saya", it="Tieni la mia mossa", nl="Mijn zet houden")

s("saveFact", "Keep a fact in the personal collection",
  fr="Garder cette connaissance", en="Keep this fact", ar="احفظ هذه المعلومة",
  es="Guardar este dato", pt="Guardar este facto", de="Diesen Fakt behalten",
  tr="Bu bilgiyi sakla", id="Simpan fakta ini", ur="یہ بات محفوظ کریں",
  ms="Simpan fakta ini", it="Conserva questo fatto", nl="Bewaar dit feit")

# ---- Arrival ---------------------------------------------------------------
s("journeyQuestion", "Name of the final question that validates an arrival",
  fr="Question du voyage", en="Journey question", ar="سؤال الرحلة",
  es="Pregunta del viaje", pt="Pergunta da viagem", de="Reisefrage",
  tr="Yolculuk sorusu", id="Pertanyaan perjalanan", ur="سفر کا سوال",
  ms="Soalan pengembaraan", it="Domanda del viaggio", nl="Reisvraag")

s("journeyQuestionIntro", "Explains the journey question",
  fr="Une dernière question pour valider ton arrivée.",
  en="One last question to make your arrival official.",
  ar="سؤال أخير لتأكيد وصولك.",
  es="Una última pregunta para validar tu llegada.",
  pt="Uma última pergunta para validar sua chegada.",
  de="Eine letzte Frage, um deine Ankunft zu bestätigen.",
  tr="Varışını onaylamak için son bir soru.",
  id="Satu pertanyaan terakhir untuk mengesahkan kedatanganmu.",
  ur="آپ کی آمد کی تصدیق کے لیے ایک آخری سوال۔",
  ms="Satu soalan terakhir untuk mengesahkan ketibaan anda.",
  it="Un'ultima domanda per convalidare il tuo arrivo.",
  nl="Nog één vraag om je aankomst te bevestigen.")

# ---- The opponent's turn, narrated ------------------------------------------
s("opponentThinking", "Turn banner while an AI opponent is choosing a horse",
  ph={"name": "String"},
  fr="{name} réfléchit…", en="{name} is thinking…", ar="{name} يفكّر…",
  es="{name} está pensando…", pt="{name} está pensando…", de="{name} überlegt…",
  tr="{name} düşünüyor…", id="{name} sedang berpikir…", ur="{name} سوچ رہا ہے…",
  ms="{name} sedang berfikir…", it="{name} sta pensando…", nl="{name} denkt na…")

s("opponentDrew", "Turn banner: the AI opponent drew a card worth N squares",
  ph={"name": "String", "count": "int"},
  fr="{name} pioche un {count}", en="{name} draws a {count}", ar="{name} يسحب {count}",
  es="{name} saca un {count}", pt="{name} tira um {count}", de="{name} zieht eine {count}",
  tr="{name} bir {count} çekti", id="{name} menarik kartu {count}",
  ur="{name} نے {count} نکالا", ms="{name} menarik kad {count}",
  it="{name} pesca un {count}", nl="{name} trekt een {count}")

s("correctAnswerWas", "Feedback sheet: the right answer, shown after a wrong one",
  ph={"answer": "String"},
  fr="La bonne réponse : {answer}", en="The right answer: {answer}",
  ar="الإجابة الصحيحة: {answer}", es="La respuesta correcta: {answer}",
  pt="A resposta certa: {answer}", de="Die richtige Antwort: {answer}",
  tr="Doğru cevap: {answer}", id="Jawaban yang benar: {answer}",
  ur="صحیح جواب: {answer}", ms="Jawapan yang betul: {answer}",
  it="La risposta giusta: {answer}", nl="Het juiste antwoord: {answer}")

s("scoreboardTitle", "Results screen: heading over the per-player score rows",
  fr="Tableau de la course", en="Race board", ar="لوحة السباق",
  es="Tablero de la carrera", pt="Quadro da corrida", de="Rennstand",
  tr="Yarış Tablosu", id="Papan Balapan", ur="ریس بورڈ", ms="Papan Perlumbaan",
  it="Tabellone della corsa", nl="Racebord")

s("scoreboardCorrect", "Results screen: correct answers count, short",
  ph={"count": "int"},
  fr="{count} bonnes réponses", en="{count} correct", ar="{count} إجابات صحيحة",
  es="{count} aciertos", pt="{count} acertos", de="{count} richtig",
  tr="{count} doğru", id="{count} benar", ur="{count} درست", ms="{count} betul",
  it="{count} corrette", nl="{count} goed")

s("scoreboardBestStreak", "Results screen: best streak of the game, short",
  ph={"count": "int"},
  fr="série de {count}", en="streak of {count}", ar="سلسلة من {count}",
  es="racha de {count}", pt="sequência de {count}", de="Serie von {count}",
  tr="{count} seri", id="rentetan {count}", ur="{count} کا سلسلہ", ms="rentetan {count}",
  it="serie di {count}", nl="reeks van {count}")

s("playAgainSameRiders", "Results screen: restart with the same players, one tap",
  fr="Encore une course !", en="Race again!", ar="سباق آخر!", es="¡Otra carrera!",
  pt="Mais uma corrida!", de="Noch ein Rennen!", tr="Bir Yarış Daha!",
  id="Balapan Lagi!", ur="ایک اور ریس!", ms="Lumba Lagi!", it="Un'altra corsa!",
  nl="Nog een race!")

s("opponentMoved", "Turn banner: the AI opponent answered right and its horse moved",
  ph={"name": "String"},
  fr="{name} avance !", en="{name} moves ahead!", ar="{name} يتقدم!",
  es="¡{name} avanza!", pt="{name} avança!", de="{name} zieht vor!",
  tr="{name} ilerliyor!", id="{name} melaju!", ur="{name} آگے بڑھا!",
  ms="{name} maju!", it="{name} avanza!", nl="{name} gaat vooruit!")

s("opponentStayed", "Turn banner: the AI opponent answered wrong and stays put",
  ph={"name": "String"},
  fr="{name} reste sur place.", en="{name} holds its ground.", ar="{name} يبقى مكانه.",
  es="{name} se queda.", pt="{name} fica parado.", de="{name} bleibt stehen.",
  tr="{name} yerinde kalıyor.", id="{name} tetap di tempat.", ur="{name} وہیں رہا۔",
  ms="{name} kekal.", it="{name} resta fermo.", nl="{name} blijft staan.")

s("shareScore", "Button: share the score card (results and daily challenge)",
  fr="Partager", en="Share", ar="مشاركة", es="Compartir", pt="Partilhar",
  de="Teilen", tr="Paylaş", id="Bagikan", ur="شیئر کریں", ms="Kongsi",
  it="Condividi", nl="Delen")

s("shareVictoryText", "Share text after a race: winner and stars",
  ph={"name": "String", "points": "int"},
  fr="{name} a gagné la course IqraQuest avec {points} ⭐ ! À toi de jouer ?",
  en="{name} won the IqraQuest race with {points} ⭐! Your turn?",
  ar="فاز {name} بسباق IqraQuest بـ {points} ⭐! هل تجرّب دورك؟",
  es="¡{name} ganó la carrera IqraQuest con {points} ⭐! ¿Te animas?",
  pt="{name} venceu a corrida IqraQuest com {points} ⭐! E tu?",
  de="{name} hat das IqraQuest-Rennen mit {points} ⭐ gewonnen! Du auch?",
  tr="{name} IqraQuest yarışını {points} ⭐ ile kazandı! Sıra sende mi?",
  id="{name} memenangkan balapan IqraQuest dengan {points} ⭐! Giliranmu?",
  ur="{name} نے IqraQuest ریس {points} ⭐ کے ساتھ جیت لی! آپ کی باری؟",
  ms="{name} memenangi lumba IqraQuest dengan {points} ⭐! Giliran anda?",
  it="{name} ha vinto la corsa IqraQuest con {points} ⭐! Tocca a te?",
  nl="{name} won de IqraQuest-race met {points} ⭐! Jij ook?")

s("shareDailyText", "Share text after the daily challenge: score out of total",
  ph={"score": "int", "total": "int"},
  fr="{score}/{total} au défi du jour IqraQuest ! Tu fais mieux ?",
  en="{score}/{total} on today's IqraQuest challenge! Can you beat it?",
  ar="{score}/{total} في تحدي اليوم من IqraQuest! هل تتفوّق عليّ؟",
  es="¡{score}/{total} en el reto del día de IqraQuest! ¿Lo superas?",
  pt="{score}/{total} no desafio do dia IqraQuest! Consegues melhor?",
  de="{score}/{total} bei der IqraQuest-Tagesaufgabe! Schaffst du mehr?",
  tr="IqraQuest günün mücadelesinde {score}/{total}! Geçebilir misin?",
  id="{score}/{total} di tantangan harian IqraQuest! Bisa lebih baik?",
  ur="IqraQuest کے آج کے چیلنج میں {score}/{total}! آپ بہتر کر سکتے ہیں؟",
  ms="{score}/{total} dalam cabaran harian IqraQuest! Boleh lebih baik?",
  it="{score}/{total} alla sfida del giorno IqraQuest! Fai di meglio?",
  nl="{score}/{total} bij de IqraQuest-daguitdaging! Doe jij het beter?")

s("dailyChallengeDone", "Daily challenge summary title once all questions are answered",
  fr="Défi du jour terminé", en="Today's challenge done", ar="اكتمل تحدي اليوم",
  es="Reto del día completado", pt="Desafio do dia concluído", de="Tagesaufgabe geschafft",
  tr="Günün mücadelesi tamam", id="Tantangan harian selesai", ur="آج کا چیلنج مکمل",
  ms="Cabaran harian selesai", it="Sfida del giorno completata", nl="Daguitdaging voltooid")

s("dailyChallengeScore", "Daily challenge summary: right answers out of total",
  ph={"score": "num", "total": "int"},
  fr="{score, plural, =0{Aucune bonne réponse sur {total}} one{{score} bonne réponse sur {total}} other{{score} bonnes réponses sur {total}}}",
  en="{score, plural, =0{None right out of {total}} one{{score} right out of {total}} other{{score} right out of {total}}}",
  ar="{score, plural, =0{لا إجابات صحيحة من {total}} one{إجابة صحيحة واحدة من {total}} two{إجابتان صحيحتان من {total}} few{{score} إجابات صحيحة من {total}} many{{score} إجابة صحيحة من {total}} other{{score} إجابة صحيحة من {total}}}",
  es="{score, plural, =0{Ningún acierto de {total}} one{{score} acierto de {total}} other{{score} aciertos de {total}}}",
  pt="{score, plural, =0{Nenhuma certa em {total}} one{{score} certa em {total}} other{{score} certas em {total}}}",
  de="{score, plural, other{{score} von {total} richtig}}",
  tr="{score, plural, other{{total} sorudan {score} doğru}}",
  id="{score, plural, other{{score} benar dari {total}}}",
  ur="{score, plural, other{{total} میں سے {score} درست}}",
  ms="{score, plural, other{{score} betul daripada {total}}}",
  it="{score, plural, =0{Nessuna risposta giusta su {total}} one{{score} giusta su {total}} other{{score} giuste su {total}}}",
  nl="{score, plural, other{{score} goed van de {total}}}")

s("dailyChallengeComeBack", "Daily challenge summary: invitation to return tomorrow",
  fr="Reviens demain pour un nouveau défi.", en="Come back tomorrow for a new one.",
  ar="عُد غدًا لتحدٍّ جديد.", es="Vuelve mañana para un nuevo reto.",
  pt="Volta amanhã para um novo desafio.", de="Morgen wartet eine neue Aufgabe.",
  tr="Yarın yeni bir mücadele için gel.", id="Kembali besok untuk tantangan baru.",
  ur="نئے چیلنج کے لیے کل پھر آئیں۔", ms="Kembali esok untuk cabaran baharu.",
  it="Torna domani per una nuova sfida.", nl="Kom morgen terug voor een nieuwe.")

s("aiOpponentsLabel", "Mode selection: stepper label for the number of computer riders",
  fr="Adversaires", en="Opponents", ar="الخصوم", es="Rivales", pt="Adversários",
  de="Gegner", tr="Rakipler", id="Lawan", ur="حریف", ms="Lawan", it="Avversari",
  nl="Tegenstanders")

s("playersLabel", "Mode selection: stepper label for the number of human riders",
  fr="Joueurs", en="Players", ar="اللاعبون", es="Jugadores", pt="Jogadores",
  de="Spieler", tr="Oyuncular", id="Pemain", ur="کھلاڑی", ms="Pemain", it="Giocatori",
  nl="Spelers")

# ---- Move outcomes ---------------------------------------------------------
s("outcomeMoved", "Feedback after a correct answer",
  fr="Ton cheval avance !", en="Your horse moves ahead!", ar="حصانك يتقدم!",
  es="¡Tu caballo avanza!", pt="Seu cavalo avança!", de="Dein Pferd zieht vor!",
  tr="Atın ilerliyor!", id="Kudamu melaju!", ur="آپ کا گھوڑا آگے بڑھا!",
  ms="Kuda anda maju!", it="Il tuo cavallo avanza!", nl="Je paard gaat vooruit!")

s("outcomeStayed", "Feedback after a wrong answer — never a setback",
  fr="Ton cheval reste sur place. Rien n'est perdu.",
  en="Your horse holds its ground. Nothing is lost.",
  ar="حصانك يبقى مكانه. لم تخسر شيئًا.",
  es="Tu caballo se queda. No pierdes nada.",
  pt="Seu cavalo fica parado. Nada se perde.",
  de="Dein Pferd bleibt stehen. Nichts geht verloren.",
  tr="Atın yerinde kalıyor. Kaybın yok.",
  id="Kudamu tetap di tempat. Tidak ada yang hilang.",
  ur="آپ کا گھوڑا وہیں رہا۔ کچھ نہیں گیا۔",
  ms="Kuda anda kekal. Tiada apa yang hilang.",
  it="Il tuo cavallo resta fermo. Non perdi nulla.",
  nl="Je paard blijft staan. Er gaat niets verloren.")

s("outcomeCaptured", "Feedback when landing on an opponent's horse and sending it home",
  fr="Tu captures un cheval adverse !", en="You capture an opponent's horse!",
  ar="لقد أسرت حصان الخصم!", es="¡Capturas un caballo rival!",
  pt="Você captura um cavalo adversário!", de="Du schlägst ein gegnerisches Pferd!",
  tr="Rakibin atını yakaladın!", id="Kamu menangkap kuda lawan!",
  ur="آپ نے حریف کا گھوڑا پکڑ لیا!", ms="Anda menangkap kuda lawan!",
  it="Catturi un cavallo avversario!", nl="Je slaat een paard van de tegenstander!")

s("outcomeExited", "Feedback after a correct answer on a 5 or 6 brought a horse out",
  fr="Ton cheval sort de l'écurie !", en="Your horse leaves the stable!",
  ar="حصانك يخرج من الإسطبل!", es="¡Tu caballo sale del establo!",
  pt="Seu cavalo sai do estábulo!", de="Dein Pferd verlässt den Stall!",
  tr="Atın ahırdan çıkıyor!", id="Kudamu keluar dari kandang!",
  ur="آپ کا گھوڑا اصطبل سے نکلا!", ms="Kuda anda keluar dari kandang!",
  it="Il tuo cavallo esce dalla stalla!", nl="Je paard verlaat de stal!")

s("outcomeNoLegalMove", "Banner when the drawn card can move no horse at all",
  fr="Cette carte ne peut bouger aucun cheval. Tour suivant !",
  en="This card can't move any horse. Next turn!",
  ar="هذه البطاقة لا تحرّك أي حصان. الدور التالي!",
  es="Esta carta no puede mover ningún caballo. ¡Siguiente turno!",
  pt="Esta carta não move nenhum cavalo. Próxima vez!",
  de="Diese Karte kann kein Pferd bewegen. Nächster Zug!",
  tr="Bu kart hiçbir atı hareket ettiremiyor. Sıradaki tur!",
  id="Kartu ini tak bisa menggerakkan kuda mana pun. Giliran berikutnya!",
  ur="یہ کارڈ کسی گھوڑے کو نہیں ہلا سکتا۔ اگلی باری!",
  ms="Kad ini tidak dapat menggerakkan mana-mana kuda. Giliran seterusnya!",
  it="Questa carta non può muovere nessun cavallo. Turno successivo!",
  nl="Deze kaart kan geen paard verplaatsen. Volgende beurt!")

s("noExitHint", "Banner when every horse is in the stable and the card is not a 6",
  fr="Il faut un 6 pour sortir un cheval de l'écurie.",
  en="You need a 6 to bring a horse out of the stable.",
  ar="تحتاج إلى 6 لإخراج حصان من الإسطبل.",
  es="Necesitas un 6 para sacar un caballo del establo.",
  pt="Você precisa de um 6 para tirar um cavalo do estábulo.",
  de="Du brauchst eine 6, um ein Pferd aus dem Stall zu holen.",
  tr="Ahırdan bir at çıkarmak için 6 gerekir.",
  id="Kamu butuh angka 6 untuk mengeluarkan kuda dari kandang.",
  ur="اصطبل سے گھوڑا نکالنے کے لیے 6 چاہیے۔",
  ms="Anda perlukan 6 untuk mengeluarkan kuda dari kandang.",
  it="Serve un 6 per far uscire un cavallo dalla stalla.",
  nl="Je hebt een 6 nodig om een paard uit de stal te halen.")

s("bonusTurnHint", "Deck hint on the second draw a 6 earned",
  fr="Tour bonus : le 6 te fait rejouer !", en="Bonus turn: the 6 lets you play again!",
  ar="دور إضافي: الرقم 6 يمنحك دورًا آخر!", es="Turno extra: ¡el 6 te deja jugar otra vez!",
  pt="Vez extra: o 6 deixa você jogar de novo!", de="Bonuszug: Die 6 lässt dich noch einmal ziehen!",
  tr="Bonus tur: 6 sana bir kez daha oynatıyor!", id="Giliran bonus: angka 6 membuatmu main lagi!",
  ur="بونس باری: 6 آپ کو دوبارہ کھیلنے دیتا ہے!", ms="Giliran bonus: 6 membuat anda bermain lagi!",
  it="Turno bonus: il 6 ti fa giocare ancora!", nl="Bonusbeurt: de 6 laat je nog een keer spelen!")

# ---- Celebrations: the key moments, shouted -------------------------------
s("celebrateSixTitle", "Celebration title when a 6 is drawn",
  fr="SIX !", en="SIX!", ar="ستة!", es="¡SEIS!", pt="SEIS!", de="SECHS!",
  tr="ALTI!", id="ENAM!", ur="چھ!", ms="ENAM!", it="SEI!", nl="ZES!")

s("celebrateSixBody", "Celebration body when a 6 is drawn: the player draws again after this turn",
  fr="Tu rejoueras après ce tour.", en="You'll draw again after this turn.",
  ar="ستسحب مرة أخرى بعد هذا الدور.", es="Volverás a robar después de este turno.",
  pt="Você vai puxar de novo depois desta vez.", de="Nach diesem Zug ziehst du noch einmal.",
  tr="Bu turdan sonra yeniden çekeceksin.", id="Kamu akan mengambil kartu lagi setelah giliran ini.",
  ur="اس باری کے بعد آپ دوبارہ کارڈ نکالیں گے۔", ms="Anda akan mencabut lagi selepas giliran ini.",
  it="Pescherai di nuovo dopo questo turno.", nl="Na deze beurt trek je nog een keer.")

s("celebrateSixExitBody", "Celebration body when a 6 both opens the stable and grants a replay",
  fr="Un cheval peut sortir — et tu rejoueras !", en="A horse can come out — and you'll play again!",
  ar="يمكن لحصان الخروج — وستلعب مرة أخرى!", es="Un caballo puede salir, ¡y volverás a jugar!",
  pt="Um cavalo pode sair — e você joga de novo!", de="Ein Pferd darf raus – und du ziehst noch einmal!",
  tr="Bir at çıkabilir — ve yeniden oynayacaksın!", id="Seekor kuda boleh keluar — dan kamu main lagi!",
  ur="ایک گھوڑا نکل سکتا ہے — اور آپ دوبارہ کھیلیں گے!", ms="Seekor kuda boleh keluar — dan anda bermain lagi!",
  it="Un cavallo può uscire — e giocherai ancora!", nl="Een paard mag naar buiten – en je speelt nog een keer!")

s("celebrateExitTitle", "Celebration title when the gate opens (folded into the 6 celebration)",
  fr="Sortie !", en="Gate open!", ar="خروج!", es="¡Salida!", pt="Saída!", de="Tor auf!",
  tr="Kapı açık!", id="Gerbang terbuka!", ur="دروازہ کھلا!", ms="Pintu terbuka!",
  it="Uscita!", nl="Poort open!")

s("celebrateExitBody", "Celebration body when the gate opens (folded into the 6 celebration)",
  fr="Un cheval peut quitter l'écurie.", en="A horse can leave the stable.",
  ar="يمكن لحصان مغادرة الإسطبل.", es="Un caballo puede salir del establo.",
  pt="Um cavalo pode sair do estábulo.", de="Ein Pferd darf den Stall verlassen.",
  tr="Bir at ahırdan çıkabilir.", id="Seekor kuda boleh keluar dari kandang.",
  ur="ایک گھوڑا اصطبل سے نکل سکتا ہے۔", ms="Seekor kuda boleh keluar dari kandang.",
  it="Un cavallo può uscire dalla stalla.", nl="Een paard mag de stal verlaten.")

s("celebrateCaptureTitle", "Celebration title when the player captures an opponent's horse",
  fr="Capture !", en="Captured!", ar="أسر!", es="¡Captura!", pt="Captura!", de="Geschlagen!",
  tr="Yakaladın!", id="Tangkap!", ur="پکڑ لیا!", ms="Tangkap!", it="Cattura!", nl="Geslagen!")

s("celebrateCaptureBody", "Celebration body when the player captures an opponent's horse",
  fr="Le cheval adverse rentre à son écurie.", en="The opponent's horse goes back to its stable.",
  ar="حصان الخصم يعود إلى إسطبله.", es="El caballo rival vuelve a su establo.",
  pt="O cavalo adversário volta ao estábulo.", de="Das gegnerische Pferd kehrt in seinen Stall zurück.",
  tr="Rakibin atı ahırına dönüyor.", id="Kuda lawan kembali ke kandangnya.",
  ur="حریف کا گھوڑا اپنے اصطبل واپس جاتا ہے۔", ms="Kuda lawan pulang ke kandangnya.",
  it="Il cavallo avversario torna nella sua stalla.", nl="Het paard van de tegenstander gaat terug naar zijn stal.")

s("celebrateCapturedTitle", "Notice title when the player's own horse is captured",
  fr="Capturé…", en="Caught…", ar="أُسر…", es="Capturado…", pt="Capturado…", de="Erwischt…",
  tr="Yakalandın…", id="Tertangkap…", ur="پکڑا گیا…", ms="Ditangkap…", it="Catturato…", nl="Gepakt…")

s("celebrateCapturedBody", "Notice body when the player's own horse is captured",
  fr="Ton cheval rentre à l'écurie. Il repartira sur un 6.",
  en="Your horse goes back to the stable. A 6 brings it out again.",
  ar="حصانك يعود إلى الإسطبل. سيخرج مجددًا بالرقم 6.",
  es="Tu caballo vuelve al establo. Saldrá otra vez con un 6.",
  pt="Seu cavalo volta ao estábulo. Um 6 o traz de volta.",
  de="Dein Pferd kehrt in den Stall zurück. Mit einer 6 kommt es wieder raus.",
  tr="Atın ahıra dönüyor. Bir 6 onu yeniden çıkarır.",
  id="Kudamu kembali ke kandang. Angka 6 mengeluarkannya lagi.",
  ur="آپ کا گھوڑا اصطبل واپس گیا۔ 6 اسے پھر نکالے گا۔",
  ms="Kuda anda pulang ke kandang. 6 mengeluarkannya semula.",
  it="Il tuo cavallo torna nella stalla. Un 6 lo farà uscire di nuovo.",
  nl="Je paard gaat terug naar de stal. Met een 6 komt het weer naar buiten.")

s("celebrateArrivalTitle", "Celebration title when a horse reaches the centre",
  fr="La Mecque !", en="Mecca!", ar="مكة!", es="¡La Meca!", pt="Meca!", de="Mekka!",
  tr="Mekke!", id="Makkah!", ur="مکہ!", ms="Makkah!", it="La Mecca!", nl="Mekka!")

s("celebrateArrivalBody", "Celebration body when a horse reaches the centre",
  fr="Ton cheval est arrivé. Une dernière question pour valider !",
  en="Your horse has arrived. One last question to make it official!",
  ar="وصل حصانك. سؤال أخير للتثبيت!",
  es="Tu caballo ha llegado. ¡Una última pregunta para validarlo!",
  pt="Seu cavalo chegou. Uma última pergunta para confirmar!",
  de="Dein Pferd ist angekommen. Eine letzte Frage macht es offiziell!",
  tr="Atın vardı. Resmileştirmek için son bir soru!",
  id="Kudamu sudah tiba. Satu pertanyaan terakhir untuk mengesahkannya!",
  ur="آپ کا گھوڑا پہنچ گیا۔ توثیق کے لیے ایک آخری سوال!",
  ms="Kuda anda telah tiba. Satu soalan terakhir untuk mengesahkannya!",
  it="Il tuo cavallo è arrivato. Un'ultima domanda per convalidarlo!",
  nl="Je paard is aangekomen. Nog één vraag om het officieel te maken!")

# ---- The free edition's finish line ------------------------------------------
s("freeLimitTitle", "Results title when the free edition's draw limit ended the race",
  fr="Fin de la course gratuite", en="End of the free race", ar="نهاية السباق المجاني",
  es="Fin de la carrera gratuita", pt="Fim da corrida gratuita", de="Ende des Gratis-Rennens",
  tr="Ücretsiz yarışın sonu", id="Akhir balapan gratis", ur="مفت ریس کا اختتام",
  ms="Tamat perlumbaan percuma", it="Fine della corsa gratuita", nl="Einde van de gratis race")

s("freeLimitLeader", "Results subtitle: who was ahead when the free race stopped",
  ph={"name": "String"},
  fr="En tête : {name}", en="In the lead: {name}", ar="في الصدارة: {name}",
  es="En cabeza: {name}", pt="Na frente: {name}", de="In Führung: {name}",
  tr="Önde: {name}", id="Memimpin: {name}", ur="آگے: {name}", ms="Mendahului: {name}",
  it="In testa: {name}", nl="Aan de leiding: {name}")

s("freeLimitBody", "Results body: the free edition stops after N draws; Premium runs to the end",
  ph={"count": "int"},
  fr="La version gratuite s'arrête après {count} pioches. Avec Premium, la course va jusqu'à La Mecque.",
  en="The free edition stops after {count} draws. With Premium, the race runs all the way to Mecca.",
  ar="تتوقف النسخة المجانية بعد {count} سحبة. مع بريميوم، يمتد السباق حتى مكة.",
  es="La versión gratuita se detiene tras {count} robos. Con Premium, la carrera llega hasta La Meca.",
  pt="A versão gratuita para após {count} puxadas. Com o Premium, a corrida vai até Meca.",
  de="Die Gratisversion endet nach {count} Zügen. Mit Premium geht das Rennen bis nach Mekka.",
  tr="Ücretsiz sürüm {count} çekilişten sonra durur. Premium ile yarış Mekke'ye kadar sürer.",
  id="Versi gratis berhenti setelah {count} kali ambil kartu. Dengan Premium, balapan berlanjut sampai Makkah.",
  ur="مفت ورژن {count} کارڈ کے بعد رک جاتا ہے۔ پریمیم کے ساتھ ریس مکہ تک جاتی ہے۔",
  ms="Versi percuma berhenti selepas {count} cabutan. Dengan Premium, perlumbaan berterusan hingga ke Makkah.",
  it="La versione gratuita si ferma dopo {count} pescate. Con Premium, la corsa arriva fino alla Mecca.",
  nl="De gratis versie stopt na {count} kaarten. Met Premium gaat de race door tot aan Mekka.")

s("freeLimitCta", "Results button: open the Premium screen after a free race stopped",
  fr="Débloquer la course illimitée", en="Unlock the unlimited race", ar="افتح السباق غير المحدود",
  es="Desbloquear la carrera ilimitada", pt="Desbloquear a corrida ilimitada",
  de="Unbegrenztes Rennen freischalten", tr="Sınırsız yarışın kilidini aç",
  id="Buka balapan tanpa batas", ur="لامحدود ریس کھولیں", ms="Buka perlumbaan tanpa had",
  it="Sblocca la corsa illimitata", nl="Onbeperkte race ontgrendelen")

s("drawsCounter", "HUD pill, free edition: cards drawn out of the limit (screen-reader label)",
  ph={"count": "int", "max": "int"},
  fr="Pioches : {count} sur {max}", en="Draws: {count} of {max}", ar="السحبات: {count} من {max}",
  es="Robos: {count} de {max}", pt="Puxadas: {count} de {max}", de="Züge: {count} von {max}",
  tr="Çekiliş: {count} / {max}", id="Ambil kartu: {count} dari {max}", ur="کارڈ: {max} میں سے {count}",
  ms="Cabutan: {count} daripada {max}", it="Pescate: {count} su {max}", nl="Kaarten: {count} van {max}")

# ---- The move choice: what to do with the card ------------------------------
s("moveChoiceTitle", "Sheet title after a draw when several horses could use the card",
  ph={"count": "int"},
  fr="Que fais-tu de ce {count} ?", en="What will you do with this {count}?",
  ar="ماذا ستفعل بهذا الرقم {count}؟", es="¿Qué haces con este {count}?",
  pt="O que você faz com este {count}?", de="Was machst du mit dieser {count}?",
  tr="Bu {count} ile ne yapacaksın?", id="Mau diapakan angka {count} ini?",
  ur="اس {count} کا کیا کریں گے؟", ms="Apa yang anda mahu buat dengan {count} ini?",
  it="Che fai con questo {count}?", nl="Wat doe je met deze {count}?")

s("moveChoiceExit", "Choice sheet option: bring a horse out of the stable",
  fr="Sortir un cheval de l'écurie", en="Bring a horse out of the stable",
  ar="إخراج حصان من الإسطبل", es="Sacar un caballo del establo",
  pt="Tirar um cavalo do estábulo", de="Ein Pferd aus dem Stall holen",
  tr="Ahırdan bir at çıkar", id="Keluarkan kuda dari kandang",
  ur="اصطبل سے ایک گھوڑا نکالیں", ms="Keluarkan kuda dari kandang",
  it="Far uscire un cavallo dalla stalla", nl="Een paard uit de stal halen")

s("moveChoiceAdvance", "Choice sheet option: ride horse N by the card's value",
  ph={"number": "int", "count": "int"},
  fr="Cheval {number} : avancer de {count}", en="Horse {number}: ride {count} ahead",
  ar="الحصان {number}: تقدّم {count}", es="Caballo {number}: avanzar {count}",
  pt="Cavalo {number}: avançar {count}", de="Pferd {number}: {count} vorrücken",
  tr="At {number}: {count} ilerle", id="Kuda {number}: maju {count}",
  ur="گھوڑا {number}: {count} آگے", ms="Kuda {number}: maju {count}",
  it="Cavallo {number}: avanza di {count}", nl="Paard {number}: {count} vooruit")

s("moveHintCapture", "Choice sheet tag: this move captures an opponent, and what the capture is worth",
  ph={"value": "int"},
  fr="capture ! +{value}", en="capture! +{value}", ar="أسر! +{value}",
  es="¡captura! +{value}", pt="captura! +{value}", de="schlagen! +{value}",
  tr="yakala! +{value}", id="tangkap! +{value}", ur="پکڑ! +{value}",
  ms="tangkap! +{value}", it="cattura! +{value}", nl="slaan! +{value}")

s("moveHintFinish", "Choice sheet tag: this move reaches the finish",
  fr="arrivée !", en="finish!", ar="الوصول!", es="¡llegada!", pt="chegada!", de="Ziel!",
  tr="varış!", id="finis!", ur="منزل!", ms="tamat!", it="arrivo!", nl="finish!")

s("moveHintOasis", "Choice sheet tag: this move lands on a safe oasis",
  fr="oasis", en="oasis", ar="واحة", es="oasis", pt="oásis", de="Oase",
  tr="vaha", id="oasis", ur="نخلستان", ms="oasis", it="oasi", nl="oase")

s("opponentExits", "Turn banner: the AI opponent brought a horse out of its stable",
  ph={"name": "String"},
  fr="{name} sort un cheval !", en="{name} brings a horse out!", ar="{name} يُخرج حصانًا!",
  es="¡{name} saca un caballo!", pt="{name} tira um cavalo!", de="{name} holt ein Pferd raus!",
  tr="{name} bir at çıkarıyor!", id="{name} mengeluarkan kuda!", ur="{name} نے گھوڑا نکالا!",
  ms="{name} mengeluarkan kuda!", it="{name} fa uscire un cavallo!", nl="{name} haalt een paard naar buiten!")

s("opponentNoMove", "Turn banner: the AI opponent's card could move nothing",
  ph={"name": "String"},
  fr="{name} ne peut rien bouger.", en="{name} can't move anything.", ar="{name} لا يستطيع تحريك شيء.",
  es="{name} no puede mover nada.", pt="{name} não pode mover nada.", de="{name} kann nichts bewegen.",
  tr="{name} hiçbir şeyi oynatamıyor.", id="{name} tak bisa menggerakkan apa pun.",
  ur="{name} کچھ نہیں ہلا سکتا۔", ms="{name} tidak dapat menggerakkan apa-apa.",
  it="{name} non può muovere nulla.", nl="{name} kan niets verplaatsen.")

s("opponentReplays", "Turn banner: the AI opponent drew a 6 and plays again",
  ph={"name": "String"},
  fr="{name} a fait un 6 et rejoue !", en="{name} drew a 6 and plays again!",
  ar="{name} سحب 6 ويلعب مجددًا!", es="¡{name} sacó un 6 y vuelve a jugar!",
  pt="{name} tirou um 6 e joga de novo!", de="{name} hat eine 6 gezogen und ist noch einmal dran!",
  tr="{name} 6 çekti ve yeniden oynuyor!", id="{name} mendapat 6 dan main lagi!",
  ur="{name} نے 6 نکالا اور دوبارہ کھیلتا ہے!", ms="{name} mendapat 6 dan bermain lagi!",
  it="{name} ha pescato un 6 e gioca ancora!", nl="{name} trok een 6 en speelt nog een keer!")

s("opponentCaptured", "Turn banner: the AI opponent captured a horse",
  ph={"name": "String"},
  fr="{name} capture un cheval !", en="{name} captures a horse!", ar="{name} يأسر حصانًا!",
  es="¡{name} captura un caballo!", pt="{name} captura um cavalo!", de="{name} schlägt ein Pferd!",
  tr="{name} bir at yakalıyor!", id="{name} menangkap kuda!", ur="{name} نے گھوڑا پکڑ لیا!",
  ms="{name} menangkap kuda!", it="{name} cattura un cavallo!", nl="{name} slaat een paard!")

s("outcomeShieldBlocked", "Feedback when a shield absorbs an overtake",
  fr="Le bouclier a protégé le cheval.", en="The shield protected the horse.",
  ar="حمى الدرع الحصان.", es="El escudo protegió al caballo.",
  pt="O escudo protegeu o cavalo.", de="Das Schild hat das Pferd geschützt.",
  tr="Kalkan atı korudu.", id="Perisai melindungi kuda itu.",
  ur="ڈھال نے گھوڑے کو بچا لیا۔", ms="Perisai melindungi kuda itu.",
  it="Lo scudo ha protetto il cavallo.", nl="Het schild beschermde het paard.")

# ---- Player profiles -------------------------------------------------------
s("playerProfile", "Label over the per-rider question level picker",
  fr="Niveau des questions", en="Question level", ar="مستوى الأسئلة",
  es="Nivel de las preguntas", pt="Nível das perguntas", de="Fragenniveau",
  tr="Soru seviyesi", id="Tingkat pertanyaan", ur="سوالات کا درجہ",
  ms="Tahap soalan", it="Livello delle domande", nl="Vragenniveau")

s("levelEasy", "Question level a rider plays at, chosen before the game",
  fr="Facile", en="Easy", ar="سهل", es="Fácil", pt="Fácil", de="Leicht",
  tr="Kolay", id="Mudah", ur="آسان", ms="Mudah", it="Facile", nl="Makkelijk")

s("levelIntermediate", "Question level a rider plays at, chosen before the game",
  fr="Intermédiaire", en="Intermediate", ar="متوسط", es="Intermedio",
  pt="Intermediário", de="Mittel", tr="Orta", id="Menengah", ur="درمیانہ",
  ms="Sederhana", it="Intermedio", nl="Gemiddeld")

s("levelExpert", "Question level a rider plays at, chosen before the game",
  fr="Expert", en="Expert", ar="خبير", es="Experto", pt="Especialista", de="Experte",
  tr="Uzman", id="Ahli", ur="ماہر", ms="Pakar", it="Esperto", nl="Expert")

# ---- Save migration --------------------------------------------------------
s("raceRulesUpdatedTitle", "Shown once when a pre-gait save is detected",
  fr="Les règles de course ont été améliorées",
  en="The race rules have been improved",
  ar="تم تحسين قواعد السباق",
  es="Las reglas de la carrera han mejorado",
  pt="As regras da corrida foram melhoradas",
  de="Die Rennregeln wurden verbessert",
  tr="Yarış kuralları geliştirildi",
  id="Aturan balapan telah ditingkatkan",
  ur="دوڑ کے قواعد بہتر کر دیے گئے",
  ms="Peraturan perlumbaan telah ditambah baik",
  it="Le regole della corsa sono state migliorate",
  nl="De racerregels zijn verbeterd")

s("raceRulesUpdatedBody", "Legacy save notice body",
  fr="Les règles ont changé : on pioche maintenant une carte, et sa valeur donne à la fois la distance et la difficulté. Ta progression, tes badges et tes achats sont conservés — seule la partie en cours ne peut pas reprendre avec les nouvelles règles.",
  en="The rules have changed: you now draw a card, and its value gives both the distance and the difficulty. Your progress, badges and purchases are kept — only the game in progress cannot resume under the new rules.",
  ar="تغيّرت القواعد: تسحب الآن بطاقة، وقيمتها تحدد المسافة والصعوبة معًا. تقدّمك وأوسمتك ومشترياتك محفوظة — الجولة الجارية وحدها لا يمكن استئنافها بالقواعد الجديدة.",
  es="Las reglas han cambiado: ahora robas una carta y su valor da a la vez la distancia y la dificultad. Tu progreso, tus insignias y tus compras se conservan; solo la partida en curso no puede continuar con las nuevas reglas.",
  pt="As regras mudaram: agora você puxa uma carta, e o valor dela dá ao mesmo tempo a distância e a dificuldade. Seu progresso, suas medalhas e suas compras são mantidos — só a partida em andamento não pode continuar com as novas regras.",
  de="Die Regeln haben sich geändert: Du ziehst jetzt eine Karte, und ihr Wert gibt zugleich Distanz und Schwierigkeit. Fortschritt, Abzeichen und Käufe bleiben erhalten — nur das laufende Spiel lässt sich mit den neuen Regeln nicht fortsetzen.",
  tr="Kurallar değişti: artık bir kart çekiyorsun ve kartın değeri hem mesafeyi hem zorluğu veriyor. İlerlemen, rozetlerin ve satın alımların korunuyor — yalnızca devam eden oyun yeni kurallarla sürdürülemiyor.",
  id="Aturannya berubah: sekarang kamu mengambil kartu, dan nilainya menentukan jarak sekaligus tingkat kesulitan. Progres, lencana, dan pembelianmu tetap tersimpan — hanya permainan yang sedang berjalan tidak bisa dilanjutkan dengan aturan baru.",
  ur="قواعد بدل گئے ہیں: اب آپ ایک کارڈ نکالتے ہیں، اور اس کی قیمت فاصلہ اور مشکل دونوں طے کرتی ہے۔ آپ کی پیش رفت، بیجز اور خریداری محفوظ ہیں — صرف جاری کھیل نئے قواعد کے ساتھ جاری نہیں رہ سکتا۔",
  ms="Peraturan telah berubah: anda kini mencabut kad, dan nilainya memberi jarak sekali gus tahap kesukaran. Kemajuan, lencana dan pembelian anda dikekalkan — hanya permainan yang sedang berjalan tidak dapat disambung dengan peraturan baharu.",
  it="Le regole sono cambiate: ora peschi una carta, e il suo valore dà insieme la distanza e la difficoltà. I tuoi progressi, i badge e gli acquisti restano — solo la partita in corso non può riprendere con le nuove regole.",
  nl="De regels zijn veranderd: je trekt nu een kaart, en de waarde bepaalt zowel de afstand als de moeilijkheid. Je voortgang, badges en aankopen blijven behouden — alleen het lopende spel kan niet verder met de nieuwe regels.")

s("startNewRace", "Button to start fresh after the rules change",
  fr="Commencer une nouvelle course", en="Start a new race",
  ar="ابدأ سباقًا جديدًا", es="Empezar una nueva carrera",
  pt="Começar uma nova corrida", de="Neues Rennen starten",
  tr="Yeni bir yarış başlat", id="Mulai balapan baru",
  ur="نئی دوڑ شروع کریں", ms="Mulakan perlumbaan baharu",
  it="Inizia una nuova corsa", nl="Start een nieuwe race")

# ---- Rules screen ----------------------------------------------------------
s("rulesTitle", "Title of the rules screen",
  fr="Les règles", en="The rules", ar="القواعد", es="Las reglas",
  pt="As regras", de="Die Regeln", tr="Kurallar", id="Aturan main",
  ur="قواعد", ms="Peraturan", it="Le regole", nl="De regels")

s("ruleGoalTitle", "Rules step 1 title: how the race is won",
  fr="Gagner la course", en="Winning the race", ar="الفوز بالسباق",
  es="Ganar la carrera", pt="Ganhar a corrida", de="Das Rennen gewinnen",
  tr="Yarışı kazanmak", id="Memenangi balapan", ur="دوڑ جیتنا",
  ms="Memenangi perlumbaan", it="Vincere la corsa", nl="De race winnen")

s("ruleGoalBody", "Rules step 1 body: bring 1, 2 or 4 horses to Mecca",
  fr="Chaque joueur mène quatre chevaux vers La Mecque, au centre du plateau. Avant la partie, la table choisit combien doivent y arriver : un seul pour une course rapide, deux pour une course en duo, les quatre pour la partie classique. Le premier joueur qui y parvient gagne.",
  en="Each player rides four horses towards Mecca, at the centre of the board. Before the game, the table chooses how many must get there: one for a quick race, two for a duo race, all four for the classic game. The first player to manage it wins.",
  ar="كل لاعب يقود أربعة خيول نحو مكة في وسط الرقعة. قبل اللعب تختار الطاولة كم منها يجب أن يصل: واحد لسباق سريع، اثنان لسباق ثنائي، والأربعة للعبة الكلاسيكية. يفوز أول لاعب يبلغ ذلك.",
  es="Cada jugador lleva cuatro caballos hacia La Meca, en el centro del tablero. Antes de la partida, la mesa elige cuántos deben llegar: uno para una carrera rápida, dos para una carrera en dúo, los cuatro para la partida clásica. Gana el primero que lo consigue.",
  pt="Cada jogador leva quatro cavalos até Meca, no centro do tabuleiro. Antes do jogo, a mesa escolhe quantos têm de chegar: um para uma corrida rápida, dois para uma corrida em dupla, os quatro para o jogo clássico. Ganha o primeiro que o conseguir.",
  de="Jeder Spieler führt vier Pferde nach Mekka, in die Mitte des Bretts. Vor dem Spiel wählt der Tisch, wie viele ankommen müssen: eines für ein schnelles Rennen, zwei für ein Duo-Rennen, alle vier für das klassische Spiel. Wer es zuerst schafft, gewinnt.",
  tr="Her oyuncu dört atını tahtanın ortasındaki Mekke'ye götürür. Oyundan önce masa kaç atın varması gerektiğini seçer: hızlı yarış için bir, ikili yarış için iki, klasik oyun için dördü. Bunu ilk başaran kazanır.",
  id="Setiap pemain menuntun empat kuda menuju Mekah, di tengah papan. Sebelum bermain, meja memilih berapa yang harus tiba: satu untuk balapan cepat, dua untuk balapan duo, keempatnya untuk permainan klasik. Pemain pertama yang berhasil menang.",
  ur="ہر کھلاڑی چار گھوڑے تختے کے مرکز، مکہ کی طرف لے جاتا ہے۔ کھیل سے پہلے میز طے کرتی ہے کہ کتنے پہنچنے چاہییں: تیز دوڑ کے لیے ایک، جوڑی دوڑ کے لیے دو، کلاسک کھیل کے لیے چاروں۔ جو پہلے کر لے وہ جیت جاتا ہے۔",
  ms="Setiap pemain membawa empat kuda ke Mekah, di tengah papan. Sebelum permainan, meja memilih berapa yang mesti tiba: satu untuk perlumbaan pantas, dua untuk perlumbaan duo, keempat-empatnya untuk permainan klasik. Pemain pertama yang berjaya menang.",
  it="Ogni giocatore conduce quattro cavalli verso la Mecca, al centro del tabellone. Prima della partita il tavolo scegli quanti devono arrivare: uno per una corsa rapida, due per una corsa in duo, tutti e quattro per la partita classica. Vince il primo che ci riesce.",
  nl="Elke speler brengt vier paarden naar Mekka, in het midden van het bord. Voor het spel kiest de tafel hoeveel er moeten aankomen: één voor een snelle race, twee voor een duorace, alle vier voor het klassieke spel. Wie het eerst zover komt, wint.")

s("ruleKnowledgeTitle", "Rules step title: the knowledge points",
  fr="Les points de savoir", en="Knowledge points", ar="نقاط المعرفة",
  es="Puntos de saber", pt="Pontos de saber", de="Wissenspunkte",
  tr="Bilgi puanları", id="Poin ilmu", ur="علم کے نکات",
  ms="Poin ilmu", it="Punti sapere", nl="Kennispunten")

s("ruleKnowledgeBody", "Rules step body: what the sparkle counter counts",
  fr="L'étoile du bandeau compte tes points de savoir : un par bonne réponse, et un de plus sur une case Connaissance. Ils ne font pas avancer ton cheval — ils disent ce que tu as appris, et départagent les joueurs si la partie s'arrête avant l'arrivée.",
  en="The sparkle in the bar counts your knowledge points: one for every right answer, and one more on a Knowledge square. They do not move your horse — they say what you have learnt, and they separate the players if the game stops before anyone arrives.",
  ar="النجمة في الشريط تعدّ نقاط معرفتك: نقطة لكل إجابة صحيحة، ونقطة إضافية على مربع المعرفة. لا تحرك حصانك — بل تقول ما تعلمته، وتفصل بين اللاعبين إذا انتهت اللعبة قبل الوصول.",
  es="La estrella de la barra cuenta tus puntos de saber: uno por cada respuesta correcta y uno más en una casilla de Conocimiento. No hacen avanzar a tu caballo — dicen lo que has aprendido y desempatan a los jugadores si la partida termina antes de la llegada.",
  pt="A estrela da barra conta os teus pontos de saber: um por cada resposta certa e um a mais numa casa de Conhecimento. Não fazem o cavalo avançar — dizem o que aprendeste e desempatam os jogadores se o jogo acabar antes da chegada.",
  de="Der Stern in der Leiste zählt deine Wissenspunkte: einen für jede richtige Antwort und einen weiteren auf einem Wissensfeld. Sie bewegen dein Pferd nicht — sie sagen, was du gelernt hast, und entscheiden zwischen den Spielern, wenn das Spiel vor der Ankunft endet.",
  tr="Çubuktaki yıldız bilgi puanlarını sayar: her doğru cevap için bir, Bilgi karesinde bir tane daha. Atını ilerletmezler — ne öğrendiğini söyler ve oyun varıştan önce biterse oyuncuları ayırırlar.",
  id="Bintang di bilah menghitung poin ilmumu: satu untuk setiap jawaban benar, dan satu lagi di petak Pengetahuan. Poin itu tidak menggerakkan kudamu — ia menyatakan apa yang kamu pelajari, dan memisahkan para pemain bila permainan berhenti sebelum ada yang tiba.",
  ur="پٹی کا ستارہ تمہارے علم کے نکات گنتا ہے: ہر درست جواب پر ایک، اور علم کے خانے پر ایک اضافی۔ یہ تمہارا گھوڑا آگے نہیں بڑھاتے — یہ بتاتے ہیں کہ تم نے کیا سیکھا، اور اگر کھیل پہنچنے سے پہلے رک جائے تو کھلاڑیوں کے درمیان فیصلہ کرتے ہیں۔",
  ms="Bintang pada bar mengira poin ilmumu: satu bagi setiap jawapan betul, dan satu lagi di petak Pengetahuan. Ia tidak menggerakkan kudamu — ia menyatakan apa yang kamu pelajari, dan memisahkan pemain jika permainan berhenti sebelum sesiapa tiba.",
  it="La stella nella barra conta i tuoi punti sapere: uno per ogni risposta esatta e uno in più su una casella Conoscenza. Non fanno avanzare il cavallo — dicono che cosa hai imparato e separano i giocatori se la partita finisce prima dell'arrivo.",
  nl="De ster in de balk telt je kennispunten: één voor elk goed antwoord en één extra op een Kennisvakje. Ze laten je paard niet vooruit — ze zeggen wat je hebt geleerd en scheiden de spelers als het spel stopt voordat iemand aankomt.")

s("ruleSpecialCellsTitle", "Rules step title: the special squares",
  fr="Les cases spéciales", en="The special squares", ar="المربعات الخاصة",
  es="Las casillas especiales", pt="As casas especiais",
  de="Die Sonderfelder", tr="Özel kareler", id="Petak khusus",
  ur="خاص خانے", ms="Petak khas", it="Le caselle speciali",
  nl="De speciale vakjes")

s("ruleSpecialCellsBody", "Rules step body: oasis, knowledge, challenge, shortcut, wisdom",
  fr="Le circuit choisi porte des cases qui font quelque chose, les mêmes dans ses quatre quarts : l'Oasis protège des captures, la Connaissance donne un point de savoir, le Défi propose une question plus dure pour +2 galops, le Raccourci une question dure pour couper devant, et la Sagesse offre un fait à garder. Un Défi ou un Raccourci raté ne coûte que le bonus : ton cheval reste où il est.",
  en="The circuit you chose carries squares that do something, the same ones in each of its four quarters: the Oasis shields from capture, Knowledge gives a knowledge point, the Challenge offers a harder question for +2 gallops, the Shortcut a hard question to cut ahead, and Wisdom gives a fact to keep. A failed Challenge or Shortcut costs only the bonus: your horse stays where it is.",
  ar="المسار الذي اخترته يحمل مربعات فاعلة، نفسها في أرباعه الأربعة: الواحة تحمي من الأسر، والمعرفة تمنح نقطة معرفة، والتحدي يعرض سؤالًا أصعب مقابل ركضتين إضافيتين، والاختصار سؤالًا صعبًا للتقدم، والحكمة تمنح فائدة تحتفظ بها. فشل التحدي أو الاختصار يكلفك المكافأة فقط: يبقى حصانك في مكانه.",
  es="El circuito que elegiste tiene casillas que hacen algo, las mismas en sus cuatro cuartos: el Oasis protege de las capturas, Conocimiento da un punto de saber, el Desafío ofrece una pregunta más difícil por +2 galopes, el Atajo una pregunta difícil para adelantarse, y Sabiduría regala un dato para guardar. Fallar un Desafío o un Atajo solo cuesta el bono: tu caballo se queda donde está.",
  pt="O percurso que escolheste tem casas que fazem algo, as mesmas nos seus quatro quartos: o Oásis protege das capturas, Conhecimento dá um ponto de saber, o Desafio propõe uma pergunta mais difícil por +2 galopes, o Atalho uma pergunta difícil para cortar à frente, e Sabedoria oferece um facto para guardar. Falhar um Desafio ou um Atalho custa só o bónus: o teu cavalo fica onde está.",
  de="Die gewählte Strecke trägt Felder, die etwas tun, in allen vier Vierteln dieselben: die Oase schützt vor Schlagen, Wissen gibt einen Wissenspunkt, die Herausforderung bietet eine schwerere Frage für +2 Galopps, die Abkürzung eine schwere Frage, um vorzurücken, und Weisheit schenkt eine Erkenntnis. Eine verlorene Herausforderung oder Abkürzung kostet nur den Bonus: dein Pferd bleibt stehen.",
  tr="Seçtiğin parkurda bir şey yapan kareler var, dört çeyreğinde de aynıları: Vaha yakalanmaktan korur, Bilgi bir bilgi puanı verir, Meydan okuma +2 dörtnal için daha zor bir soru sunar, Kısayol öne geçmek için zor bir soru, Hikmet ise saklayacağın bir bilgi verir. Kaybedilen bir Meydan okuma ya da Kısayol yalnızca bonusa mal olur: atın yerinde kalır.",
  id="Lintasan yang kamu pilih memuat petak yang berfungsi, sama di keempat kuadrannya: Oase melindungi dari tangkapan, Pengetahuan memberi satu poin ilmu, Tantangan menawarkan soal lebih sulit untuk +2 derap, Jalan Pintas soal sulit untuk memotong ke depan, dan Hikmah memberi satu fakta untuk disimpan. Tantangan atau Jalan Pintas yang gagal hanya menghilangkan bonusnya: kudamu tetap di tempat.",
  ur="تمہارا منتخب راستہ ایسے خانے رکھتا ہے جو کچھ کرتے ہیں، اس کے چاروں حصوں میں وہی: نخلستان پکڑے جانے سے بچاتا ہے، علم ایک نکتہ دیتا ہے، چیلنج +2 سرپٹ کے لیے مشکل سوال پیش کرتا ہے، شارٹ کٹ آگے نکلنے کے لیے مشکل سوال، اور حکمت ایک بات دیتی ہے جو تم رکھ سکو۔ ناکام چیلنج یا شارٹ کٹ صرف بونس کا نقصان ہے: تمہارا گھوڑا وہیں رہتا ہے۔",
  ms="Laluan yang kamu pilih membawa petak yang berfungsi, sama di keempat sukuannya: Oasis melindungi daripada tangkapan, Pengetahuan memberi satu poin ilmu, Cabaran menawarkan soalan lebih sukar untuk +2 derap, Jalan Singkat soalan sukar untuk memotong ke depan, dan Hikmah memberi satu fakta untuk disimpan. Cabaran atau Jalan Singkat yang gagal hanya merugikan bonusnya: kudamu kekal di tempatnya.",
  it="Il percorso che hai scelto porta caselle che fanno qualcosa, le stesse nei suoi quattro quarti: l'Oasi protegge dalle catture, Conoscenza dà un punto sapere, la Sfida propone una domanda più difficile per +2 galoppi, la Scorciatoia una domanda difficile per passare avanti, e Saggezza offre un fatto da conservare. Una Sfida o una Scorciatoia mancata costa solo il bonus: il tuo cavallo resta dov'è.",
  nl="Het gekozen parcours heeft vakjes die iets doen, in elk van zijn vier kwarten dezelfde: de Oase beschermt tegen slaan, Kennis geeft een kennispunt, de Uitdaging biedt een moeilijker vraag voor +2 galops, de Kortere Weg een moeilijke vraag om voor te komen, en Wijsheid geeft een feit om te bewaren. Een mislukte Uitdaging of Kortere Weg kost alleen de bonus: je paard blijft staan.")

s("ruleDrawCardTitle", "Rules step 1 title",
  fr="Pioche une carte", en="Draw a card", ar="اسحب بطاقة",
  es="Roba una carta", pt="Puxe uma carta", de="Zieh eine Karte",
  tr="Bir kart çek", id="Ambil kartu", ur="ایک کارڈ نکالیں",
  ms="Cabut sekeping kad", it="Pesca una carta", nl="Trek een kaart")

s("ruleDrawCardBody", "Rules step: the card turns over onto its stake",
  fr="À ton tour, pioche une carte. Elle se retourne sur son enjeu — « Carte à 5 galops » — puis sa question s'ouvre, toujours à ton niveau, choisi au départ : facile, intermédiaire ou expert. Tu sais donc ce que vaut une bonne réponse avant de répondre.",
  en="On your turn, draw a card. It turns over onto its stake — \"A 5-gallop card\" — and then its question opens, always at your own level, chosen before the game: easy, intermediate or expert. So you know what a right answer is worth before you answer.",
  ar="في دورك، اسحب بطاقة. تنقلب على قيمتها — «بطاقة بخمس ركضات» — ثم يُفتح سؤالها، دائمًا على مستواك المختار قبل اللعب: سهل أو متوسط أو خبير. فتعرف قيمة الإجابة الصحيحة قبل أن تجيب.",
  es="En tu turno, roba una carta. Se vuelve mostrando su valor — «Carta de 5 galopes» — y luego se abre su pregunta, siempre a tu nivel, elegido al principio: fácil, intermedio o experto. Así sabes lo que vale una respuesta correcta antes de responder.",
  pt="Na tua vez, tira uma carta. Ela vira mostrando o seu valor — «Carta de 5 galopes» — e depois abre a pergunta, sempre ao teu nível, escolhido no início: fácil, intermédio ou especialista. Assim sabes o que vale uma resposta certa antes de responder.",
  de="Zieh in deinem Zug eine Karte. Sie dreht sich auf ihren Wert — „Karte über 5 Galopps\" — dann öffnet sich ihre Frage, immer auf deiner Stufe, die du vorher gewählt hast: leicht, mittel oder Experte. Du weißt also vorher, was eine richtige Antwort wert ist.",
  tr="Sıran gelince bir kart çek. Kart değerini göstererek dönüyor — «5 dörtnallık kart» — sonra sorusu açılır, her zaman başta seçtiğin düzeyde: kolay, orta ya da uzman. Yani doğru cevabın değerini cevaplamadan önce bilirsin.",
  id="Pada giliranmu, ambil satu kartu. Kartu berbalik memperlihatkan nilainya — «Kartu 5 derap» — lalu pertanyaannya terbuka, selalu di tingkatmu, yang dipilih sejak awal: mudah, menengah, atau ahli. Jadi kamu tahu nilai jawaban benar sebelum menjawab.",
  ur="اپنی باری پر ایک کارڈ نکالو۔ وہ اپنی قیمت دکھاتے ہوئے پلٹتا ہے — «5 سرپٹ کا کارڈ» — پھر اس کا سوال کھلتا ہے، ہمیشہ تمہارے منتخب کردہ درجے پر: آسان، درمیانہ یا ماہر۔ یوں تم جواب دینے سے پہلے جان لیتے ہو کہ درست جواب کی قیمت کیا ہے۔",
  ms="Pada pusinganmu, cabut satu kad. Kad itu terbalik menunjukkan nilainya — «Kad 5 derap» — kemudian soalannya terbuka, selalu pada tahapmu, yang dipilih pada mulanya: mudah, sederhana atau pakar. Jadi kamu tahu nilai jawapan betul sebelum menjawab.",
  it="Al tuo turno pesca una carta. Si gira sul suo valore — «Carta da 5 galoppi» — poi si apre la domanda, sempre al tuo livello, scelto all'inizio: facile, intermedio o esperto. Sai quindi quanto vale una risposta esatta prima di rispondere.",
  nl="Pak op je beurt een kaart. Ze draait om op haar waarde — \"Kaart van 5 galops\" — en dan opent haar vraag, altijd op jouw niveau, vooraf gekozen: makkelijk, gemiddeld of expert. Je weet dus wat een goed antwoord waard is voordat je antwoordt.")

s("ruleAnswerToAdvanceTitle", "Rules step 2 title",
  fr="Réponds pour avancer", en="Answer to advance", ar="أجب لتتقدم",
  es="Responde para avanzar", pt="Responda para avançar",
  de="Antworte, um vorzurücken", tr="İlerlemek için cevapla",
  id="Jawab untuk maju", ur="آگے بڑھنے کے لیے جواب دیں",
  ms="Jawab untuk maju", it="Rispondi per avanzare", nl="Antwoord om vooruit te gaan")

s("ruleAnswerToAdvanceBody", "Rules step: a right answer wins the card's gallops",
  fr="Une bonne réponse te fait gagner les galops de la carte : un galop, une case. Choisis alors le cheval qui les prend — touche-le pour voir où il arriverait, puis glisse-le jusqu'à sa case dorée. Le dépôt vaut validation : rien ne bouge avant, rien ne demande de confirmer après. Une mauvaise réponse laisse tout sur place : tu ne recules jamais.",
  en="A right answer wins you the card's gallops: one gallop, one square. Then choose the horse that takes them — touch it to see where it would land, then drag it onto its gold square. The drop is the move: nothing moves before it, nothing asks to confirm after it. A wrong answer moves nothing at all: you never go backwards.",
  ar="الإجابة الصحيحة تكسبك ركضات البطاقة: ركضة واحدة، مربع واحد. اختر الحصان الذي يأخذها — المسه لترى أين سيحل، ثم اسحبه إلى مربعه الذهبي. الإفلات هو الحركة: لا شيء يتحرك قبله ولا شيء يطلب تأكيدًا بعده. الإجابة الخاطئة لا تحرك شيئًا: لا تتراجع أبدًا.",
  es="Una respuesta correcta te gana los galopes de la carta: un galope, una casilla. Elige entonces el caballo que los toma — tócalo para ver dónde llegaría y arrástralo a su casilla dorada. Soltarlo es la jugada: nada se mueve antes, nada pide confirmar después. Una respuesta incorrecta no mueve nada: nunca retrocedes.",
  pt="Uma resposta certa dá-te os galopes da carta: um galope, uma casa. Escolhe então o cavalo que os leva — toca-lhe para ver onde chegaria e arrasta-o até à sua casa dourada. Largar é jogar: nada se move antes, nada pede confirmação depois. Uma resposta errada não move nada: nunca recuas.",
  de="Eine richtige Antwort gewinnt die Galopps der Karte: ein Galopp, ein Feld. Wähle dann das Pferd, das sie nimmt — tippe es an, um sein Ziel zu sehen, und zieh es auf sein goldenes Feld. Das Ablegen ist der Zug: davor bewegt sich nichts, danach fragt nichts nach einer Bestätigung. Eine falsche Antwort bewegt nichts: du gehst nie zurück.",
  tr="Doğru cevap kartın dörtnallarını kazandırır: bir dörtnal, bir kare. Sonra onları alacak atı seç — nereye varacağını görmek için dokun, ardından altın karesine sürükle. Bırakmak hamledir: öncesinde hiçbir şey oynamaz, sonrasında onay istenmez. Yanlış cevap hiçbir şeyi oynatmaz: asla geri gitmezsin.",
  id="Jawaban benar memberimu derap kartu itu: satu derap, satu petak. Lalu pilih kuda yang mengambilnya — sentuh untuk melihat ke mana ia akan mendarat, lalu geser ke petak emasnya. Melepaskannya adalah langkahnya: tak ada yang bergerak sebelumnya, tak ada konfirmasi sesudahnya. Jawaban salah tidak menggerakkan apa pun: kamu tak pernah mundur.",
  ur="درست جواب تمہیں کارڈ کے سرپٹ دلاتا ہے: ایک سرپٹ، ایک خانہ۔ پھر وہ گھوڑا چنو جو انہیں لے — دیکھنے کے لیے چھوؤ کہ وہ کہاں پہنچے گا، پھر اسے اس کے سنہری خانے تک کھینچو۔ چھوڑنا ہی چال ہے: اس سے پہلے کچھ نہیں ہلتا، بعد میں کوئی تصدیق نہیں مانگی جاتی۔ غلط جواب کچھ نہیں ہلاتا: تم کبھی پیچھے نہیں ہٹتے۔",
  ms="Jawapan betul memberimu derap kad itu: satu derap, satu petak. Kemudian pilih kuda yang mengambilnya — sentuh untuk melihat ke mana ia akan mendarat, lalu leretkannya ke petak emasnya. Melepaskannya ialah langkahnya: tiada apa bergerak sebelumnya, tiada pengesahan selepasnya. Jawapan salah tidak menggerakkan apa-apa: kamu tidak pernah mengundur.",
  it="Una risposta esatta ti fa guadagnare i galoppi della carta: un galoppo, una casella. Scegli poi il cavallo che li prende — toccalo per vedere dove arriverebbe, poi trascinalo sulla sua casella dorata. Lasciarlo è la mossa: nulla si muove prima, nulla chiede conferma dopo. Una risposta sbagliata non muove nulla: non torni mai indietro.",
  nl="Een goed antwoord wint je de galops van de kaart: één galop, één vakje. Kies dan het paard dat ze neemt — tik het aan om te zien waar het zou landen en sleep het naar zijn gouden vakje. Het neerzetten is de zet: daarvoor beweegt niets, daarna vraagt niets om bevestiging. Een fout antwoord beweegt niets: je gaat nooit achteruit.")

s("ruleEscalierTitle", "Rules step 3 title",
  fr="L'escalier vers La Mecque", en="The escalier to Mecca",
  ar="السلّم إلى مكة", es="La escalera hacia La Meca",
  pt="A escada até Meca", de="Die Treppe nach Mekka",
  tr="Mekke'ye çıkan merdiven", id="Tangga menuju Makkah",
  ur="مکہ کی طرف زینہ", ms="Tangga ke Makkah",
  it="La scala verso La Mecca", nl="De trap naar Mekka")

s("ruleEscalierBody", "Rules step 3 body",
  fr="Après un tour complet du plateau, ton cheval monte les cinq marches de son escalier jusqu'à La Mecque. Là, personne ne peut plus le rattraper.",
  en="After a full lap of the board, your horse climbs the five steps of its escalier to Mecca. Once there, no one can catch it.",
  ar="بعد دورة كاملة حول اللوحة، يصعد حصانك درجات سلّمه الخمس إلى مكة. وهناك لا يستطيع أحد اللحاق به.",
  es="Tras una vuelta completa al tablero, tu caballo sube los cinco escalones de su escalera hacia La Meca. Allí ya nadie puede alcanzarlo.",
  pt="Depois de uma volta completa no tabuleiro, seu cavalo sobe os cinco degraus da sua escada até Meca. Ali ninguém mais o alcança.",
  de="Nach einer vollen Runde steigt dein Pferd die fünf Stufen seiner Treppe nach Mekka hinauf. Dort kann es niemand mehr einholen.",
  tr="Tahtada tam bir tur attıktan sonra atın kendi merdiveninin beş basamağını çıkıp Mekke'ye ulaşır. Orada kimse ona yetişemez.",
  id="Setelah satu putaran penuh, kudamu menaiki lima anak tangganya menuju Makkah. Di sana tidak ada yang bisa menyusulnya.",
  ur="پورے چکر کے بعد آپ کا گھوڑا اپنے زینے کی پانچ سیڑھیاں چڑھ کر مکہ پہنچتا ہے۔ وہاں اسے کوئی نہیں پکڑ سکتا۔",
  ms="Selepas satu pusingan penuh, kuda anda menaiki lima anak tangga tangganya ke Makkah. Di situ tiada siapa boleh mengejarnya.",
  it="Dopo un giro completo del tabellone, il tuo cavallo sale i cinque gradini della sua scala verso La Mecca. Lì nessuno può più raggiungerlo.",
  nl="Na een volledige ronde beklimt je paard de vijf treden van zijn trap naar Mekka. Daar kan niemand het nog inhalen.")

s("ruleExitTitle", "Rules step: leaving the stable on a 6",
  fr="Sortir de l'écurie", en="Leaving the stable", ar="الخروج من الإسطبل",
  es="Salir del establo", pt="Sair do estábulo", de="Den Stall verlassen",
  tr="Ahırdan çıkmak", id="Keluar dari kandang", ur="اصطبل سے نکلنا",
  ms="Keluar dari kandang", it="Uscire dalla stalla", nl="De stal verlaten")

s("ruleExitBody", "Rules step: the first horse is already out, the others need a 6",
  fr="Chaque joueur a quatre chevaux, et le premier est déjà sur sa case de départ : tu joues dès la première carte, sans attendre. Les trois autres sortent de l'écurie sur un 6 — réponds juste et le cheval se place sur la case de départ. Deux de tes chevaux ne peuvent jamais partager une case : un cheval à toi posé sur ta case de départ en bloque la sortie jusqu'à ce qu'il avance.",
  en="Each player has four horses, and the first already stands on its start square: you play from the very first card, with nothing to wait for. The other three leave the stable on a 6 — answer right and the horse takes the start square. Two of your horses can never share a square: one of yours sitting on your start square keeps the gate shut until it moves on.",
  ar="لكل لاعب أربعة خيول، والأول يقف أصلًا على مربع انطلاقه: تلعب من البطاقة الأولى دون انتظار. تخرج الثلاثة الأخرى من الإسطبل على 6 — أجب صحيحًا فيحل الحصان على مربع الانطلاق. لا يمكن لحصانين لك أن يتشاركا مربعًا: حصانك الواقف على مربع انطلاقك يغلق البوابة حتى يتقدم.",
  es="Cada jugador tiene cuatro caballos, y el primero ya está en su casilla de salida: juegas desde la primera carta, sin esperar. Los otros tres salen del establo con un 6 — acierta y el caballo ocupa la casilla de salida. Dos de tus caballos nunca comparten casilla: uno tuyo sobre tu casilla de salida cierra la puerta hasta que avance.",
  pt="Cada jogador tem quatro cavalos, e o primeiro já está na sua casa de partida: jogas desde a primeira carta, sem esperar. Os outros três saem do estábulo com um 6 — acerta e o cavalo ocupa a casa de partida. Dois dos teus cavalos nunca partilham uma casa: um teu na casa de partida fecha o portão até avançar.",
  de="Jeder Spieler hat vier Pferde, und das erste steht schon auf seinem Startfeld: du spielst ab der ersten Karte, ohne zu warten. Die anderen drei verlassen den Stall bei einer 6 — antworte richtig, und das Pferd nimmt das Startfeld. Zwei deiner Pferde teilen niemals ein Feld: eines von dir auf deinem Startfeld hält das Tor zu, bis es weiterzieht.",
  tr="Her oyuncunun dört atı var ve ilki zaten başlangıç karesinde: ilk karttan itibaren oynarsın, bekleyecek bir şey yok. Diğer üçü 6 ile ahırdan çıkar — doğru cevap ver, at başlangıç karesine yerleşir. İki atın asla aynı kareyi paylaşmaz: başlangıç karende duran atın, ilerleyene kadar kapıyı kapalı tutar.",
  id="Setiap pemain punya empat kuda, dan yang pertama sudah berada di petak awalnya: kamu bermain sejak kartu pertama, tanpa menunggu. Tiga lainnya keluar dari kandang dengan angka 6 — jawab benar dan kuda itu menempati petak awal. Dua kudamu tidak pernah berbagi satu petak: kudamu yang berdiri di petak awal menutup gerbangnya sampai ia maju.",
  ur="ہر کھلاڑی کے چار گھوڑے ہیں، اور پہلا پہلے ہی اپنے آغاز کے خانے پر ہے: تم پہلی ہی کارڈ سے کھیلتے ہو، انتظار کے بغیر۔ باقی تین 6 پر اصطبل سے نکلتے ہیں — درست جواب دو اور گھوڑا آغاز کے خانے پر آ جاتا ہے۔ تمہارے دو گھوڑے کبھی ایک خانہ نہیں بانٹ سکتے: تمہارے آغاز کے خانے پر بیٹھا گھوڑا دروازہ بند رکھتا ہے جب تک آگے نہ بڑھے۔",
  ms="Setiap pemain ada empat kuda, dan yang pertama sudah berada di petak mulanya: kamu bermain dari kad pertama, tanpa menunggu. Tiga yang lain keluar dari kandang dengan angka 6 — jawab betul dan kuda itu mengambil petak mula. Dua kudamu tidak boleh berkongsi satu petak: kudamu yang berada di petak mula menutup pintunya sehingga ia bergerak.",
  it="Ogni giocatore ha quattro cavalli, e il primo è già sulla sua casella di partenza: giochi dalla prima carta, senza attendere. Gli altri tre escono dalla stalla con un 6 — rispondi bene e il cavallo prende la casella di partenza. Due dei tuoi cavalli non condividono mai una casella: uno dei tuoi fermo sulla casella di partenza tiene chiuso il cancello finché non avanza.",
  nl="Elke speler heeft vier paarden, en het eerste staat al op zijn startvakje: je speelt vanaf de eerste kaart, zonder te wachten. De andere drie verlaten de stal met een 6 — antwoord goed en het paard neemt het startvakje. Twee van je paarden delen nooit een vakje: een eigen paard op je startvakje houdt de poort dicht tot het verder rijdt.")

s("ruleSixTitle", "Rules step: a 6 grants another draw",
  fr="Le 6 fait rejouer", en="A 6 plays again", ar="الرقم 6 يعيد اللعب",
  es="El 6 repite turno", pt="O 6 joga de novo", de="Die 6 zieht noch einmal",
  tr="6 yeniden oynatır", id="Angka 6 main lagi", ur="6 دوبارہ کھیل",
  ms="6 bermain lagi", it="Il 6 fa rigiocare", nl="Een 6 speelt opnieuw")

s("ruleSixBody", "Rules step: a 6 replays, exactly as on the die",
  fr="Comme au dé : quand tu pioches un 6, tu rejoues après ton tour, que ta réponse soit bonne ou non.",
  en="Just as on the die: draw a 6 and you play again after your turn, whether your answer was right or wrong.",
  ar="كما مع حجر النرد: إذا سحبت 6 تلعب مرة أخرى بعد دورك، صحّت إجابتك أو أخطأت.",
  es="Como con el dado: si sacas un 6, vuelves a jugar después de tu turno, aciertes o no.",
  pt="Como no dado: se tirares um 6, jogas outra vez depois da tua vez, tenhas acertado ou não.",
  de="Wie beim Würfel: Ziehst du eine 6, kommst du nach deinem Zug noch einmal dran — richtig geantwortet oder nicht.",
  tr="Zardaki gibi: 6 çekersen, cevabın doğru ya da yanlış olsun, turundan sonra yeniden oynarsın.",
  id="Seperti pada dadu: bila kamu menarik 6, kamu bermain lagi setelah giliranmu, benar atau salah jawabanmu.",
  ur="پانسے کی طرح: اگر تم 6 نکالو تو اپنی باری کے بعد دوبارہ کھیلتے ہو، جواب درست ہو یا غلط۔",
  ms="Seperti pada dadu: jika kamu mencabut 6, kamu bermain lagi selepas pusinganmu, betul atau salah jawapanmu.",
  it="Come col dado: se peschi un 6, giochi di nuovo dopo il tuo turno, che la risposta sia esatta o no.",
  nl="Net als bij de dobbelsteen: trek je een 6, dan speel je na je beurt nog eens, goed of fout geantwoord.")

s("ruleCaptureTitle", "Rules step 4 title",
  fr="Capturer et renvoyer", en="Capture and send home", ar="الأسر والإعادة",
  es="Capturar y enviar a casa", pt="Capturar e mandar de volta",
  de="Schlagen und heimschicken", tr="Yakala ve ahıra yolla",
  id="Menangkap dan memulangkan", ur="پکڑیں اور واپس بھیجیں",
  ms="Menangkap dan menghantar pulang", it="Cattura e rimanda a casa",
  nl="Slaan en naar huis sturen")

s("ruleCaptureBody", "Rules step 4 body: a capture sends the horse home and pays twenty",
  fr="Arriver exactement sur un cheval adverse le renvoie tranquillement à son écurie — sauf si la case est une oasis ou si ce cheval porte un bouclier du savoir. La capture se paie : ton cheval bondit aussitôt de 20 galops. Un cheval qui sort de l\'écurie capture toujours sur sa case de départ.",
  en="Landing exactly on an opponent\'s horse sends it calmly back to its stable — unless the square is an oasis, or that horse carries a knowledge shield. A capture pays: your horse bounds 20 gallops forward at once. A horse leaving its stable always captures on its start square.",
  ar="الوصول تمامًا إلى حصان الخصم يعيده بهدوء إلى إسطبله — إلا إذا كان المربع واحة أو كان ذلك الحصان يحمل درع المعرفة. والأسر يُكافأ: يقفز حصانك فورًا 20 ركضة. والحصان الخارج من إسطبله يأسر دائمًا على مربع انطلاقه.",
  es="Caer exactamente sobre el caballo de un rival lo devuelve con calma a su establo, salvo que la casilla sea un oasis o ese caballo lleve un escudo del saber. La captura se paga: tu caballo salta al instante 20 galopes. Un caballo que sale del establo siempre captura en su casilla de salida.",
  pt="Cair exatamente sobre o cavalo de um adversário o manda calmamente de volta ao estábulo — a menos que a casa seja um oásis ou que o cavalo tenha um escudo do saber. A captura paga: o seu cavalo salta na hora 20 galopes. Um cavalo que sai do estábulo sempre captura na sua casa de partida.",
  de="Wer genau auf dem Pferd eines Gegners landet, schickt es ruhig in seinen Stall zurück — außer das Feld ist eine Oase oder das Pferd trägt einen Wissensschild. Ein Schlag zahlt sich aus: Dein Pferd springt sofort 20 Galopp vor. Ein Pferd, das den Stall verlässt, schlägt auf seinem Startfeld immer.",
  tr="Rakibin atının bulunduğu kareye tam olarak konmak onu sakince ahırına yollar — kare bir vaha değilse ya da o at bir bilgi kalkanı taşımıyorsa. Yakalamak ödüllendirilir: atın hemen 20 dörtnal ileri sıçrar. Ahırdan çıkan bir at başlangıç karesinde her zaman yakalar.",
  id="Mendarat tepat di kuda lawan mengirimnya kembali dengan tenang ke kandang — kecuali petaknya oasis, atau kuda itu membawa perisai pengetahuan. Menangkap ada imbalannya: kudamu langsung melompat 20 lompatan. Kuda yang keluar dari kandang selalu menangkap di petak start-nya.",
  ur="حریف کے گھوڑے پر بالکل ٹھیک پہنچنا اسے سکون سے اس کے اصطبل واپس بھیج دیتا ہے — سوائے اس کے کہ خانہ نخلستان ہو یا وہ گھوڑا علم کی ڈھال رکھتا ہو۔ پکڑنے کا انعام ہے: آپ کا گھوڑا فوراً 20 سرپٹ آگے چھلانگ لگاتا ہے۔ اصطبل سے نکلنے والا گھوڑا اپنے شروعاتی خانے پر ہمیشہ پکڑتا ہے۔",
  ms="Mendarat tepat pada kuda lawan menghantarnya pulang dengan tenang ke kandang — melainkan petak itu oasis, atau kuda itu membawa perisai ilmu. Tangkapan ada ganjarannya: kuda anda melompat 20 lompatan serta-merta. Kuda yang keluar dari kandang sentiasa menangkap di petak permulaannya.",
  it="Arrivare esattamente sul cavallo di un avversario lo rimanda con calma alla sua stalla, a meno che la casella sia un\'oasi o quel cavallo porti uno scudo del sapere. La cattura si paga: il tuo cavallo balza subito di 20 galoppi. Un cavallo che esce dalla stalla cattura sempre sulla sua casella di partenza.",
  nl="Precies op het paard van een tegenstander landen stuurt het rustig terug naar de stal — tenzij het vakje een oase is of dat paard een kennisschild draagt. Slaan loont: je paard springt meteen 20 galop vooruit. Een paard dat de stal verlaat, slaat altijd op zijn startvak.")

s("ruleStreakTitle", "Rules step 5 title",
  fr="La série de bonnes réponses", en="The streak of right answers",
  ar="سلسلة الإجابات الصحيحة", es="La serie de respuestas correctas",
  pt="A série de respostas certas", de="Die Serie richtiger Antworten",
  tr="Doğru cevap serisi", id="Rentetan jawaban benar",
  ur="درست جوابات کا سلسلہ", ms="Rentetan jawapan betul",
  it="La serie di risposte esatte", nl="De reeks goede antwoorden")

s("ruleStreakBody", "Rules step 5 body",
  fr="Trois bonnes réponses d'affilée offrent un bouclier, cinq le Grand Galop et dix un badge de maîtrise. Le Grand Galop se dépense tout seul, et seulement quand ses +2 galops suffisent à franchir l'arrivée. Les bonus s'obtiennent uniquement par la connaissance.",
  en="Three correct answers in a row earn a shield, five the Grand Gallop, and ten a mastery badge. The Grand Gallop spends itself, and only when its +2 gallops are enough to reach the finish. Bonuses come from knowledge alone.",
  ar="ثلاث إجابات صحيحة متتالية تمنح درعًا، وخمس تمنح الركض الكبير، وعشر تمنح شارة إتقان. يُصرف الركض الكبير تلقائيًا، وفقط حين تكفي ركضتاه الإضافيتان لبلوغ النهاية. المكافآت تأتي من المعرفة وحدها.",
  es="Tres respuestas correctas seguidas dan un escudo, cinco el Gran Galope y diez una insignia de maestría. El Gran Galope se gasta solo, y únicamente cuando sus +2 galopes bastan para llegar a la meta. Las bonificaciones vienen solo del conocimiento.",
  pt="Três respostas certas seguidas dão um escudo, cinco o Grande Galope e dez uma medalha de maestria. O Grande Galope é gasto sozinho, e só quando seus +2 galopes bastam para chegar ao fim. Os bônus vêm apenas do conhecimento.",
  de="Drei richtige Antworten hintereinander bringen einen Schild, fünf den Großen Galopp und zehn ein Meisterabzeichen. Der Große Galopp wird von selbst eingesetzt, und nur wenn seine +2 Galopps zum Ziel reichen. Boni kommen allein aus Wissen.",
  tr="Üst üste üç doğru cevap bir kalkan, beş Büyük Dörtnal, on ise ustalık rozeti kazandırır. Büyük Dörtnal kendiliğinden harcanır ve yalnızca +2 dörtnalı bitişe ulaşmaya yettiğinde. Bonuslar yalnızca bilgiden gelir.",
  id="Tiga jawaban benar berturut-turut memberi perisai, lima memberi Grand Galop, dan sepuluh memberi lencana penguasaan. Grand Galop terpakai sendiri, dan hanya bila +2 derapnya cukup untuk mencapai garis akhir. Bonus hanya datang dari pengetahuan.",
  ur="لگاتار تین درست جواب ایک ڈھال دیتے ہیں، پانچ گرینڈ گیلپ اور دس مہارت کا بیج۔ گرینڈ گیلپ خود خرچ ہوتا ہے، اور صرف تب جب اس کے +2 سرپٹ اختتام تک پہنچنے کے لیے کافی ہوں۔ بونس صرف علم سے ملتے ہیں۔",
  ms="Tiga jawapan betul berturut-turut memberi perisai, lima memberi Grand Galop, dan sepuluh lencana penguasaan. Grand Galop dibelanjakan sendiri, dan hanya apabila +2 derapnya cukup untuk sampai ke penamat. Bonus datang daripada pengetahuan sahaja.",
  it="Tre risposte giuste di fila danno uno scudo, cinque il Gran Galoppo e dieci un distintivo di maestria. Il Gran Galoppo si spende da solo, e solo quando i suoi +2 galoppi bastano a tagliare il traguardo. I bonus vengono solo dalla conoscenza.",
  nl="Drie goede antwoorden op rij geven een schild, vijf de Grote Galop en tien een meesterschapsbadge. De Grote Galop wordt vanzelf ingezet, en alleen als zijn +2 galops genoeg zijn om de finish te halen. Bonussen komen alleen uit kennis.")

s("ruleArrivalTitle", "Rules step 6 title",
  fr="L'arrivée", en="The arrival", ar="الوصول", es="La llegada",
  pt="A chegada", de="Die Ankunft", tr="Varış", id="Kedatangan",
  ur="آمد", ms="Ketibaan", it="L'arrivo", nl="De aankomst")

s("ruleArrivalBody", "Rules step 6 body: the finish is reached on an exact count",
  fr="La ligne d'arrivée se gagne au compte exact : à trois cases de La Mecque, il te faut exactement un 3. Un 4, un 5 ou un 6 laisse le cheval où il est, et tu attends la bonne carte. Une fois arrivé, réponds à la Question du voyage pour valider ton arrivée ; une erreur ne te fait jamais reculer, tu réessaies au tour suivant.",
  en="The finish is reached on an exact count: three squares from Mecca you need exactly a 3. A 4, a 5 or a 6 leaves the horse where it stands, waiting for the right card. Once there, answer the Question of the Journey to make the arrival official; a wrong answer never pushes you back, you simply try again next turn.",
  ar="يُبلَغ خط النهاية بالعدد المضبوط: على بُعد ثلاثة مربعات من مكة تحتاج إلى 3 تمامًا. الـ4 أو الـ5 أو الـ6 يترك الحصان مكانه في انتظار البطاقة الصحيحة. وعند الوصول أجب عن سؤال الرحلة لتثبيت وصولك؛ الإجابة الخاطئة لا تعيدك أبدًا، بل تحاول في الدور التالي.",
  es="La meta se alcanza con el número exacto: a tres casillas de La Meca necesitas justo un 3. Un 4, un 5 o un 6 deja el caballo donde está, esperando la carta correcta. Al llegar, responde la Pregunta del viaje para validar tu llegada; un error nunca te hace retroceder, lo intentas de nuevo en el siguiente turno.",
  pt="A chegada exige o número exato: a três casas de Meca você precisa de exatamente 3. Um 4, um 5 ou um 6 deixa o cavalo onde está, esperando a carta certa. Ao chegar, responda à Pergunta da viagem para validar sua chegada; um erro nunca faz você recuar, basta tentar de novo na próxima vez.",
  de="Das Ziel wird nur mit der genauen Zahl erreicht: drei Felder vor Mekka brauchst du genau eine 3. Eine 4, 5 oder 6 lässt das Pferd stehen, bis die richtige Karte kommt. Bist du da, beantworte die Frage der Reise, um die Ankunft zu bestätigen; ein Fehler wirft dich nie zurück, du versuchst es im nächsten Zug erneut.",
  tr="Varış tam sayıyla kazanılır: Mekke'ye üç kare kala tam olarak 3 gerekir. 4, 5 ya da 6 atı yerinde bırakır, doğru kartı bekler. Vardığında varışını resmileştirmek için Yolculuk Sorusu\'nu cevapla; yanlış cevap seni asla geri götürmez, sıradaki turda yeniden denersin.",
  id="Garis akhir dicapai dengan hitungan tepat: tiga petak dari Mekah kamu butuh persis 3. Angka 4, 5, atau 6 membiarkan kuda di tempatnya, menunggu kartu yang pas. Setelah sampai, jawab Pertanyaan Perjalanan untuk mengesahkan kedatanganmu; jawaban salah tidak pernah memundurkanmu, kamu tinggal mencoba lagi.",
  ur="منزل ٹھیک گنتی سے ملتی ہے: مکہ سے تین خانے پہلے آپ کو بالکل 3 چاہیے۔ 4، 5 یا 6 گھوڑے کو وہیں چھوڑ دیتا ہے، صحیح کارڈ کے انتظار میں۔ پہنچنے پر آمد کی توثیق کے لیے سفر کے سوال کا جواب دیں؛ غلط جواب آپ کو کبھی پیچھے نہیں کرتا، آپ اگلی باری دوبارہ کوشش کرتے ہیں۔",
  ms="Garisan penamat dicapai dengan kiraan tepat: tiga petak dari Mekah anda perlukan tepat 3. Nombor 4, 5 atau 6 membiarkan kuda di tempatnya, menunggu kad yang betul. Setibanya, jawab Soalan Perjalanan untuk mengesahkan ketibaan anda; jawapan salah tidak pernah mengundurkan anda, anda cuba lagi pada giliran seterusnya.",
  it="Il traguardo si raggiunge con il conto esatto: a tre caselle dalla Mecca ti serve esattamente un 3. Un 4, un 5 o un 6 lascia il cavallo dov\'è, in attesa della carta giusta. Una volta arrivato, rispondi alla Domanda del viaggio per convalidare l\'arrivo; un errore non ti fa mai arretrare, riprovi al turno successivo.",
  nl="De finish haal je met het exacte aantal: drie vakjes voor Mekka heb je precies een 3 nodig. Een 4, 5 of 6 laat het paard staan tot de juiste kaart komt. Eenmaal daar beantwoord je de Vraag van de Reis om de aankomst te bevestigen; een fout zet je nooit terug, je probeert het gewoon opnieuw.")


# ---- Core gameplay evolution: answer first, place the horse, bonus squares ----
s("hapticFeedback", "Settings item: toggle for the board's vibrations",
  fr="Vibrations", en="Vibration", ar="الاهتزاز", es="Vibración", pt="Vibração",
  de="Vibration", tr="Titreşim", id="Getaran", ur="وائبریشن", ms="Getaran",
  it="Vibrazione", nl="Trillingen")

s("squaresWon", "Reward reveal caption after a right answer: the gallops won, i.e. how far the card carries a horse",
  ph={"count": "int"},
  fr="{count, plural, one{Gagné {count} galop} other{Gagné {count} galops}}",
  en="{count, plural, one{Won {count} gallop} other{Won {count} gallops}}",
  ar="{count, plural, =0{لا ركضات} one{ركضة واحدة} two{ركضتان} few{ربحت {count} ركضات} many{ربحت {count} ركضة} other{ربحت {count} ركضة}}",
  es="{count, plural, one{¡{count} galope ganado!} other{¡{count} galopes ganados!}}",
  pt="{count, plural, one{{count} galope ganho} other{{count} galopes ganhos}}",
  de="{count, plural, one{{count} Galopp gewonnen} other{{count} Galoppsprünge gewonnen}}",
  tr="{count, plural, other{{count} dörtnal kazanıldı}}",
  id="{count, plural, other{Menang {count} lompatan}}",
  ur="{count, plural, one{{count} سرپٹ جیتی} other{{count} سرپٹیں جیتیں}}",
  ms="{count, plural, other{Menang {count} lompatan}}",
  it="{count, plural, one{{count} galoppo vinto} other{{count} galoppi vinti}}",
  nl="{count, plural, one{{count} galop gewonnen} other{{count} galopsprongen gewonnen}}")

s("chooseHorseToMove", "Placement banner: pick which horse takes the won squares",
  fr="Choisissez un cheval", en="Choose a horse", ar="اختر حصانًا", es="Elige un caballo",
  pt="Escolha um cavalo", de="Wähle ein Pferd", tr="Bir at seç", id="Pilih seekor kuda",
  ur="ایک گھوڑا چنیں", ms="Pilih seekor kuda", it="Scegli un cavallo", nl="Kies een paard")

s("touchHorseHint", "Placement banner hint before any horse is touched",
  fr="Touchez un cheval pour voir où il irait",
  en="Touch a horse to see where it would go",
  ar="المس حصانًا لترى إلى أين سيذهب",
  es="Toca un caballo para ver adónde iría",
  pt="Toque num cavalo para ver aonde iria",
  de="Tippe ein Pferd an, um sein Ziel zu sehen",
  tr="Nereye gideceğini görmek için bir ata dokun",
  id="Sentuh kuda untuk melihat tujuannya",
  ur="گھوڑے کو چھوئیں تاکہ دیکھیں وہ کہاں جائے گا",
  ms="Sentuh kuda untuk melihat ke mana ia pergi",
  it="Tocca un cavallo per vedere dove andrebbe",
  nl="Tik op een paard om te zien waar het heen gaat")

s("dragHorseToDestination", "Placement banner hint once a horse is selected: drag it onto the highlighted square",
  fr="Glissez le cheval jusqu'à sa case dorée",
  en="Drag the horse to its golden square",
  ar="اسحب الحصان إلى مربعه الذهبي",
  es="Arrastra el caballo hasta su casilla dorada",
  pt="Arraste o cavalo até a casa dourada",
  de="Zieh das Pferd auf sein goldenes Feld",
  tr="Atı altın karesine sürükle",
  id="Seret kuda ke petak emasnya",
  ur="گھوڑے کو اس کے سنہری خانے تک گھسیٹیں",
  ms="Seret kuda ke petak emasnya",
  it="Trascina il cavallo sulla sua casella dorata",
  nl="Sleep het paard naar zijn gouden vakje")

s("bonusLabel", "Word shouted when a bonus square fires, above its value",
  fr="BONUS", en="BONUS", ar="مكافأة", es="BONUS", pt="BÔNUS", de="BONUS",
  tr="BONUS", id="BONUS", ur="بونس", ms="BONUS", it="BONUS", nl="BONUS")

s("bonusPlus", "Bonus value with its unit, e.g. '+10 gallops'",
  ph={"value": "int"},
  fr="+{value} galops", en="+{value} gallops", ar="+{value} ركضة", es="+{value} galopes",
  pt="+{value} galopes", de="+{value} Galopp", tr="+{value} dörtnal", id="+{value} lompatan",
  ur="+{value} سرپٹ", ms="+{value} lompatan", it="+{value} galoppi", nl="+{value} galop")

s("captureBonusLabel", "Word shouted when a capture pays its bond of extra squares",
  fr="CAPTURE", en="CAPTURE", ar="أسر", es="CAPTURA", pt="CAPTURA", de="SCHLAG",
  tr="YAKALAMA", id="TANGKAP", ur="پکڑ", ms="TANGKAP", it="CATTURA", nl="SLAG")

s("captureBonusRide", "Turn banner while the horse rides the bond a capture paid",
  ph={"value": "int"},
  fr="Capture ! Votre cheval bondit de {value} galops.",
  en="Capture! Your horse bounds {value} gallops forward.",
  ar="أسر! يقفز حصانك {value} ركضة إلى الأمام.",
  es="¡Captura! Tu caballo salta {value} galopes.",
  pt="Captura! O seu cavalo salta {value} galopes.",
  de="Geschlagen! Dein Pferd springt {value} Galopp vor.",
  tr="Yakaladın! Atın {value} dörtnal ileri sıçrıyor.",
  id="Tangkap! Kudamu melompat {value} lompatan ke depan.",
  ur="پکڑ! آپ کا گھوڑا {value} سرپٹ آگے چھلانگ لگاتا ہے۔",
  ms="Tangkap! Kuda anda melompat {value} lompatan ke hadapan.",
  it="Cattura! Il tuo cavallo balza in avanti di {value} galoppi.",
  nl="Geslagen! Je paard springt {value} galop vooruit.")

s("bonusRide", "Turn banner while the horse rides the bonus it landed on",
  ph={"value": "int"},
  fr="Case bonus ! Votre cheval avance encore de {value} cases.",
  en="Bonus square! Your horse rides on {value} more squares.",
  ar="مربع مكافأة! يتقدّم حصانك {value} مربعات إضافية.",
  es="¡Casilla bonus! Tu caballo avanza {value} casillas más.",
  pt="Casa bônus! Seu cavalo avança mais {value} casas.",
  de="Bonusfeld! Dein Pferd reitet {value} Felder weiter.",
  tr="Bonus kare! Atın {value} kare daha ilerliyor.",
  id="Petak bonus! Kudamu melaju {value} petak lagi.",
  ur="بونس خانہ! آپ کا گھوڑا مزید {value} خانے آگے بڑھتا ہے۔",
  ms="Petak bonus! Kuda anda mara {value} petak lagi.",
  it="Casella bonus! Il tuo cavallo avanza di altre {value} caselle.",
  nl="Bonusvakje! Je paard rijdt nog {value} vakjes door.")

s("cardWasWorth", "Feedback sheet line after a wrong answer: what the card would have moved",
  ph={"count": "int"},
  fr="{count, plural, one{Cette carte valait {count} galop.} other{Cette carte valait {count} galops.}}",
  en="{count, plural, one{This card was worth {count} gallop.} other{This card was worth {count} gallops.}}",
  ar="{count, plural, one{كانت هذه البطاقة تساوي ركضة واحدة.} two{كانت هذه البطاقة تساوي ركضتين.} few{كانت هذه البطاقة تساوي {count} ركضات.} other{كانت هذه البطاقة تساوي {count} ركضة.}}",
  es="{count, plural, one{Esta carta valía {count} galope.} other{Esta carta valía {count} galopes.}}",
  pt="{count, plural, one{Esta carta valia {count} galope.} other{Esta carta valia {count} galopes.}}",
  de="{count, plural, one{Diese Karte war {count} Galopp wert.} other{Diese Karte war {count} Galoppsprünge wert.}}",
  tr="{count, plural, other{Bu kart {count} dörtnal değerindeydi.}}",
  id="{count, plural, other{Kartu ini bernilai {count} lompatan.}}",
  ur="{count, plural, one{یہ کارڈ {count} سرپٹ کا تھا۔} other{یہ کارڈ {count} سرپٹوں کا تھا۔}}",
  ms="{count, plural, other{Kad ini bernilai {count} lompatan.}}",
  it="{count, plural, one{Questa carta valeva {count} galoppo.} other{Questa carta valeva {count} galoppi.}}",
  nl="{count, plural, one{Deze kaart was {count} galop waard.} other{Deze kaart was {count} galopsprongen waard.}}")

s("answerToReveal", "Face of the drawn card while its value is still hidden",
  fr="Répondez pour découvrir sa valeur", en="Answer to reveal its value",
  ar="أجب لتكشف قيمتها", es="Responde para descubrir su valor",
  pt="Responda para descobrir o valor", de="Antworte, um ihren Wert zu sehen",
  tr="Değerini görmek için cevapla", id="Jawab untuk mengungkap nilainya",
  ur="اس کی قیمت جاننے کے لیے جواب دیں", ms="Jawab untuk mendedahkan nilainya",
  it="Rispondi per scoprire il suo valore", nl="Antwoord om de waarde te onthullen")

s("opponentPlaces", "Turn banner while the AI opponent picks which horse takes its squares",
  ph={"name": "String"},
  fr="{name} choisit un cheval…", en="{name} is choosing a horse…", ar="{name} يختار حصانًا…",
  es="{name} elige un caballo…", pt="{name} está escolhendo um cavalo…", de="{name} wählt ein Pferd…",
  tr="{name} bir at seçiyor…", id="{name} memilih kuda…", ur="{name} گھوڑا چن رہا ہے…",
  ms="{name} memilih kuda…", it="{name} sceglie un cavallo…", nl="{name} kiest een paard…")

s("opponentBonus", "Turn banner when the AI opponent's horse fires a bonus square",
  ph={"name": "String", "value": "int"},
  fr="{name} décroche un bonus +{value} !", en="{name} lands a +{value} bonus!",
  ar="{name} يحصل على مكافأة +{value}!", es="¡{name} consigue un bonus +{value}!",
  pt="{name} ganha um bônus +{value}!", de="{name} holt einen +{value}-Bonus!",
  tr="{name} +{value} bonus kazandı!", id="{name} mendapat bonus +{value}!",
  ur="{name} کو +{value} بونس ملا!", ms="{name} mendapat bonus +{value}!",
  it="{name} ottiene un bonus +{value}!", nl="{name} pakt een +{value} bonus!")

s("leaderLabel", "Small HUD tag on the rider currently ahead in the race",
  fr="En tête", en="Leading", ar="في المقدمة", es="En cabeza", pt="Na frente",
  de="Vorne", tr="Önde", id="Memimpin", ur="سب سے آگے", ms="Mendahului",
  it="In testa", nl="Aan kop")

s("tookTheLead", "Short notice when a rider overtakes to become the leader",
  ph={"name": "String"},
  fr="{name} passe en tête !", en="{name} takes the lead!", ar="{name} يتصدّر السباق!",
  es="¡{name} se pone en cabeza!", pt="{name} assume a liderança!", de="{name} übernimmt die Führung!",
  tr="{name} öne geçti!", id="{name} memimpin!", ur="{name} آگے نکل گیا!",
  ms="{name} mendahului!", it="{name} passa in testa!", nl="{name} neemt de leiding!")

s("bonusSquareSemantics", "Screen-reader label of a bonus square on the board",
  ph={"value": "int"},
  fr="Case bonus +{value}", en="Bonus square +{value}", ar="مربع مكافأة +{value}",
  es="Casilla bonus +{value}", pt="Casa bônus +{value}", de="Bonusfeld +{value}",
  tr="Bonus kare +{value}", id="Petak bonus +{value}", ur="بونس خانہ +{value}",
  ms="Petak bonus +{value}", it="Casella bonus +{value}", nl="Bonusvakje +{value}")

s("moveHintBonus", "Destination tag: this ride ends on a bonus square worth +N",
  ph={"value": "int"},
  fr="Bonus +{value}", en="Bonus +{value}", ar="مكافأة +{value}", es="Bonus +{value}",
  pt="Bônus +{value}", de="Bonus +{value}", tr="Bonus +{value}", id="Bonus +{value}",
  ur="بونس +{value}", ms="Bonus +{value}", it="Bonus +{value}", nl="Bonus +{value}")

s("bonusSquaresTeaser", "Player setup screen: what the board holds this game",
  fr="16 cases bonus sont cachées sur le plateau : +5, +10 et la rare +20.",
  en="16 bonus squares await on the board: +5, +10 and the rare +20.",
  ar="16 مربع مكافأة على اللوحة: +5 و+10 و+20 النادر.",
  es="16 casillas bonus te esperan en el tablero: +5, +10 y la rara +20.",
  pt="16 casas bônus esperam no tabuleiro: +5, +10 e a rara +20.",
  de="16 Bonusfelder warten auf dem Brett: +5, +10 und das seltene +20.",
  tr="Tahtada 16 bonus kare seni bekliyor: +5, +10 ve nadir +20.",
  id="16 petak bonus menanti di papan: +5, +10, dan +20 yang langka.",
  ur="بورڈ پر 16 بونس خانے منتظر ہیں: +5، +10 اور نایاب +20۔",
  ms="16 petak bonus menanti di papan: +5, +10 dan +20 yang jarang.",
  it="16 caselle bonus ti aspettano sul tabellone: +5, +10 e la rara +20.",
  nl="16 bonusvakjes wachten op het bord: +5, +10 en de zeldzame +20.")

s("ridersSubtitle", "Player setup screen subtitle under the title",
  fr="Chaque cavalier choisit son niveau ; la carte ne décide que la distance.",
  en="Every rider picks their level; the card only sets the distance.",
  ar="كل فارس يختار مستواه؛ البطاقة تحدّد المسافة فقط.",
  es="Cada jinete elige su nivel; la carta solo marca la distancia.",
  pt="Cada cavaleiro escolhe seu nível; a carta só define a distância.",
  de="Jeder Reiter wählt sein Niveau; die Karte bestimmt nur die Distanz.",
  tr="Her binici seviyesini seçer; kart yalnızca mesafeyi belirler.",
  id="Setiap penunggang memilih tingkatnya; kartu hanya menentukan jarak.",
  ur="ہر سوار اپنا درجہ چنتا ہے؛ کارڈ صرف فاصلہ طے کرتا ہے۔",
  ms="Setiap penunggang memilih tahapnya; kad hanya menentukan jarak.",
  it="Ogni cavaliere sceglie il suo livello; la carta decide solo la distanza.",
  nl="Elke ruiter kiest zijn niveau; de kaart bepaalt alleen de afstand.")

s("ruleBonusTitle", "Rules step: the bonus squares",
  fr="Les cases bonus", en="Bonus squares", ar="مربعات المكافأة", es="Las casillas bonus",
  pt="As casas bônus", de="Die Bonusfelder", tr="Bonus kareler", id="Petak bonus",
  ur="بونس خانے", ms="Petak bonus", it="Le caselle bonus", nl="De bonusvakjes")

s("ruleBonusBody", "Rules step body: sixteen bonus squares, they chain, and they are optional",
  fr="Si la table les garde, seize cases bonus sont réparties sur le plateau à chaque partie, quatre par quart. Un cheval qui s'arrête exactement dessus repart aussitôt de +5, +10 ou +20 galops — et si ce bond le pose pile sur une autre case bonus, elle part à son tour : les bonus s'enchaînent. Chaque case ne sert qu'une fois par tour et reste en jeu pour tous. Sans elles, une carte vaut exactement ses galops.",
  en="If the table keeps them, sixteen bonus squares are dealt onto the board each game, four per quarter. A horse that stops exactly on one rides straight on by +5, +10 or +20 gallops — and if that ride sets it down exactly on another bonus square, that one fires too: bonuses chain. Each square pays once per turn and stays in play for everyone. Without them, a card is worth exactly its gallops.",
  ar="إن أبقتها الطاولة، تُوزَّع ست عشرة مربعة مكافأة على الرقعة في كل لعبة، أربع في كل ربع. الحصان الذي يتوقف عليها بالضبط ينطلق فورًا بمقدار +5 أو +10 أو +20 ركضة — وإن أوقعه ذلك على مربعة مكافأة أخرى بالضبط انطلقت هي أيضًا: المكافآت تتسلسل. كل مربعة تدفع مرة واحدة في الدور وتبقى في اللعب للجميع. وبدونها تساوي البطاقة ركضاتها بالضبط.",
  es="Si la mesa las conserva, dieciséis casillas de bonificación se reparten en el tablero cada partida, cuatro por cuarto. Un caballo que se detiene exactamente en una sigue de inmediato +5, +10 o +20 galopes — y si esa cabalgada lo deja justo en otra casilla de bonificación, esa también se dispara: las bonificaciones se encadenan. Cada casilla paga una vez por turno y sigue en juego para todos. Sin ellas, una carta vale exactamente sus galopes.",
  pt="Se a mesa as mantiver, dezesseis casas de bónus são distribuídas no tabuleiro em cada jogo, quatro por quarto. Um cavalo que pare exatamente numa segue logo +5, +10 ou +20 galopes — e se essa cavalgada o deixar em cima de outra casa de bónus, essa também dispara: os bónus encadeiam-se. Cada casa paga uma vez por turno e fica em jogo para todos. Sem elas, uma carta vale exatamente os seus galopes.",
  de="Behält der Tisch sie, werden je Spiel sechzehn Bonusfelder aufs Brett verteilt, vier pro Viertel. Ein Pferd, das genau darauf hält, reitet sofort +5, +10 oder +20 Galopps weiter — und setzt dieser Ritt es genau auf ein weiteres Bonusfeld, löst auch dieses aus: Boni verketten sich. Jedes Feld zahlt einmal pro Zug und bleibt für alle im Spiel. Ohne sie zählt eine Karte genau ihre Galopps.",
  tr="Masa onları tutarsa, her oyunda tahtaya on altı bonus kare dağıtılır, çeyrek başına dört. Tam üzerinde duran at hemen +5, +10 ya da +20 dörtnal daha ilerler — ve bu koşu onu tam başka bir bonus karesine indirirse o da patlar: bonuslar zincirlenir. Her kare turda bir kez öder ve herkes için oyunda kalır. Onlar olmadan bir kart tam olarak kendi dörtnalları kadar eder.",
  id="Bila meja mempertahankannya, enam belas petak bonus disebar di papan setiap permainan, empat per kuadran. Kuda yang berhenti tepat di atasnya langsung melaju +5, +10, atau +20 derap — dan bila laju itu mendaratkannya tepat di petak bonus lain, petak itu pun menyala: bonus berantai. Setiap petak membayar sekali per giliran dan tetap berlaku bagi semua. Tanpanya, satu kartu bernilai persis derapnya.",
  ur="اگر میز انہیں رکھے تو ہر کھیل میں سولہ بونس خانے تختے پر تقسیم ہوتے ہیں، ہر چوتھائی میں چار۔ جو گھوڑا بالکل اس پر رکے وہ فوراً ‎+5، ‎+10 یا ‎+20 سرپٹ مزید چلتا ہے — اور اگر یہ چال اسے بالکل کسی دوسرے بونس خانے پر لے جائے تو وہ بھی چل پڑتا ہے: بونس سلسلہ بناتے ہیں۔ ہر خانہ فی باری ایک بار دیتا ہے اور سب کے لیے کھیل میں رہتا ہے۔ ان کے بغیر کارڈ بالکل اپنے سرپٹ کے برابر ہے۔",
  ms="Jika meja mengekalkannya, enam belas petak bonus disebar di papan setiap permainan, empat setiap sukuan. Kuda yang berhenti tepat di atasnya terus melaju +5, +10 atau +20 derap — dan jika laju itu mendaratkannya tepat di petak bonus lain, petak itu turut menyala: bonus berangkai. Setiap petak membayar sekali setiap pusingan dan kekal dalam permainan untuk semua. Tanpanya, satu kad bernilai tepat derapnya.",
  it="Se il tavolo le tiene, sedici caselle bonus sono distribuite sul tabellone a ogni partita, quattro per quarto. Un cavallo che si ferma esattamente su una riparte subito di +5, +10 o +20 galoppi — e se quella cavalcata lo posa esattamente su un'altra casella bonus, parte anche quella: i bonus si concatenano. Ogni casella paga una volta per turno e resta in gioco per tutti. Senza di esse, una carta vale esattamente i suoi galoppi.",
  nl="Houdt de tafel ze, dan worden er elk spel zestien bonusvakjes op het bord verdeeld, vier per kwart. Een paard dat er precies op stopt, rijdt meteen +5, +10 of +20 galops door — en zet die rit het precies op een ander bonusvakje, dan gaat dat er ook af: bonussen schakelen door. Elk vakje betaalt één keer per beurt en blijft voor iedereen in het spel. Zonder ze is een kaart precies zijn galops waard.")


# ---------------------------------------------------------------------
def validate():
    for key, (desc, ph, texts) in K.items():
        for lang in LANGS:
            assert texts[lang].strip(), f"{key}/{lang} is blank"
    print(f"{len(K)} keys x {len(LANGS)} languages = {len(K) * len(LANGS)} strings")

def write_arb():
    os.makedirs(OUT, exist_ok=True)
    for lang in LANGS:
        data = {"@@locale": lang}
        for key, (desc, ph, texts) in K.items():
            data[key] = texts[lang]
            if lang == "en":
                meta = {"description": desc}
                if ph:
                    meta["placeholders"] = {
                        name: {"type": kind} for name, kind in ph.items()
                    }
                data[f"@{key}"] = meta
        path = f"{OUT}/app_{lang}.arb"
        with open(path, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
            f.write("\n")
    print("Wrote", len(LANGS), "ARB files to", OUT)

if __name__ == "__main__":
    validate()
    write_arb()
