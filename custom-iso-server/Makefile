
# ================================================
# CUSTOM ISO DOCKER SERVER - MAKEFILE
# ================================================
# This Makefile manages the Docker-based configuration server
# that provides dynamic configuration delivery during ISO installation.
#
# Network Configuration:
# - Subnet: 172.20.0.0/16
# - Gateway: 172.20.0.1
# - Server IP: 172.20.0.2
# - Service Port: 3003
# ================================================

# Docker command with sudo access
DOCKER:= sudo docker

# Network configuration for Docker server
GATEWAY:=172.20.0.1
IP:=172.20.0.2
NETWORK_NAME:=custom_iso_network
SUBNET:=172.20.0.0/16

# Color definitions for output
COLOR_BLUE = \033[0;34m
COLOR_GREEN = \033[0;32m
COLOR_ORANGE = \033[0;33m
COLOR_RED = \033[0;31m
COLOR_RESET = \033[0m

# ================================================
# MAKEFILE TARGETS
# ================================================

.PHONY: help
help: ## Show available Docker server commands
	@echo "$(COLOR_BLUE)Custom ISO Docker Server - Available Commands$(COLOR_RESET)"
	@echo "$(COLOR_BLUE)=============================================$(COLOR_RESET)"
	@echo ""
	@echo "$(COLOR_GREEN)Server Management:$(COLOR_RESET)"
	@echo "  iso_server_build - Build Docker configuration server image"
	@echo "  iso_server_run   - Run Docker configuration server"
	@echo "  iso_server_shell - Access server shell for debugging"
	@echo ""
	@echo "$(COLOR_GREEN)Maintenance:$(COLOR_RESET)"
	@echo "  iso_server_clean - Remove Docker network and containers"
	@echo "  clean           - Full cleanup of server components"
	@echo ""
	@echo "$(COLOR_ORANGE)Network Information:$(COLOR_RESET)"
	@echo "  Network: $(SUBNET)"
	@echo "  Gateway: $(GATEWAY)"
	@echo "  Server IP: $(IP)"
	@echo ""

# Default target for quick setup
all: iso_server_build iso_server_run

.PHONY: iso_server_build
iso_server_build: ## Build Docker configuration server image
	@echo "$(COLOR_BLUE)Building Docker configuration server...$(COLOR_RESET)"
	@echo "Creating Docker network: $(NETWORK_NAME)"
	$(DOCKER) network create --subnet=$(SUBNET) --gateway=$(GATEWAY) $(NETWORK_NAME) || true
	@echo "Building server image from Dockerfile"
	$(DOCKER) build -t docker_server_user --file $(PWD)/custom-iso-server/server.Dockerfile $(PWD)/custom-iso-server/
	@echo "$(COLOR_GREEN)Docker server build completed$(COLOR_RESET)"

.PHONY: iso_server_run  
iso_server_run: ## Run Docker configuration server
	@echo "$(COLOR_BLUE)Starting Docker configuration server...$(COLOR_RESET)"
	@echo "Network: $(NETWORK_NAME) ($(SUBNET))"
	@echo "Server IP: $(IP)"
	$(DOCKER) network create --subnet=$(SUBNET) --gateway=$(GATEWAY) $(NETWORK_NAME) || true
	@echo "$(COLOR_GREEN)Server starting on http://$(IP):3003$(COLOR_RESET)"
	@echo "$(COLOR_ORANGE)Use Ctrl+C to stop the server$(COLOR_RESET)"
	$(DOCKER) run -it --network $(NETWORK_NAME) --ip $(IP) docker_server_user || true

.PHONY: iso_server_shell
iso_server_shell: ## Access server shell for debugging and monitoring
	@echo "$(COLOR_BLUE)Accessing Docker server shell...$(COLOR_RESET)"
	@echo "$(COLOR_ORANGE)Use 'exit' to leave the server shell$(COLOR_RESET)"
	$(DOCKER) run -it --network $(NETWORK_NAME) --ip $(IP) --entrypoint /bin/bash docker_server_user

.PHONY: iso_server_clean
iso_server_clean: ## Clean up Docker network and containers
	@echo "$(COLOR_BLUE)Cleaning up Docker server components...$(COLOR_RESET)"
	$(DOCKER) network rm $(NETWORK_NAME) || true
	@echo "$(COLOR_GREEN)Docker server cleanup completed$(COLOR_RESET)"

.PHONY: clean
clean: ## Full cleanup of all server components
	@make iso_server_clean