#!/usr/local/bin/bash

SCRIPT='src/main/bash/releases/upload.sh'

echo "Running test for \"${SCRIPT}\"..."

. $asserts/files/execs.sh "${SCRIPT}"

if ! /usr/local/bin/bash -n "${SCRIPT}"; then
 echo "\"${SCRIPT}\" has invalid syntax!" >&2; exit 1; fi

STDOUT="$(mktemp)"
STDERR="$(mktemp)"

#

:> "${STDOUT}"
:> "${STDERR}"
"${SCRIPT}" > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" 'Wrong arguments!'$'\n'

:> "${STDOUT}"
:> "${STDERR}"
"${SCRIPT}" '' '' '' '' '' '' > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" 'Wrong arguments!'$'\n'

:> "${STDOUT}"
:> "${STDERR}"
"${SCRIPT}" '' '' '' '' '' '' '' '' > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" 'Wrong arguments!'$'\n'

#

GITHUBX_REP_OWNER=''
GITHUBX_REP_NAME=''
GITHUBX_PAT_SRC=''
GITHUBX_RELEASE_ID=''
GITHUBX_ASSET_PATH=''
GITHUBX_ASSET_NAME=''
GITHUBX_DST=''

#

:> "${STDOUT}"
:> "${STDERR}"
"${SCRIPT}" "${GITHUBX_REP_OWNER}" "${GITHUBX_REP_NAME}" "${GITHUBX_PAT_SRC}" "${GITHUBX_RELEASE_ID}" "${GITHUBX_ASSET_PATH}" "${GITHUBX_ASSET_NAME}" "${GITHUBX_DST}" > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" 'No repository owner!'$'\n'

GITHUBX_REP_OWNER='foo'

:> "${STDOUT}"
:> "${STDERR}"
"${SCRIPT}" "${GITHUBX_REP_OWNER}" "${GITHUBX_REP_NAME}" "${GITHUBX_PAT_SRC}" "${GITHUBX_RELEASE_ID}" "${GITHUBX_ASSET_PATH}" "${GITHUBX_ASSET_NAME}" "${GITHUBX_DST}" > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" 'No repository name!'$'\n'

GITHUBX_REP_NAME='bar'

:> "${STDOUT}"
:> "${STDERR}"
"${SCRIPT}" "${GITHUBX_REP_OWNER}" "${GITHUBX_REP_NAME}" "${GITHUBX_PAT_SRC}" "${GITHUBX_RELEASE_ID}" "${GITHUBX_ASSET_PATH}" "${GITHUBX_ASSET_NAME}" "${GITHUBX_DST}" > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" 'Wrong token!'$'\n'

GITHUBX_PAT_SRC='GITHUBX_PAT'

:> "${STDOUT}"
:> "${STDERR}"
"${SCRIPT}" "${GITHUBX_REP_OWNER}" "${GITHUBX_REP_NAME}" "${GITHUBX_PAT_SRC}" "${GITHUBX_RELEASE_ID}" "${GITHUBX_ASSET_PATH}" "${GITHUBX_ASSET_NAME}" "${GITHUBX_DST}" > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" 'Token is unset!'$'\n'

:> "${STDOUT}"
:> "${STDERR}"
GITHUBX_PAT='' \
 "${SCRIPT}" "${GITHUBX_REP_OWNER}" "${GITHUBX_REP_NAME}" "${GITHUBX_PAT_SRC}" "${GITHUBX_RELEASE_ID}" "${GITHUBX_ASSET_PATH}" "${GITHUBX_ASSET_NAME}" "${GITHUBX_DST}" > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" 'No token!'$'\n'

#

echo 'Not implemented!'; exit 1 # todo

#

rm "${STDOUT}"
rm "${STDERR}"
