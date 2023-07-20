# git-lfs-download

A CLI tool which downloads a git-lfs repo fully or partially without temporarily using x2 disk space and without using any disk space for lfs files which are not downloaded.

**Usage:**

`$ git-lfs-download <repo-uri> [--match <pattern>] [--without <pattern>]`

By default the full repository is downloaded. Adding `--match` patterns will only include files which match any of them. Adding `--without` patterns will exclude files which match any of them.

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

## Task 2

You want to download only some large files from a git lfs repo

## Proper solution

Manually `$ git lfs pull --include <file>`. This is pretty cumbersome especially if there are many files, or files to filter-*out*.

Disk space x2 will be required.

## Hack which this project implements

* Clone a shallow repo skipping lfs smudge
* Parse `.gitattributes` to identify lfs files
* Filter lfs files according to provided options (if any)
* Fetch lfs files
* `mv` the files from `.git/lfs/objects` to their places in the git root
* `$ rm -rf .git`

## Copyright

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

This software is distributed under the MIT Software License.

See accompanying file LICENSE or copy [here](https://opensource.org/licenses/MIT).

Copyright &copy; 2023 [Borislav Stanimirov](http://github.com/iboB)
