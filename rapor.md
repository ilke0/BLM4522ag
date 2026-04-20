# Proje 2: Veritabanı Yedekleme ve Felaketten Kurtarma Planı

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

## 7. Zamanlayıcı ile Otomatik Yedekleme

SQL Server Express sürümlerinde SQL Server Agent bulunmadığı için, yedekleme işlemleri **Windows Task Scheduler** kullanılarak otomatik hale getirilmiştir.

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

## 8. Test ve Doğrulama

Yapılan kurtarma işlemlerinin başarısı aşağıdaki sorgu ile teyit edilmiştir:

```sql
USE SirketDB;
SELECT * FROM Musteriler;
```

> ✅ Testler sonucunda, silinen verilerin eksiksiz şekilde geri geldiği görülmüştür.

---

## 9. Sonuç

Bu proje kapsamında aşağıdaki yetkinlikler başarıyla uygulanmıştır:

| Yetkinlik | Açıklama |
|---|---|
| **Kademeli Yedekleme** | Full, Diff ve Log yedekleme stratejileri ile veri güvenliği optimize edildi. |
| **Kritik Kurtarma** | Point-in-time restore ile saniyeler bazında veri kurtarma yapıldı. |
| **Yüksek Erişilebilirlik** | Mirroring mantığı ile donanım hatalarına karşı önlem alındı. |
| **Otomasyon** | Task Scheduler entegrasyonu ile manuel işlem yükü ortadan kaldırıldı. |

Sonuç olarak, kurumsal düzeyde bir **Disaster Recovery (Felaket Kurtarma)** sistemi tasarlanmış, test edilmiş ve başarıyla doğrulanmıştır.