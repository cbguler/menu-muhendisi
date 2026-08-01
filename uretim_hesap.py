# uretim_hesap.py
#
# Kritik yol (critical path) hesabı: bir reçetenin aşamaları, birbirine
# bağımlılıklarına göre bir DAG (yönlendirilmiş döngüsüz graf) oluşturur.
# Bağımlılığı olmayan aşamalar paralel sayılır -- toplam geçen süre, tüm
# aşamaların toplamı değil, EN UZUN YOLUN (kritik yolun) süresidir.
#
# Bunu genel bir DAG için SQL'de doğru hesaplamak kırılgan (özellikle bir
# aşamanın birden fazla önceki aşamaya bağlı olduğu "elmas" durumlarda),
# bu yüzden klasik topolojik sıralama + dinamik programlama burada,
# Python'da yapılır. İki senaryoyla (elmas bağımlılık + paralel dal) test
# edilmiştir.

from collections import defaultdict, deque


def kritik_yolu_hesapla(asamalar, bagimliliklar):
    """
    asamalar: [{"id": ..., "sure_dakika": ...}, ...]
    bagimliliklar: [{"asama_id": ..., "onceki_asama_id": ...}, ...]

    Dönüş: {
        "toplam_sure_dakika": float,
        "en_erken_bitis": {asama_id: dakika, ...},
        "kritik_yol": [asama_id, ...],  # en uzun yolu oluşturan aşamalar, sıralı
    }
    """
    sure = {a["id"]: a["sure_dakika"] for a in asamalar}
    onceki = defaultdict(list)
    sonraki = defaultdict(list)

    for b in bagimliliklar:
        onceki[b["asama_id"]].append(b["onceki_asama_id"])
        sonraki[b["onceki_asama_id"]].append(b["asama_id"])

    # Kahn algoritması ile topolojik sıralama
    giris_derecesi = {a["id"]: len(onceki[a["id"]]) for a in asamalar}
    kuyruk = deque([aid for aid, derece in giris_derecesi.items() if derece == 0])
    sirali = []

    while kuyruk:
        aid = kuyruk.popleft()
        sirali.append(aid)
        for sonraki_aid in sonraki[aid]:
            giris_derecesi[sonraki_aid] -= 1
            if giris_derecesi[sonraki_aid] == 0:
                kuyruk.append(sonraki_aid)

    if len(sirali) != len(asamalar):
        raise ValueError(
            "Aşama bağımlılıklarında döngü tespit edildi -- kritik yol hesaplanamaz."
        )

    en_erken_bitis = {}
    onceki_asama_izi = {}

    for aid in sirali:
        if not onceki[aid]:
            en_erken_bitis[aid] = sure[aid]
            onceki_asama_izi[aid] = None
        else:
            en_iyi_onceki = max(onceki[aid], key=lambda o: en_erken_bitis[o])
            en_erken_bitis[aid] = en_erken_bitis[en_iyi_onceki] + sure[aid]
            onceki_asama_izi[aid] = en_iyi_onceki

    if not en_erken_bitis:
        return {"toplam_sure_dakika": 0, "en_erken_bitis": {}, "kritik_yol": []}

    son_asama = max(en_erken_bitis, key=lambda a: en_erken_bitis[a])
    toplam_sure = en_erken_bitis[son_asama]

    kritik_yol = []
    a = son_asama
    while a is not None:
        kritik_yol.append(a)
        a = onceki_asama_izi[a]
    kritik_yol.reverse()

    return {
        "toplam_sure_dakika": toplam_sure,
        "en_erken_bitis": en_erken_bitis,
        "kritik_yol": kritik_yol,
    }
