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

s("onboardingWelcomeSubtitle", "Onboarding first screen subtitle",
  fr="Réponds aux questions, choisis ton allure, guide ton cheval de La Mecque à Médine.",
  en="Answer questions, choose your gait, guide your horse from Makkah to Madinah.",
  ar="أجب عن الأسئلة، اختر خطوتك، وقُد حصانك من مكة إلى المدينة.",
  es="Responde preguntas, elige tu paso y guía tu caballo de La Meca a Medina.",
  pt="Responda perguntas, escolha seu passo e guie seu cavalo de Meca a Medina.",
  de="Beantworte Fragen, wähle deine Gangart und führe dein Pferd von Mekka nach Medina.",
  tr="Soruları cevapla, temponu seç, atını Mekke'den Medine'ye götür.",
  id="Jawab pertanyaan, pilih langkahmu, dan bawa kudamu dari Makkah ke Madinah.",
  ur="سوالات کے جواب دیں، اپنی چال چنیں، اور اپنے گھوڑے کو مکہ سے مدینہ لے جائیں۔",
  ms="Jawab soalan, pilih langkah anda, dan bawa kuda anda dari Makkah ke Madinah.",
  it="Rispondi alle domande, scegli la tua andatura e guida il tuo cavallo dalla Mecca a Medina.",
  nl="Beantwoord vragen, kies je gang en leid je paard van Mekka naar Medina.")

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
s("chooseYourGait", "Header above the six horseshoe gait choices",
  fr="Choisis ton allure", en="Choose your gait", ar="اختر خطوتك",
  es="Elige tu paso", pt="Escolha seu passo", de="Wähle deine Gangart",
  tr="Temponu seç", id="Pilih langkahmu", ur="اپنی چال منتخب کریں",
  ms="Pilih langkah anda", it="Scegli la tua andatura", nl="Kies je gang")

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

s("confirmBoldGait", "Confirmation before a risky gait in child mode",
  fr="Cette allure demande une question plus difficile. On continue ?",
  en="This gait draws a harder question. Continue?",
  ar="هذه الخطوة تتطلب سؤالاً أصعب. هل نتابع؟",
  es="Este paso pide una pregunta más difícil. ¿Continuamos?",
  pt="Este passo pede uma pergunta mais difícil. Continuar?",
  de="Diese Gangart zieht eine schwerere Frage. Weiter?",
  tr="Bu tempo daha zor bir soru getirir. Devam edilsin mi?",
  id="Langkah ini menarik pertanyaan lebih sulit. Lanjutkan?",
  ur="اس چال کے لیے مشکل سوال آئے گا۔ جاری رکھیں؟",
  ms="Langkah ini menarik soalan lebih sukar. Teruskan?",
  it="Questa andatura porta una domanda più difficile. Continuare?",
  nl="Deze gang trekt een moeilijkere vraag. Doorgaan?")

# ---- Knowledge streak and rewards -----------------------------------------
s("knowledgeStreak", "Name of the streak gauge",
  fr="Élan du savoir", en="Knowledge momentum", ar="زخم المعرفة",
  es="Impulso del saber", pt="Impulso do saber", de="Wissensschwung",
  tr="Bilgi ivmesi", id="Momentum pengetahuan", ur="علم کی رفتار",
  ms="Momentum ilmu", it="Slancio del sapere", nl="Kennismomentum")

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

s("circuitOasisRouteDescription", "Circuit description",
  fr="Parcours court et lumineux. Parfait pour une partie rapide.",
  en="A short, sunlit course. Perfect for a quick game.",
  ar="مسار قصير مشمس. مثالي للعبة سريعة.",
  es="Recorrido corto y luminoso. Perfecto para una partida rápida.",
  pt="Percurso curto e luminoso. Perfeito para um jogo rápido.",
  de="Kurze, sonnige Strecke. Perfekt für ein schnelles Spiel.",
  tr="Kısa ve güneşli parkur. Hızlı bir oyun için ideal.",
  id="Lintasan pendek dan cerah. Cocok untuk permainan cepat.",
  ur="مختصر، روشن راستہ۔ تیز کھیل کے لیے بہترین۔",
  ms="Laluan pendek dan cerah. Sesuai untuk permainan pantas.",
  it="Percorso breve e luminoso. Perfetto per una partita rapida.",
  nl="Kort, zonnig parcours. Perfect voor een snel spel.")

s("circuitCaravanTrailDescription", "Circuit description",
  fr="Campements et lanternes. Un parcours plus stratégique.",
  en="Camps and lanterns. A more strategic course.",
  ar="مخيمات وفوانيس. مسار أكثر استراتيجية.",
  es="Campamentos y faroles. Un recorrido más estratégico.",
  pt="Acampamentos e lanternas. Um percurso mais estratégico.",
  de="Lager und Laternen. Eine strategischere Strecke.",
  tr="Kamplar ve fenerler. Daha stratejik bir parkur.",
  id="Perkemahan dan lentera. Lintasan yang lebih strategis.",
  ur="پڑاؤ اور لالٹینیں۔ زیادہ حکمت عملی والا راستہ۔",
  ms="Perkhemahan dan tanglung. Laluan yang lebih strategik.",
  it="Accampamenti e lanterne. Un percorso più strategico.",
  nl="Kampen en lantaarns. Een strategischer parcours.")

s("circuitGreatRideDescription", "Circuit description",
  fr="Du jour au ciel étoilé. Le grand voyage.",
  en="From daylight to a starlit sky. The great journey.",
  ar="من النهار إلى سماء النجوم. الرحلة الكبرى.",
  es="Del día al cielo estrellado. El gran viaje.",
  pt="Do dia ao céu estrelado. A grande viagem.",
  de="Vom Tag zum Sternenhimmel. Die große Reise.",
  tr="Gündüzden yıldızlı göğe. Büyük yolculuk.",
  id="Dari siang ke langit berbintang. Perjalanan agung.",
  ur="دن سے ستاروں بھرے آسمان تک۔ عظیم سفر۔",
  ms="Dari siang ke langit berbintang. Pengembaraan agung.",
  it="Dal giorno al cielo stellato. Il grande viaggio.",
  nl="Van daglicht tot sterrenhemel. De grote reis.")

# ---- Special squares -------------------------------------------------------
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

s("outcomeCaptured", "Feedback when passing an opponent",
  fr="Tu dépasses un adversaire !", en="You overtake an opponent!",
  ar="لقد تجاوزت خصمًا!", es="¡Adelantas a un rival!",
  pt="Você ultrapassa um adversário!", de="Du überholst einen Gegner!",
  tr="Bir rakibi geçtin!", id="Kamu menyalip lawan!",
  ur="آپ نے حریف کو پیچھے چھوڑا!", ms="Anda memintas lawan!",
  it="Superi un avversario!", nl="Je haalt een tegenstander in!")

s("outcomeShieldBlocked", "Feedback when a shield absorbs an overtake",
  fr="Le bouclier a protégé le cheval.", en="The shield protected the horse.",
  ar="حمى الدرع الحصان.", es="El escudo protegió al caballo.",
  pt="O escudo protegeu o cavalo.", de="Das Schild hat das Pferd geschützt.",
  tr="Kalkan atı korudu.", id="Perisai melindungi kuda itu.",
  ur="ڈھال نے گھوڑے کو بچا لیا۔", ms="Perisai melindungi kuda itu.",
  it="Lo scudo ha protetto il cavallo.", nl="Het schild beschermde het paard.")

# ---- Player profiles -------------------------------------------------------
s("playerProfile", "Label for the per-player knowledge level",
  fr="Niveau du joueur", en="Player level", ar="مستوى اللاعب",
  es="Nivel del jugador", pt="Nível do jogador", de="Spielerstufe",
  tr="Oyuncu seviyesi", id="Tingkat pemain", ur="کھلاڑی کا درجہ",
  ms="Tahap pemain", it="Livello giocatore", nl="Spelerniveau")

s("profileChild", "Player level",
  fr="Enfant", en="Child", ar="طفل", es="Niño", pt="Criança", de="Kind",
  tr="Çocuk", id="Anak", ur="بچہ", ms="Kanak-kanak", it="Bambino", nl="Kind")

s("profileDiscovery", "Player level",
  fr="Découverte", en="Discovery", ar="اكتشاف", es="Descubrimiento",
  pt="Descoberta", de="Entdeckung", tr="Keşif", id="Penjelajahan",
  ur="دریافت", ms="Penerokaan", it="Scoperta", nl="Ontdekking")

s("profileIntermediate", "Player level",
  fr="Intermédiaire", en="Intermediate", ar="متوسط", es="Intermedio",
  pt="Intermediário", de="Mittel", tr="Orta", id="Menengah", ur="درمیانہ",
  ms="Sederhana", it="Intermedio", nl="Gemiddeld")

s("profileAdvanced", "Player level",
  fr="Avancé", en="Advanced", ar="متقدم", es="Avanzado", pt="Avançado",
  de="Fortgeschritten", tr="İleri", id="Lanjutan", ur="اعلیٰ",
  ms="Lanjutan", it="Avanzato", nl="Gevorderd")

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

s("raceRulesUpdatedBody", "Explains why an old save cannot be resumed",
  fr="Le dé a disparu : c'est maintenant toi qui choisis ton allure, et donc ton niveau de risque. Ta progression, tes badges et tes achats sont conservés — seule la partie en cours ne peut pas reprendre avec les nouvelles règles.",
  en="The dice is gone: you now choose your own gait, and with it your level of risk. Your progress, badges and purchases are all kept — only the game in progress cannot continue under the new rules.",
  ar="اختفى النرد: أنت الآن تختار خطوتك، ومعها مستوى المخاطرة. تقدمك وشاراتك ومشترياتك محفوظة — اللعبة الجارية فقط لا يمكن متابعتها بالقواعد الجديدة.",
  es="El dado ha desaparecido: ahora eliges tu paso y, con él, tu nivel de riesgo. Tu progreso, insignias y compras se conservan; solo la partida en curso no puede continuar con las nuevas reglas.",
  pt="O dado acabou: agora você escolhe seu passo e, com ele, seu nível de risco. Seu progresso, emblemas e compras são mantidos — apenas o jogo em andamento não pode continuar com as novas regras.",
  de="Der Würfel ist weg: Du wählst jetzt deine Gangart und damit dein Risiko. Fortschritt, Abzeichen und Käufe bleiben erhalten — nur das laufende Spiel kann nicht mit den neuen Regeln fortgesetzt werden.",
  tr="Zar kalktı: artık kendi temponu, dolayısıyla risk seviyeni sen seçiyorsun. İlerlemen, rozetlerin ve satın alımların korunuyor — yalnızca devam eden oyun yeni kurallarla sürdürülemiyor.",
  id="Dadu telah hilang: kini kamu memilih langkahmu sendiri, dan dengan itu tingkat risikomu. Kemajuan, lencana, dan pembelianmu tetap tersimpan — hanya permainan yang sedang berjalan tidak dapat dilanjutkan dengan aturan baru.",
  ur="پانسہ ختم: اب آپ خود اپنی چال اور اس کے ساتھ خطرے کا درجہ چنتے ہیں۔ آپ کی پیش رفت، بیجز اور خریداری محفوظ ہیں — صرف جاری کھیل نئے قواعد کے ساتھ جاری نہیں رہ سکتا۔",
  ms="Dadu telah tiada: kini anda memilih langkah anda sendiri, dan dengannya tahap risiko anda. Kemajuan, lencana dan pembelian anda dikekalkan — hanya permainan yang sedang berjalan tidak dapat diteruskan dengan peraturan baharu.",
  it="Il dado non c'è più: ora scegli tu la tua andatura, e con essa il livello di rischio. Progressi, distintivi e acquisti sono conservati — solo la partita in corso non può continuare con le nuove regole.",
  nl="De dobbelsteen is weg: jij kiest nu je eigen gang, en daarmee je risico. Je voortgang, badges en aankopen blijven behouden — alleen het lopende spel kan niet verder onder de nieuwe regels.")

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

s("ruleChooseGaitTitle", "Rules step 1 title",
  fr="Choisis ton allure", en="Choose your gait", ar="اختر خطوتك",
  es="Elige tu paso", pt="Escolha seu passo", de="Wähle deine Gangart",
  tr="Temponu seç", id="Pilih langkahmu", ur="اپنی چال چنیں",
  ms="Pilih langkah anda", it="Scegli la tua andatura", nl="Kies je gang")

s("ruleChooseGaitBody", "Rules step 1 body",
  fr="Décide toi-même de combien de cases avancer, de 1 à 6. Plus tu vas loin, plus la question est difficile : 1-2 facile, 3-4 moyenne, 5-6 difficile.",
  en="You decide how far to move, from 1 to 6 squares. The further you go, the harder the question: 1-2 easy, 3-4 medium, 5-6 hard.",
  ar="أنت تقرر عدد المربعات التي تتقدمها، من 1 إلى 6. كلما ابتعدت، صعب السؤال: 1-2 سهل، 3-4 متوسط، 5-6 صعب.",
  es="Tú decides cuántas casillas avanzar, de 1 a 6. Cuanto más lejos vayas, más difícil será la pregunta: 1-2 fácil, 3-4 media, 5-6 difícil.",
  pt="Você decide quantas casas avançar, de 1 a 6. Quanto mais longe for, mais difícil a pergunta: 1-2 fácil, 3-4 média, 5-6 difícil.",
  de="Du entscheidest, wie weit du ziehst, von 1 bis 6 Feldern. Je weiter, desto schwerer die Frage: 1-2 leicht, 3-4 mittel, 5-6 schwer.",
  tr="Kaç kare ilerleyeceğine sen karar verirsin, 1'den 6'ya. Ne kadar uzağa gidersen soru o kadar zorlaşır: 1-2 kolay, 3-4 orta, 5-6 zor.",
  id="Kamu yang menentukan seberapa jauh melangkah, dari 1 sampai 6 petak. Makin jauh, makin sulit pertanyaannya: 1-2 mudah, 3-4 sedang, 5-6 sulit.",
  ur="آپ خود طے کرتے ہیں کہ کتنے خانے آگے بڑھنا ہے، 1 سے 6 تک۔ جتنا دور جائیں گے، سوال اتنا مشکل ہوگا: 1-2 آسان، 3-4 درمیانہ، 5-6 مشکل۔",
  ms="Anda yang menentukan sejauh mana untuk bergerak, dari 1 hingga 6 petak. Semakin jauh, semakin sukar soalannya: 1-2 mudah, 3-4 sederhana, 5-6 sukar.",
  it="Decidi tu di quante caselle avanzare, da 1 a 6. Più vai lontano, più la domanda è difficile: 1-2 facile, 3-4 media, 5-6 difficile.",
  nl="Jij bepaalt hoe ver je gaat, van 1 tot 6 vakjes. Hoe verder, hoe moeilijker de vraag: 1-2 makkelijk, 3-4 gemiddeld, 5-6 moeilijk.")

s("ruleAnswerToAdvanceTitle", "Rules step 2 title",
  fr="Réponds pour avancer", en="Answer to advance", ar="أجب لتتقدم",
  es="Responde para avanzar", pt="Responda para avançar",
  de="Antworte, um vorzurücken", tr="İlerlemek için cevapla",
  id="Jawab untuk maju", ur="آگے بڑھنے کے لیے جواب دیں",
  ms="Jawab untuk maju", it="Rispondi per avanzare", nl="Antwoord om vooruit te gaan")

s("ruleAnswerToAdvanceBody", "Rules step 2 body",
  fr="Une bonne réponse fait avancer ton cheval exactement du nombre de cases choisi. Une mauvaise réponse le laisse sur place : tu ne recules jamais.",
  en="A correct answer moves your horse exactly the distance you chose. A wrong answer leaves it where it stands — you never go backwards.",
  ar="الإجابة الصحيحة تحرك حصانك بالضبط بالمسافة التي اخترتها. والإجابة الخاطئة تتركه مكانه — لا تتراجع أبدًا.",
  es="Una respuesta correcta mueve tu caballo exactamente la distancia elegida. Una respuesta incorrecta lo deja donde está: nunca retrocedes.",
  pt="Uma resposta certa move seu cavalo exatamente a distância escolhida. Uma resposta errada o deixa onde está — você nunca retrocede.",
  de="Eine richtige Antwort bewegt dein Pferd genau um die gewählte Distanz. Eine falsche Antwort lässt es stehen — du gehst nie zurück.",
  tr="Doğru cevap atını tam olarak seçtiğin kadar ilerletir. Yanlış cevap onu olduğu yerde bırakır — asla geri gitmezsin.",
  id="Jawaban benar menggerakkan kudamu tepat sejauh yang kamu pilih. Jawaban salah membiarkannya di tempat — kamu tidak pernah mundur.",
  ur="درست جواب آپ کے گھوڑے کو بالکل اتنا ہی آگے بڑھاتا ہے جتنا آپ نے چنا۔ غلط جواب اسے وہیں رکھتا ہے — آپ کبھی پیچھے نہیں ہٹتے۔",
  ms="Jawapan betul menggerakkan kuda anda tepat sejauh yang anda pilih. Jawapan salah membiarkannya di tempatnya — anda tidak pernah berundur.",
  it="Una risposta corretta muove il tuo cavallo esattamente della distanza scelta. Una risposta sbagliata lo lascia dov'è: non torni mai indietro.",
  nl="Een goed antwoord verplaatst je paard precies de gekozen afstand. Een fout antwoord laat het staan — je gaat nooit achteruit.")

s("ruleGaitCycleTitle", "Rules step 3 title",
  fr="Une allure par cycle", en="One gait per cycle", ar="خطوة واحدة لكل دورة",
  es="Un paso por ciclo", pt="Um passo por ciclo", de="Eine Gangart pro Runde",
  tr="Döngü başına bir tempo", id="Satu langkah per siklus",
  ur="فی چکر ایک چال", ms="Satu langkah setiap kitaran",
  it="Un'andatura per ciclo", nl="Eén gang per cyclus")

s("ruleGaitCycleBody", "Rules step 3 body",
  fr="Chaque allure ne s'utilise qu'une fois. Quand les six sont épuisées, elles reviennent toutes : à toi d'anticiper.",
  en="Each gait can be used only once. When all six are spent, the whole set comes back — so plan ahead.",
  ar="كل خطوة تُستخدم مرة واحدة فقط. وعندما تنفد الست، تعود جميعها — فخطط مسبقًا.",
  es="Cada paso solo se usa una vez. Cuando se agotan los seis, vuelven todos: planifica con antelación.",
  pt="Cada passo só pode ser usado uma vez. Quando os seis se esgotam, todos voltam — planeje com antecedência.",
  de="Jede Gangart kann nur einmal genutzt werden. Sind alle sechs verbraucht, kommen sie alle zurück — plane voraus.",
  tr="Her tempo yalnızca bir kez kullanılır. Altısı da bitince hepsi geri gelir — önceden planla.",
  id="Setiap langkah hanya bisa dipakai sekali. Ketika keenamnya habis, semuanya kembali — jadi rencanakan.",
  ur="ہر چال صرف ایک بار استعمال ہوتی ہے۔ جب چھ ختم ہو جائیں تو سب واپس آ جاتی ہیں — پہلے سے منصوبہ بنائیں۔",
  ms="Setiap langkah hanya boleh digunakan sekali. Apabila keenam-enamnya habis, semuanya kembali — jadi rancang lebih awal.",
  it="Ogni andatura si usa una sola volta. Quando tutte e sei sono esaurite, tornano tutte: pianifica in anticipo.",
  nl="Elke gang kun je maar één keer gebruiken. Als alle zes op zijn, komen ze allemaal terug — plan dus vooruit.")

s("ruleCaptureTitle", "Rules step 4 title",
  fr="Dépasser et renvoyer", en="Overtake and send home", ar="التجاوز والإعادة",
  es="Adelantar y enviar a casa", pt="Ultrapassar e mandar de volta",
  de="Überholen und heimschicken", tr="Geç ve ahıra yolla",
  id="Menyalip dan memulangkan", ur="آگے نکلیں اور واپس بھیجیں",
  ms="Memintas dan menghantar pulang", it="Sorpassa e rimanda a casa",
  nl="Inhalen en naar huis sturen")

s("ruleCaptureBody", "Rules step 4 body",
  fr="Arriver exactement sur un cheval adverse le renvoie tranquillement à son écurie — sauf si la case est une oasis ou si ce cheval porte un bouclier du savoir.",
  en="Landing exactly on an opponent's horse sends it calmly back to its stable — unless the square is an oasis, or that horse carries a knowledge shield.",
  ar="الوصول تمامًا إلى حصان الخصم يعيده بهدوء إلى إسطبله — إلا إذا كان المربع واحة أو كان ذلك الحصان يحمل درع المعرفة.",
  es="Caer exactamente sobre el caballo de un rival lo devuelve con calma a su establo, salvo que la casilla sea un oasis o ese caballo lleve un escudo del saber.",
  pt="Cair exatamente sobre o cavalo de um adversário o manda calmamente de volta ao estábulo — a menos que a casa seja um oásis ou que o cavalo tenha um escudo do saber.",
  de="Wer genau auf dem Pferd eines Gegners landet, schickt es ruhig in seinen Stall zurück — außer das Feld ist eine Oase oder das Pferd trägt einen Wissensschild.",
  tr="Rakibin atının bulunduğu kareye tam olarak konmak onu sakince ahırına yollar — kare bir vaha değilse ya da o at bir bilgi kalkanı taşımıyorsa.",
  id="Mendarat tepat di kuda lawan mengirimnya kembali dengan tenang ke kandang — kecuali petaknya oasis, atau kuda itu membawa perisai pengetahuan.",
  ur="حریف کے گھوڑے پر بالکل ٹھیک پہنچنا اسے سکون سے اس کے اصطبل واپس بھیج دیتا ہے — سوائے اس کے کہ خانہ نخلستان ہو یا وہ گھوڑا علم کی ڈھال رکھتا ہو۔",
  ms="Mendarat tepat pada kuda lawan menghantarnya pulang dengan tenang ke kandang — melainkan petak itu oasis, atau kuda itu membawa perisai ilmu.",
  it="Arrivare esattamente sul cavallo di un avversario lo rimanda con calma alla sua stalla, a meno che la casella sia un'oasi o quel cavallo porti uno scudo del sapere.",
  nl="Precies op het paard van een tegenstander landen stuurt het rustig terug naar de stal — tenzij het vakje een oase is of dat paard een kennisschild draagt.")

s("ruleStreakTitle", "Rules step 5 title",
  fr="L'élan du savoir", en="The knowledge streak", ar="اندفاع المعرفة",
  es="El impulso del saber", pt="O impulso do saber",
  de="Der Schwung des Wissens", tr="Bilgi serisi", id="Rentetan pengetahuan",
  ur="علم کی روانی", ms="Rentetan ilmu", it="Lo slancio del sapere",
  nl="De kennisreeks")

s("ruleStreakBody", "Rules step 5 body",
  fr="Trois bonnes réponses d'affilée offrent un bouclier, cinq offrent le Grand Galop (+2 cases) et dix un badge de maîtrise. Les bonus s'obtiennent uniquement par la connaissance.",
  en="Three correct answers in a row earn a shield, five earn the Grand Gallop (+2 squares), and ten earn a mastery badge. Bonuses come from knowledge alone.",
  ar="ثلاث إجابات صحيحة متتالية تمنح درعًا، وخمس تمنح الركض الكبير (+2 مربع)، وعشر تمنح شارة إتقان. المكافآت تأتي من المعرفة وحدها.",
  es="Tres respuestas correctas seguidas dan un escudo, cinco dan el Gran Galope (+2 casillas) y diez, una insignia de maestría. Los bonus solo se ganan con conocimiento.",
  pt="Três respostas certas seguidas dão um escudo, cinco dão o Grande Galope (+2 casas) e dez, um emblema de maestria. Os bônus vêm apenas do conhecimento.",
  de="Drei richtige Antworten in Folge bringen einen Schild, fünf den Großen Galopp (+2 Felder) und zehn ein Meisterabzeichen. Boni gibt es nur durch Wissen.",
  tr="Üst üste üç doğru cevap bir kalkan, beş doğru Büyük Dörtnal (+2 kare), on doğru bir ustalık rozeti kazandırır. Bonuslar yalnızca bilgiyle gelir.",
  id="Tiga jawaban benar berturut-turut memberi perisai, lima memberi Galop Agung (+2 petak), dan sepuluh memberi lencana penguasaan. Bonus hanya datang dari pengetahuan.",
  ur="لگاتار تین درست جواب ایک ڈھال دیتے ہیں، پانچ عظیم سرپٹ (+2 خانے) اور دس مہارت کا بیج۔ انعامات صرف علم سے ملتے ہیں۔",
  ms="Tiga jawapan betul berturut-turut memberi perisai, lima memberi Larian Agung (+2 petak), dan sepuluh memberi lencana penguasaan. Bonus datang daripada ilmu sahaja.",
  it="Tre risposte corrette di fila danno uno scudo, cinque il Gran Galoppo (+2 caselle) e dieci un distintivo di maestria. I bonus si ottengono solo con la conoscenza.",
  nl="Drie goede antwoorden op rij leveren een schild op, vijf de Grote Galop (+2 vakjes) en tien een meesterschapsbadge. Bonussen komen alleen uit kennis.")

s("ruleArrivalTitle", "Rules step 6 title",
  fr="L'arrivée", en="The arrival", ar="الوصول", es="La llegada",
  pt="A chegada", de="Die Ankunft", tr="Varış", id="Kedatangan",
  ur="آمد", ms="Ketibaan", it="L'arrivo", nl="De aankomst")

s("ruleArrivalBody", "Rules step 6 body",
  fr="Atteins le bout du parcours — dépasser la ligne est permis — puis réponds à la Question du voyage pour valider ton arrivée. Une erreur ne te fait jamais reculer : tu réessaies au tour suivant.",
  en="Reach the end of the course — going past the line is fine — then answer the Question of the Journey to make your arrival official. A wrong answer never pushes you back: you simply try again next turn.",
  ar="اِبلغ نهاية المسار — وتجاوز الخط مسموح — ثم أجب عن سؤال الرحلة لتثبيت وصولك. الإجابة الخاطئة لا تعيدك أبدًا: تحاول ببساطة في الدور التالي.",
  es="Llega al final del recorrido —pasarse de la línea está permitido— y responde la Pregunta del viaje para validar tu llegada. Un error nunca te hace retroceder: lo intentas de nuevo en el siguiente turno.",
  pt="Chegue ao fim do percurso — passar da linha é permitido — e responda à Pergunta da viagem para validar sua chegada. Um erro nunca faz você recuar: basta tentar de novo na próxima vez.",
  de="Erreiche das Ende der Strecke — über die Linie hinaus ist erlaubt — und beantworte dann die Frage der Reise, um deine Ankunft zu bestätigen. Ein Fehler wirft dich nie zurück: Du versuchst es einfach im nächsten Zug erneut.",
  tr="Parkurun sonuna ulaş — çizgiyi geçmek serbest — sonra varışını resmileştirmek için Yolculuk Sorusu'nu cevapla. Yanlış cevap seni asla geri götürmez: sıradaki turda yeniden denersin.",
  id="Capai ujung lintasan — melewati garis tidak masalah — lalu jawab Pertanyaan Perjalanan untuk mengesahkan kedatanganmu. Jawaban salah tidak pernah memundurkanmu: kamu tinggal mencoba lagi di giliran berikutnya.",
  ur="راستے کے آخر تک پہنچیں — لکیر سے آگے نکلنا ٹھیک ہے — پھر اپنی آمد کی توثیق کے لیے سفر کے سوال کا جواب دیں۔ غلط جواب آپ کو کبھی پیچھے نہیں کرتا: آپ اگلی باری میں دوبارہ کوشش کرتے ہیں۔",
  ms="Capai penghujung laluan — melepasi garisan tidak mengapa — kemudian jawab Soalan Perjalanan untuk mengesahkan ketibaan anda. Jawapan salah tidak pernah mengundurkan anda: anda cuba lagi pada giliran seterusnya.",
  it="Raggiungi la fine del percorso — superare la linea è permesso — poi rispondi alla Domanda del viaggio per convalidare il tuo arrivo. Un errore non ti fa mai arretrare: riprovi al turno successivo.",
  nl="Bereik het einde van het parcours — voorbij de streep gaan mag — en beantwoord dan de Vraag van de Reis om je aankomst te bevestigen. Een fout zet je nooit terug: je probeert het gewoon opnieuw.")


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
