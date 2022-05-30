all: build

push: build
	rsync -avz --delete book/ hostname.domain.xyz:/var/www/html/newbook/

build:
	mdbook build

serve:
	mdbook serve --open --hostname 127.0.0.1
