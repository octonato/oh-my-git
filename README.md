# Oh-my-git

A collection of git scripts that I use to automate my workflow

## Requirements

Some commands requires extra libraries, namely `hub` and `jq`. 

* `hub`  - https://hub.github.com/
* `jq` - https://stedolan.github.io/jq/
* `complete` (a default function in bash)

## Install

### Check out this repo

```bash
git clone git@github.com:renatocaval/oh-my-git.git
```

* Add the bin folder to your PATH
* source `git-functions.sh` and `gh-functions.sh`
* define env variable: `GITHUB_SRC` (eg: GITHUB_SRC=/Users/renato)
* define env variable: `GITHUB_USER` (eg: GITHUB_USER=renatocaval)

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
$ ghp rena<TAB>/oh-<TAB>/ 
renatocaval/oh-my-git/doc-usage           renatocaval/oh-my-git/master
renatocaval/oh-my-git/more-usage-docs
```

### git clone-fork

Quickly clone and fork a git repository. 

```
git clone-fork git@github.com:lagom/lagom.git
```

**Note** only the `SSH` protocol (not `HTTPS`) is supported.

### pr.new

The commant `pr.new` doesn't work if your git editor is set to `vim`. 
You will get the following error message: `Vim: Warning: Output is not to a terminal`. 

To use that command you will need to switch to another editor: VS Code and Emacs are know to work.