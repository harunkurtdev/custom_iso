# ================================================
# CUSTOM ISO BUILDER - MAKEFILE CONFIGURATION
# ================================================
# Bu dosya Ubuntu 22.04 Server için özelleştirilmiş
# ISO dosyaları oluşturmak üzere tasarlanmıştır.
# APU/APU2 sistemleri için optimize edilmiştir.

# ================================================
# UBUNTU VERSİYON AYARLARI (Ubuntu Version Settings)
# ================================================
UBUNTU_VERSION = 22.04.3                    # Kullanılacak Ubuntu versiyonu
UBUNTU_RELEASE = 22.04                      # Ubuntu release numarası
ISO_URLBASE = https://releases.ubuntu.com/$(UBUNTU_RELEASE)/
ISO_FILENAME_DOWNLOAD = ubuntu-$(UBUNTU_VERSION)-live-server-amd64.iso
ISO_FILENAME = $(PWD)/custom-iso-editor/ubuntu-$(UBUNTU_VERSION)-live-server-amd64.iso

# ================================================
# DOSYA YOLLARı (File Paths)
# ================================================
ISO_MOUNTPOINT = /mnt/user_custom_iso        # Geçici mount noktası
ISO_ROOT = $(PWD)/custom-iso-editor/iso_root # Çıkarılan ISO içeriği
ISO_FILES = $(PWD)/custom-iso-editor/user_iso_files  # Oluşturulan ISO dosyaları

# ================================================
# KONFİGÜRASYON DOSYA KOPYALAMA (Config File Copying)
# ================================================
## GRUB bootloader ayarları
GRUBCFG_SRC = $(PWD)/custom-iso-editor/config/boot/grub/grub.cfg
GRUBCFG_DEST = $(PWD)/custom-iso-editor/iso_root/boot/grub/grub.cfg

## Otomatik kurulum konfigürasyonu
USERDATA_SRC = $(PWD)/custom-iso-editor/config/user-data
USERDATA_DEST =$(PWD)/custom-iso-editor/iso_root/pressed/user-data

## Sistem meta verileri
METADATA_SRC = $(PWD)/custom-iso-editor/config/meta-data
METADATA_DEST = $(PWD)/custom-iso-editor/iso_root/pressed/meta-data

## Ekstra dosyalar (custom scriptler, sertifikalar vb.)
EXTRAS_SRCDIR = $(PWD)/custom-iso-editor/config/extras/
EXTRAS_DESTDIR = $(PWD)/custom-iso-editor/iso_root/extras/

# ================================================
# ISO OLUŞTURMA AYARLARI (ISO Generation Settings)
# ================================================
GENISO_LABEL = UserCustomISO                # ISO volume etiketi
# Zaman damgalı dosya adı için dinamik isim oluşturma
GENISO_FILENAME = $(PWD)/custom-iso-editor/user_iso_files/user-custom-autoinstaller.$(shell date +%Y%m%d.%H%M%S).iso
GENISO_BOOTIMG = boot/grub/i386-pc/eltorito.img    # GRUB boot imajı
GENISO_BOOTCATALOG = /boot.catalog                  # Boot katalog dosyası
# Dinamik sektör hesaplama (ISO'dan alınır)
GENISO_START_SECTOR = $(shell sudo fdisk -l $(ISO_FILENAME) |grep iso2 | cut -d' ' -f2)
GENISO_END_SECTOR = $(shell sudo fdisk -l $(ISO_FILENAME) |grep iso2 | cut -d' ' -f3)
GENISO_LANG = C                             # Dil ayarı (C = İngilizce/Evrensel)

# ================================================
# APU/APU2 SİSTEM AYARLARI (APU/APU2 System Settings)
# ================================================
## APU sistemleri BIOS tabanlı boot kullanır, UEFI değil
GENISO_ISOLINUX = /usr/lib/ISOLINUX/isolinux.bin          # ISOLINUX bootloader
GENISO_ISOLINUX_MODULEDIR = /usr/lib/syslinux/modules/bios/ # BIOS modülleri
GENISO_HYBRIDMBR = /usr/lib/ISOLINUX/isohdpfx.bin         # Hibrit MBR
ISOLINUX_CONFIGDIR = $(PWD)/custom-iso-editor/config/isolinux
ISOLINUX_DIRNAME = isolinux

# ================================================
# TERMINAL RENK AYARLARI (Terminal Color Settings)
# ================================================
## Kullanıcı deneyimini iyileştirmek için renkli çıktılar
COLOR_RED = \033[5;31m                      # Kırmızı (hata mesajları)
COLOR_GREEN = \033[5;32m                    # Yeşil (başarı mesajları)
COLOR_ORANGE = \033[5;33m                   # Turuncu (uyarı mesajları)
COLOR_BLUE = \033[5;34m                     # Mavi (bilgi mesajları)
COLOR_GRAY = \033[1;37m                     # Gri (normal mesajlar)
COLOR_GRAY_BLINK = \033[4;37m               # Yanıp sönen gri
COLOR_GRAY_BLINK_UNDERLINE = \033[5;37m\033[4m  # Alt çizgili yanıp sönen
COLOR_RESET = \033[0m                       # Renk sıfırlama
BLINK = \033[5m                             # Yanıp sönme
UNDERLINE = \033[4m                         # Alt çizgi

# ================================================
# MAKEFILE HEDEFLER (Makefile Targets)
# ================================================



# ================================================
# HEDEF: iso_download
# ================================================
# Ubuntu 22.04 Server ISO dosyasını resmi siteden indirir
# Bu işlem sadece bir kez yapılır (ilk kurulumda)
.PHONY: iso_download
iso_download:
	@echo "$(COLOR_BLUE)Ubuntu ISO dosyası indiriliyor...$(COLOR_RESET)"
	wget -O ${ISO_FILENAME} -N $(ISO_URLBASE)/$(ISO_FILENAME_DOWNLOAD)
	@echo "$(COLOR_GREEN)ISO indirme tamamlandı: ${ISO_FILENAME}$(COLOR_RESET)"

# ================================================
# HEDEF: iso_init  
# ================================================
# İndirilen ISO dosyasını mount eder ve içeriğini çıkarır
# Çalışma dizinini hazırlar ve gerekli klasörleri oluşturur
.PHONY: iso_init
iso_init:
	@echo "$(COLOR_BLUE)ISO initialization başlatılıyor...$(COLOR_RESET)"
	# Gerekli paketleri yükle
	sudo apt install xorriso rsync
	
	# Eski ISO root varsa yedekle
	( test -d $(ISO_ROOT) && mv -f $(ISO_ROOT) $(ISO_ROOT).$(shell date +%Y%m%d.%H%M%S) ) || true
	
	# Gerekli klasörleri oluştur
	mkdir -p $(ISO_ROOT)           # Ana ISO içerik klasörü
	mkdir -p $(ISO_ROOT)/pressed   # Autoinstall config klasörü
	mkdir -p $(ISO_ROOT)/extras    # Özel dosyalar klasörü
	mkdir -p $(ISO_FILES)          # Oluşturulan ISO'lar için
	sudo mkdir -p $(ISO_MOUNTPOINT)  # Mount noktası
	
	# Var olan mount'u temizle
	(mountpoint $(ISO_MOUNTPOINT) && sudo umount -q $(ISO_MOUNTPOINT)) || true
	
	# ISO'yu mount et ve içeriğini kopyala
	@echo "$(COLOR_ORANGE)ISO dosyası mount ediliyor ve içerik çıkarılıyor...$(COLOR_RESET)"
	sudo mount -o ro,loop $(ISO_FILENAME) $(ISO_MOUNTPOINT)
	rsync -av $(ISO_MOUNTPOINT)/. $(ISO_ROOT)/.
	sudo umount $(ISO_MOUNTPOINT)
	@echo "$(COLOR_GREEN)ISO initialization tamamlandı!$(COLOR_RESET)"

# ================================================
# HEDEF: iso_setup
# ================================================
# Özelleştirilmiş konfigürasyon dosyalarını ISO'ya entegre eder
# GRUB, user-data, meta-data ve extra dosyaları kopyalar
.PHONY: iso_setup
iso_setup:
	@echo "$(COLOR_BLUE)Konfigürasyon dosyaları entegre ediliyor...$(COLOR_RESET)"
	
	# İzinleri düzelt
	chmod 755 $(ISO_ROOT)
	chmod 644 $(GRUBCFG_DEST)
	
	# GRUB konfigürasyonunu kopyala (boot menüsü)
	@echo "$(COLOR_ORANGE)GRUB konfigürasyonu kopyalanıyor...$(COLOR_RESET)"
	cp -f $(GRUBCFG_SRC) $(GRUBCFG_DEST)
	
	# Otomatik kurulum dosyalarını kopyala
	@echo "$(COLOR_ORANGE)Autoinstall dosyaları kopyalanıyor...$(COLOR_RESET)"
	cp -f $(USERDATA_SRC) $(USERDATA_DEST)    # Ana kurulum scripti
	cp -f $(METADATA_SRC) $(METADATA_DEST)    # Sistem meta verileri
	
	# Ekstra dosyaları kopyala (custom scriptler, sertifikalar vb.)
	@echo "$(COLOR_ORANGE)Ekstra dosyalar kopyalanıyor...$(COLOR_RESET)"
	rsync -av $(EXTRAS_SRCDIR)/. $(EXTRAS_DESTDIR)/.
	
	# İzinleri yeniden düzelt  
	chmod 755 $(ISO_ROOT)
	@echo "$(COLOR_GREEN)Konfigürasyon kurulumu tamamlandı!$(COLOR_RESET)"

# ================================================
# HEDEF: iso_setup-isolinux
# ================================================
# APU/APU2 sistemleri için ISOLINUX bootloader kurulumunu yapar
# Bu sistemler UEFI yerine BIOS boot kullanır
.PHONY: iso_setup-isolinux
iso_setup-isolinux:
	@echo "$(COLOR_BLUE)APU/APU2 için ISOLINUX kurulumu başlatılıyor...$(COLOR_RESET)"
	
	# İzinleri düzelt
	chmod 755 $(ISO_ROOT)
	
	# ISOLINUX paketlerini yükle
	@echo "$(COLOR_ORANGE)ISOLINUX bağımlılıkları yükleniyor...$(COLOR_RESET)"
	sudo apt install isolinux syslinux-common
	
	# ISOLINUX bootloader'ı kopyala
	@echo "$(COLOR_ORANGE)ISOLINUX bootloader kopyalanıyor...$(COLOR_RESET)"
	cp $(GENISO_ISOLINUX) $(ISO_ROOT)/
	
	# ISOLINUX klasörünü oluştur ve modülleri kopyala
	mkdir -p $(ISO_ROOT)/$(ISOLINUX_DIRNAME)
	rsync -av $(GENISO_ISOLINUX_MODULEDIR)/. $(ISO_ROOT)/$(ISOLINUX_DIRNAME)/.
	
	# APU/APU2 özel konfigürasyonlarını kopyala
	@echo "$(COLOR_ORANGE)APU/APU2 konfigürasyonları kopyalanıyor...$(COLOR_RESET)"
	rsync -av $(ISOLINUX_CONFIGDIR)/. $(ISO_ROOT)/$(ISOLINUX_DIRNAME)/.
	@echo "$(COLOR_GREEN)ISOLINUX kurulumu tamamlandı!$(COLOR_RESET)"

# ================================================
# HEDEF: iso_geniso
# ================================================
# Standard sistemler için ISO dosyası oluşturur (GRUB/UEFI boot)
# Modern sistemlerin çoğu bu yöntemi kullanır
.PHONY: iso_geniso
iso_geniso:
	@echo "$(COLOR_BLUE)Standard ISO dosyası oluşturuluyor...$(COLOR_RESET)"
	@echo "$(COLOR_ORANGE)Bu işlem birkaç dakika sürebilir...$(COLOR_RESET)"
	sudo env LANG=$(GENISO_LANG) xorriso -as mkisofs -volid $(GENISO_LABEL) \
	-output $(GENISO_FILENAME) \
	-eltorito-boot $(GENISO_BOOTIMG) \
	-eltorito-catalog $(GENISO_BOOTCATALOG) -no-emul-boot \
	-boot-load-size 4 -boot-info-table -eltorito-alt-boot \
	-no-emul-boot -isohybrid-gpt-basdat \
	-append_partition 2 28732ac11ff8d211ba4b00a0c93ec93b --interval:local_fs:$(GENISO_START_SECTOR)d-$(GENISO_END_SECTOR)d::'$(ISO_FILENAME)' \
	-e '--interval:appended_partition_2_start_1782357s_size_8496d:all::' \
	--grub2-mbr --interval:local_fs:0s-15s:zero_mbrpt,zero_gpt:'$(ISO_FILENAME)' \
	"${ISO_ROOT}"
	@echo "$(COLOR_GREEN)Standard ISO oluşturuldu: $(GENISO_FILENAME)$(COLOR_RESET)"

# ================================================
# HEDEF: iso_geniso-isolinux
# ================================================
# APU/APU2 sistemleri için ISO dosyası oluşturur (ISOLINUX/BIOS boot)
# Endüstriyel ve embedded sistemler için optimize edilmiştir
.PHONY: iso_geniso-isolinux
iso_geniso-isolinux:
	@echo "$(COLOR_BLUE)APU/APU2 için ISOLINUX ISO dosyası oluşturuluyor...$(COLOR_RESET)"
	@echo "$(COLOR_ORANGE)Bu işlem birkaç dakika sürebilir...$(COLOR_RESET)"
	sudo env LANG=$(GENISO_LANG) xorriso -as mkisofs -volid $(GENISO_LABEL) \
	-output $(GENISO_FILENAME) \
	-eltorito-boot /$(shell basename $(GENISO_ISOLINUX)) \
	-eltorito-catalog $(GENISO_BOOTCATALOG) -no-emul-boot \
	-boot-load-size 4 -boot-info-table -eltorito-alt-boot \
	-no-emul-boot -isohybrid-gpt-basdat \
	-append_partition 2 28732ac11ff8d211ba4b00a0c93ec93b --interval:local_fs:$(GENISO_START_SECTOR)d-$(GENISO_END_SECTOR)d::'$(ISO_FILENAME)' \
	-isohybrid-mbr $(GENISO_HYBRIDMBR) \
	-e '--interval:appended_partition_2_start_1782357s_size_8496d:all::' \
	"${ISO_ROOT}"
	@echo "$(COLOR_GREEN)APU/APU2 ISO oluşturuldu: $(GENISO_FILENAME)$(COLOR_RESET)"


# ================================================
# HEDEF: iso_write_usb
# ================================================
# ⚠️  KRİTİK: En son oluşturulan ISO'yu USB'ye yazar
# DİKKAT: Bu komut tüm bağlı USB cihazlarına yazım yapar!
# Önemli verileriniz silinebilir!
.PHONY: iso_write_usb
iso_write_usb:
	@echo "$(COLOR_RED)$(BLINK)⚠️  DİKKAT: USB YAZMA İŞLEMİ BAŞLIYOR! ⚠️$(COLOR_RESET)"
	@echo "$(COLOR_RED)Tüm bağlı USB cihazlarındaki veriler SİLİNECEK!$(COLOR_RESET)"
	@echo "$(COLOR_ORANGE)5 saniye sonra işlem başlayacak... İptal etmek için Ctrl+C$(COLOR_RESET)"
	@sleep 5
	
	# En son oluşturulan ISO dosyasını bul
	latest_iso=$(shell ls -t $(ISO_FILES)/user-custom-autoinstaller.*.iso | head -n 1); \
	echo "$(COLOR_BLUE)Yazdirilacak son ISO bulunuyor....$(COLOR_RESET)"; \
	if [ -z "$$latest_iso" ]; then \
		echo -e "$(COLOR_RED)ISO dosyası bulunamadı! Önce 'make iso_geniso-isolinux' çalıştırın.$(COLOR_RESET)"; \
		exit 1; \
	else \
		echo "$(COLOR_GREEN)En son ISO dosyası: $(UNDERLINE)$$latest_iso$(COLOR_RESET)"; \
	fi; \
	
	# Bağlı USB cihazları bul
	usb_device=$$(lsblk -npl -o NAME,TYPE | awk '$$2=="disk" && $$1 ~ /^\/dev\/sd[a-z]/ {print $$1}'); \
	if [ -z "$$usb_device" ]; then \
		echo "$(COLOR_RED)USB cihaz bulunamadı!$(COLOR_RESET)"; \
		exit 1; \
	fi; \
	
	# Her USB cihaza yazım yap
	for disk in $$usb_device; do \
		echo "$(COLOR_GRAY)USB disk bulundu: $(COLOR_GREEN)$$disk$(COLOR_RESET)"; \
		echo "$(COLOR_GRAY_BLINK)Harun Kahve Icmeye gidebilirsin...$(COLOR_RESET)"; \
		echo "$(COLOR_ORANGE)Disk formatlanıyor: $$disk$(COLOR_RESET)"; \
		yes | sudo mkfs -t ext4 "$$disk"; \
		echo "$(COLOR_ORANGE)ISO yazılıyor: $$disk$(COLOR_RESET)"; \
		sudo dd if="$$latest_iso" of="$$disk" bs=4M status=progress; \
		echo "$(COLOR_GRAY_BLINK_UNDERLINE)────────────────────────────────────────────────────────$(COLOR_RESET)"; \
		echo "$(COLOR_GREEN)✅ Yazım tamamlandı: $$disk$(COLOR_RESET)"; \
	done; \
	@echo "$(COLOR_GREEN)$(BLINK)🎉 Tüm USB cihazlara yazım başarıyla tamamlandı! 🎉$(COLOR_RESET)" \


# ================================================
# YARDıMCı FONKSİYONLAR (Utility Functions)
# ================================================

# Chroot fonksiyonu - ISO içerisinde komut çalıştırmak için
# Debugging ve özel konfigürasyonlar için kullanılır
define chroot
	sudo chroot $(ISO_ROOT) $(1)
endef

# ================================================
# HEDEF: iso_chroot-shell
# ================================================
# ISO dosyası içerisinde interaktif shell açar
# Debugging ve manuel konfigürasyonlar için kullanılır
.PHONY: iso_chroot-shell
iso_chroot-shell:
	@echo "$(COLOR_BLUE)ISO chroot environment açılıyor...$(COLOR_RESET)"
	@echo "$(COLOR_ORANGE)⚠️  Dikkat: Root olarak ISO içerisinde çalışıyorsunuz!$(COLOR_RESET)"
	# Sistem dizinlerini mount et
	sudo mount --bind /dev $(ISO_ROOT)/dev
	sudo mount --bind /proc $(ISO_ROOT)/proc
	sudo mount --bind /sys $(ISO_ROOT)/sys
	# Chroot shell'i aç
	$(call chroot,/bin/bash)
	# Temizlik yap
	sudo umount $(ISO_ROOT)/dev
	sudo umount $(ISO_ROOT)/proc
	sudo umount $(ISO_ROOT)/sys
	@echo "$(COLOR_GREEN)Chroot environment kapatıldı.$(COLOR_RESET)"

# ================================================
# TEMİZLİK HEDEFLERİ (Cleanup Targets)
# ================================================

.PHONY: clean
clean:
	@echo "$(COLOR_ORANGE)Geçici dosyalar temizleniyor...$(COLOR_RESET)"
	echo User ISO Dosyalar temizlendi.
	@make iso_clean-up-all
	@echo "$(COLOR_GREEN)Temizlik tamamlandı.$(COLOR_RESET)"
	
.PHONY: iso_clean-up-all
iso_clean-up-all: clean
	@echo "$(COLOR_RED)TÜM ISO dosyaları ve klasörleri SİLİNİYOR...$(COLOR_RESET)"
	@echo "$(COLOR_ORANGE)Bu işlem geri alınamaz!$(COLOR_RESET)"
	sudo rm -rf ${ISO_ROOT}          # Çıkarılan ISO içeriği
	sudo rm -rf ${ISO_FILES}         # Oluşturulan ISO dosyaları
	sudo rm -rf ${ISO_ROOT}.*        # Yedek klasörler
	@echo "$(COLOR_GREEN)Tam temizlik tamamlandı.$(COLOR_RESET)"

# ================================================
# YARDIM VE BİLGİ (Help and Information)
# ================================================

.PHONY: help
help:
	@echo "$(COLOR_BLUE)$(UNDERLINE)CUSTOM ISO BUILDER - YARDIM$(COLOR_RESET)"
	@echo ""
	@echo "$(COLOR_GREEN)Temel Kurulum:$(COLOR_RESET)"
	@echo "  make iso_depends        - Sistem bağımlılıklarını yükle"
	@echo "  make iso_download       - Ubuntu ISO'yu indir"
	@echo "  make iso_init           - ISO'yu çıkar ve hazırla"
	@echo ""
	@echo "$(COLOR_GREEN)Konfigürasyon:$(COLOR_RESET)"
	@echo "  make iso_setup          - Özel konfigürasyonları uygula"
	@echo "  make iso_setup-isolinux - APU/APU2 için ISOLINUX kur"
	@echo ""
	@echo "$(COLOR_GREEN)ISO Oluşturma:$(COLOR_RESET)"
	@echo "  make iso_geniso         - Standard ISO oluştur (GRUB)"
	@echo "  make iso_geniso-isolinux- APU/APU2 ISO oluştur (ISOLINUX)"
	@echo ""
	@echo "$(COLOR_RED)Kritik İşlemler:$(COLOR_RESET)"
	@echo "  make iso_write_usb      - $(COLOR_RED)⚠️  USB'ye yaz (VERİ SİLİNİR!)$(COLOR_RESET)"
	@echo ""
	@echo "$(COLOR_ORANGE)Yardımcı İşlemler:$(COLOR_RESET)"
	@echo "  make iso_chroot-shell   - ISO içinde shell aç"
	@echo "  make clean              - Geçici dosyaları temizle"
	@echo "  make iso_clean-up-all   - TÜM dosyaları sil"
	@echo ""
	@echo "$(COLOR_BLUE)Docker Server:$(COLOR_RESET)"
	@echo "  make iso_server_build   - Docker sunucusunu oluştur"
	@echo "  make iso_server_run     - Docker sunucusunu çalıştır"
	@echo ""

.PHONY: status
status:
	@echo "$(COLOR_BLUE)$(UNDERLINE)SİSTEM DURUMU$(COLOR_RESET)"
	@echo ""
	@echo "$(COLOR_GREEN)ISO Durumu:$(COLOR_RESET)"
	@if [ -f "$(ISO_FILENAME)" ]; then \
		echo "  ✅ Ubuntu ISO: $(COLOR_GREEN)Mevcut$(COLOR_RESET) - $(ISO_FILENAME)"; \
	else \
		echo "  ❌ Ubuntu ISO: $(COLOR_RED)Yok$(COLOR_RESET) - 'make iso_download' çalıştırın"; \
	fi
	@if [ -d "$(ISO_ROOT)" ]; then \
		echo "  ✅ ISO Root: $(COLOR_GREEN)Hazır$(COLOR_RESET) - $(ISO_ROOT)"; \
	else \
		echo "  ❌ ISO Root: $(COLOR_RED)Yok$(COLOR_RESET) - 'make iso_init' çalıştırın"; \
	fi
	@echo ""
	@echo "$(COLOR_GREEN)Oluşturulan ISO'lar:$(COLOR_RESET)"
	@if [ -d "$(ISO_FILES)" ] && [ -n "$$(ls -A $(ISO_FILES) 2>/dev/null)" ]; then \
		ls -lh $(ISO_FILES)/user-custom-autoinstaller.*.iso 2>/dev/null | awk '{print "  📀 " $$9 " (" $$5 ")"}' || echo "  ❌ Hiç ISO oluşturulmamış"; \
	else \
		echo "  ❌ Hiç ISO oluşturulmamış"; \
	fi

