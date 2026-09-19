with open("pages/0_Yillik_Menu.py", encoding="utf-8") as f:
    satirlar = f.readlines()
with open("gecici_cikti.txt", "w", encoding="utf-8") as out:
    for i in range(1590, 1665):
        out.write(f"{i+1}: {satirlar[i]}")
print("Yazildi: gecici_cikti.txt")
