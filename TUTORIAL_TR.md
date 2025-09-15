# 🎓 Detaylı Kullanım Kılavuzu (Comprehensive Usage Guide)

Bu kılavuz, Custom ISO Builder projesinin adım adım nasıl kullanılacağını detaylı şekilde açıklar.

## 📋 İçindekiler

1. [Sistem Gereksinimleri](#-sistem-gereksinimleri)
2. [İlk Kurulum](#-i̇lk-kurulum)
3. [ISO Oluşturma Süreci](#-iso-oluşturma-süreci)
4. [Docker Sunucu Kurulumu](#-docker-sunucu-kurulumu)
5. [Konfigürasyon Özelleştirme](#-konfigürasyon-özelleştirme)
6. [Sorun Giderme](#-sorun-giderme)
7. [İleri Seviye Kullanım](#-i̇leri-seviye-kullanım)

## 🖥️ Sistem Gereksinimleri

### Minimum Gereksinimler
- **İşletim Sistemi:** Ubuntu 20.04+ / Debian 11+
- **RAM:** 4GB (8GB önerilen)
- **Disk Alanı:** 20GB boş alan
- **İnternet:** ISO indirme için gerekli
- **Yetki:** sudo erişimi

### Gerekli Paketler
```bash
# Sistem güncelleme
sudo apt update && sudo apt upgrade -y

# Temel gereksinimler kontrol edilir
sudo apt install -y make git curl wget
```

## 🚀 İlk Kurulum

### Adım 1: Projeyi Klonlama
```bash
# Proje klasörüne git
cd ~/Desktop  # veya istediğiniz bir klasör

# Repoyu klonla
git clone https://github.com/harunkurtdev/custom_iso.git
cd custom_iso

# Klasör yapısını kontrol et
ls -la
```

**Beklenen Çıktı:**
```
total 32
drwxrwxr-x 5 user user 4096 Dec 15 10:00 .
drwxrwxr-x 3 user user 4096 Dec 15 10:00 ..
drwxrwxr-x 8 user user 4096 Dec 15 10:00 .git
-rw-rw-r-- 1 user user  156 Dec 15 10:00 Makefile
-rw-rw-r-- 1 user user 8492 Dec 15 10:00 README.md
drwxrwxr-x 3 user user 4096 Dec 15 10:00 custom-iso-editor
drwxrwxr-x 4 user user 4096 Dec 15 10:00 custom-iso-server
drwxrwxr-x 2 user user 4096 Dec 15 10:00 images
```

### Adım 2: Sistem Bağımlılıklarını Yükleme
```bash
# Gerekli paketleri yükle
make iso_depends

# Kurulum kontrolü
which xorriso  # /usr/bin/xorriso dönmeli
which qemu-img # /usr/bin/qemu-img dönmeli
```

**Bu komut şu paketleri yükler:**
- `xorriso` - ISO dosyası oluşturma
- `qemu-utils` - Disk imaj araçları
- `curl, wget` - Dosya indirme
- `gdisk, kpartx` - Disk yönetimi
- Ve diğer yardımcı araçlar

## 💿 ISO Oluşturma Süreci

### Senaryo A: İlk Kez Tam Kurulum

Bu senaryo hiç ISO oluşturmamış kullanıcılar içindir.

#### Adım 1: Ubuntu ISO İndirme
```bash
# Ubuntu 22.04.3 Server ISO'yu indir (~1.4GB)
make iso_download

# İndirme kontrolü
ls -lh custom-iso-editor/ubuntu-*.iso
```

**Beklenen Çıktı:**
```
-rw-rw-r-- 1 user user 1.4G Dec 15 10:15 custom-iso-editor/ubuntu-22.04.3-live-server-amd64.iso
```

#### Adım 2: ISO Çıkarma ve Hazırlama
```bash
# ISO'yu mount et ve içeriğini çıkar
make iso_init

# Çıkarma kontrolü
ls custom-iso-editor/iso_root/
```

**Beklenen Çıktı:**
```
boot  casper  dists  EFI  isolinux  md5sum.txt  pool  pressed  ubuntu
```

⏱️ **Süre:** Bu işlem 5-10 dakika sürebilir.

#### Adım 3: Konfigürasyon Uygulama
```bash
# Özel ayarları uygula
make iso_setup

# APU/APU2 için ISOLINUX kur
make iso_setup-isolinux

# Kontrol et
ls custom-iso-editor/iso_root/isolinux/
```

#### Adım 4: ISO Oluşturma
```bash
# APU/APU2 sistemler için ISO oluştur
make iso_geniso-isolinux

# Oluşturulan ISO'yu kontrol et
ls -lh custom-iso-editor/user_iso_files/
```

**Beklenen Çıktı:**
```
-rw-r--r-- 1 root root 1.4G Dec 15 10:30 user-custom-autoinstaller.20241215.103045.iso
```

### Senaryo B: Konfigürasyon Değişikliği Sonrası

Sadece user-data veya diğer ayarları değiştirdiyseniz:

```bash
# Sadece konfigürasyonu yeniden uygula
make iso_setup
make iso_setup-isolinux

# Yeni ISO oluştur
make iso_geniso-isolinux
```

⏱️ **Süre:** Bu işlem 2-3 dakika sürer.

## 🐳 Docker Sunucu Kurulumu

### Adım 1: Docker Sunucu Oluşturma
```bash
# Docker imajını oluştur
make iso_server_build
```

**Bu işlem:**
- Docker ağını oluşturur (`172.20.0.0/16`)
- Web sunucu imajını build eder
- Gerekli dosyaları container'a kopyalar

### Adım 2: Sunucuyu Başlatma
```bash
# Sunucuyu çalıştır (interaktif mod)
make iso_server_run
```

**Beklenen Çıktı:**
```
🚀 Docker sunucu başlatılıyor...
🌐 Sunucu çalıştırılıyor: http://172.20.0.2:3003
⚠️  Bu pencereyi kapatmayın - sunucu çalışır durumda!
🛑 Durdurmak için: Ctrl+C

Starting HTTP server on port 3003...
Server ready at http://172.20.0.2:3003
```

### Adım 3: Sunucu Testi
Yeni bir terminal açın:
```bash
# Sunucu bağlantısını test et
make iso_server_test

# Veya manuel test
curl http://172.20.0.2:3003/user-data
```

## ⚙️ Konfigürasyon Özelleştirme

### User-Data Dosyasını Düzenleme

```bash
# User-data dosyasını düzenle
nano custom-iso-editor/config/user-data
```

**Yaygın Özelleştirmeler:**

#### 1. Kullanıcı Bilgilerini Değiştirme
```yaml
identity:
  realname: "Şirket Yöneticisi"
  hostname: "prod-server-01"
  username: "admin"
  password: "$6$yeni_hash_burada"  # Yeni şifre hash'i
```

#### 2. Ek Paket Ekleme
```yaml
packages:
  - docker.io      # Docker
  - nginx          # Web sunucu
  - postgresql     # Veritabanı
  - python3-pip    # Python paket yöneticisi
  - nodejs         # Node.js
  - npm            # Node paket yöneticisi
```

#### 3. Kurulum Sonrası Komutlar
```yaml
late-commands:
  # Docker'ı başlat ve enable et
  - curtin in-target --target=/target -- systemctl enable docker
  - curtin in-target --target=/target -- systemctl start docker
  
  # Kullanıcıyı docker grubuna ekle
  - curtin in-target --target=/target -- usermod -aG docker admin
  
  # Özel script çalıştır
  - curtin in-target --target=/target -- /home/admin/setup-app.sh
```

### GRUB Menüsünü Özelleştirme

```bash
# GRUB konfigürasyonunu düzenle
nano custom-iso-editor/config/boot/grub/grub.cfg
```

**Örnek Özelleştirme:**
```
set timeout=10  # 10 saniye bekleme
set default=0   # İlk seçenek varsayılan

menuentry "Şirket Sunucu Kurulumu - Otomatik" {
    set gfxpayload=keep
    linux   /casper/vmlinuz quiet autoinstall "ds=nocloud-net;s=http://172.20.0.2:3003"  ---
    initrd  /casper/initrd.lz
}

menuentry "Şirket Sunucu Kurulumu - USB'den" {
    set gfxpayload=keep
    linux   /casper/vmlinuz quiet autoinstall "ds=nocloud-net;s=file:///cdrom/preseed/"  ---
    initrd  /casper/initrd.lz
}
```

### Yeni Şifre Hash'i Oluşturma
```bash
# Güçlü şifre hash'i oluştur
openssl passwd -6 -salt $(openssl rand -hex 16) "YeniGüçlüŞifre123!"

# Çıktıyı kopyalayıp user-data dosyasına yapıştır
```

## 💾 USB'ye Yazma

⚠️ **UYARI:** Bu işlem USB'deki tüm verileri siler!

```bash
# USB cihazları listele
lsblk

# Beklenen çıktı:
# NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
# sdb      8:16   1  14.9G  0 disk 
# └─sdb1   8:17   1  14.9G  0 part /media/user/USB

# ÖNEMLİ: USB'yi umount et
sudo umount /dev/sdb*  # sdb sizin USB'nizin adı

# ISO'yu USB'ye yaz
make iso_write_usb
```

**Güvenli Alternatif:**
```bash
# Manuel olarak belirli USB'ye yazma
sudo dd if=custom-iso-editor/user_iso_files/user-custom-autoinstaller.*.iso of=/dev/sdb bs=4M status=progress
```

## 🔧 Sorun Giderme

### Problem 1: "ISO dosyası bulunamadı"
```bash
# Çözüm: ISO'yu yeniden indir
make iso_download

# Kontrol et
ls -la custom-iso-editor/ubuntu-*.iso
```

### Problem 2: "Mount point busy"
```bash
# Çözüm: Mount'ları temizle
sudo umount /mnt/user_custom_iso
sudo rm -rf /mnt/user_custom_iso
sudo mkdir -p /mnt/user_custom_iso
```

### Problem 3: Docker ağ hatası
```bash
# Çözüm: Docker'ı temizle ve yeniden başlat
make iso_server_clean
sudo systemctl restart docker
make iso_server_build
```

### Problem 4: USB yazma başarısız
```bash
# USB cihazını kontrol et
sudo fdisk -l | grep "Disk /dev/sd"

# USB'yi güvenli şekilde çıkar
sudo eject /dev/sdb  # sdb sizin USB'niz

# Yeniden tak ve tekrar dene
```

### Debug Komutları
```bash
# Sistem durumunu kontrol et
make status  # ISO editör durumu
make iso_server_status  # Docker sunucu durumu

# Logları incele
journalctl -u docker  # Docker logları
dmesg | tail -20  # Sistem mesajları
```

## 🎯 İleri Seviye Kullanım

### 1. Özel Script Ekleme

#### Adım 1: Script Oluşturma
```bash
# Özel script klasörü oluştur
mkdir -p custom-iso-editor/config/extras/scripts

# Script dosyası oluştur
cat > custom-iso-editor/config/extras/scripts/company-setup.sh << 'EOF'
#!/bin/bash
# Şirket özel kurulum scripti

echo "🏢 Şirket konfigürasyonu başlatılıyor..."

# Firewall ayarları
ufw enable
ufw default deny incoming
ufw allow 22    # SSH
ufw allow 80    # HTTP
ufw allow 443   # HTTPS

# Şirket sertifikalarını kur
curl -O https://company.com/certs/ca-cert.pem
cp ca-cert.pem /usr/local/share/ca-certificates/company-ca.crt
update-ca-certificates

# Monitoring agent kur
curl -L https://company.com/agent/install.sh | bash

echo "✅ Şirket konfigürasyonu tamamlandı!"
EOF

chmod +x custom-iso-editor/config/extras/scripts/company-setup.sh
```

#### Adım 2: User-data'ya Entegrasyon
```yaml
late-commands:
  # Script'i kopyala
  - cp /cdrom/extras/scripts/company-setup.sh /target/home/admin/
  - chmod +x /target/home/admin/company-setup.sh
  
  # Script'i çalıştır
  - curtin in-target --target=/target -- /home/admin/company-setup.sh
```

### 2. Multi-Environment Konfigürasyonu

#### Geliştirme Ortamı
```bash
# Dev konfigürasyonu kopyala
cp custom-iso-editor/config/user-data custom-iso-editor/config/user-data.dev

# Düzenle: dev paketleri ekle
nano custom-iso-editor/config/user-data.dev
```

```yaml
packages:
  - git
  - vim
  - curl
  - docker.io
  - nodejs
  - python3-dev
  - build-essential
```

#### Üretim Ortamı
```bash
# Prod konfigürasyonu
cp custom-iso-editor/config/user-data custom-iso-editor/config/user-data.prod

# Düzenle: minimal paketler
nano custom-iso-editor/config/user-data.prod
```

```yaml
packages:
  - unzip
  - net-tools
  # Minimal kurulum için sadece gerekli paketler
```

#### Konfigürasyon Değiştirme
```bash
# Dev için
cp custom-iso-editor/config/user-data.dev custom-iso-editor/config/user-data
make iso_setup && make iso_geniso-isolinux

# Prod için  
cp custom-iso-editor/config/user-data.prod custom-iso-editor/config/user-data
make iso_setup && make iso_geniso-isolinux
```

### 3. Otomatik Test Sistemi

```bash
# Test scripti oluştur
cat > test-installation.sh << 'EOF'
#!/bin/bash
set -e

echo "🧪 ISO kurulum testi başlatılıyor..."

# QEMU ile test
qemu-system-x86_64 \
  -cdrom custom-iso-editor/user_iso_files/user-custom-autoinstaller.*.iso \
  -m 2048 \
  -hda test-disk.img \
  -boot d \
  -vnc :1 \
  -daemonize

echo "✅ Test VM başlatıldı. VNC ile :5901 portuna bağlanın"
echo "📋 Test tamamlandığında: killall qemu-system-x86_64"
EOF

chmod +x test-installation.sh
```

### 4. CI/CD Entegrasyonu

GitHub Actions örneği:
```yaml
# .github/workflows/build-iso.yml
name: Build Custom ISO

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Install dependencies
      run: make iso_depends
    
    - name: Download Ubuntu ISO
      run: make iso_download
      
    - name: Initialize ISO
      run: make iso_init
      
    - name: Apply configuration
      run: |
        make iso_setup
        make iso_setup-isolinux
        
    - name: Generate ISO
      run: make iso_geniso-isolinux
      
    - name: Upload ISO artifact
      uses: actions/upload-artifact@v3
      with:
        name: custom-iso
        path: custom-iso-editor/user_iso_files/*.iso
```

## 📚 Referanslar ve Kaynaklar

### Resmi Dokümantasyon
- [Ubuntu Autoinstall Guide](https://ubuntu.com/server/docs/install/autoinstall)
- [Cloud-init Documentation](https://cloud-init.readthedocs.io/)
- [Subiquity Examples](https://github.com/canonical/subiquity/tree/main/examples/autoinstall)

### Faydalı Araçlar
- [YAML Validator](https://yaml-online-parser.appspot.com/)
- [Cloud-init Schema Validator](https://cloudinit.readthedocs.io/en/latest/topics/schema.html)
- [OpenSSL Password Generator](https://www.openssl.org/docs/man1.1.1/man1/openssl-passwd.html)

### Video Eğitimler
- [Ubuntu Server Autoinstall](https://ubuntu.com/tutorials/automated-server-installation-quickstart)
- [Docker Network Management](https://docs.docker.com/network/)

---

## 💡 Son İpuçları

1. **Yedekleme:** Önemli konfigürasyonlarınızı git ile versiyonlayın
2. **Test:** Her değişiklikten sonra VM'de test edin
3. **Güvenlik:** Production'da güçlü şifreler kullanın
4. **Monitoring:** Kurulum loglarını düzenli kontrol edin
5. **Dokümantasyon:** Özel ayarlarınızı dokümante edin

**İyi kurulumlar! 🚀**