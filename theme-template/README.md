# Updating the `theme-template/` Files

John Simpson `<jms1@jms1.net>` 2025-05-26

Last updated 2025-08-03

There will be times when `mdbook` makes changes to the *original* files that this repo's `theme-template/` files were copied from. In a few cases, these changes can "break" `mdbook`, especially since the mechanism used to make the browser reload itself automatically, is implemented in Javascript.

As an example, in 2024-11, `mdbook` v0.4.41 changed how the web pages are rendered. Previously, each page was in a single file and contained a copy of the ToC. Now, the ToC is stored in a separate file from the main page, and it's generated from *two* template files - one for browsers running javascript, and one for browsers *not* running javascript.

### Updating the Template Files By Hand

To update the template files by hand ...

* Copy the original files from the [`mdbook` source code](https://github.com/rust-lang/mdBook/blob/master/src/theme/), into the book's `theme-template/` directory.

* Edit the copies. Insert the HTML fragments in the correct places.

This sounds simple, but for me it became fairly tedious after doing it half a dozen times. A big part of my day job involves automating system administration tasks, so to me it seemed natural to write a script to automate it. This is why I wrote the `mdbook-fix-templates` script, and later "clean up" the script when other people started working on some of the books I write at work.


## The `mdbook-fix-templates` script

This script updates the `.hbs` files in the `theme-template/` directory, after `mdbook` itself is upgraded. It works by reading the original files from `mdbook`'s source code, inserting the necessary HTML fragments where needed, and writing the modified files to the current directory.

I had originally written this as a quick-and-dirty shell script, and while it did *work*, I found myself having to do a lot of manual maintenance on it. It started off as a shell script with a mix of shell variable operators, plus a few `sed` and `awk` commands, and I had to update it for almost every new `mdbook` version because it made a lot of assumptions about the structure of the source file ... and then later it needed to edit *three* files instead of just one.

Recently (2024-05) I decided to re-write the whole thing in Perl, which is *much* better at manipulating text. While doing this, I decided to also clean it up and share it with the world.

I also structured the script so the HTML fragments are stored in each book's repo, so that different books can have different things added to them. I use `mdbook` for personal projects *and* at work, and the books I maintain at work have different requirements than what I use for personal projects. In particular, adding links at the top of the ToC is something I do at work.


### One-Time Setup

* Clone the [mdbook source code](https://github.com/rust-lang/mdBook/) on your workstation.

    ```
    mkdir -p ~/git/rust-lang
    cd ~/git/rust-lang/
    git clone https://github.com/rust-lang/mdBook
    ```

* The script will need to be told where the mdbook source code repo is cloned. There are three ways to do this:

    * Create a `$HOME/.config/mdbook-fix-templates/repo_dir.txt` file, whose *first line* contains the path to the right directory. (Everything other than the first line will be ignored.)

        ```
        mkdir -p ~/.config/mdbook-fix-templates
        cd ~/.config/mdbook-fix-templates/
        echo "/path/to/rust-lang/mdBook" > repo_dir.txt
        ```

    * Use the `-r` option every time you run the script. (If you also created the `repo_dir.txt` file, this value will be used instead of what's in the file.)

        ```
        ./mdbook-fix-templates -r /path/to/rust-lang/mdBook
        ```

    * If neither is done, the script will use "`$HOME/git/rust-lang/mdBook`" by default.

* Wherever the repo is cloned, mke sure it's "checked out" to the tag for which corresponds to the version of `mdbook` you're running.

    ```
    cd ~/git/rust-lang/mdBook/
    git fetch -p
    git checkout $( mdbook --version | awk '{print $2}' )
    ```

### Add or Customize the HTML Fragments

In the book's `theme-template/` directory, create or update the following files, *if they are needed in that book*. If you're working on a book which doesn't need one or more of these files, remove them from the directory.

* `above-toc.html` - The contents of this file will be added above the ToC (Table of Contents). I use this at work to add a link back to an internal web page containing a list of "books".

    ```html
    ↵
    <!-- Start content above ToC -->
        <a href='https://github.com/kg4zow/mdbook-template/'>Github Repo</a>
    <!-- End content above ToC -->
    ↵
    ```

* `below-toc.html` - The contents of this file will be added below the ToC. I use this for the commit information added by the `version-commit` script.

    ```html
    ↵
    <!-- Start version-commit content below ToC -->
        <hr/>
        <div class="part-title">Version</div>
        <div id="commit" class='version-commit-div'>
            <span class='version-commit-hash'><tt>@VERSION_COMMIT_HASH@</tt></span><br/>
            <span class='version-commit-time'><tt>@VERSION_COMMIT_TIME@</tt></span>
        </div>
        <div class="part-title">Generated</div>
        <div id="generated" class='version-commit-div'>
            <span class='version-commit-now'><tt>@VERSION_COMMIT_NOW@</tt></span>
        </div>
    <!-- End version-commit content below ToC -->
    ↵
    ```

* `below-page.html` - The contents of this file will be added at the bottom of the content on every page.

    ```html
    ↵
    <!-- Start version-commit content below every page -->
        <hr/>
        <div class="version-commit-div" style="float: right">
            Generated
            <span class='version-commit-now'><tt>@VERSION_COMMIT_NOW@</tt></span>
        </div>
        <div class="version-commit-div">
            <span class='version-commit-hash'><tt>@VERSION_COMMIT_HASH@</tt></span>
            <span class='version-commit-time'><tt>@VERSION_COMMIT_TIME@</tt></span>
        </div>
    <!-- End version-commit content below every page -->
    ↵
    ```

> &#x2139;&#xFE0F; **Blank Lines**
>
> Github's markdown engine won't show blank lines at the beginning or end of a code block, but all three of the HTML fragments above should have empty lines above and below them. I'm using the "&#x21B5;" symbol to represent that blank line. If you copy/paste the blocks, be sure to remove these characters.

### Using the Script

When you're about to start working on a "book", do the following:

* Check which version of `mdbook` you're using.

    ```
    $ mdbook --version
    mdbook v0.4.52
    ```

* If a newer version is available, you may want to upgrade.

    I like to use the [latest released version](https://github.com/rust-lang/mdBook/releases). I use [Homebrew](https://brew.sh/) to install `mdbook` on my workstations, so *for me* the upgrade process is ...

    * Run "`brew update`" to see if a new version of `mdbook` is available.

    * If so, run "`brew upgrade mdbook`" to upgrade it, or "`brew upgrade`" to upgrade *all* packages which have updates available.

* Check the version which generated the current template files.

    The script adds a line to the end of each file it generates, identifying the versions of `mdbook-fix-template` and `mdbook` that were used to generate that file. (The option on the `tail` command is a "one", not a "lowercase L".)

    ```
    $ tail -1 *.hbs
    ==> index.hbs <==
    <!-- mdbook-fix-templates v0.2.0 2025-05-25 - mdbook v0.4.50 -->

    ==> toc.html.hbs <==
    <!-- mdbook-fix-templates v0.2.0 2025-05-25 - mdbook v0.4.50 -->

    ==> toc.js.hbs <==
    // mdbook-fix-templates v0.2.0 2025-05-25 - mdbook v0.4.50
    ```

    If you're using the same version of `mdbook` which generated the files, you shouldn't need to update the files. If not (as in the example) ...

* Make sure your clone of the mdbook source code repo is up to date, and checked out to the same tag as whatever version of `mdbook` you're using.

    ```
    cd ~/git/rust-lang/mdBook/
    git fetch -p
    git checkout $( mdbook --version | awk '{print $2}' )
    ```

* Make sure the book's directory is up to date with the book's git repo.

    ```
    cd /path/to/book/
    git fetch -p
    git checkout main
    git pull
    ```

* In the book's `theme-template/` directory, run the script.

    ```
    cd theme-template/
    ./mdbook-fix-templates
    ```

* Run `git status` to see if any of the files were changed. If so, commit *just* those changes, so they show up as their own commit in the repo's history.

    ```
    git status
    git add .
    git commit -m "Update templates for $( mdbook --version )"
    ```

After this, start updating the book's content as usual.

```
cd ..
bbedit .
make serve
```

# License

The `mdbook-fix-templates` script was written (and then re-written) by myself, and is licensed under the [MIT License](LICENSE.txt).

The `.hbs` files in this repo's `/theme-template/` directory were copied from the `/src/theme/` directory in [the mdbook source](https://github.com/rust-lang/mdBook/blob/master/src/theme/) and then modified. As such, these files are technically covered by the Mozilla Public License 2.0, [as noted in their repo](https://github.com/rust-lang/mdBook/blob/master/LICENSE).

Enjoy.
