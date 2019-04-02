A collection of git scripts that I use to automate my workflow


## Requirements

Some commands requires extra libraries, namely `hub` and `jq`. 

* `hub`  - https://hub.github.com/
* `jq` - https://stedolan.github.io/jq/

## Install

### Check out this repo

```
git clone git@github.com:renatocaval/oh-my-git.git
```

* Add the bin folder to your PATH
* Add `.prinfo` to .gitignore_global: `echo .prinfo >> ~/.gitignore_global`


### git pr-create

The commant `git pr-create` doesn't work if your git editor is set to `vim`. 
You will get the following error message: `Vim: Warning: Output is not to a terminal`. 

To use that command you will need to switch to another editor: VS Code and Emacs are know to work.
