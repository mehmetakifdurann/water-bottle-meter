# Su Şişesi Doluluk Ölçer

Su Şişesi Doluluk Ölçer, tek bir fotoğraftan şişenin doluluk oranını tahmin eden Türkçe bir MATLAB masaüstü uygulamasıdır. Şişenin dış hatları ve su çizgisi algılandığında fotoğraf üzerinde işaretlenir ve sonuç yüzde olarak gösterilir.

## Çalıştırma

MATLAB R2025a veya üzeri gerekir. Python ve ek MATLAB toolbox kurulumu gerekmez.

1. Proje klasörünü MATLAB’da açın.
2. Command Window’da şu komutu çalıştırın.

   ```matlab
   SuSisesiDoluluk
   ```

3. **Fotoğraf Aç** ile kendi görselinizi seçin. **Örneği Aç** düğmesi %75 dolulukla oluşturulmuş sentetik örneği yükler.

## Kullanım

- **Otomatik Ölç** şişenin sınırlarını ve su çizgisini arar. Şişenin farklı yüksekliklerdeki genişliğini hesaba katarak yaklaşık hacim oranı üretir.
- **Su Çizgisini İşaretle** algılanan şişe sınırlarını kullanır ve su seviyesini fotoğraf üzerinde düzeltmenizi sağlar.
- **Şişeyi Elle Çerçevele** şişenin iç hacmini çevreleyen kutunun sol üst ve sağ alt köşelerini seçmenizi ister. Ardından su çizgisine tıkladığınızda uygulama yükseklik oranını gösterir. Şişe daralıp genişliyorsa yükseklik oranı ile hacim oranı farklı olabilir.

Fotoğrafı yandan çekin. Şişenin tamamı kadrajda, şişe dik ve su çizgisi görünür olsun. Düz bir arka plan ve yumuşak ışık otomatik algılamaya yardımcı olur.

## Test sonuçları

MATLAB R2026b’de altı sentetik testte bilinen doluluk oranı ile tahmin arasındaki en büyük fark **0,6 yüzde puanı** oldu.

Wikimedia Commons’tan alınan yedi gerçek fotoğrafın hiçbirinde otomatik mod şişe sınırlarını bulamadı ve yüzde üretmedi. Elle işaretleme iki fotoğrafta çalıştı ve **%52** ile **%85** yükseklik oranı gösterdi. Bu fotoğrafların ölçülmüş su hacimleri bilinmediği için gerçek fotoğraflarda hacim doğruluğu henüz doğrulanmadı.

Sentetik testleri yeniden çalıştırmak için:

```matlab
testBottleFill
```

## Sınırlamalar

Opak şişelerde veya etiket su çizgisini kapattığında tek fotoğraftan doluluk belirlenemez. Yansıma, gölge, desenli arka plan ve eğik kamera açısı otomatik algılamayı bozabilir.
