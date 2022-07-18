# Oh-my-git

A collection of git scripts that I use to automate my workflow

## Requirements

Some commands requires extra libraries the GitHub CLI.

* `gh`  - https://cli.github.com
* `complete` (a default function in bash)

## Install

### Check out this repo

```bash
git clone git@github.com:octonato/oh-my-git.git
```

* Add the bin folder to your PATH
* source `git-functions.sh` and `gh-functions.sh`
* define env variable: `GITHUB_SRC` (eg: GITHUB_SRC=/Users/renato)
* define env variable: `GITHUB_USER` (eg: GITHUB_USER=octonato)
* define env variable: `GH_USER_PREFIX` (eg: GH_USER_PREFIX=wip) - optional. This adds a prefix to each new branch.

## Usage

Use `oh-my-git` to print the list of commands, alias, git extensions and git alias provided.

### Folder Structure

Some of the commands provided by `oh-my-git` expect your local clone to follow a certain folder structure:

```
$GITHUB_SRC
├── some-github-org
│   └── fancy-repo
│       └── master
├── another-org
│   ├── repo1
│   │   └── master
│   └── repo1
│       ├── bugfix-branch
│       └── master
└── renatocaval
    └── oh-my-git
        ├── master
        └── more-usage-docs

```


### ghp

If you followed the convention described in [Folder Structure](#Folder-Structure) you can use `ghp <TABx2>` to quickly navigate to a workbranch on your local clones useing autocompletion of the organization, repository and branch names:

```bash
$ ghp octonato<TAB>/oh-<TAB>/ 
octonato/oh-my-git/doc-usage           octonato/oh-my-git/master
octonato/oh-my-git/more-usage-docs
```

### git clone-fork

Quickly clone and fork a git repository. 

```
git clone-fork git@github.com:lagom/lagom.git
```

**Note** only the `SSH` protocol (not `HTTPS`) is supported.
