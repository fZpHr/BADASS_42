all:									   
	@docker compose -f dockercompose.yml up || echo "Docker compose failed, continuing..."

stop:
	@docker compose -f dockercompose.yml stop

ls:
	@-docker compose -f dockercompose.yml ps
	@docker images
	@docker volume ls
	@docker network ls

clean:
	@-docker compose -f dockercompose.yml down
	@docker system prune -a -f
	@docker volume prune -f
	@docker network prune -f

re: stop clean all

.PHONY: start stop ls clean all info re
