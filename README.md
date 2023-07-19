# git-lfs-download

## Task

You want to download a git-lfs repo

## Problem

Using `$ git clone` will download the repo, but after the download it will copy all files from the `.git` directory to the clone directory. This uses at least double the disk space of the repo.

You may not have 2x disk space. It could be hundreds of gigabytes: game assets, weights for huge neural networks...

Time is wasted in copying these huge files. Note that this will likely be negligible compared to the download time, but still, unpleasant.

## Proper solution

Use [git-archive](https://git-scm.com/docs/git-archive) and pipe its output to an extracting program.

`$ git archive --format=tar --remote=<repo url> HEAD | tar xf -`

This will also solve the sane problem if you encounter it with non git-lfs files.

Unfortunately git-archive can exert quite the cpu toll on the server and most git providers (like GitHub and Huggingface) have it disabled server-side rendering it unusable.

## Hack which this project implements

* Clone a bare repo
* Clone the same repo skipping lfs smudge to `target`
* Parse `target/.gitattributes` to identify lfs files
* Fetch lfs files
* `mov` the files from `bare/.git/lfs/objects` to their places in `target/`
* `$ rm -rf bare`
* `$ rm -rf target/.git`
* `target/` contains the downloaded repo

## Copyright

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

This software is distributed under the MIT Software License.

See accompanying file LICENSE or copy [here](https://opensource.org/licenses/MIT).

Copyright &copy; 2023 [Borislav Stanimirov](http://github.com/iboB)
