all: build

build:
	mdbook build

serve:
	mdbook serve --open --hostname 127.0.0.1

###############################################################################
#
# Change the 'push' target to reference the specific target(s) you want the
# site to be published to. Examples:
#
#   push: rsync
#   push: gh-pages

push:

########################################
# IF you're going to publish the generated book to a web server, and you're
# able to use 'rsync' to upload the files ...
#
# - Change the 'push:' line to say 'push: rsync'
# - Edit the rsync command below as needed.

rsync: build
	rsync -avz --delete book/ host.domain.xyz:/var/www/html/newbook/

########################################
# IF you're going to publish the generated book to GitHub Pages, using the
# same repo where you're tracking the source ...
#
# - Change the 'push:' line above to say 'push: gh-pages'
#
# NOTES:
# - These commands work for me using bash. If you're using some other shell,
#   you may need to adjust or remove this line.
# - The 'git worktree' commands require git version 2.0.7 or later.

gh-pages: build
	set -ex ; \
	WORK="$$( mktemp -d )" ; \
	VER="$$( git describe --always --tags --dirty )" ; \
	git worktree add --force "$$WORK" gh-pages ; \
	rm -rf "$$WORK"/* ; \
	rsync -av book/ "$$WORK"/ ; \
	pushd "$$WORK" ; \
	git add -A ; \
	git commit -m "Updated gh-pages $$VER" ; \
	popd ; \
	git worktree remove "$$WORK" ; \
	git push origin gh-pages