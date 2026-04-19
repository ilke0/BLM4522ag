# Proje 2: Veritabanı Yedekleme ve Felaketten Kurtarma Planı
• Bir veritabanının yedekleme ve felaketten kurtarma planlarının tasarlanması.
SQL Server Backup, Point-in-time restore, ve Database Mirroring gibi
teknikler.
o Tam, Artık, Fark Yedeklemeleri: Yedekleme stratejilerini oluşturma.
o Zamanlayıcılarla Yedekleme: Yedekleme işlerini belirli aralıklarla
otomatik hale getirme.
o Felaketten Kurtarma Senaryoları: Kaza ile silinen verilerin geri
getirilmesi ve kurtarma süreçleri.
o Test Yedekleme Senaryoları: Yedeklerin doğruluğunu test etme.

## 1. Giriş
Bu projede, MSSQL Server kullanılarak `SirketDB` adında örnek bir veritabanı oluşturulmuş, ardından felaketten kurtarma senaryoları tasarlanarak manuel yedekleme stratejileri uygulanmıştır.

## 2. Test Ortamının Hazırlanması
Sistemde öncelikle `SirketDB` oluşturulmuş ve içerisine `Personel` tablosu eklenerek örnek veriler girilmiştir.
![Test Ortamı](img1.png) 

## 3. Yedekleme Stratejilerinin Uygulanması
Veri kaybını sıfıra indirmek için 3 aşamalı yedekleme yapılmıştır:
1. **Full Backup:** Veritabanının temel yedeği alınmıştır.
2. **Differential Backup:** Yeni bir personel eklendikten sonra, sadece son tam yedekten sonraki değişiklikleri içeren fark yedeği alınmıştır.
3. **Transaction Log Backup:** Noktasal zaman kurtarması (Point-in-time) yapabilmek için log yedeği alınmıştır.
*(![Yedekleme](img2.png) )*

## 4. Felaket Senaryosu ve Kurtarma (Point-in-Time Restore)
Sistemde bir insan hatası simüle edilmiş ve `Personel` tablosu `DROP TABLE` komutu ile tamamen silinmiştir. 
Ardından SSMS üzerinden **Restore Database -> Timeline** özelliği kullanılarak veritabanı, silinme işleminin gerçekleştiği zamandan 1 dakika öncesine döndürülmüştür. İşlem sonucunda tüm veriler kayıpsız olarak geri getirilmiştir.
*(![Kurtarma](img3.png) )*

## 5. Sonuç
Doğru bir yedekleme stratejisi (Full + Diff + Log) sayesinde, geri döndürülemez gibi görünen "tablo silinmesi" gibi felaket durumlarında dahi veri kaybı yaşanmadan sistemin ayağa kaldırılabileceği kanıtlanmıştır.