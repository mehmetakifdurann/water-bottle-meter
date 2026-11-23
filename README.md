# Su Şişesi Doluluk Ölçer

Bir şişe fotoğrafını açıp su çizgisini gösteren ve doluluğu yüzde olarak tahmin eden Türkçe MATLAB masaüstü uygulaması. İşlem yerel olarak yapılır. Python ve ek MATLAB toolbox gerekmez.

## Çalıştırma

1. ZIP dosyasını açın. MATLAB'da **Current Folder** olarak `su-sisesi-matlab` klasörünü seçin.
2. **Command Window**'da şu komutu çalıştırın.

   ```matlab
   SuSisesiDoluluk
   ```

3. **Fotoğraf Aç** ile JPG, PNG, TIFF veya HEIC seçin. **Örneği Aç** düğmesiyle %75'lik sentetik örneği deneyebilirsiniz.

MATLAB R2025a ve sonrası için yazıldı. Testler macOS üzerinde MATLAB R2026b Update 1 ile çalıştırıldı.

## Fotoğrafı çekme ve sonucu düzeltme

- Tek şişeyi dik tutun ve tamamı kadraja girecek şekilde yandan, mümkünse şişenin orta hizasından çekin. Sağda ve solda boşluk bırakın. Düz bir fon ve yumuşak ışık kullanın.
- Turkuaz çizgi su yüzeyinden farklı bir yerdeyse **Su Çizgisini İşaretle** düğmesine basıp doğru seviyeye tıklayın. Bu işlem algılanan şişe profilini kullanır.
- Şişenin sınırı bulunamadıysa **Şişeyi Elle Çerçevele** düğmesine basın. Kapağı dışarıda bırakıp şişenin iç hacmini çevreleyen kutunun önce sol üst, sonra sağ alt köşesini seçin. Son olarak su seviyesine tıklayın. Bu modda ekranda yükseklik oranı gösterilir. Bir şişenin boş veya dolu olduğunu biliyorsanız seviyeyi sırasıyla alt veya üst sınıra işaretleyebilirsiniz.

## Ölçümün kapsamı

Otomatik mod, şişenin dış hatlarını ve gövdesindeki yatay görüntü değişimini arar. İç hacim, satır satır görünen genişliğin karesiyle ağırlıklandırılır. Su çizgisinin altında kalan toplam ağırlık yüzdeye çevrilir. Bu yaklaşım, kamera açısı düz olduğunda ve şişenin yatay kesitleri benzer şekli koruduğunda hacim için yaklaşık bir sonuç verir.

Opak şişe veya etiketten dolayı su çizgisi görünmüyorsa doluluk fotoğraftan belirlenemez. Desenli fon, güçlü gölge, yansıma, eğik çekim ve etiket otomatik algılamayı bozabilir. Su çizgisinin görünmediği tam dolu veya boş şişeler için uygulama otomatik yüzde vermeyebilir.

## Örnekler ve test

`ornekler/` klasöründe bilinen %25, %50 ve %75 hacim oranlarıyla oluşturulmuş sentetik şişe görselleri vardır. Altı sentetik testte hedef oran ile tahmin arasındaki en büyük fark 0,6 yüzde puanıydı.

```matlab
testBottleFill
```

Arayüzü açmadan işlemek için:

```matlab
sonuc = estimateBottleFill("ornekler/sise_75.png");
disp(sonuc.percent)
```

Otomatik ölçüm yapılamadığında `sonuc.percent` değeri `NaN` olur ve `sonuc.message` açıklama içerir.

### Gerçek fotoğraf testi

Wikimedia Commons'tan indirilen yedi orijinal JPEG, elle kırpma veya ışık düzeltmesi uygulanmadan MATLAB R2026b Update 1'de test edildi. **Otomatik mod 7 fotoğrafın hiçbirinde şişe sınırını çıkaramadı ve yüzde göstermedi.**

| Fotoğraf | Kaynak açıklaması | Elle işaretleme |
| --- | --- | --- |
| Gölgeli çekim | Yarıya yakın su | |
| Etiketli PET şişe | Yarıya yakın su | %52 yükseklik oranı |
| Sokakta asılı şişe | Yaklaşık yarı dolu | |
| Şeffaf şişe | Boş | |
| Yatay kadrajda şişe | Az miktarda su kalıntısı | |
| Siyah kapaklı şişe | Dolu | |
| Cam yüzey üzerinde şişe | Su içeriyor | %85 yükseklik oranı |

Elle işaretlenen yüzdeler, fotoğrafta seçilen su çizgisinin şişe yüksekliğine oranıdır. Kaynaklarda ölçülmüş hacim yüzdeleri verilmediği için bu sonuçlarla hacim doğruluğu hesaplanamaz. Bir JPEG'in yön etiketindeki geçersiz değer MATLAB uyarısı verdi ve görüntü yine açıldı.

[Gölgeli çekim](https://commons.wikimedia.org/wiki/File:Bottle_of_Water.jpg) · [Etiketli PET şişe](https://commons.wikimedia.org/wiki/File:Botella_de_pl%C3%A1stico_-_PET.jpg) · [Sokakta asılı şişe](https://commons.wikimedia.org/wiki/File:DSC_6417_A_half-filled_plastic_bottle_hanging_by_a_string_above_a_blurred_street_scene_at_dusk.jpg) · [Şeffaf şişe](https://commons.wikimedia.org/wiki/File:Clear_water_bottle.jpg) · [Kalıntı su bulunan şişe](https://commons.wikimedia.org/wiki/File:Empty_Plastic_Bottle.jpg) · [Siyah kapaklı şişe](https://commons.wikimedia.org/wiki/File:Cil%C3%ADndrica_botella_de_agua_con_tapa_negra.jpg) · [Cam yüzey üzerinde şişe](https://commons.wikimedia.org/wiki/File:Plastic_Water_Bottle.jpg)
