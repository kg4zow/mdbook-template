# `mdbook-template`

John Simpson `<jms1@jms1.net>` 2022-05-30

This repo contains a template that I use when creating new "books" using [mdbook](https://rust-lang.github.io/mdBook/), so I don't have to manually copy and edit a bunch of files.

# Background

## Section Lines

### What are "Section Lines"?

If you're looking at the generated HTML version of this file, you will notice horizontal lines of different thickness above some of the section headers. The three section headers above this paragraph will have the three "sizes" of lines.

Note that if you're looking at the Markdown files in the GitHub web interface, you'll see *different* horizontal lines (i.e. only for `H1` and `H2`, with lines the same thickness, and with the lines *below* the section header). This is because GitHub uses their own stylesheet, and doesn't offer a way to override it.

### Why?

I do this because it makes it easier for me to tell where each logical section of the document starts.

### How?

This is done using two files:

* **`section-lines.css`** - contains the CSS declarations which add the lines to the HTML.

    The CSS customizes the appearance of HTML `H1`, `H2`, and `H3` elements, *other than* the first `H1` on the page (because having an extra heavy bar across the top of the page was just too much.)

* **`book.toml`** - tells `mdbook` how to generate the book. The following line tells `mdbook`, when it generates HTML output, to include the following CSS files in addition to the ones included in the theme.

    ```toml
    [output.html]
    additional-css  = [ "section-lines.css" , "version-commit.css" ]
    ```

    This example has a second file in the `additional-css` list. This other file is used by the Automatic Git Commit Information feature, which is explained below.

## Automatic Git Commit Information

If you're looking at the generated HTML from this repo, you will notice at the bottom of the navigation bar on the left, a block containing a "Version". This information is the git commit from which the HTML was generated. This is not something that `mdbook` does on its own, I had to figure out how to make it happen.

**I am not the first person to figure out how to do this.** There are several other web pages out there explaining how to do more or less the same thing, and I *did* read through a few of them to get ideas. The pages I found all seemed to want to add the version information at the bottom of each page, but I wanted the information to be at the bottom of the navigation bar, so I ended up having to do a lot of trial and error and figure out parts of it myself.

I'm a firm believer in giving credit where credit is due, however while I was figuring this out, I didn't think I would end up writing my own documentation about it, so I didn't keep a list of the pages I was looking at - or if I did, they're in a file on a different computer. If I happen to find those links in the future, I will update this document to give credit where credit is due.

The way I'm doing it involves the following files, in this repo.

### `version-commit`

This is a script which does two things:

1. Reads a stream of data provided by `mdbook`, and prints part of it out.

    When `mdbook` runs a filter, it sends that script a JSON list with two elements. The first element will contain information about the overall "book", and the second element will contain information about the "chapters", or pages, which make up the book. This includes the contents of the input Markdown files.

    Filtering scripts are expected to output a *possibly modified* copy of *just the second element* from the JSON structure. If the script happens to modify the JSON, it changes the "input" that `mdbook` processes, and thereby modifies the generated HTML pages.

    In our case, we aren't modifying anything about the Markdown input itself. We're only writing a "filter" because it's the only "hook" that `mdbook` provides to run user-supplied scripts before building the HTML pages.

    Because we aren't modifying the input, the script just prints the second element as-is.

2. Reads the "`theme/index-template.hbs`" file, substitutes a few values related to the state of the git working directory, and writes a new "`theme/index.hbs`" file.

    Specifically, the script substitutes values for the following tags:

    * `@VERSION_COMMIT_HASH@` - the output from "`git describe --always --tags --dirty`", which includes the most recent tag and how many commits "ahead" of that tag we are, the commit hash (if it's different from the tag), and whether or not the content is "dirty" (i.e. if the working directory contains content which hasn't been committed yet).

    * `@VERSION_COMMIT_TIME@` - the timestamp of that commit.

    * `@VERSION_COMMIT_NOW@` - the timestamp when the script was executed by `mdbook`.

    All other content from the "`the/index-template.hbs`" file is copied as-is to the "`theme/index.hbs`" file.

### `version-commit.css`

Contains CSS to control the formatting of the items being added to the template.

In my case I wanted the text to be a bit smaller than the normal text in the Table of Contents, so [the file I use](./version-commit.css) contains some simple directives to set the text size and line spacing. I like the way it looks, obviously you're free to customize it any way you like.

### `theme/index-template.hbs`

This is a *copy* of the `index.hbs` file from the default theme built into `mdbook`, with the appropriate lines added to make the version information appear where and how I wanted it.

To get this file, use your copy of `mdbook` to create a dummy book with the full set of theme files, and copy the `theme/index.hbs` file from there.

* Create a dummy book with the theme files, by running "`mdbook init --theme`" in an empty directory.

    ```
    $ mkdir ~/work/xyz
    $ cd ~/work/xyz
    $ mdbook init --theme --ignore none -title x
    ```

* Copy `theme/index.hbs` from this dummy book, to somewhere outside the directory. Give your copy the name "`index-template.hbs`".

    ```
    $ cd ~/work/xyz/
    $ cp theme/index.hbs ~/index-template.hbs
    ```

* You can delete the dummy book now if you like.

    ```
    $ cd
    $ rm -rf ~/work/xyz/
    ```

* Edit your copy of the file, and search for "`toc`". You should find it within a "`<nav>`" element that looks like this:

    ```html
            <nav id="sidebar" class="sidebar" aria-label="Table of contents">
                <div class="sidebar-scrollbox">
                    {{#toc}}{{/toc}}
                </div>
                <div id="sidebar-resize-handle" class="sidebar-resize-handle"></div>
            </nav>
    ```

* Just after the `{{/toc}}` tag, add the new content shown below. Everything between the two "`<!--`" lines is being added, and nothing outside of those two lines is being changed or deleted.

    ```html
            <nav id="sidebar" class="sidebar" aria-label="Table of contents">
                <div class="sidebar-scrollbox">
                    {{#toc}}{{/toc}}
    <!-- The @VERSION_COMMIT_XXX@ tags below will be replaced with specific values
         by the 'version-commit' script, every time 'mdbook' rebuilds the HTML. -->
                    <hr/><div class="part-title">Version</div>
                    <div id="commit" class='version-commit-div'>
                        <span class='version-commit-hash'><tt>@VERSION_COMMIT_HASH@</tt></span><br/>
                        <span class='version-commit-time'><tt>@VERSION_COMMIT_TIME@</tt></span>
                    </div>
                    <div class="part-title">Generated</div>
                    <div id="generated" class='version-commit-div'>
                        <span class='version-commit-now'><tt>@VERSION_COMMIT_NOW@</tt></span>
                    </div>
    <!-- End of @VERSION_COMMIT_XXX@ stuff -->
                </div>
                <div id="sidebar-resize-handle" class="sidebar-resize-handle"></div>
            </nav>
    ```

* Save the result as `theme/index-template.hbs` within your new book.

Note that you can also get the original `index.hbs` file from [the `mdbook` source code](https://github.com/rust-lang/mdBook/blob/master/src/theme/index.hbs).

> &#x1F6D1; **Be sure to use the file matching the version of `mdbook` that you're running.**
>
> As an example, the `index.hbs` file from `v0.4.15` was updated in `v0.4.16`. The change had something to do with how the "`mdbook serve`" auto-reload functionality works. As a result, books using an `index-template.hbs` file from `v0.4.15` won't automatically reload if you're using `mdbook v0.4.16` or later.

### `book.toml`

The `[preprocessor.version-commit]` section in the `book.toml` file tells `mdbook` to run the `version-commit` file before generating the HTML output.

```toml
[preprocessor.version-commit]
renderers       = [ "html" ]
command         = "./version-commit"
```

* If you want to change how the git commit information is formatted within the pages, edit `theme/index-template.hbs`.

* If you want to change how the "version" or the timestamps are presented (i.e. to use a different `git` command to get the commit info, or to format the timestamps differently), edit the `version-commit` script.

    It's written in Perl, however it's very *simple* Perl, and if you're familiar with other scripting languages (i.e. shell, Python, Ruby, etc.) you should be able to understand it, even if you aren't familiar with Perl itself.

This file also contains a declaration which makes the `version-commit.css` file be included as part of the HTML files.

```toml
[output.html]
additional-css  = [ "section-lines.css" , "version-commit.css" ]
```

This example has a second file in the `additional-css` list. This other file is used by the Section Lines feature, which is explained above.

# Pre-requisites

The following items need to be installed on the machine where you're going to be working. Note that the instructions below are meant for macOS and Linux. I don't use ms-windows, if you're stuck with it my only suggestion is to use "WSL" and treat it as a Linux machine.

This is a quick list of what's required, I'm not going to go into a lot of detail about these.

### Perl

Perl itself is generally installed as part of the operating system, or available from the OS vendor's package repositories (i.e. `yum`, `apt`, etc.) On macOS, Perl is already installed.

### Perl JSON module

The Perl JSON module contains code for Perl scripts to work with JSON files. Some operating systems may install this automatically as part of Perl itself -- if you run "`perldoc JSON`" and it shows you documentation, it's already installed.

If this module not installed ...

* Most Linux distributions have a package to install it. For example, under CentOS 7 you can run "`yum install perl-JSON`".

* If an OS package is not available, you can install it using [CPAN](https://www.cpan.org/), which is a library of third-party Perl modules. See [the documentation](https://www.cpan.org/modules/INSTALL.html) for information about how to do this, including how to install the `cpan` or `cpanm` command line tool.

* You can [download the module](https://metacpan.org/pod/JSON) (download link on the left, under "Tools") and install it from source.

### `mdbook`

Obviously.

* macOS using Homebrew: run "`brew install mdbook`".

* Others: [This page](https://rust-lang.github.io/mdBook/guide/installation.html) explains how to install `mdbook`.

### `git`

Some operating systems come with `git` pre-installed, or have it available through an OS package repository (or a reputable third-party repository, such as [EPEL](https://docs.fedoraproject.org/en-US/epel/) for CentOS).

macOS comes with a "stub" `git` command. If you run it and the XCode Command Line Tools aren't already installed, it will walk you through the process of downloading and installing them. Once they are installed, `git` commands will work normally.

You can also install `git` from [Homebrew](https://brew.sh/) by running "`brew install git`". I normally do this anyway, because it installs a newer version of `git` than the one included with the XCode Command Line Tools.

# Starting a new book from this repo

As mentioned above, you can also use this repo as the starting point for a new book. It already has these customizations in place, all you'll need to do is delete the documentation you're reading right now and start new pages.

* Clone this repo into a new directory.

    ```
    $ cd ~/git/
    $ git clone https://github.com/kg4zow/mdbook-template newbook
    ```

* Remove the `.git/` directory, which contains the commit history from my repo, and start a brand new git repository for *your* book. (This isn't *required*, I just figure you're not going to want *my* repo's commit history mixed in with yours.)

    ```
    $ cd ~/git/newbook/
    $ rm -rf .git/
    $ git init
    ```

* Start your repo with a commit that includes the files exactly as you received them from the template repo.

    ```
    $ git add .
    $ git commit
    ```

* I normally add a tag called "`initial`" on the very first commit in every new repo. (This is also not *required*.)

    ```
    # git tag initial
    ```

* Edit or remove the `README.md` and `LICENSE.txt` files, depending on the needs of the book you're starting.

* If you're planning to host the resulting HTML pages on a web server somewhere, edit `Makefile` and update the `push` target with whatever commands will copy the `book/` directory (where `mdbook` stores the generated HTML files) to the appropriate server and directory.

* If your editor creates "temp files" of any kind, you should update the `.gitignore` file so these files aren't accidentally committed into the repo. Common filename patterns for this include "`*.bak`", "`*.swp`", and "`*~`". I normally work on macOS so the file already includes "`._*`" and "`.DS_Store`".

    You will also notice that the `.gitignore` file includes a few other entries...

    * **`/book/`** - this excludes the `book/` directory where `mdbook` writes the generated HTML files. If the "`mdbook init`" command creates a `.gitignore` file, it writes "`book`" in the file. The difference is, "`book`" by itself would exclude any file or directory anywhere in the repo with the name "book", but "`/book/`" only excludes a directory called "book", in the root of the repo.

    * **`/theme/index.hbs`** - this file is *generated* by the `version-commit` script when the HTML is generated. For the purposes of your repo it should be thought of as a "temp" file, and not stored in the git repo.

* Edit the `src/introduction.md` file. Remove the documentation about the *template*.

At this point, you may want to commit any changes.

# Working on your book

My normal workflow looks like this:

```
$ cd ~/git/newbook/
$ bbedit .
$ make serve
```

I normally use either [BBEdit](https://www.barebones.com/products/bbedit/index.html) or [Sublime Text](https://www.sublimetext.com/) to work on Markdown files, with a slight preference for BBEdit because, while I can use "`subl .`" to open the directory, you don't actually *see* the list of files unless you know to hit &#x2318;K followed by &#x2318;B to make the list appear. If you don't, it just looks like an empty window, waiting for you to create a new file.

The "`make serve`" command runs "`mdbook serve --open --hostname 127.0.0.1`". This does a few things:

* Generates the HTML files for your book.
* Starts up a web server, listening on `127.0.0.1:3000`.
* Opens a browser window pointing to `127.0.0.0:3000`.
* Watches the files in the book's directory. If it detects any changes to a file containing (or controlling) the book's content, it re-generates the HTML and signals the browser window to refresh itself.

This lets you see a "live preview" of what the finished product is going to look like, while you're working on the content.

When you're finished working on the book for now, hit CONTROL-C to exit from "`mdbook serve`", and then commit your changes.

```
$ git commit -a
```

If the book's repo is stored on a remote service (like GitHub), push the changes.

```
$ git push
```

If the generated HTML is being hosted on a web site somewhere, and you've updated `Makefile` so it knows how to upload the new content, push the HTML files to the web server.

```
$ make push
```

# License

Most of the content in this repo, including the `version-commit` script and the stylesheets, were written by myself and are licensed under the [MIT License](LICENSE.txt).

The `/theme/index-template.hbs` file in this repo was copied from `/src/theme/index.hbs` in [the mdbook source](https://github.com/rust-lang/mdBook/blob/master/src/theme/index.hbs) and then modified. As such, this file is technically covered by the Mozilla Public License 2.0, [as noted in their repo](https://github.com/rust-lang/mdBook/blob/master/LICENSE).

Other files in this repo were *generated* using mdbook, and possibly modified after that. I'll be honest, I'm not sure if that means they're covered under the MPL license or the MIT license, but either way, I have no intention of going after anybody who wants to copy and use them, and I *seriously* doubt that the mdbook developers will either. Enjoy.

*-jms1 2022-05-30*
