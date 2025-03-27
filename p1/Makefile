all: 						   
	@docker compose -f dockercompose.yml build
	@docker compose -f dockercompose.yml pull

stop:
	@docker compose -f dockercompose.yml stop

ls:
	@-docker compose -f dockercompose.yml ps
	@docker images
	@docker volume ls
	@docker network ls

down:
	-docker compose -f dockercompose.yml down
	-docker container prune -f
	-docker volume prune -f
	-docker image prune -f -a
	-docker network prune -f
	-docker system prune --all --volumes --force

re: stop down all

.PHONY: start stop ls down all info re
