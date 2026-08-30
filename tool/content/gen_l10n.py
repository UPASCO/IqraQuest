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

# key -> (description, {lang: text})
K = {}

def s(key, desc, **texts):
    missing = [l for l in LANGS if l not in texts]
    assert not missing, f"{key}: missing {missing}"
    K[key] = (desc, texts)

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

s("onboardingWelcomeSubtitle", "Onboarding first screen subtitle",
  fr="Réponds aux questions, lance le dé, guide ton cheval de La Mecque à Médine.",
  en="Answer questions, roll the dice, guide your horse from Makkah to Madinah.",
  ar="أجب عن الأسئلة، ألقِ النرد، وقُد حصانك من مكة إلى المدينة.",
  es="Responde preguntas, lanza el dado y guía tu caballo de La Meca a Medina.",
  pt="Responda perguntas, lance o dado e guie seu cavalo de Meca a Medina.",
  de="Beantworte Fragen, würfle und führe dein Pferd von Mekka nach Medina.",
  tr="Soruları cevapla, zar at, atını Mekke'den Medine'ye götür.",
  id="Jawab pertanyaan, lempar dadu, dan bawa kudamu dari Makkah ke Madinah.",
  ur="سوالات کے جواب دیں، پانسہ پھینکیں، اور اپنے گھوڑے کو مکہ سے مدینہ لے جائیں۔",
  ms="Jawab soalan, baling dadu, dan bawa kuda anda dari Makkah ke Madinah.",
  it="Rispondi alle domande, lancia il dado e guida il tuo cavallo dalla Mecca a Medina.",
  nl="Beantwoord vragen, gooi de dobbelsteen en leid je paard van Mekka naar Medina.")

s("getStarted", "Primary CTA button on onboarding",
  fr="Commencer", en="Get started", ar="ابدأ", es="Comenzar", pt="Começar",
  de="Loslegen", tr="Başla", id="Mulai", ur="شروع کریں", ms="Mulakan",
  it="Inizia", nl="Beginnen")

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
s("quickGame", "Game variant: 1 pawn per player",
  fr="Partie rapide", en="Quick game", ar="لعبة سريعة", es="Partida rápida",
  pt="Jogo rápido", de="Schnellspiel", tr="Hızlı Oyun", id="Permainan Cepat",
  ur="فوری کھیل", ms="Permainan Pantas", it="Partita rapida", nl="Snel spel")

s("classicGame", "Game variant: 4 pawns per player",
  fr="Partie classique", en="Classic game", ar="لعبة كلاسيكية", es="Partida clásica",
  pt="Jogo clássico", de="Klassisches Spiel", tr="Klasik Oyun", id="Permainan Klasik",
  ur="کلاسک کھیل", ms="Permainan Klasik", it="Partita classica", nl="Klassiek spel")

s("chooseDifficulty", "AI difficulty picker label",
  fr="Choisir la difficulté", en="Choose difficulty", ar="اختر مستوى الصعوبة",
  es="Elegir dificultad", pt="Escolher dificuldade", de="Schwierigkeit wählen",
  tr="Zorluk seçin", id="Pilih tingkat kesulitan", ur="مشکل کا درجہ منتخب کریں",
  ms="Pilih tahap kesukaran", it="Scegli difficoltà", nl="Kies moeilijkheidsgraad")

s("difficultyEasy", "AI/quiz difficulty level",
  fr="Facile", en="Easy", ar="سهل", es="Fácil", pt="Fácil", de="Leicht",
  tr="Kolay", id="Mudah", ur="آسان", ms="Mudah", it="Facile", nl="Makkelijk")

s("difficultyMedium", "AI/quiz difficulty level",
  fr="Intermédiaire", en="Medium", ar="متوسط", es="Intermedio", pt="Intermediário",
  de="Mittel", tr="Orta", id="Menengah", ur="درمیانہ", ms="Sederhana",
  it="Intermedio", nl="Gemiddeld")

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

s("rollDice", "Dice button label",
  fr="Lancer le dé", en="Roll the dice", ar="ألقِ النرد", es="Lanzar el dado",
  pt="Lançar o dado", de="Würfeln", tr="Zar At", id="Lempar Dadu",
  ur="پانسہ پھینکیں", ms="Baling Dadu", it="Lancia il dado", nl="Dobbelsteen gooien")

s("diceLocked", "Dice disabled state message",
  fr="Réponds à la question pour débloquer le dé",
  en="Answer the question to unlock the dice",
  ar="أجب عن السؤال لفتح النرد",
  es="Responde la pregunta para desbloquear el dado",
  pt="Responda a pergunta para desbloquear o dado",
  de="Beantworte die Frage, um den Würfel freizuschalten",
  tr="Zarı açmak için soruyu cevaplayın", id="Jawab pertanyaan untuk membuka dadu",
  ur="پانسے کو کھولنے کے لیے سوال کا جواب دیں",
  ms="Jawab soalan untuk membuka kunci dadu",
  it="Rispondi alla domanda per sbloccare il dado",
  nl="Beantwoord de vraag om de dobbelsteen te ontgrendelen")

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

s("premiumUnlockAll", "Premium sheet value proposition",
  fr="Débloque les 500 questions et toutes les difficultés",
  en="Unlock all 500 questions and every difficulty",
  ar="افتح جميع الأسئلة الـ500 وكل مستويات الصعوبة",
  es="Desbloquea las 500 preguntas y todas las dificultades",
  pt="Desbloqueie as 500 perguntas e todas as dificuldades",
  de="Schalte alle 500 Fragen und jeden Schwierigkeitsgrad frei",
  tr="500 sorunun ve tüm zorluk seviyelerinin kilidini açın",
  id="Buka 500 pertanyaan dan semua tingkat kesulitan",
  ur="تمام 500 سوالات اور ہر مشکل درجہ کھولیں",
  ms="Buka kunci 500 soalan dan semua tahap kesukaran",
  it="Sblocca tutte le 500 domande e ogni livello di difficoltà",
  nl="Ontgrendel alle 500 vragen en elke moeilijkheidsgraad")

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

s("darkMode", "Settings item",
  fr="Mode nuit", en="Dark mode", ar="الوضع الليلي", es="Modo oscuro",
  pt="Modo escuro", de="Dunkelmodus", tr="Karanlık Mod", id="Mode Gelap",
  ur="ڈارک موڈ", ms="Mod Gelap", it="Modalità scura", nl="Donkere modus")

s("about", "Settings item",
  fr="À propos", en="About", ar="حول التطبيق", es="Acerca de", pt="Sobre",
  de="Über", tr="Hakkında", id="Tentang", ur="بارے میں", ms="Tentang",
  it="Informazioni", nl="Over")

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

# ---------------------------------------------------------------------
def validate():
    for key, (desc, texts) in K.items():
        for lang in LANGS:
            assert texts[lang].strip(), f"{key}/{lang} is blank"
    print(f"{len(K)} keys x {len(LANGS)} languages = {len(K) * len(LANGS)} strings")

def write_arb():
    os.makedirs(OUT, exist_ok=True)
    for lang in LANGS:
        data = {"@@locale": lang}
        for key, (desc, texts) in K.items():
            data[key] = texts[lang]
            if lang == "en":
                data[f"@{key}"] = {"description": desc}
        path = f"{OUT}/app_{lang}.arb"
        with open(path, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
            f.write("\n")
    print("Wrote", len(LANGS), "ARB files to", OUT)

if __name__ == "__main__":
    validate()
    write_arb()
