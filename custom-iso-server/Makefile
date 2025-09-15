
DOCKER:= sudo docker
GATEWAY:=172.20.0.1
IP:=172.20.0.2


all: iso_server_build server_run

iso_server_build:
	$(DOCKER) network create --subnet=172.20.0.0/16 --gateway=172.20.0.1  custom_iso_network || true
	$(DOCKER) build -t docker_server_user --file $(PWD)/custom-iso-server/server.Dockerfile $(PWD)/custom-iso-server/

iso_server_run:
	$(DOCKER) network create --subnet=172.20.0.0/16 --gateway=172.20.0.1  custom_iso_network || true
	$(DOCKER) run -it --network custom_iso_network --ip 172.20.0.2  docker_server_user || true

iso_server_shell:
	$(DOCKER) run -it --network custom_iso_network --ip 172.20.0.2 --entrypoint /bin/bash docker_server_user


.PHONY: iso_server_clean
iso_server_clean:
	$(DOCKER) network rm custom_iso_network || true
	@echo "User Custom ISO Server temizlendi."
	@echo $(PWD)


.PHONY: clean
clean:
	@make iso_server_clean