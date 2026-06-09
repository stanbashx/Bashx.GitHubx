#!/usr/local/bin/bash

SCRIPT='src/main/bash/user.sh'

echo "Running test of \"${SCRIPT}\"..."

. $asserts/files/execs.sh "${SCRIPT}"

if ! /usr/local/bin/bash -n "${SCRIPT}"; then
 echo "\"${SCRIPT}\" has wrong syntax!" >&2; exit 1; fi

STDOUT="$(mktemp)"
STDERR="$(mktemp)"

# arguments

:> "${STDOUT}"
:> "${STDERR}"
"${SCRIPT}" 2>"${STDERR}"
. $asserts/strings/eq.sh "${SCRIPT}" "$?" '1'
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/strings/eq.sh "${SCRIPT}" "$(<"${STDERR}")" 'Wrong arguments!'

:> "${STDOUT}"
:> "${STDERR}"
"${SCRIPT}" '' 2>"${STDERR}"
. $asserts/strings/eq.sh "${SCRIPT}" "$?" '1'
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/strings/eq.sh "${SCRIPT}" "$(<"${STDERR}")" 'Wrong arguments!'

:> "${STDOUT}"
:> "${STDERR}"
"${SCRIPT}" '' '' '' 2>"${STDERR}"
. $asserts/strings/eq.sh "${SCRIPT}" "$?" '1'
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/strings/eq.sh "${SCRIPT}" "$(<"${STDERR}")" 'Wrong arguments!'

#

:> "${STDOUT}"
:> "${STDERR}"
"${SCRIPT}" '' '' 2>"${STDERR}"
. $asserts/strings/eq.sh "${SCRIPT}" "$?" '1'
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/strings/eq.sh "${SCRIPT}" "$(<"${STDERR}")" 'No token!'

GITHUBX_PAT='foo'

:> "${STDOUT}"
:> "${STDERR}"
"${SCRIPT}" "${GITHUBX_PAT}" '' 2>"${STDERR}"
. $asserts/strings/eq.sh "${SCRIPT}" "$?" '1'
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/strings/eq.sh "${SCRIPT}" "$(<"${STDERR}")" 'No dst!'

:> "${STDOUT}"
:> "${STDERR}"
GITHUBX_DST="$(mktemp -d)"
"${SCRIPT}" "${GITHUBX_PAT}" "${GITHUBX_DST}" 2>"${STDERR}"
. $asserts/strings/eq.sh "${SCRIPT}" "$?" '1'
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/strings/eq.sh "${SCRIPT}" "$(<"${STDERR}")" "\"${GITHUBX_DST}\" is not a file!"
rm -rf "${GITHUBX_DST}"

:> "${STDOUT}"
:> "${STDERR}"
GITHUBX_DST="$(mktemp)"
rm "${GITHUBX_DST}"
ln -s "${GITHUBX_DST}" "${GITHUBX_DST}"
"${SCRIPT}" "${GITHUBX_PAT}" "${GITHUBX_DST}" 2>"${STDERR}"
. $asserts/strings/eq.sh "${SCRIPT}" "$?" '1'
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/strings/eq.sh "${SCRIPT}" "$(<"${STDERR}")" "\"${GITHUBX_DST}\" is a symlink!"
rm "${GITHUBX_DST}"

:> "${STDOUT}"
:> "${STDERR}"
GITHUBX_DST="$(mktemp)"
"${SCRIPT}" "${GITHUBX_PAT}" "${GITHUBX_DST}" 2>"${STDERR}"
. $asserts/strings/eq.sh "${SCRIPT}" "$?" '1'
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/strings/eq.sh "${SCRIPT}" "$(<"${STDERR}")" "\"${GITHUBX_DST}\" exists!"
rm "${GITHUBX_DST}"

#

:> "${STDOUT}"
:> "${STDERR}"
GITHUBX_DST="$(mktemp)"
rm "${GITHUBX_DST}"
PATH="$mocks/curl/bin:${PATH}" \
MOCKS_CURL_EXIT_CODE=1 \
"${SCRIPT}" "${GITHUBX_PAT}" "${GITHUBX_DST}" 2>"${STDERR}"
. $asserts/strings/eq.sh "${SCRIPT}" "$?" '1'
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/strings/eq.sh "${SCRIPT}" "$(<"${STDERR}")" 'Request error!'

HTTP_CODES=(2 20 22 202 2000 401 403 429 500 '' 'foo')
for HTTP_CODE in "${HTTP_CODES[@]}"; do
 :> "${STDOUT}"
 :> "${STDERR}"
 GITHUBX_DST="$(mktemp)"
 rm "${GITHUBX_DST}"
 PATH="$mocks/curl/bin:${PATH}" \
 MOCKS_CURL_HTTP_CODE="${HTTP_CODE}" \
 "${SCRIPT}" "${GITHUBX_PAT}" "${GITHUBX_DST}" 2>"${STDERR}"
 . $asserts/strings/eq.sh "${SCRIPT}" "$?" '1'
 . $asserts/files/empty.sh "${STDOUT}"
 . $asserts/strings/eq.sh "${SCRIPT}" "$(<"${STDERR}")" 'Code error!'
done

echo 'Not implemented!'; exit 1 # todo

rm "${STDERR}"
