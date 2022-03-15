.PHONY: build save

NAME:=alpine-oreo

#  --no-cache
build: Dockerfile oreo.tar.gz
	docker build --tag "$(NAME)" --file Dockerfile .

# https://docs.docker.com/engine/reference/commandline/save/
save: build
	@echo "saving (this may take some time)"
	docker save "$(NAME):latest" | gzip > "$(NAME).tar.gz"
	@echo "saved to: \"$(NAME).tar.gz\""