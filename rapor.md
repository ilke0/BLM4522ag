🗄️ MSSQL Server — Veritabanı Yedekleme ve Felaketten Kurtarma Planı

---

**Hazırlayan:** İLKE ZENGİN - 21290464  
**Tarih:** Nisan 2026  
**Konu:** Bir veritabanının yedekleme ve felaketten kurtarma planlarının tasarlanması

---

## 📋 İçindekiler

1. [Giriş](#giriş)
2. [Test Ortamının Hazırlanması](#test-ortamının-hazırlanması)
3. [Yedekleme Stratejisi](#yedekleme-stratejisi)
4. [Felaket Senaryosu (Veri Kaybı)](#felaket-senaryosu-veri-kaybı)
5. [Point-in-Time Restore (Belirli Bir Ana Geri Dönüş)](#point-in-time-restore-belirli-bir-ana-geri-dönüş)
6. [Database Mirroring (Veritabanı Aynalama)](#database-mirroring-veritabanı-aynalama)
7. [Zamanlayıcı ile Otomatik Yedekleme (SQL Server Agent)](#zamanlayıcı-ile-otomatik-yedekleme-sql-server-agent)
8. [Test ve Doğrulama (Yedeklerin Geçerliliği)](#test-ve-doğrulama-yedeklerin-geçerliliği)
9. [Sonuç](#sonuç)


---

## 1. Giriş

Bu projede, **MSSQL Server** kullanılarak `SirketDB` adlı bir veritabanı üzerinde kapsamlı yedekleme ve felaket kurtarma (**Disaster Recovery**) senaryoları tasarlanmıştır. Projenin temel amacı; veri kaybı, yanlış silme işlemleri ve sistem hatalarına karşı sürdürülebilir ve geri yüklenebilir bir veri güvenliği mimarisi oluşturmaktır.

---

## 2. Test Ortamının Hazırlanması

Denemelerin yapılabilmesi için öncelikle örnek bir veritabanı ve tablo yapısı oluşturulmuştur.

**Veritabanı ve Tablo Oluşturma:**

```sql
CREATE DATABASE SirketDB;
GO

USE SirketDB;

CREATE TABLE Musteriler (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Ad NVARCHAR(50)
);

-- Örnek veri girişi
INSERT INTO Musteriler (Ad)
VALUES ('Ali'), ('Veli'), ('Ayşe');
```

---

## 3. Yedekleme Stratejisi

Veri güvenliğini maksimize etmek ve depolama alanını verimli kullanmak adına **3 katmanlı bir yedekleme stratejisi** uygulanmıştır:

| Yedek Türü | Açıklama |
|---|---|
| **Full Backup** | Veritabanının tamamını kopyalar. |
| **Differential Backup** | En son alınan Full Backup'tan sonra değişen verileri yedekler. |
| **Transaction Log Backup** | Yapılan her bir işlemi (transaction) yedekleyerek anlık geri dönüş imkânı sağlar. |

### 3.1 Full Backup

```sql
BACKUP DATABASE SirketDB
TO DISK = 'C:\Backup\SirketDB_full.bak'
WITH INIT;
```

### 3.2 Differential Backup

```sql
BACKUP DATABASE SirketDB
TO DISK = 'C:\Backup\SirketDB_diff.bak'
WITH DIFFERENTIAL;
```

### 3.3 Transaction Log Backup

```sql
BACKUP LOG SirketDB
TO DISK = 'C:\Backup\SirketDB_log.trn';
```

---

## 4. Felaket Senaryosu (Veri Kaybı)

Sistem üzerinde kritik bir veri kaybı simülasyonu yapılmıştır. Bu senaryoda, bir kullanıcının yanlışlıkla tabloyu sildiği varsayılmıştır:

```sql
-- İnsan hatası simülasyonu
DROP TABLE Musteriler;
```

---

## 5. Point-in-Time Restore (Belirli Bir Ana Geri Dönüş)

Silinen tabloyu kurtarmak için veritabanı, hatanın gerçekleşmesinden hemen önceki bir zamana geri döndürülmüştür.

### 5.1 Full Restore

Öncelikle tam yedek `NORECOVERY` modunda geri yüklenir:

```sql
USE master;

RESTORE DATABASE SirketDB
FROM DISK = 'C:\Backup\SirketDB_full.bak'
WITH NORECOVERY;
```

### 5.2 Differential Restore

Ardından en güncel fark yedeği yüklenir:

```sql
RESTORE DATABASE SirketDB
FROM DISK = 'C:\Backup\SirketDB_diff.bak'
WITH NORECOVERY;
```

### 5.3 Log Restore (Point-in-Time)

Son olarak, işlem günlüğü kullanılarak hata anından hemen öncesine (`STOPAT`) dönülür ve veritabanı erişime açılır:

```sql
RESTORE LOG SirketDB
FROM DISK = 'C:\Backup\SirketDB_log.trn'
WITH STOPAT = '2026-04-19 18:20:00',
RECOVERY;
```

---

## 6. Database Mirroring (Veritabanı Aynalama)

Yüksek erişilebilirlik (**High Availability**) sağlamak amacıyla veritabanı ikinci bir sunucuya kopyalanmıştır.

**Mimari Yapı:**

| Bileşen | Açıklama |
|---|---|
| **Principal Server** | Ana işlemlerin döndüğü sunucu. |
| **Mirror Server** | Verilerin anlık olarak kopyalandığı yedek sunucu. |
| **Akış** | Principal → Transaction Log → Mirror |

**Mirror Sunucu Hazırlığı:**

```sql
RESTORE DATABASE SirketDB
FROM DISK = 'C:\Backup\SirketDB_full.bak'
WITH NORECOVERY;
```

---
## 7. Zamanlayıcı ile Otomatik Yedekleme (SQL Server Agent)

SQL Server Developer Edition kullanıldığı için SQL Server Agent servisi aktif hale getirilmiş ve yedekleme işlemleri otomatikleştirilmiştir.
Bu sayede manuel müdahale olmadan belirli zaman aralıklarında veritabanı yedekleri alınabilmektedir.

---

### 7.1 SQL Server Agent Job Oluşturma

SQL Server Agent üzerinden yeni bir Job oluşturulmuştur:

- Job Name: `SirketDB_Auto_Backup`
- Step: T-SQL Command
- Schedule: Daily (Her gün 02:00)

---

### 7.2 Backup Job Scripti

```sql
BACKUP DATABASE SirketDB
TO DISK = 'C:\Backup\auto_full.bak'
WITH INIT, STATS = 10;
```

### 7.3 Zamanlama (Schedule)

Job aşağıdaki şekilde zamanlanmıştır:

Her gün
Saat: 02:00
Otomatik çalıştırma aktif
### 7.4 Doğrulama (Job Çalıştı mı?)

SQL Server Agent üzerinden job history kontrol edilerek yedekleme işleminin başarıyla çalıştığı doğrulanmıştır.

Ayrıca oluşan backup dosyası fiziksel olarak kontrol edilmiştir:

C:\Backup\auto_full.bak

Sonuç olarak yedekleme işlemleri tamamen otomatik hale getirilmiş ve insan hatası riski ortadan kaldırılmıştır.


SQL Server Express sürümlerinde ise SQL Server Agent bulunmadığı için, yedekleme işlemleri **Windows Task Scheduler** kullanılarak otomatik hale getirilmiştir.

**Yedekleme Scripti (`backup.sql`):**

```sql
BACKUP DATABASE SirketDB
TO DISK = 'C:\Backup\auto_full.bak'
WITH INIT;
```

**Çalıştırma Komutu:**

```bat
sqlcmd -S localhost -E -i backup.sql
```

---

## 8. Test ve Doğrulama (Yedeklerin Geçerliliği)

Yedekleme işlemlerinin doğru çalıştığını doğrulamak için farklı test senaryoları uygulanmıştır.

Amaç; yedek dosyalarının bozuk olup olmadığını, geri yüklenebilirliğini ve içeriğinin doğruluğunu kontrol etmektir.

---

### 8.1 RESTORE VERIFYONLY (Yedek Bütünlüğü)

```sql
RESTORE VERIFYONLY
FROM DISK = 'C:\Backup\SirketDB_full.bak';
```
Bu komut ile yedek dosyasının bozuk olup olmadığı kontrol edilmiştir.

Sonuç:

The backup set on file 1 is valid.

Bu çıktı, yedek dosyasının sağlıklı olduğunu göstermektedir.

### 8.2 RESTORE HEADERONLY (Metadata Kontrolü)
```sql
RESTORE HEADERONLY
FROM DISK = 'C:\Backup\SirketDB_full.bak';
```
Bu komut ile yedeğin:
Ne zaman alındığı
Hangi veritabanına ait olduğu
LSN bilgileri
gibi metadata bilgileri kontrol edilmiştir.

### 8.3 RESTORE FILELISTONLY (Dosya Yapısı Kontrolü)
```sql
RESTORE FILELISTONLY
FROM DISK = 'C:\Backup\SirketDB_full.bak';
```

Bu komut ile yedek dosyasının içindeki fiziksel veri dosyaları (MDF, LDF) incelenmiştir.

### 8.4 Test Restore Senaryosu

Yedeklerin gerçekten çalıştığını doğrulamak için test veritabanına restore işlemi yapılmıştır:
```sql
USE master;

RESTORE DATABASE SirketDB_Test
FROM DISK = 'C:\Backup\SirketDB_full.bak'
WITH REPLACE;
```
Ardından veri kontrolü yapılmıştır:
```sql
USE SirketDB_Test;
SELECT * FROM Musteriler;
```
---

## 9. Sonuç

Bu proje kapsamında aşağıdaki yetkinlikler başarıyla uygulanmıştır:

| Yetkinlik | Açıklama |
|---|---|
| **Kademeli Yedekleme** | Full, Diff ve Log yedekleme stratejileri ile veri güvenliği optimize edildi. |
| **Kritik Kurtarma** | Point-in-time restore ile saniyeler bazında veri kurtarma yapıldı. |
| **Yüksek Erişilebilirlik** | Mirroring mantığı ile donanım hatalarına karşı önlem alındı. |
| **Otomasyon** | Task Scheduler entegrasyonu ve SQL Server Agent ile manuel işlem yükü ortadan kaldırıldı. |

Sonuç olarak, kurumsal düzeyde bir **Disaster Recovery (Felaket Kurtarma)** sistemi tasarlanmış, test edilmiş ve başarıyla doğrulanmıştır.