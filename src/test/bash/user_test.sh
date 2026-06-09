#!/usr/local/bin/bash

SCRIPT='src/main/bash/user.sh'

echo "Running test for \"${SCRIPT}\"..."

. $asserts/files/execs.sh "${SCRIPT}"

if ! /usr/local/bin/bash -n "${SCRIPT}"; then
 echo "\"${SCRIPT}\" has invalid syntax!" >&2; exit 1; fi

STDOUT="$(mktemp)"
STDERR="$(mktemp)"

# arguments

:> "${STDOUT}"
:> "${STDERR}"
"${SCRIPT}" >"${STDOUT}" 2>"${STDERR}"
. $asserts/strings/eq.sh "${SCRIPT}" "$?" '1'
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/strings/eq.sh "${SCRIPT}" "$(<"${STDERR}")" 'Wrong arguments!'

:> "${STDOUT}"
:> "${STDERR}"
"${SCRIPT}" '' >"${STDOUT}" 2>"${STDERR}"
. $asserts/strings/eq.sh "${SCRIPT}" "$?" '1'
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/strings/eq.sh "${SCRIPT}" "$(<"${STDERR}")" 'Wrong arguments!'

:> "${STDOUT}"
:> "${STDERR}"
"${SCRIPT}" '' '' '' >"${STDOUT}" 2>"${STDERR}"
. $asserts/strings/eq.sh "${SCRIPT}" "$?" '1'
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/strings/eq.sh "${SCRIPT}" "$(<"${STDERR}")" 'Wrong arguments!'

#

:> "${STDOUT}"
:> "${STDERR}"
"${SCRIPT}" '' '' >"${STDOUT}" 2>"${STDERR}"
. $asserts/strings/eq.sh "${SCRIPT}" "$?" '1'
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/strings/eq.sh "${SCRIPT}" "$(<"${STDERR}")" 'No token!'

GITHUBX_PAT='foo'

:> "${STDOUT}"
:> "${STDERR}"
"${SCRIPT}" "${GITHUBX_PAT}" '' >"${STDOUT}" 2>"${STDERR}"
. $asserts/strings/eq.sh "${SCRIPT}" "$?" '1'
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/strings/eq.sh "${SCRIPT}" "$(<"${STDERR}")" 'No dst!'

:> "${STDOUT}"
:> "${STDERR}"
GITHUBX_DST="$(mktemp -d)"
"${SCRIPT}" "${GITHUBX_PAT}" "${GITHUBX_DST}" >"${STDOUT}" 2>"${STDERR}"
. $asserts/strings/eq.sh "${SCRIPT}" "$?" '1'
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/strings/eq.sh "${SCRIPT}" "$(<"${STDERR}")" "\"${GITHUBX_DST}\" is not a file!"
rm -rf "${GITHUBX_DST}"

:> "${STDOUT}"
:> "${STDERR}"
GITHUBX_DST="$(mktemp)"
rm "${GITHUBX_DST}"
ln -s "${GITHUBX_DST}" "${GITHUBX_DST}"
"${SCRIPT}" "${GITHUBX_PAT}" "${GITHUBX_DST}" >"${STDOUT}" 2>"${STDERR}"
. $asserts/strings/eq.sh "${SCRIPT}" "$?" '1'
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/strings/eq.sh "${SCRIPT}" "$(<"${STDERR}")" "\"${GITHUBX_DST}\" is a symlink!"
rm "${GITHUBX_DST}"

:> "${STDOUT}"
:> "${STDERR}"
GITHUBX_DST="$(mktemp)"
"${SCRIPT}" "${GITHUBX_PAT}" "${GITHUBX_DST}" >"${STDOUT}" 2>"${STDERR}"
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
"${SCRIPT}" "${GITHUBX_PAT}" "${GITHUBX_DST}" >"${STDOUT}" 2>"${STDERR}"
. $asserts/strings/eq.sh "${SCRIPT}" "$?" '1'
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/strings/eq.sh "${SCRIPT}" "$(<"${STDERR}")" 'Request error!'
. $asserts/files/not_exists.sh "${GITHUBX_DST}"

HTTP_CODES=(2 20 22 202 2000 401 403 429 500 '' 'foo')
for HTTP_CODE in "${HTTP_CODES[@]}"; do
 :> "${STDOUT}"
 :> "${STDERR}"
 GITHUBX_DST="$(mktemp)"
 rm "${GITHUBX_DST}"
 PATH="$mocks/curl/bin:${PATH}" \
 MOCKS_CURL_HTTP_CODE="${HTTP_CODE}" \
 "${SCRIPT}" "${GITHUBX_PAT}" "${GITHUBX_DST}" >"${STDOUT}" 2>"${STDERR}"
 . $asserts/strings/eq.sh "${SCRIPT}" "$?" '1'
 . $asserts/files/empty.sh "${STDOUT}"
 . $asserts/strings/eq.sh "${SCRIPT}" "$(<"${STDERR}")" 'Code error!'
 . $asserts/files/not_exists.sh "${GITHUBX_DST}"
done

VALUES=('foo' '{}0' '[]' 'null' '42')
for MOCKS_CURL_DST in "${VALUES[@]}"; do
 :> "${STDOUT}"
 :> "${STDERR}"
 GITHUBX_DST="$(mktemp)"
 rm "${GITHUBX_DST}"
 PATH="$mocks/curl/bin:${PATH}" \
 MOCKS_CURL_HTTP_CODE=200 \
 MOCKS_CURL_DST="${MOCKS_CURL_DST}" \
 "${SCRIPT}" "${GITHUBX_PAT}" "${GITHUBX_DST}" >"${STDOUT}" 2>"${STDERR}"
 . $asserts/strings/eq.sh "${SCRIPT}" "$?" '1'
 . $asserts/files/empty.sh "${STDOUT}"
 . $asserts/strings/eq.sh "${SCRIPT}" "$(<"${STDERR}")" 'Parse dst error!'
 rm "${GITHUBX_DST}"
done

VALUES=('{}' '{"id":null}' '{"id":0}' '{"id":"42"}' '{"id":-1}' '{"id":0.5}')
for MOCKS_CURL_DST in "${VALUES[@]}"; do
 :> "${STDOUT}"
 :> "${STDERR}"
 GITHUBX_DST="$(mktemp)"
 rm "${GITHUBX_DST}"
 PATH="$mocks/curl/bin:${PATH}" \
 MOCKS_CURL_HTTP_CODE=200 \
 MOCKS_CURL_DST="${MOCKS_CURL_DST}" \
 "${SCRIPT}" "${GITHUBX_PAT}" "${GITHUBX_DST}" >"${STDOUT}" 2>"${STDERR}"
 . $asserts/strings/eq.sh "${SCRIPT}" "$?" '1'
 . $asserts/files/empty.sh "${STDOUT}"
 . $asserts/strings/eq.sh "${SCRIPT}" "$(<"${STDERR}")" 'Check dst error!'
 rm "${GITHUBX_DST}"
done

:> "${STDOUT}"
:> "${STDERR}"
GITHUBX_DST="$(mktemp)"
rm "${GITHUBX_DST}"
PATH="$mocks/curl/bin:${PATH}" \
MOCKS_CURL_HTTP_CODE=200 \
MOCKS_CURL_DST='{"id":42}' \
"${SCRIPT}" "${GITHUBX_PAT}" "${GITHUBX_DST}" >"${STDOUT}" 2>"${STDERR}"
. $asserts/strings/eq.sh "${SCRIPT}" "$?" '0'
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/empty.sh "${STDERR}"
. $asserts/strings/eq.sh "${SCRIPT}" "$(<"${GITHUBX_DST}")" '{"id":42}'
rm "${GITHUBX_DST}"

rm "${STDOUT}"
rm "${STDERR}"
