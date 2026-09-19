import os
print("Calisma dizini:", os.getcwd())
print("Dosya var mi:", os.path.exists("pages/0_Yillik_Menu.py"))

with open("pages/0_Yillik_Menu.py", encoding="utf-8") as f:
    satirlar = f.readlines()
print("Toplam satir sayisi:", len(satirlar))

with open("hedef_teshis_ciktisi.txt", "w", encoding="utf-8") as out:
    for i in range(1590, 1665):
        out.write(f"{i+1}: {satirlar[i]}")

print("BASARILI -- hedef_teshis_ciktisi.txt olusturuldu.")
print("Tam yolu:", os.path.abspath("hedef_teshis_ciktisi.txt"))
