# talimatlar_parti1.py
#
# Pisirme talimatlari -- I. Parti: orijinal 75 "Klasik" tariflik
# kutuphanenin I. Grup (ana yemek) tarifleri (30 adet).
# talimat_yukle.py ile (recete_id'yi isme gore bulup UPDATE ederek)
# Supabase'e islenir.

TALIMATLAR = {
    "Dana Kuşbaşı Sote": """1. Dana kuşbaşı etini oda sıcaklığına getirin, kağıt havluyla kurulayın.
2. Geniş bir tavada yağı kızdırın, eti parti parti (tavayı doldurmadan) yüksek ateşte mühürleyin.
3. Doğranmış soğanı ekleyip pembeleşene kadar kavurun.
4. Ateşi kısıp kapağı kapatarak et yumuşayana kadar (yakl. 25-30 dk) kendi suyunda pişirin, gerekirse az su ekleyin.
5. Son 5 dakikada tuz ve karabiberle tatlandırıp sıcak servis edin.""",

    "Izgara Dana Biftek": """1. Bifteği pişirmeden en az 20 dakika önce buzdolabından çıkarın, oda sıcaklığına gelsin.
2. Her iki yüzünü kağıt havluyla kurulayın, zeytinyağı sürüp tuz ve karabiberle baharatlayın.
3. Izgara ya da dökme tavayı dumanı tütene kadar çok kızdırın.
4. Bifteği istenen pişirme derecesine göre her yüzde 2-4 dakika çevirmeden pişirin.
5. Ocaktan alıp folyoyla örterek 5 dakika dinlendirin, sonra dilimleyip servis edin.""",

    "Kuzu Tandır": """1. Kuzu eti parçasını tuz ve karabiberle ovun, üzerine ince doğranmış soğan serpin.
2. Fırın kabına yerleştirip az su ilave edin, kapağını kapatın (ya da folyoyla sıkıca örtün).
3. 160°C fırında 2,5-3 saat, et kemikten ayrılana kadar ağır ateşte pişirin.
4. Son 15 dakika kapağı açıp üstünü kızartarak rengini alın.
5. Pişirme suyuyla birlikte parçalayarak servis edin.""",

    "Sığır Kaburga Haşlama": """1. Kaburga etini soğuk suyla yıkayın, geniş bir tencereye alın.
2. Üzerini geçecek kadar su ekleyin, kaynayınca oluşan köpüğü alın.
3. İri doğranmış soğan, havuç ve birkaç tane karabiber tanesini ekleyin.
4. Ateşi kısıp kapağı aralık bırakarak et kemikten ayrılana kadar (yakl. 2 saat) ağır ateşte haşlayın.
5. Son 10 dakikada tuzu ekleyin, süzülmüş et ve sebzeleri sıcak servis edin.""",

    "Dana Rosto": """1. Rosto etini oda sıcaklığına getirin, tuz ve karabiberle ovun.
2. Tencerede yağı kızdırıp etin her yüzünü mühürleyin.
3. Doğranmış soğanı ekleyip pembeleşene kadar kavurun.
4. Az su ekleyip kapağı kapatarak kısık ateşte 1-1,5 saat, et yumuşayana kadar pişirin.
5. Dilimleyip kendi sosuyla servis edin.""",

    "Kuzu Pirzola Izgara": """1. Pirzolaları pişirmeden 20 dakika önce çıkarıp oda sıcaklığına getirin.
2. Zeytinyağı, tuz ve karabiberle ovup dinlendirin.
3. Izgarayı çok kızdırın, pirzolaları her yüzde 3-4 dakika (orta pişmiş için) çevirin.
4. Kalın kesimlerde kenarları da birkaç saniye ızgaraya değdirerek pişirin.
5. Ocaktan alıp 3-4 dakika dinlendirdikten sonra servis edin.""",

    "Fırında Tavuk But": """1. Tavuk butlarını yıkayıp kurulayın, zeytinyağı, tuz ve karabiberle ovun.
2. İsteğe göre limon dilimleri ve sarımsakla birlikte fırın tepsisine dizin.
3. 200°C'ye ısıtılmış fırında 35-40 dakika, ara sıra kendi yağıyla yağlayarak pişirin.
4. Üzeri kızarıp iç sıcaklığı yeterli olduğunda (bıçakla kestiğinizde suyu berrak akmalı) fırından alın.
5. 5 dakika dinlendirip servis edin.""",

    "Tavuk Şiş": """1. Tavuk göğsünü küp küp doğrayın, zeytinyağı, tuz, karabiber ve limonla marine edip en az 30 dakika bekletin.
2. Etleri şişlere dizin.
3. Izgara ya da tavayı iyice kızdırın.
4. Şişleri çevirerek her yüzü altın rengi alana kadar, toplam 10-12 dakika pişirin.
5. İçinin tam piştiğinden emin olduktan sonra servis edin.""",

    "Tavuk Sote": """1. Tavuk göğsünü ince şeritler halinde doğrayın.
2. Tavada yağı kızdırıp doğranmış soğanı pembeleşene kadar kavurun.
3. Tavuğu ekleyip yüksek ateşte rengi dönene kadar karıştırarak pişirin.
4. Ateşi orta seviyeye alıp tavuk suyunu tamamen çekene, et yumuşayana kadar pişirmeye devam edin.
5. Tuz ve karabiberle tatlandırıp sıcak servis edin.""",

    "Tavuk Suyu Haşlama": """1. Tavuk parçalarını geniş bir tencereye alıp üzerini geçecek kadar soğuk su ekleyin.
2. Kaynamaya başlayınca oluşan köpüğü kaşıkla alın.
3. İri doğranmış soğan, havuç ve birkaç tane karabiber ekleyin.
4. Ateşi kısıp kapağı aralık bırakarak et kemikten ayrılana kadar (yakl. 45-60 dk) haşlayın.
5. Son 10 dakikada tuz ekleyin; hem et hem elde ettiğiniz tavuk suyu kullanıma hazırdır.""",

    "Kremalı Mantarlı Tavuk": """1. Tavuk göğsünü dilimleyip tuz ve karabiberle tatlandırın.
2. Tavada yağda her iki yüzü kızarana kadar mühürleyip tavadan alın.
3. Aynı tavada doğranmış mantarları suyunu salıp çekene kadar kavurun.
4. Kremayı ekleyip karıştırarak kaynatın, tavuğu tekrar tavaya alıp sosla kaplayın.
5. Kısık ateşte 5 dakika daha pişirip sıcak servis edin.""",

    "Izgara Tavuk Göğsü": """1. Tavuk göğsünü eşit kalınlıkta olacak şekilde hafifçe tokmaklayın ya da dilimleyin.
2. Zeytinyağı, tuz, karabiber ve isteğe göre kekikle marine edin.
3. Izgara ya da dökme tavayı iyice kızdırın.
4. Her yüzünü 5-6 dakika, içi tam pişene kadar çevirerek ızgara yapın.
5. 2-3 dakika dinlendirip servis edin.""",

    "Fırında Levrek": """1. Levreği temizletip yıkayın, iç ve dış yüzeyini tuzlayın.
2. Karnına limon dilimi ve taze dereotu yerleştirin.
3. Üzerine zeytinyağı gezdirip fırın tepsisine alın.
4. 200°C fırında 20-25 dakika, eti kolayca kemikten ayrılana kadar pişirin.
5. Limon dilimleriyle servis edin.""",

    "Izgara Çipura": """1. Çipurayı temizletip yıkayın, her iki yüzüne çapraz kesikler atın.
2. Zeytinyağı ve tuzla ovun.
3. Izgarayı orta-yüksek ateşte kızdırın.
4. Balığı her yüzde 6-8 dakika, derisi çıtır çıtır olana kadar pişirin.
5. Limon ile sıcak servis edin.""",

    "Hamsi Tava": """1. Hamsileri temizleyip yıkayın, kağıt havluyla kurulayın.
2. Mısır unu, tuz ve karabiberle harmanlayın.
3. Hamsileri una bulayıp fazlasını silkeleyin.
4. Bol sıcak yağda her yüzü altın rengi alana kadar kızartın.
5. Kağıt havlu üzerinde fazla yağını aldırıp sıcak servis edin.""",

    "Somon Izgara": """1. Somon fileto pişirmeden 15 dakika önce buzdolabından çıkarın.
2. Zeytinyağı, tuz, karabiber ve limonla ovun.
3. Izgara ya da tavayı kızdırın, önce deri tarafından başlayarak pişirin.
4. Deri çıtır olduğunda çevirip diğer yüzü de 3-4 dakika pişirin.
5. İç kısmı hafif pembe kalacak şekilde ocaktan alıp servis edin.""",

    "Karides Güveç": """1. Karidesleri kabuklarından ve bağırsak ipliğinden temizleyin.
2. Güveç kabında zeytinyağında doğranmış soğan ve sarımsağı kavurun.
3. Domates (ya da domates sosu) ekleyip birkaç dakika pişirin.
4. Karidesleri ekleyip 3-4 dakika, pembeleşene kadar (fazla pişirmeyin) pişirin.
5. Üzerine kaşar peyniri serpip fırında peynir eriyene kadar tutup sıcak servis edin.""",

    "Kalamar Tava": """1. Kalamarları halka halka doğrayın, kağıt havluyla kurulayın.
2. Un, tuz ve karabiberle harmanlayın.
3. Kalamar halkalarını una bulayıp fazlasını silkeleyin.
4. Bol sıcak yağda 1-2 dakika (fazla pişirirseniz lastikleşir) hızlıca kızartın.
5. Limon dilimiyle hemen sıcak servis edin.""",

    "Karnıyarık": """1. Patlıcanları soyup çizik atarak bol yağda kızartın (ya da fırında közleyin), kenara alın.
2. Ayrı bir tavada kıymayı doğranmış soğan ve sarımsakla kavurun.
3. Domates, yeşil biber ve baharatları ekleyip harcı pişirin.
4. Kızarmış patlıcanları fırın kabına dizip ortalarını açarak harcı doldurun.
5. Üzerine domates dilimi koyup 180°C fırında 20 dakika pişirin.""",

    "Etli Biber Dolması": """1. Biberlerin kapaklarını kesip içini boşaltın.
2. Kıymayı pirinç, doğranmış soğan ve baharatlarla harmanlayın.
3. Harcı biberlere, üstte biraz boşluk bırakarak (pirinç şişer) doldurun.
4. Tencereye dik dizip üzerine domates ve su ekleyin.
5. Kapağı kapatıp kısık ateşte 40-45 dakika, pirinç yumuşayana kadar pişirin.""",

    "Etli Kabak Dolması": """1. Kabakları oyup içini boşaltın (kabuğu delmemeye dikkat edin).
2. Kıymayı pirinç, doğranmış soğan ve baharatlarla harmanlayın.
3. Harcı kabaklara doldurun.
4. Tencereye dizip az su ekleyip kapağını kapatın.
5. Kısık ateşte 35-40 dakika, kabak ve pirinç yumuşayana kadar pişirin.""",

    "Etli Yaprak Sarma": """1. Salamura yaprakları tuzunu gidermek için sıcak suda birkaç dakika bekletip süzün.
2. Kıymayı pirinç, doğranmış soğan ve baharatlarla harmanlayın.
3. Her yaprağın parlak yüzü altta kalacak şekilde bir tutam harç koyup sıkıca sarın.
4. Tencereye sık dizip üzerine ters bir tabak, ardından az su koyun.
5. Kısık ateşte 40-45 dakika pişirip sıcak servis edin.""",

    "Patlıcan Musakka": """1. Patlıcanları dilimleyip hafif tuzlayın, 15 dakika suyunu bıraktıktan sonra kurulayın.
2. Dilimleri bol yağda her iki yüzü kızarana kadar kızartın.
3. Ayrı bir tavada kıymayı soğan ve domatesle kavurup harcı hazırlayın.
4. Fırın kabına patlıcan ve kıyma harcını sırayla katman katman dizin.
5. Üzerine domates dilimi koyup 180°C fırında 20-25 dakika pişirin.""",

    "Etli Kuru Fasulye": """1. Kuru fasulyeyi bir gece önceden suda bekletin, suyunu süzün.
2. Tencerede kıymayı (ya da kuşbaşı eti) doğranmış soğanla kavurun.
3. Fasulyeyi ekleyip üzerini geçecek kadar su koyun.
4. Domates salçası ve baharatları ekleyip kapağı kapatarak fasulye yumuşayana kadar (yakl. 1-1,5 saat) pişirin.
5. Kıvamını kontrol edip tuzunu ayarlayarak servis edin.""",

    "Etli Nohut Yemeği": """1. Nohutları bir gece önceden suda bekletin (ya da haşlanmış nohut kullanın).
2. Tencerede eti doğranmış soğanla kavurun.
3. Nohutu ekleyip üzerini geçecek kadar su koyun.
4. Domates salçası ekleyip kapağı kapatarak et ve nohut yumuşayana kadar pişirin.
5. Tuzunu ayarlayıp sıcak servis edin.""",

    "Mercimek Köftesi": """1. Kırmızı mercimeği yıkayıp suyla haşlayın, suyunu çekince ince bulguru ekleyip demlenmeye bırakın (10 dk).
2. Karışım ılınınca doğranmış soğan, salça, baharat ve limon suyunu ekleyin.
3. Karışımı yoğurarak pürüzsüz bir kıvam elde edin.
4. Avuç içinde küçük parçalar alıp şekil verin.
5. Marul yaprağı ya da limonla servis edin (pişirme gerekmez).""",

    "Zeytinyağlı Barbunya Pilaki": """1. Taze barbunyayı ayıklayıp yıkayın.
2. Tencerede zeytinyağında doğranmış soğan ve havucu kavurun.
3. Barbunyayı ekleyip birkaç dakika çevirin.
4. Domates ve az su ekleyip kapağını kapatarak barbunya yumuşayana kadar (yakl. 25-30 dk) pişirin.
5. Ilık ya da soğuk servis edin.""",

    "Zeytinyağlı Nohut Yemeği": """1. Haşlanmış nohutu hazırlayın (ya da bir gece bekletip haşlayın).
2. Tencerede zeytinyağında doğranmış soğanı kavurun.
3. Nohutu ve domatesi (ya da salçayı) ekleyip az su koyun.
4. Kapağı kapatıp kısık ateşte 15-20 dakika, sos koyulaşana kadar pişirin.
5. Ilık ya da soğuk servis edin.""",

    "Menemen": """1. Domatesleri rendeleyin ya da küçük küp doğrayın, yeşil biberi ince doğrayın.
2. Tavada yağda biberi birkaç dakika kavurun.
3. Domatesi ekleyip suyunu salıp çekene kadar pişirin.
4. Yumurtaları kırıp karıştırmadan ya da hafif karıştırarak (kişisel tercihe göre) pişirin.
5. Kıvamı istediğiniz gibi olunca tuzla tatlandırıp hemen servis edin.""",

    "Sahanda Yumurta (Sucuklu)": """1. Sucuğu ince dilimleyin.
2. Tavada yağda sucuğu her iki yüzü kızarıp yağını bırakana kadar pişirin.
3. Yumurtaları doğrudan sucuğun üzerine kırın.
4. Kapağı kapatıp ak kısım pişene, sarısı istenen kıvama gelene kadar kısık ateşte pişirin.
5. Sıcak servis edin.""",
}
