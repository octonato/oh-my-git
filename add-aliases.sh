#!/bin/sh
(
  cd bin
  for i in git-*
  do
    ALIAS=${i##git-}
    git config --global alias.$ALIAS !$i
  done

)