#!/usr/local/bin/bash

SCRIPT='src/main/bash/user.sh'

echo "Running test of \"${SCRIPT}\"..."

. $asserts/files/execs.sh "${SCRIPT}"

if ! /usr/local/bin/bash -n "${SCRIPT}"; then
 echo "\"${SCRIPT}\" has wrong syntax!" >&2; exit 1; fi

STDERR="$(mktemp)"

# arguments

:> "${STDERR}"
"${SCRIPT}" 2>"${STDERR}"
. $asserts/strings/eq.sh "${SCRIPT}" "$?" '1'
. $asserts/strings/eq.sh "${SCRIPT}" "$(<"${STDERR}")" 'Wrong arguments!'

:> "${STDERR}"
"${SCRIPT}" '' 2>"${STDERR}"
. $asserts/strings/eq.sh "${SCRIPT}" "$?" '1'
. $asserts/strings/eq.sh "${SCRIPT}" "$(<"${STDERR}")" 'Wrong arguments!'

:> "${STDERR}"
"${SCRIPT}" '' '' '' 2>"${STDERR}"
. $asserts/strings/eq.sh "${SCRIPT}" "$?" '1'
. $asserts/strings/eq.sh "${SCRIPT}" "$(<"${STDERR}")" 'Wrong arguments!'

#

:> "${STDERR}"
"${SCRIPT}" '' '' 2>"${STDERR}"
. $asserts/strings/eq.sh "${SCRIPT}" "$?" '1'
. $asserts/strings/eq.sh "${SCRIPT}" "$(<"${STDERR}")" 'No token!'

GITHUBX_PAT='foo'

:> "${STDERR}"
"${SCRIPT}" "${GITHUBX_PAT}" '' 2>"${STDERR}"
. $asserts/strings/eq.sh "${SCRIPT}" "$?" '1'
. $asserts/strings/eq.sh "${SCRIPT}" "$(<"${STDERR}")" 'No dst!'

:> "${STDERR}"
GITHUBX_DST="$(mktemp -d)"
"${SCRIPT}" "${GITHUBX_PAT}" "${GITHUBX_DST}" 2>"${STDERR}"
. $asserts/strings/eq.sh "${SCRIPT}" "$?" '1'
. $asserts/strings/eq.sh "${SCRIPT}" "$(<"${STDERR}")" "\"${GITHUBX_DST}\" is not a file!"
rm -rf "${GITHUBX_DST}"

:> "${STDERR}"
GITHUBX_DST="$(mktemp)"
rm "${GITHUBX_DST}"
ln -s "${GITHUBX_DST}" "${GITHUBX_DST}"
"${SCRIPT}" "${GITHUBX_PAT}" "${GITHUBX_DST}" 2>"${STDERR}"
. $asserts/strings/eq.sh "${SCRIPT}" "$?" '1'
. $asserts/strings/eq.sh "${SCRIPT}" "$(<"${STDERR}")" "\"${GITHUBX_DST}\" is a symlink!"
rm "${GITHUBX_DST}"

:> "${STDERR}"
GITHUBX_DST="$(mktemp)"
"${SCRIPT}" "${GITHUBX_PAT}" "${GITHUBX_DST}" 2>"${STDERR}"
. $asserts/strings/eq.sh "${SCRIPT}" "$?" '1'
. $asserts/strings/eq.sh "${SCRIPT}" "$(<"${STDERR}")" "\"${GITHUBX_DST}\" exists!"
rm "${GITHUBX_DST}"

#

echo 'Not implemented!'; exit 1 # todo

rm "${STDERR}"
