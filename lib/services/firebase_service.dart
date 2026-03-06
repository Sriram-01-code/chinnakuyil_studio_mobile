import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) return UserModel.fromFirestore(doc.data()!, uid);
      return null;
    } catch (e) { return null; }
  }

  static Future<void> saveUser(UserModel user) async {
    try { 
      await _firestore.collection('users').doc(user.uid).set(user.toFirestore());
    } catch (e) {
      debugPrint('Error saving user: $e');
    }
  }

  static Future<void> saveSession(String uid, String firstName, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('uid', uid);
    await prefs.setString('firstName', firstName);
    await prefs.setString('role', role);
    await prefs.setBool('isLoggedIn', true);
  }

  static Future<Map<String, String?>> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    return {'uid': prefs.getString('uid'), 'firstName': prefs.getString('firstName'), 'role': prefs.getString('role')};
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<void> seedDatabase() async {
    try {
      final songsCollection = _firestore.collection('songs');
      
      final List<Map<String, dynamic>> premiumSongs = [
        {
          "title": "Ninnukori Varanam 💃✨",
          "lyrics": "நின்னுக்கோரி வர்ணம் வர்ணம்\nஇசைத்திட என்னைத்தேடி வரணும் வரணும்\nஒரு கிளி தனித்திருக்க\nஉனக்கெனத் தவமிருக்க\nஇரு விழி சிவந்திருக்க\nஇதழ் மட்டும் வெளுத்திருக்க\nஅழகிய ரகுவரனே – அனுதினமும்\nநின்னுக்கோரி வர்ணம் வர்ணம்\nஇசைத்திட என்னைத்தேடி வரணும் வரணும்\nஉன்னைத்தான் சின்னப்பெண் ஏதோ கேட்க\nஉள்ளுக்குள் அங்கங்கே ஏக்கம் தாக்க\nமொட்டுத்தான் மெல்லத்தான் பூப்போல் பூக்க\nதொட்டுப்பார் கட்டிப்பார் தேகம் வேர்க்க\nபூஜைக்காக வாடுது தேவன் உன்னைத் தேடுது\nஆசை நெجمة ஏங்குது\nஆட்டம் போட்டுத் தூங்குது\nஉன்னோடுநான் ஓயாமல் தேனாற்றிலே\nநீராடத் நினைக்கையில்\nநின்னுக்கோரி வர்ணம் வர்ணம்\nஇசைத்திட என்னைத்தேடி வரணும் வரணும்\nஒரு கிளி தனித்திருக்க\nஉனக்கெனத் தவமிருக்க\nஇரு விழி சிவந்திருக்க\nஇதழ் மட்டும் வெளுத்திருக்க\nஅழகிய ரகுவரனே – அனுதினமும்\nநின்னுக்கோரி வர்ணம் வர்ணம் – இசைத்திட\nஎன்னைத்தேடி வரணும் வரணும்\nபெண்ணல்ல வீணை நான் நீதான் மீட்டு\nஎன்னென்ன ராகங்கள் நீதான் காட்டு\nஇன்றல்ல நேற்றல்ல காலம்தோறும்\nஉன்னோடு பின்னோடு காதல் நெஞ்சம்\nவன்னப்பாவை மோகனம் வாடிப்போன காரணம்\nகன்னித்தோகை மேனியில்\nமின்னல் பாய்ச்சும் வாலிபம்\nஉன் ஞாபகம் நீங்காமல் என்\nநெஞ்சிலே தீயாகக் கொதித்திட\nநின்னுக்கோரி வர்ணம் வர்ணம்\nஇசைத்திட என்னைத்தேடி வரணும் வரணும்\nஒரு கிளி தனித்திருக்க\nஉனக்கெனத் தவமிருக்க\nஇரு விழி சிவந்திருக்க\nஇதழ் மட்டும் வெளுத்திருக்க\nஅழகிய ரகுவரனே – அனுதினமும்\nநின்னுக்கோரி வர்ணம் வர்ணம் –\nஇசைத்திட என்னைத்தேடி வரணும் வரணும்",
          "audioSource": "eZI7kQmfu7c",
          "sourceType": "youtube",
          "mood": "Dance",
          "isSuggested": true,
          "movie": "Agni Natchathiram",
          "composer": "Ilaiyaraaja",
          "originalArtist": "K.S. Chithra",
          "difficulty": "Masterpiece",
          "searchKeywords": ["ninnukori", "varanam", "agni", "natchathiram", "chithra", "ilaiyaraaja"],
          "addedBy": "Sriram",
          "createdAt": FieldValue.serverTimestamp(),
        },
        {
          "title": "Senthoora Poove 🌺🍃",
          "lyrics": "பெண் : செந்தூர பூவே\nஇங்கு தேன் சிந்த வா\nவா தென்பாங்கு காற்றே\nநீயும் தேர் கொண்டு வா\nவா\n\nபெண் : இரு கரை மீதிலே\nதன் நிலைமீறியே ஒரு\nநதிபோல என் நெஞ்சம்\nஅலை மோதுதே……\n\nபெண் : ஓ செந்தூர பூவே\nஇங்கு தேன் சிந்த வா\nவா தென்பாங்கு காற்றே\nநீயும் தேர் கொண்டு வா\nவா\n\nஆண் : …………………….\n\nஆண் : { வெண்பனி போலே\nகண்களில் ஆடும் மல்லிகை\nதோட்டம் கண்டேன் அழகான\nவெள்ளைக்கிங்கே கலகங்கள்\nஇல்லை } (2)\n\nஆண் : அதுதானே என்றும்\nஇங்கே நான் தேடும் எல்லை\nசெந்தூர பூவே இங்கு தேன்\nசிந்த வா வா தென்பாங்கு\nகாற்றே நீயும் தேர் கொண்டு\nவா வா\n\nஆண் : மின்னலை தேடும்\nதாழம்பூவே உன் எழில்\nமின்னல் நானே பனிபார்வை\nஒன்றே போதும் பசி தீரும்\nமானே\n\nஆண் : ஆ ஹா ஹா மின்னலை\nதேடும் தாழம்பூவே உன் எழில்\nமின்னல் நானே பனிபார்வை\nஒன்றே போதும் பசி தீரும் மானே\nஉறவாடும் எந்தன் நெஞ்சம்\nஉனக்காக தானே\n\nஆண் : செந்தூர பூவே\nஇங்கு தேன் சிந்த வா\nவா தென்பாங்கு காற்றே\nநீயும் தேர் கொண்டு வா\nவா\n\nஆண் : { அன்னங்கள் போலே\nஎண்ணங்கள் கோடி ஊர்வலம்\nபோகும் வேளை நிழல் தேடும்\nசோலை ஒன்றை விழியோரம்\nகண்டேன் } (2)\nநிழலாக நானும் மாற\nபறந்தோடி வந்தேன்\n\nஆண் : செந்தூர பூவே\nஇங்கு தேன் சிந்த வா\nவா தென்பாங்கு காற்றே\nநீயும் தேர் கொண்டு வா\nவா",
          "audioSource": "T_jlO-dNXuE",
          "sourceType": "youtube",
          "mood": "Melody",
          "isSuggested": true,
          "movie": "16 Vayathinile",
          "composer": "Ilaiyaraaja",
          "originalArtist": "S. Janaki",
          "difficulty": "Masterpiece",
          "searchKeywords": ["senthoora", "poove", "vayathinile", "janaki", "ilaiyaraaja"],
          "addedBy": "Sriram",
          "createdAt": FieldValue.serverTimestamp(),
        },
        {
          "title": "Putham Pudhu Kaalai 🌅💛",
          "lyrics": "Female : Putham pudhu kaalai\nPonnira velai\nEn vazhvilae dhinandhorum thondrum\nSuga raagam ketkkum\nEnnaalum aanandham\n\nFemale : Putham pudhu kaalai\nPonnira velai….\n\nFemale : Poovil thondrum vaasam adhuthaan raagamo\nIlam poovai nenjil thondrum adhuthaan thaalamo\nManadhin aasaigal malarin kolangal\nKuyilosayin paribhashaigal\nAdhikaalaiyin varaverpugal\n\nFemale : Putham pudhu kaalai\nPonnira velai….\n\nFemale : Poovil thondrum vaasam adhuthaan raagamo\nIlam poovai nenjil thondrum adhuthaan thaalamo\nManadhin aasaigal … malarin kolangal\nKuyil osayin paribhsashaigal\nAdhikaalaiyin varaverpugal\n\nFemale : Putham pudhu kaalai\nPonnira velai……\n\nFemale : Humming …………………………\n\nFemale : Vaanil thondrum kolam adhai yaar pottadho\nPani vaadai veesum kaatril sugam yaar serthadho\nVayadhil thondridum ninaivil anandham\nValarndhoduthu isai paaduthu\nVazhi koodidum suvai kooduthu\n\nFemale : Putham pudhu kaalai\nPonnira velai\nEn vazhvilae dhinandhorum thondrum\nSuga raagam ketkum\nEnnaalum aanandham",
          "audioSource": "RKbxKRJCiYA",
          "sourceType": "youtube",
          "mood": "Romantic",
          "isSuggested": true,
          "movie": "Alaigal Oivathillai",
          "composer": "Ilaiyaraaja",
          "originalArtist": "S. Janaki",
          "difficulty": "Masterpiece",
          "searchKeywords": ["putham", "pudhu", "kaalai", "alaigal", "janaki", "ilaiyaraaja"],
          "addedBy": "Sriram",
          "createdAt": FieldValue.serverTimestamp(),
        },
        {
          "title": "Yamunai Aatrile 🌊💙",
          "lyrics": "Female : Yamunai aatrilae\nEera kaatrilae\nKannanodu dhaan aada\nPaarvai poothida\nPaadhai paarthida\nPaavai raadhaiyo vaada\n\nChorus : Yamunai aatrilae\nEera kaatrilae\nKannanodu dhaan aada\nPaarvai poothida\nPaadhai paarthida\nPaavai raadhaiyo vaada\n\nFemale : Iravum ponathu\nPagalum ponathu\nMannan illayae kooda\nIlaiya kanniyin\nImaithidaatha kan\nIngum angumae thaeda\n\nChorus : Iravum ponathu\nPagalum ponathu\nMannan illayae kooda\nIlaiya kanniyin\nImaithidaatha kan\nIngum angumae thaeda\n\nFemale : {Aayarpaadiyil kannan illaiyo\nAasai vaippathae anbu thollaiyo} (2)\nPaavam raadhaa..\n\nChorus : Yamunai aatrilae\nEera kaatrilae\nKannanodu dhaan aada\nFemale : Paarvai poothida\nPaadhai paarthida\nPaavai raadhaiyo vaada",
          "audioSource": "ZpA8mRQwTFg",
          "sourceType": "youtube",
          "mood": "Melody",
          "isSuggested": true,
          "movie": "Thalapathi",
          "composer": "Ilaiyaraaja",
          "originalArtist": "Mitali Banerjee Bhawmik",
          "difficulty": "Medium",
          "searchKeywords": ["yamunai", "aatrile", "thalapathi", "mitali", "ilaiyaraaja"],
          "addedBy": "Sriram",
          "createdAt": FieldValue.serverTimestamp(),
        },
        {
          "title": "Kuzhaloodhum Kannanukku 🪈🎵",
          "lyrics": "Female : Kuzhaloodhum kannanukku\nkuyil paadum paattu ketkuthaa\nkukkoo kukkoo kukkoo….\n\nFemale : Kuzhaloodhum kannanukku\nkuyil paadum paattu ketkuthaa\nkukkoo kukkoo kukkoo….\n\nFemale : En kuralodu machaan unga\nKuzhaloosa potti poduthaa..\n\nFlute : Kukkoo kukkoo kukkoo…\n\nFemale : Elaiyodu poovum thalaiyaattum paaru..\nElaiyodu poovum kaayum thalaiyaattum paaru paaru\n\nFemale : Kuzhaloodhum kannanukku\nkuyil paadum paattu ketkuthaa\nkukkoo kukkoo kukkoo….\n\nFemale : {Malakaathu veesurapothu malligapoo paadaathaa\nMazhamegam koodurapothu vanna mayil aadaathaa} (2)\n\nFemale : En meni thaenarumbu… en paattu poonkarumbu\nMachan naan Mettedupen unnathaan kattivaipen\nSugamana thalam thatti paadattumaa\nUnakachu enakaachu sarijodi naamaachu kelaiyaa\n\nFemale : Kuzhaloodhum kannanukku\nkuyil paadum paattu ketkuthaa\nkukkoo kukkoo kukkoo….\n\nFemale : En kuralodu machaan unga\nKuzhaloosa potti poduthaa..\n\nFlute : Kukkoo kukkoo kukkoo…\n\nFemale : {Kanna un vaaliba nenjai en paattu usuppuradha\nKarkandu sarkaraiyellam ippathaan kasakuratha} (2)\n\nFemale : Vandhachu chithirai thaan… poyaachu nithiraithaan\nPoovaana ponnukuthaan… raavaana theduthu thaan\nMedhuvaaga thoothu solli paadattumaa\nVelakethum pozhudaanaa ilanenjam padum paadu kelaiyaa…\n\nFemale : Kuzhaloodhum kannanukku\nkuyil paadum paattu ketkuthaa\nkukkoo kukkoo kukkoo….\n\nFemale : En kuralodu machaan unga\nKuzhaloosa potti poduthaa..\n\nFlute : Kukkoo kukkoo kukkoo…",
          "audioSource": "yULopMNjnW0",
          "sourceType": "youtube",
          "mood": "Melody",
          "isSuggested": true,
          "movie": "Mella Thirandhathu Kadhavu",
          "composer": "Ilaiyaraaja",
          "originalArtist": "K.S. Chithra",
          "difficulty": "Hard",
          "searchKeywords": ["kuzhaloodhum", "kannanukku", "mella", "chithra", "ilaiyaraaja"],
          "addedBy": "Sriram",
          "createdAt": FieldValue.serverTimestamp(),
        },
        {
          "title": "Ondra Renda 🔢💞",
          "lyrics": "Chorus : Mmm…mmm…mmmm…\nMmmm…mmm…mmm\n\nFemale : Ondra renda aasaigal\nEllaam sollavae orr naal podhumaa\nMale : Sollu\n\nFemale : Ondra renda aasaigal\nEllaam sollavae orr naal podhumaa\nAnbae…iravai ketkalaam…\nVidiyal thaandiyum…\nIravae neelumaa\n\nFemale : En kanavil…aaa..haaa\nNaan kanda…aahaaa..\nNaalidhudhaan…\nKalaaba kaadhalaa\nPaarvaigalaal…aa..haaa..\nPalakadhaigal …aaa…haaa..\nPesidalaam…\nKalaaba kaadhalaa\n\nFemale : Ondra renda aasaigal\nEllaam sollavae orr naal podhumaa\nAnbae…iravai ketkalaam…\nVidiyal thaandiyum…\nIravae neelumaa\n\nFemale : Pengalai nimirndhu paarthida\nUn iniya ganniyam pidikudhae\nKangalai nera paathudhaan\nNee pesum thoranai pidikudhae\n\nFemale : Dhooraththil nee vandhaalae\nEn manasil…mazhaiyadikkum\nMigapidiththa…paadal ondrai\nUdhadugalum…munumunukkum…\n\nFemale : Mandhagaasam sindhum\nUndhan mugham\nMaranam varaiyil en nenjil thangum\nUnadhu kangalil yenadhu kanavinai\nKaanapogiren…\n\nFemale : Ondra renda aasaigal\nEllaam sollavae orr naal podhumaa\nAnbae…iravai ketkalaam…ketkalaam…\nVidiyal thaandiyum…\nIravae neelumaa\n\nChorus : ……………………………\n\nFemale : Sandhiyaa kaala megangal\nUn vaanil oorvalam pogudhae\nPaarkaiyil yeno nenjilae\nUn nadayin sayalae thonudhae\n\nFemale : Nadhigalilae…neeraadum…\nSooriyanai… naan kanden\nVervaigalin thulivazhiya\nNee varuvaai…yena nindren\n\nFemale : Unnaal en nenjil aanin manam\nNaanum sondham endra ennam tharum\nMaghizhchchi meerudhae…\nVaanai thaandudhae saaga thondrudhae\nThondrudhae",
          "audioSource": "xiCsLRdq1lU",
          "sourceType": "youtube",
          "mood": "Melody",
          "isSuggested": true,
          "movie": "Kaakha Kaakha",
          "composer": "Harris Jayaraj",
          "originalArtist": "Bombay Jayashri",
          "difficulty": "Masterpiece",
          "searchKeywords": ["ondra", "renda", "kaakha", "harris", "bombay", "jayashri"],
          "addedBy": "Sriram",
          "createdAt": FieldValue.serverTimestamp(),
        },
        {
          "title": "Akkam Pakkam 🌍🕊️",
          "lyrics": "Female : Akkam pakkam yaarum illla\nBhoologam vendum\nAndhi pagal Unarugae\nNaan vaazha vendum\n\nEn aasai ellam un irukathilae\nEn ayul varai un anaipinilae\nVerenna vendum ulagathilae\nIndha inbam pothum nejinilae\nEzhezhuu jenjam vaazhndu viten\n\nFemale : Akkam pakkam yaarum illla\nBhoologam vendum\nAndhi pagal Unarugae\nNaan vaazha vendum\n\nFemale : Nee pesum vaarthaigal segarithu\nSeiven anbae orr agaraathi\nNee thoongum nerathil thoongamal\nParpen thinam un thalai kothi\nKadorathil epothumae un moochu kaatrin\nVeppam sumapen\nKayoduthaan kai korthu thaan un maarbu sootil\nMugham puthaipen\n\nFemale : Verenna vendum ulagathilae\nIndha inbam pothum nejinilae\nEzhezhuu jenjam vaazhndu viten\n\nFemale : Akkam pakkam yaarum illla\nBhoologam vendum\nAndhi pagal Unarugae\nNaan vaazha vendum\n\nFemale : Neeyum naanum serumunnae\nNizhal rendum ondru kalakirathae\nNeram kaalam theriyamal\nNenjam indru vinnil mithakiradhae\n\nFemale : Unal indru pennagavae\nNaan pirandadin arthangal arindu konden\nUn Theendalil en dhegathil\nPuthu janalgal thirapathai therindu konden\n\nFemale : Verenna vendum ulagathilae\nIndha inbam pothum nejinilae\nEzhezhuu jenjam vaazhndu viten\n\nFemale : Nana nanaa nana nanaa nanaaananana\nLalalala lalalala lalaaaala laala..",
          "audioSource": "LtnNed1PkKM",
          "sourceType": "youtube",
          "mood": "Romantic",
          "isSuggested": true,
          "movie": "Kireedam",
          "composer": "G.V. Prakash Kumar",
          "originalArtist": "Sadhana Sargam",
          "difficulty": "Masterpiece",
          "searchKeywords": ["akkam", "pakkam", "kireedam", "prakash", "sadhana", "sargam"],
          "addedBy": "Sriram",
          "createdAt": FieldValue.serverTimestamp(),
        },
        {
          "title": "Snehidhane 🤝💕",
          "lyrics": "Female : Snehidhanae snehidhanae\nRagasiya snehidhanae\nChinna chinnadhaai korikkaigal\nSevikodu snehidhanae\nIdhae azhutham azhutham\nIdhae anaippu anaippu\nVaazhvin ellai varai\nVendum vendum\nVaazhvin ellai varai\nVendum vendum\nSnehidhanae snehidhanae\n\nRagasiya snehidhanae\n\nFemale : Chinna chinna\nAthumeeral purivaai\nEn cell ellaam\nPookkal pookka cheivaai\nMalargalil malarvaai\nPoopparikkum bakthan pola medhuvaai\nNaan thoongumbodhu viral nagam kalaivaai\nSathamindri thuyilvaai\nAiviral idukkil oliv ennai poosi\nSevaiyum seiyavendum\nNeeyezhumbodhu naan azha nerndhaal\nThudaikkindra viral vendum\n\nFemale : Snehidhanae snehidhanae\nRagasiya snehidhanae\nChinna chinnadhaai korikkaigal\nSevikodu snehidhanae\n\nMale : Netru munniravil unnaithilavu madiyil\nKaatru nuzhaivadhu oh uyir\nKalandhu kalithirundhen\nIndru vinnilavil andha eera ninaivil\nKandru thavippadhu oh manam\nKalangi pulambugiren\n\n{ Koondhal nelivil ezhil kola charivil } (2)\n\nGaruvam azhindhadhadi\nEn garuvam azhindhadhadi\n\nFemale : Sonnadhellaam pagalilae puriven\nSonnadhellaam pagalile purivaen\n\nNee sollaadhadhum iravilae puriven\nKaadhil koondhal nuzhaippen\nUndhan sattai nanum pottu alaiven\nNee kulikkaiyil nanum konjam nanaiven\nUppu moottai sumappen\nUnnaiyalli eduthu ullangaiyil madithu\nKaikuttaiyil olithukkolven\nVelivarumbodhu vidudhalai Seidhu\nVendum varam vaangikkolven\n\nFemale : Snehidhanae snehidhanae\nRagasiya snehidhanae\nChinna chinnadhaai korikkaigal\nSevikodu snehidhanae",
          "audioSource": "kmG_v9FhAXg",
          "sourceType": "youtube",
          "mood": "Melody",
          "isSuggested": true,
          "movie": "Alaipayuthey",
          "composer": "A.R. Rahman",
          "originalArtist": "Sadhana Sargam, Srinivas",
          "difficulty": "Masterpiece",
          "searchKeywords": ["snehidhane", "alaipayuthey", "rahman", "sadhana", "srinivas"],
          "addedBy": "Sriram",
          "createdAt": FieldValue.serverTimestamp(),
        },
        {
          "title": "Annul Maelae ❄️💧",
          "lyrics": "Female : {Anal melae pani thuli\nAlaipaayum oru kili\nMaram thedum mazhai thuli\nIvaithaanae ival ini\nImai irandum thani thani\nUrakkangal urai pani\nEdharkaaga thadai inii…} (2)\n\nFemale : Endha kaatrin alaavalil\nMalaridazhgal virinthidumo\nEndha deva vinadiyil\nManaraigal thirandidumo\n\nFemale : Oru siruvali irunthathuvae\nIdhayathilae idhayathilae\nUnadu iruvizhi tadaviyadhal\nAmilnthuvitten mayakathilae\nUdhiratumae udalin thirai\nAdhu thaanae nilaavin karai karai\n\nFemale : Anal melae pani thuli\nAlaipaayum oru kili\nMaram thedum mazhai thuli\nIvaithaanae ival ini\nImai irandum thani thani\nUrakkangal urai pani\nEdharkaaga thadai inii…\n\nChorus : Hmm…mmmm…mmmm..\nHmm…mmmm…mmmm..mmm…\n\nFemale : Santhithomae kanaakalil\nSila muraiyaa pala muraiyaa\nAndhi vaanil ulaavinom\nAthu unakku ninaivillaiyaa\nIru karaigalai udaiththidave\nPerugidumaa kadal alaiyae\nIru iru uyir thaththalikkaiyil\nVazhi sollumaa kalangaraiyae\nUnathalaigal ennai adikka\nKarai servathum kanaavil nigazhnthida\n\nFemale : Anal melae pani thuli\nAlaipaayum oru kili\nMaram thedum mazhai thuli\nIvaithaanae ival ini\nImai irandum thani thani\nUrakkangal urai pani\nEdharkaaga thadai inii…\n\nChorus : {Hmm…mmmm…mmmm..\nHmmm..mmmm..mmm..mmmm….} (2)",
          "audioSource": "-XReR0m8tHU",
          "sourceType": "youtube",
          "mood": "Melody",
          "isSuggested": true,
          "movie": "Vaaranam Aayiram",
          "composer": "Harris Jayaraj",
          "originalArtist": "Sudha Raghunathan",
          "difficulty": "Masterpiece",
          "searchKeywords": ["annul", "maelae", "vaaranam", "harris", "sudha"],
          "addedBy": "Sriram",
          "createdAt": FieldValue.serverTimestamp(),
        },
        {
          "title": "Sandai Kozhi 🐓⚔️",
          "lyrics": "Female : Humguma huma humguma huma\nHunguma humagum\nHumguma huma humguma huma\nHunguma humagum\nHum hum hum hum humguma\nHuma hunguma humagum\n\nFemale : Sanda kozhi kozhi\nIva sanda kozhi\nKonjam thadavu thadavu\nIva sondha kozhiyaa\n\nFemale : Sanda kozhi kozhi\nIva sanda kozhi\nKonjam thadavu thadavu\nIva sondha kozhiyaa\n\nFemale : Kaiya vechaa nenjukkullae\nKaiya muiyaa\nNee rendu molathula\nPaaya podaiyaa\nSandai vandhuchaa thalli padumaiyaa\nRendu molathula paaya podaiyaa\nSandai vandhuchaa thalli padumaiyaa\n\nFemale : Konja neram\nEnna kollaiyaa aiyaa aaa\nKonja naeram enna kollaiyaa\nAiyaa yaa\nKonja naeram eenna kollaiyaa\n\nFemale : Vaangi potten vethalai\nSevakkalai saami\nVaayi muththam kuduthaa\nSevanthidum saami\nSorgapuram povonum\nNalla vazhi kaami\n\nFemale : Oh ottukkinnu maeni\nThodangattum uravu\nVatti kada polae\nValarattum vayiru\n\nFemale : Konja neram\nEnna kollaiyaa aiyaa aaa\nKonja naeram enna kollaiyaa\n\nFemale : Sanda kozhi kozhi\nIva sanda kozhi\nKonjam thadavu thadavu\nIva sondha kozhiyaa\n\nFemale : Sanda kozhi kozhi\nIva sanda kozhi\nKonjam thadavu thadavu\nIva sondha kozhiyaa\n\nFemale : Kaiya vechaa nenjukkullae\nKaiya muiyaa\n\nMale : Ah ah ah ah ah ah ah ah ah ah\nAh ah ah ah ah ah ah ah ah ah\nHey aah aah aah ah ah ah ah ah ah\nAh ah ah ah ah ah ah ah ah ah\nAh ah ah ah ah ah ah ah ah ah\nAh ah ah ah ah ah ah ah ah ah\nAh ah ah ah ah ah ah ah ah ah\n\nFemale : Machchu veedae venaam\nMettu kattu podhum\nMeththa yedhum venaam\nOththa paayi podhum\n\nFemale : Mookkuthiyin pon keethu\nRaathirikku podhum\nOh saiva muththam koduthaa\nOththu poga maatten\nSaagasatha kaattu\nSethu poga maatten",
          "audioSource": "eyI948lETfE",
          "sourceType": "youtube",
          "mood": "Dance",
          "isSuggested": true,
          "movie": "Aayutha Ezhuthu",
          "composer": "A.R. Rahman",
          "originalArtist": "Madhushree",
          "difficulty": "Hard",
          "searchKeywords": ["sandai", "kozhi", "aayutha", "rahman", "madhushree"],
          "addedBy": "Sriram",
          "createdAt": FieldValue.serverTimestamp(),
        },
        {
          "title": "Kangal Irandal 👀🏹",
          "lyrics": "Male : {Kangal irandaal un kangal irandaal\nEnnai katti izhuthai izhuthai podhadhena\nChinna sirippil oru kalla sirippil\nEnnai thalli vittu thalli vittu moodi maraithaai} (2)\n\nFemale : Pesa enni sila naal\nArugil varuven\nPinbu parvai podhum ena naan\nNinaithae nagarvenae maatri\n\nKangal ezhudhum iru kangal ezhudhum\nOru vanna kavidhai kaadhal daana\nOru varthai illayae idhil osai illayae\nIdhai irulilum padithida mudigiradhae\n\nMale : Iravum alladha pagalum alladha\nPozhudhugal unnodu kazhiyuma\nThodavum koodatha padavum koodatha\nIdaiveli appodhu kuraiyuma\n\nFemale : Madiyinil saindhida thudikudhae\nMarupuram naanamum thadukudhae\nIdhu varai yaaridamum solladha kadhai\n\nMale : Kangal irandaal un kangal irandaal\nEnnai katti izhuthai izhuthai podhadhena\nChinna sirippil oru kalla sirippil\nEnnai thalli vittu thalli vittu odi maraithai\n\nFemale : Karaigal andaatha kaatrum theendatha\nManadhirukkul eppodhu nuzhaindhitaai\nUdalum alladha uruvam kolladha\nkadavulai pol vandhu kalandhitaai\n\nMale : Unnai indri ver oru ninaivillai\nIni indha vonuyir enadhillai\nThadaiyilai saavilumae unnodu vara\n\nFemale : Kangal ezhudhum iru kangal ezhudhum\nOru vanna kavidhai kaadhal daana\nOru varthai illayae idhil osai illayae\nIdhai irulilum padithida mudigiradhae\n\nMale : Pesa enni sila naal\nArugil varuven\nPinbu paarvai podhum ena naan\nNinaithae nagarvenae maatri\n\nFemale : Kangal irandaal un kangal irandaal\nEnnai katti izhuthai izhuthai podhadhena\nMale : Chinna sirippil oru kalla sirippil\nEnnai thalli vittu thalli vittu odi maraithai",
          "audioSource": "3qj7o283j1g",
          "sourceType": "youtube",
          "mood": "Romantic",
          "isSuggested": true,
          "movie": "Subramaniapuram",
          "composer": "James Vasanthan",
          "originalArtist": "Belly Raj, Deepa Miriam",
          "difficulty": "Hard",
          "searchKeywords": ["kangal", "irandal", "subramaniapuram", "james", "deepa"],
          "addedBy": "Sriram",
          "createdAt": FieldValue.serverTimestamp(),
        },
        {
          "title": "Manmadhane Nee 🏹💔",
          "lyrics": "Female : Manmadhanae nee kalaignyan thaan\nManmadhanae nee kavingyan thaan\nManmadhanae nee kaadhalan thaan\nManmadhanae nee kaavalan thaan\n\nFemale : Ennai unakullae tholaithen yeno theriyala\nUnnai kanda nodi yeno innum nagarala\nUnthan rasigai nanum unaken puriyavillai\n\nFemale : { Ethanai aangal kadanthu vanthen\nEvanaiyum pidikavillai\nIrubathu varudam unnai pol evanum\nEnnaiyum mayakavillai } (2)\n\nFemale : Manmadhanae nee kalaignyan thaan\nManmadhane nee kavingyan thaan\nManmadhanae nee kaadhalan thaan\nManmadhanae nee kaavalan thaan\n\nMale : …………………………………\n\nFemale : Lai lai lai lalaa\nLai lai lai lalaa …. lai lai lai lai lalaa\n\nFemale : Naanum oar pennena pirantha palanai indrae thaan Adainthen\nUnnai naan paartha pin aangal vargathai naanum mathithen\nEnthan nenjil oonjal katti aadi kondae irukiraai\nEnakul pugunthu engo neeyum odi kondae irukiraai\n\nFemale : Azhagaai naanum maarugiren\nArivaai naanum pesugiren\nSugamaai naanum malarugiren\nUnakethum therigirathaa\n\nFemale : { Oru murai paarthaal pala murai inikira enna visithiramo\nNanbanae enaku kaadhalan aanaal athuthaan sarithiramo } (2)\n\nFemale : Manmadhanae unnai paarkiren\nManmadhanae unnai rasikiren\nManmadhanae unnai rusikiren\nManmadhanae unnil vasikiren\n\nFemale : Unnai muzhuthaaga naanum mendru muzhungavo\nUnthan munnadi matum vetkam marakavo\nEnthan padukaraiku unthan peyarai vaikavo\n\nFemale : { Adimai saasanam ezhuthi tharugiren ennai yetru kolla\nAayul varayil unnudan irupen anbaai paarthu kolla } (2)\n\nFemale : Aahaha haa haa haa haa … aahaha haa\nAahaha haa haa haa haa ….. aahaha haa",
          "audioSource": "MFf94YYSi_o",
          "sourceType": "youtube",
          "mood": "Melody",
          "isSuggested": true,
          "movie": "Manmadhan",
          "composer": "Yuvan Shankar Raja",
          "originalArtist": "Sadhana Sargam",
          "difficulty": "Medium",
          "searchKeywords": ["manmadhane", "nee", "manmadhan", "yuvan", "sadhana"],
          "addedBy": "Sriram",
          "createdAt": FieldValue.serverTimestamp(),
        },
        {
          "title": "Aathadi Manasudhan 🕊️❤️",
          "lyrics": "Male : Aathadi manasudhaan\nRekkakatti parakuthae\nAanalum vayasudhaan\nKitta vara thayanguthae\n\nMale : Akkam pakkam\nPaarthu paarthu\nAasaiyaaga veesum kaathu\nNenjukulla yedho pesuthae…ae…\n\nMale : Adada indha manasudhan\nSuthi suthi unna theduthae\nAzhaga indha kolusudhan\nAda thathi thathi un peyar solludhae\n\nMale : Aathadi manasudhaan\nRekkakatti parakuthae\nAanalum vayasudhaan\nKitta vara thayanguthae\n\nMale : Kitta vandhu neeyum\nPesum podhu\nKitta thatta kannu verthu pogum\nMoochae kaaichalaa maarum\n\nMale : Vittu vittu unna\nPaarkum podhu\nVetti vetti minnal onnu modhum\nManasae maargazhi maasam\n\nMale : Arugil undhan vaasam\nIntha kaathil veesuthu\nVizhi theruvil pogum undhan\nUruvam theduthu\n\nMale : Paavi nenja enna senja\nUndhan pera solli konja\nAvala konnaalum appodhum\nUn pera solvaaladaa\n\nMale : Onna renda enna\nNaanum solla\nOraayiram aasa vachen ulla\nPesa dhairiyam illa\n\nMale : Ohoo..ulla oru vartha\nVandhu thulla\nUllam avala mutti mutti thalla\nIrundhum vetkathil sella\n\nMale : Kaalam ellam avala\nNee paarthae vazhanum\nUyir pogum neram avalin\nMadiyil saaindhae saaganaum\n\nMale : Unna thavira enna venum\nVera enna ketka thonum\nNenjam avaloda vazhaama\nMannodu saayaadhada …aaa….",
          "audioSource": "vw1YxqeOvHU",
          "sourceType": "youtube",
          "mood": "Melody",
          "isSuggested": true,
          "movie": "Kazhugu",
          "composer": "Yuvan Shankar Raja",
          "originalArtist": "Priya Himesh",
          "difficulty": "Medium",
          "searchKeywords": ["aathadi", "manasudhan", "kazhugu", "yuvan", "priya", "himesh"],
          "addedBy": "Sriram",
          "createdAt": FieldValue.serverTimestamp(),
        },
        {
          "title": "Sha La La 💃🕺",
          "lyrics": "Female : Sha la la sha la la\nRettai vaal vennila\nEnnai pol chuttippen\nIndha bhoomiyilaa\n\nFemale : Se se se sevvandhi\nEn thozhi saamandhi\nVetrikku eppothum\nNaan thaanae mundhi\n\nFemale : Kottum aruvi vi vi\nEnnai thazhuvi vi vi\nAlli kolla aasaikalvan\nIngae varuvaanoo\n\nChorus : Dum taka dum taka dum dum\nDum taka dum taka dum dum\nDum taka dum taka dum dum\nDum taka dum taka dum dum\n\nFemale : Sha la la sha la la\nRettai vaal vennila\nEnnai pol chuttippen\nIndha bhoomiyilaa\n\nFemale : Na na na…nana\nNana nana nana naaanaa\nNan nana nana nana naa\nNana naanaa naanaa naa naa\n\nFemale : Marangalae marangalae\nOtrai kaalil iruppathen\nEnnavoo ennavoo thavamaa\n\nFemale : Nadhigalae nadhigalae\nSaththam pottu thaan nadappathen\nKaalgalin viralgalae kolusaa\n\nFemale : Bhaarathi pola thalaipaagai\nKattiyathae theekuchi\nNeruppillaamal pugai varuthae\nAdhisayamaana neerveezhchi\n\nFemale : Idayai aati nadayai aati\nOdum rayilae sol\nNaatiyamaa…hey naatiyamaa\n\nChorus : Dum taka dum taka dum dum\nDum taka dum taka dum dum\nDum taka dum taka dum dum\nDum taka dum taka dum dum\n\nFemale : Ta ta ta ta ta ta\nTa ta ta ..ta ta ta\nTata ta tata ta tata tata taa\n\nChorus : Doom doom do do doom\nDoom doom do do doom\nDoom doom do do doom\nDoom doom do do doom\n\nFemale : Thannaa nana…\nThanna nana nana naa\nThannaa nana……ohooo….\n\nFemale : Thaai mugam paartha naal\nThaavani potta naal\nMarakkumaa marakkumaa nenjae\n\nFemale : Mazhaithuli rasithathum\nPani thuli rusithathum\nKaraiyuma karaiyuma kannil\n\nFemale : Hyder kaala veeranthaan\nKuthirai yeri varuvaanoo\nKaaval thaandi ennai thaan\nKadathi kondu povaanoo\n\nFemale : Kannukkul mudhal\nNenjukkul varai\nAasai saemikkiraen\nYaaravanoo yaaravanoo\n\nChorus : Dum taka dum taka dum dum\nDum taka dum taka dum dum\nDum taka dum taka dum dum\nDum taka dum taka dum dum\n\nFemale : Sha la la sha la la\nRettai vaal vennila\nEnnai pol chuttippen\nIndha bhoomiyilaa\n\nFemale : Kottum aruvi vi vi\nEnnai thazhuvi vi vi\nAlli kolla aasaikalvan\nIngae varuvaanoo\n\nChorus : Dum taka dum taka dum dum\nDum taka dum taka dum dum\nDum taka dum taka dum dum\nDum taka dum taka dum dum",
          "audioSource": "w9J3KfloL14",
          "sourceType": "youtube",
          "mood": "Dance",
          "isSuggested": true,
          "movie": "Ghilli",
          "composer": "Vidyasagar",
          "originalArtist": "Sunidhi Chauhan",
          "difficulty": "Medium",
          "searchKeywords": ["sha", "la", "ghilli", "vidyasagar", "sunidhi", "chauhan"],
          "addedBy": "Sriram",
          "createdAt": FieldValue.serverTimestamp(),
        },
        {
          "title": "Kannazhaga 👀❤️",
          "lyrics": "Female : Kannazhaga.. kaalazhaga\nPonnazhaga.. penn azhaga\nEngaeyo thaedi sellum.. viral azhaga\nEn kaigal korthu kollum vidham azhaga\n\nMale : Uyirae uyirae unaivida edhuvum\nUyril peridhaai illayadi\nAzhagae azhagae unaivida edhuvum\nAzhagil azhagaai illaiyadi\n\nFemale : Engaeyo paarkiraai\nEnnenna solgiraai\nEllaigal thaandida\nMaayangam seikiraai\n\nMale : Unnakul paarkiren\nUlladhai solgiren\nUnnuyir serndhida\nNaan vazhi paarkiren\n\nFemale : Idhazhum idhazhum\nInnaiyattumae\npudhidhaai vazhigal illai\nMale : Immaigal moodi aruginil vaa\nIdhupol edhuvum illai\n\nFemale : Unnakul paarkava\nUlladhai ketkkava\nEnnuyir serndhida\nNaan vazhi sollava\n\nMale : Kannazhagae perazhagae\nPenn azhagae ennazhagae\n\nMale : Uyirae uyirae unaivida edhuvum\nUyril peridhaai illayadi",
          "audioSource": "0tX2ck4Rmzk",
          "sourceType": "youtube",
          "mood": "Romantic",
          "isSuggested": true,
          "movie": "3",
          "composer": "Anirudh Ravichander",
          "originalArtist": "Dhanush, Shruti Haasan",
          "difficulty": "Medium",
          "searchKeywords": ["kannazhaga", "dhanush", "anirudh", "shruti", "haasan"],
          "addedBy": "Sriram",
          "createdAt": FieldValue.serverTimestamp(),
        }
      ];

      for (var song in premiumSongs) {
        // UPSERT LOGIC: Use title as unique identifier
        final query = await songsCollection.where('title', isEqualTo: song['title']).limit(1).get();
        
        if (query.docs.isNotEmpty) {
          // Update existing document
          await songsCollection.doc(query.docs.first.id).update(song);
          debugPrint('Updated existing track: ${song['title']}');
        } else {
          // Create new document
          await songsCollection.add(song);
          debugPrint('Added new premium track: ${song['title']}');
        }
      }
    } catch (e) { 
        debugPrint('Seed error: $e');
      }
  }
}
