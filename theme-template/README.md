# Updating the `theme-template/` Files

John Simpson `<jms1@jms1.net>` 2025-05-26

Last updated 2026-01-21

There will be times when `mdbook` makes changes to the *original* files that this repo's `theme-template/` files were copied from. In a few cases, these changes can "break" `mdbook`, especially since the mechanism used to make the browser reload itself automatically, is implemented in Javascript.

As an example, in 2024-11, `mdbook` v0.4.41 changed how the web pages are rendered. Previously, each page was in a single file and contained a copy of the ToC. Now, the ToC is stored in a separate file from the main page, and it's generated from *two* template files - one for browsers running javascript, and one for browsers *not* running javascript.


### Updating the Template Files By Hand

To update the template files by hand ...

* Copy the original files from the [`mdbook` source code](https://github.com/rust-lang/mdBook/blob/master/src/theme/), into the book's `theme-template/` directory.

* Edit the copies. Insert the HTML fragments in the correct places.

This sounds simple, but for me it became fairly tedious after doing it half a dozen times, since it has to be done in every book, every time `mdbook` is updated.

A big part of my day job involves automating system administration tasks, so to me it seemed natural to write a script to do it automatically. This is why I wrote the `mdbook-fix-templates` script.


## The `mdbook-fix-templates` script

This script updates the `.hbs` files in the `theme-template/` directory. It does the following:

* Identify which version of `mdbook` is running.
* Read the custom HTML fragment into memory.
* For each file being customized ...
    * Download the original from `mdbook`'s source code in Github, if it hasn't been downloaded yet. (The downloaded files are saved locally so each one only needs to be downloaded once.)
    * Read the original file (from `mdbook`) into memory.
    * Insert the HTML fragments in the correct places.
    * Write the modified file in the `theme-template/` directory.

The script needs to be run ...

* After `mdbook` itself is upgraded.
* Whenever the HTML fragment files are updated.

After running this script ... when `mdbook` converts the Markdown source files to HTML, it runs the `version-commit` script. This reads the files from `theme-template/`, substitutes the versions and timestamps in the correct places, and writes the *actual* theme files to the `theme/` directory, which is then used to build the book's HTML files. This happens *every time the book is rendered*, which may happen dozens or hundreds of times while `mdbook serve` is running.

I had originally written this as a quick-and-dirty shell script, and while it did *work*, I found myself having to do a lot of manual maintenance on it. It started off as a shell script with a mix of shell variable operators, plus a few `sed` and `awk` commands, and I had to update it for almost every new `mdbook` version because it made a lot of assumptions about the structure of the source file ... and then later it needed to edit *three* files instead of just one.

Recently (2024-05) I decided to re-write the whole thing in Perl, which is *much* better at manipulating text. While doing this, I decided to also clean it up and share it with the world.

I also structured the script so the HTML fragments are stored in each book's repo, so that different books can have different things added to them. I use `mdbook` for personal projects *and* at work, and the books I maintain at work have different requirements than what I use for personal projects. In particular, adding links at the top of the ToC is something I do at work.


### Adding or Updating the HTML Fragments

In the book's `theme-template/` directory, create or update the following files, *if they are needed in that book*. If you're working on a book which doesn't need one or more of these files, remove them from the directory.

* `above-toc.html` - If this file exists, its contents will be added above the ToC (Table of Contents). I use this at work to add a link back to an internal web page containing a list of "books".

    ```html
    ↵
    <!-- Start content above ToC -->
        <a href='https://github.com/kg4zow/mdbook-template/'>Github Repo</a>
    <!-- End content above ToC -->
    ↵
    ```

* `below-toc.html` - If this file exists, its contents will be added below the ToC. I use this for the commit information added by the `version-commit` script.

    ```html
    ↵
    <!-- Start version-commit content below ToC -->
        <hr/>
        <div class="part-title">Version</div>
        <div id="commit" class='version-commit-div-l'>
            <span class='version-commit-hash'><tt>@VERSION_COMMIT_HASH@</tt></span><br/>
            <span class='version-commit-time'><tt>@VERSION_COMMIT_TIME@</tt></span>
        </div>
        <div class="part-title">Generated</div>
        <div id="generated" class='version-commit-div-l'>
            <span class='version-commit-now'><tt>@VERSION_COMMIT_NOW@</tt></span>
        </div>
    <!-- End version-commit content below ToC -->
    ↵
    ```

* `below-page.html` - If this file exists, its contents will be added at the bottom of every page.

    ```html
    ↵
    <!-- Start version-commit content below every page -->
        <hr/>
        <div class="version-commit-div-r" style="float: right">
            Generated
            <span class='version-commit-now'><tt>@VERSION_COMMIT_NOW@</tt></span>
        </div>
        <div class="version-commit-div-l">
            <span class='version-commit-hash'><tt>@VERSION_COMMIT_HASH@</tt></span>
            <span class='version-commit-time'><tt>@VERSION_COMMIT_TIME@</tt></span>
        </div>
    <!-- End version-commit content below every page -->
    ↵
    ```

> &#x2139;&#xFE0F; **Blank Lines**
>
> Github's markdown engine won't show blank lines at the beginning or end of a code block, but all three of the HTML fragments above should have empty lines above and below them. I'm using the "&#x21B5;" symbol to represent that blank line. If you copy/paste the blocks, be sure to remove these characters.

Other files you may see in the directory:

* `.gitignore` - tells `git` which files in/under this directory should be ignored
* `index.hbs` - the updated template, used to generate pages in the book
* `mdbook-fix-templates` - the script
* `README.md` - the documentation you're reading right now
* `toc.html.hbs` - the updated template for the ToC, when the browser *doesn't* allow javascript
* `toc.js.hbs` - the updated template for the ToC, when the browser *does* support javascript
* `vX.X.X/` (directory) - these directories will contain copies of the *original* `.hbs` files from `mdbook`'s source code


### Using the Script

When you're about to start working on a "book", do the following:

* Check which version of `mdbook` you're using.

    ```
    $ mdbook --version
    mdbook v0.4.52
    ```

* If a newer version of `mdbook` is *available*, you may want to upgrade.

    I like to use the [latest released version](https://github.com/rust-lang/mdBook/releases). I use [Homebrew](https://brew.sh/) to install `mdbook` on my workstations (usually macOS), so *for me* the upgrade process looks like this ...

    * Run "`brew update`" to update your computer's list of what packages are available in the Homebrew repositories. This will usually print a list of any outdated packages, i.e. packages for which updates are available, when it finishes.

    * If the command didn't show the list, or if you want to see it again, you can run "`brew outdated`" to show the list.

    * If a newer version of `mdbook` is available, run "`brew upgrade mdbook`" to upgrade just `mdbook`, or "`brew upgrade`" to upgrade *all* outdated packages.

    If you're using a different OS, or installed `mdbook` using some other method, you'll need to use the appropriate commands for your system.

* Check the version which generated the current template files.

    The script adds a comment at the end of each file it generates, identifying the versions of `mdbook-fix-template` and `mdbook` that were used to generate that file.

    ```
    $ tail -1 *.hbs
    ==> index.hbs <==
    <!-- mdbook-fix-templates v0.4.0 2025-12-12 - mdbook v0.5.2 -->

    ==> toc.html.hbs <==
    <!-- mdbook-fix-templates v0.4.0 2025-12-12 - mdbook v0.5.2 -->

    ==> toc.js.hbs <==
    // mdbook-fix-templates v0.4.0 2025-12-12 - mdbook v0.5.2
    ```

    (The option on the `tail` command is a "one", not a "lowercase L".)

If you're using the same version of `mdbook` which generated the current files, and the `.html` files haven't changed, then you shouldn't *need* to update the files. With that said, it won't hurt anything if you do - it'll just generate new copies of what will already be in the directory.

To run the script ...

* Make sure the book's directory is up to date with the book's git repo.

    ```
    cd /path/to/book/
    git fetch -p
    git pull
    ```

* In the book's `theme-template/` directory, run the script.

    ```
    cd theme-template/
    ./mdbook-fix-templates
    ```

    The output will look something like this.

    ```
    mdbook      v0.5.2
    reading     above-toc.html
    reading     below-toc.html
    reading     below-page.html
    downloading https://raw.githubusercontent.com/rust-lang/mdBook/refs/tags/v0.5.2/...
    writing     v0.5.2/index.hbs
    writing     ./index.hbs
    downloading https://raw.githubusercontent.com/rust-lang/mdBook/refs/tags/v0.5.2/...
    writing     v0.5.2/toc.html.hbs
    writing     ./toc.html.hbs
    downloading https://raw.githubusercontent.com/rust-lang/mdBook/refs/tags/v0.5.2/...
    writing     v0.5.2/toc.js.hbs
    writing     ./toc.js.hbs
    ```

    The script creates a directory for each `mdbook` version, where it stores that version's *original* `.hbs` files from Github. These `vX.X.X/` directories generally don't need to be saved in your book's git repo, so the `.gitignore` file contains the line "`v*/`".

    Note that if the original files have already been downloaded, the script will read them from the `vX.X.X/` directory instead of downloading them again.

* Run `git status` to see if any of the files were changed. If so, commit *just* those changes, so they show up as their own commit in the repo's history.

    ```
    git status
    git add .
    git commit -m "Update templates for $( mdbook --version )"
    ```

After updating the templates, start updating the book's content as usual.

```
cd ..
bbedit .
make serve
```

# License

The `mdbook-fix-templates` script was written (and then re-written) by myself, and is licensed under the [MIT License](LICENSE.txt).

Some files in this repo's `/theme-template/` directory may have been downloaded from [the mdbook source code](https://github.com/rust-lang/mdBook/blob/master/src/theme/) and then modified. As such, these files are covered by the Mozilla Public License 2.0, [as noted in their repo](https://github.com/rust-lang/mdBook/blob/master/LICENSE).

Enjoy.

*-jms1 2025-12-12*
