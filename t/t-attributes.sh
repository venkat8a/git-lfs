#!/usr/bin/env bash

. "$(dirname "$0")/testlib.sh"

begin_test "macros"
(
  set -e

  reponame="$(basename "$0" ".sh")"
  clone_repo "$reponame" repo

  mkdir dir
  printf '[attr]lfs filter=lfs diff=lfs merge=lfs -text\n*.dat lfs\n' \
    > .gitattributes
  printf '[attr]lfs2 filter=lfs diff=lfs merge=lfs -text\n*.bin lfs2\n' \
    > dir/.gitattributes
  git add .gitattributes dir
  git commit -m 'initial import'

  contents="some data"
  printf "$contents" > foo.dat
  git add *.dat
  git commit -m 'foo.dat'
  assert_local_object "$(calc_oid "$contents")" 9

  contents2="other data"
  printf "$contents2" > dir/foo.bin
  git add dir
  git commit -m 'foo.bin'
  refute_local_object "$(calc_oid "$contents2")"

  git lfs track '*.dat' 2>&1 | tee track.log
  grep '"*.dat" already supported' track.log

  git lfs track 'dir/*.bin' 2>&1 | tee track.log
  ! grep '"dir/*.bin" already supported' track.log
)
end_test

begin_test "macros with HOME"
(
  set -e

  reponame="$(basename "$0" ".sh")-home"
  clone_repo "$reponame" repo-home

  mkdir -p "$HOME/.config/git"
  printf '[attr]lfs filter=lfs diff=lfs merge=lfs -text\n*.dat lfs\n' \
    > "$HOME/.config/git/attributes"

  contents="some data"
  printf "$contents" > foo.dat
  git add *.dat
  git commit -m 'foo.dat'
  assert_local_object "$(calc_oid "$contents")" 9

  git lfs track 2>&1 | tee track.log
  grep '*.dat' track.log
)
end_test

begin_test "macros with HOME split"
(
  set -e

  reponame="$(basename "$0" ".sh")-home-split"
  clone_repo "$reponame" repo-home-split

  mkdir -p "$HOME/.config/git"
  printf '[attr]lfs filter=lfs diff=lfs merge=lfs -text\n' \
    > "$HOME/.config/git/attributes"

  printf '*.dat lfs\n' > .gitattributes
  git add .gitattributes
  git commit -m 'initial import'

  contents="some data"
  printf "$contents" > foo.dat
  git add *.dat
  git commit -m 'foo.dat'
  assert_local_object "$(calc_oid "$contents")" 9

  git lfs track '*.dat' 2>&1 | tee track.log
  grep '"*.dat" already supported' track.log
)
end_test
