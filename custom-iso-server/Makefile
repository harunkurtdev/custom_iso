
# ================================================
# CUSTOM ISO DOCKER SERVER - MAKEFILE
# ================================================
# Bu dosya Docker tabanlı HTTP sunucusunu yönetir
# Sunucu, autoinstall dosyalarını ağ üzerinden sunar
# IP: 172.20.0.2, Port: 3003

# ================================================
# DOCKER VE AĞ AYARLARI (Docker and Network Settings)
# ================================================
DOCKER:= sudo docker                           # Docker komut prefix'i (sudo gerekli)
GATEWAY:=172.20.0.1                           # Ağ geçidi (host sistem)
IP:=172.20.0.2                                # Sunucu IP adresi
NETWORK_NAME:=custom_iso_network               # Docker ağ adı
SUBNET:=172.20.0.0/16                         # Ağ alt ağı
CONTAINER_NAME:=docker_server_user             # Container adı
DOCKERFILE_PATH:=$(PWD)/custom-iso-server/server.Dockerfile
BUILD_CONTEXT:=$(PWD)/custom-iso-server/

# ================================================
# ANA HEDEFLER (Main Targets)
# ================================================

# Varsayılan hedef: sunucuyu oluştur ve çalıştır
all: iso_server_build iso_server_run
	@echo "$(COLOR_GREEN)Docker sunucu hazır ve çalışıyor!$(COLOR_RESET)"

# ================================================
# HEDEF: iso_server_build
# ================================================
# Docker imajını oluşturur ve ağ yapılandırmasını yapar
# Bu işlem değişiklik yapıldığında tekrarlanmalıdır
.PHONY: iso_server_build
iso_server_build:
	@echo "🐳 Docker sunucu imajı oluşturuluyor..."
	
	# Docker ağını oluştur (zaten varsa hata vermez)
	@echo "📡 Docker ağı oluşturuluyor: $(NETWORK_NAME)"
	$(DOCKER) network create --subnet=$(SUBNET) --gateway=$(GATEWAY) $(NETWORK_NAME) || true
	
	# Eski container'ı temizle (varsa)
	@echo "🧹 Eski container temizleniyor..."
	$(DOCKER) rm -f $(CONTAINER_NAME) 2>/dev/null || true
	
	# Docker imajını oluştur
	@echo "🔨 Docker imajı build ediliyor..."
	$(DOCKER) build -t $(CONTAINER_NAME) --file $(DOCKERFILE_PATH) $(BUILD_CONTEXT)
	
	@echo "✅ Docker sunucu başarıyla oluşturuldu!"
	@echo "📋 Ağ Bilgileri:"
	@echo "   - Subnet: $(SUBNET)"
	@echo "   - Gateway: $(GATEWAY)"
	@echo "   - Server IP: $(IP)"

# ================================================
# HEDEF: iso_server_run
# ================================================
# Docker container'ını çalıştırır ve sunucuyu başlatır
# Container interaktif modda çalışır
.PHONY: iso_server_run
iso_server_run:
	@echo "🚀 Docker sunucu başlatılıyor..."
	
	# Ağın mevcut olduğundan emin ol
	$(DOCKER) network create --subnet=$(SUBNET) --gateway=$(GATEWAY) $(NETWORK_NAME) || true
	
	# Sunucuyu çalıştır
	@echo "🌐 Sunucu çalıştırılıyor: http://$(IP):3003"
	@echo "⚠️  Bu pencereyi kapatmayın - sunucu çalışır durumda!"
	@echo "🛑 Durdurmak için: Ctrl+C"
	$(DOCKER) run -it --rm --network $(NETWORK_NAME) --ip $(IP) --name $(CONTAINER_NAME) $(CONTAINER_NAME) || true

# ================================================
# HEDEF: iso_server_shell
# ================================================
# Sunucu container'ı içinde interaktif shell açar
# Debug ve konfigürasyon için kullanılır
.PHONY: iso_server_shell
iso_server_shell:
	@echo "🐚 Docker sunucu shell'i açılıyor..."
	@echo "💡 Tips: 'exit' yazarak shell'den çıkabilirsiniz"
	$(DOCKER) run -it --rm --network $(NETWORK_NAME) --ip $(IP) --entrypoint /bin/bash $(CONTAINER_NAME)

# ================================================
# HEDEF: iso_server_logs
# ================================================
# Çalışan sunucunun loglarını gösterir
.PHONY: iso_server_logs
iso_server_logs:
	@echo "📋 Docker sunucu logları..."
	$(DOCKER) logs -f $(CONTAINER_NAME) 2>/dev/null || echo "❌ Çalışan container bulunamadı"

# ================================================
# HEDEF: iso_server_status
# ================================================
# Sunucu ve ağ durumunu kontrol eder
.PHONY: iso_server_status
iso_server_status:
	@echo "📊 Docker Sunucu Durumu:"
	@echo ""
	@echo "🐳 Container Durumu:"
	@$(DOCKER) ps -a --filter name=$(CONTAINER_NAME) --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" || echo "❌ Container bulunamadı"
	@echo ""
	@echo "📡 Ağ Durumu:"
	@$(DOCKER) network ls --filter name=$(NETWORK_NAME) --format "table {{.Name}}\t{{.Driver}}\t{{.Scope}}" || echo "❌ Ağ bulunamadı"
	@echo ""
	@echo "🌐 Ağ Detayları:"
	@$(DOCKER) network inspect $(NETWORK_NAME) --format '{{range .IPAM.Config}}Subnet: {{.Subnet}}, Gateway: {{.Gateway}}{{end}}' 2>/dev/null || echo "❌ Ağ detayları alınamadı"

# ================================================
# HEDEF: iso_server_test
# ================================================
# Sunucunun çalışıp çalışmadığını test eder
.PHONY: iso_server_test
iso_server_test:
	@echo "🧪 Sunucu bağlantısı test ediliyor..."
	@echo "📡 Test URL: http://$(IP):3003"
	
	# Curl ile bağlantı testi
	@if command -v curl >/dev/null 2>&1; then \
		echo "🔍 HTTP GET test yapılıyor..."; \
		curl -f --connect-timeout 5 http://$(IP):3003/ && echo "✅ Sunucu erişilebilir!" || echo "❌ Sunucu erişilemiyor!"; \
	else \
		echo "⚠️  curl bulunamadı, ping testi yapılıyor..."; \
		ping -c 3 $(IP) && echo "✅ IP erişilebilir!" || echo "❌ IP erişilemiyor!"; \
	fi


# ================================================
# TEMİZLİK VE BAKIM HEDEFLERİ (Cleanup and Maintenance)
# ================================================

.PHONY: iso_server_clean
iso_server_clean:
	@echo "🧹 Docker sunucu temizleniyor..."
	
	# Çalışan container'ı durdur
	@echo "🛑 Container durduruluyor..."
	$(DOCKER) stop $(CONTAINER_NAME) 2>/dev/null || true
	
	# Container'ı sil
	@echo "🗑️  Container siliniyor..."
	$(DOCKER) rm $(CONTAINER_NAME) 2>/dev/null || true
	
	# Docker imajını sil
	@echo "🗑️  Docker imajı siliniyor..."
	$(DOCKER) rmi $(CONTAINER_NAME) 2>/dev/null || true
	
	# Ağı sil
	@echo "🗑️  Docker ağı siliniyor..."
	$(DOCKER) network rm $(NETWORK_NAME) 2>/dev/null || true
	
	@echo "✅ Docker sunucu temizlendi."

.PHONY: iso_server_restart
iso_server_restart:
	@echo "🔄 Docker sunucu yeniden başlatılıyor..."
	@make iso_server_clean
	@make iso_server_build
	@echo "✅ Sunucu yeniden oluşturuldu. Çalıştırmak için: make iso_server_run"

# ================================================
# YARDIM VE DOKÜMANTASYON (Help and Documentation)
# ================================================

.PHONY: help
help:
	@echo "🐳 DOCKER SUNUCU YARDIM"
	@echo ""
	@echo "📋 Temel Komutlar:"
	@echo "  make iso_server_build   - Docker imajını oluştur"
	@echo "  make iso_server_run     - Sunucuyu başlat (interaktif)"
	@echo "  make iso_server_shell   - Container içinde shell aç"
	@echo ""
	@echo "🔍 İzleme ve Test:"
	@echo "  make iso_server_status  - Sunucu durumunu kontrol et"
	@echo "  make iso_server_test    - Bağlantı testi yap"
	@echo "  make iso_server_logs    - Sunucu loglarını göster"
	@echo ""
	@echo "🧹 Temizlik:"
	@echo "  make iso_server_clean   - Sunucuyu tamamen temizle"
	@echo "  make iso_server_restart - Sunucuyu yeniden oluştur"
	@echo ""
	@echo "🌐 Ağ Bilgileri:"
	@echo "  Server URL: http://$(IP):3003"
	@echo "  Network: $(NETWORK_NAME)"
	@echo "  Subnet: $(SUBNET)"

# Ana temizlik hedefi (üst Makefile ile uyumluluk için)
.PHONY: clean
clean:
	@make iso_server_clean

# ================================================
# GELİŞTİRİCİ HEDEFLERİ (Developer Targets)
# ================================================

.PHONY: iso_server_debug
iso_server_debug:
	@echo "🐛 Debug modunda sunucu başlatılıyor..."
	@echo "📋 Debug bilgileri:"
	@echo "  - Container: $(CONTAINER_NAME)"
	@echo "  - Network: $(NETWORK_NAME)"
	@echo "  - IP: $(IP)"
	@echo "  - Dockerfile: $(DOCKERFILE_PATH)"
	@echo ""
	$(DOCKER) run -it --rm --network $(NETWORK_NAME) --ip $(IP) \
		-e DEBUG=1 \
		--name $(CONTAINER_NAME) \
		$(CONTAINER_NAME)

.PHONY: iso_server_inspect
iso_server_inspect:
	@echo "🔍 Container detayları:"
	$(DOCKER) inspect $(CONTAINER_NAME) 2>/dev/null || echo "❌ Container bulunamadı"
	@echo ""
	@echo "🔍 Network detayları:"
	$(DOCKER) network inspect $(NETWORK_NAME) 2>/dev/null || echo "❌ Network bulunamadı"

# ================================================
# NOTLAR VE İPUÇLARI
# ================================================
# 
# 🎯 Kullanım Örnekleri:
# 
# 1. İlk Kurulum:
#    make iso_server_build
#    make iso_server_run
# 
# 2. Geliştirme:
#    make iso_server_shell  # Dosyaları düzenle
#    make iso_server_restart # Değişiklikleri uygula
# 
# 3. Problem Giderme:
#    make iso_server_status
#    make iso_server_test
#    make iso_server_logs
# 
# 4. Temizlik:
#    make iso_server_clean
# 
# ⚠️  Notlar:
# - Sunucu 172.20.0.2:3003 adresinde çalışır
# - Container interaktif modda çalışır (Ctrl+C ile durdur)
# - Network otomatik olarak oluşturulur/silinir
# - user-data ve meta-data dosyaları HTTP üzerinden sunulur
# 
# ================================================