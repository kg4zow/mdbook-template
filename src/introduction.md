# Introduction

This is a newly created "book" using [mdbook](https://rust-lang.github.io/mdBook/), with the customizations I normally use:

* Horizontal bars of varying thickness above `H1`, `H2`, and `H3` headers. (See below for examples of what they look like.)

    I find this makes it easier to quickly spot the beginnings of the sections when the lines are used as separators between the sections. I also think it makes more sense to have the bars *above* the section headers instead of below them.

* Automatic git commit and version information at the bottom of the navigation panel on the left, and/or at the bottom of every page. (This template repo has both, so you can see what they look like.)

* A `Makefile` with rules to publish the HTML and other files that make up the book, either to a web server or to GitHub Pages.

[`https://github.com/kg4zow/mdbook-template/`](https://github.com/kg4zow/mdbook-template/) contains more detail about how to use this repo.

The `theme/index-template.hbs` file also includes a *commented-out* example of how you might add a link to a page "outside" the book, at the top of the Table of Contents in the navigation panel. This could be useful if you're writing a set of books and want each one to have a link back to a common "list of books" index page.

Below this are a few example section headers, so you can see what they look like.

# Example H1 Section Header

## Example H2 Section Header

### Example H3 Section Header
