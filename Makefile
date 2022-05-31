all: build

push: build
	rsync -avz --delete book/ jms1.net:/var/www/mdbook-template.jms1.info/docs/

build:
	mdbook build

serve:
	mdbook serve --open --hostname 127.0.0.1
