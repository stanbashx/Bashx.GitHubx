#!/usr/local/bin/bash

SCRIPT='src/main/bash/rate_limit.sh'

echo "Running test for \"${SCRIPT}\"..."

. $asserts/files/execs.sh "${SCRIPT}"

if ! /usr/local/bin/bash -n "${SCRIPT}"; then
 echo "\"${SCRIPT}\" has invalid syntax!" >&2; exit 1; fi

STDOUT="$(mktemp)"
STDERR="$(mktemp)"

#

:> "${STDOUT}"
:> "${STDERR}"
"${SCRIPT}" >"${STDOUT}" 2>"${STDERR}"
. $asserts/strings/eq.sh "${SCRIPT}" "$?" '1'
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" $'Wrong arguments!\n'

:> "${STDOUT}"
:> "${STDERR}"
"${SCRIPT}" '' '' >"${STDOUT}" 2>"${STDERR}"
. $asserts/strings/eq.sh "${SCRIPT}" "$?" '1'
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" $'Wrong arguments!\n'

#

:> "${STDOUT}"
:> "${STDERR}"
GITHUBX_DST=''
"${SCRIPT}" "${GITHUBX_DST}" >"${STDOUT}" 2>"${STDERR}"
. $asserts/strings/eq.sh "${SCRIPT}" "$?" '1'
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" $'No dst!\n'

:> "${STDOUT}"
:> "${STDERR}"
GITHUBX_DST="$(mktemp -d)"
"${SCRIPT}" "${GITHUBX_DST}" >"${STDOUT}" 2>"${STDERR}"
. $asserts/strings/eq.sh "${SCRIPT}" "$?" '1'
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" "\"${GITHUBX_DST}\" is not a file!"$'\n'
rm -r "${GITHUBX_DST}"

:> "${STDOUT}"
:> "${STDERR}"
GITHUBX_DST="$(mktemp)"
rm "${GITHUBX_DST}"
ln -s "${GITHUBX_DST}" "${GITHUBX_DST}"
"${SCRIPT}" "${GITHUBX_DST}" >"${STDOUT}" 2>"${STDERR}"
. $asserts/strings/eq.sh "${SCRIPT}" "$?" '1'
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" "\"${GITHUBX_DST}\" is a symlink!"$'\n'
rm -r "${GITHUBX_DST}"

:> "${STDOUT}"
:> "${STDERR}"
GITHUBX_DST="$(mktemp)"
"${SCRIPT}" "${GITHUBX_DST}" >"${STDOUT}" 2>"${STDERR}"
. $asserts/strings/eq.sh "${SCRIPT}" "$?" '1'
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" "\"${GITHUBX_DST}\" exists!"$'\n'
rm -r "${GITHUBX_DST}"

#

:> "${STDOUT}"
:> "${STDERR}"
GITHUBX_DST="$(mktemp)"
rm "${GITHUBX_DST}"
PATH="${mocks}/curl/bin:${PATH}" \
 MOCKS_CURL_EXIT_CODE=1 \
 "${SCRIPT}" "${GITHUBX_DST}" >"${STDOUT}" 2>"${STDERR}"
. $asserts/strings/eq.sh "${SCRIPT}" "$?" '1'
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" $'Request error!\n'
rm -f "${GITHUBX_DST}"

HTTP_CODES=(2 20 22 202 2000 401 403 429 500 '' 'foo' '-1' '200 ' ' 200' $'\n200' $'\t200')
for HTTP_CODE in "${HTTP_CODES[@]}"; do
 :> "${STDOUT}"
 :> "${STDERR}"
 GITHUBX_DST="$(mktemp)"
 rm "${GITHUBX_DST}"
 PATH="${mocks}/curl/bin:${PATH}" \
  MOCKS_CURL_HTTP_CODE="${HTTP_CODE}" \
  "${SCRIPT}" "${GITHUBX_DST}" >"${STDOUT}" 2>"${STDERR}"
 . $asserts/strings/eq.sh "${SCRIPT}" "$?" '1'
 . $asserts/files/empty.sh "${STDOUT}"
 . $asserts/files/equals.sh "${STDERR}" $'Response error!\n'
 rm -f "${GITHUBX_DST}"
done

VALUES=('foo' '{}0' '[]' 'null' '42')
for MOCKS_CURL_DST in "${VALUES[@]}"; do
 :> "${STDOUT}"
 :> "${STDERR}"
 GITHUBX_DST="$(mktemp)"
 rm "${GITHUBX_DST}"
 PATH="${mocks}/curl/bin:${PATH}" \
  MOCKS_CURL_HTTP_CODE=200 \
  MOCKS_CURL_DST="${MOCKS_CURL_DST}" \
  "${SCRIPT}" "${GITHUBX_DST}" >"${STDOUT}" 2>"${STDERR}"
 . $asserts/strings/eq.sh "${SCRIPT}" "$?" '1'
 . $asserts/files/empty.sh "${STDOUT}"
 . $asserts/files/equals.sh "${STDERR}" $'Parse dst error!\n'
 rm "${GITHUBX_DST}"
done

VALUES=(
 '{}'
 '{"resources":{}}'
 '{"resources":{"core":{}}}'
 '{"resources":{"core":{"limit":null}}}'
 '{"resources":{"core":{"limit":{}}}}'
 '{"resources":{"core":{"limit":[]]}}}'
 '{"resources":{"core":{"limit":0]}}}'
 '{"resources":{"core":{"limit":"42"}}}'
 '{"resources":{"core":{"limit":-1]}}}'
 '{"resources":{"core":{"limit":0.5]}}}'
)
for MOCKS_CURL_DST in "${VALUES[@]}"; do
 :> "${STDOUT}"
 :> "${STDERR}"
 GITHUBX_DST="$(mktemp)"
 rm "${GITHUBX_DST}"
 PATH="${mocks}/curl/bin:${PATH}" \
  MOCKS_CURL_HTTP_CODE=200 \
  MOCKS_CURL_DST="${MOCKS_CURL_DST}" \
  "${SCRIPT}" "${GITHUBX_DST}" >"${STDOUT}" 2>"${STDERR}"
 . $asserts/strings/eq.sh "${SCRIPT}" "$?" '1'
 . $asserts/files/empty.sh "${STDOUT}"
 . $asserts/files/equals.sh "${STDERR}" $'Check dst error!\n'
 rm "${GITHUBX_DST}"
done

:> "${STDOUT}"
:> "${STDERR}"
GITHUBX_DST="$(mktemp)"
rm "${GITHUBX_DST}"
MOCKS_CURL_DST=200
PATH="${mocks}/curl/bin:${PATH}" \
 MOCKS_CURL_HTTP_CODE=201 \
 MOCKS_CURL_DST="${MOCKS_CURL_DST}" \
 "${SCRIPT}" "${GITHUBX_DST}" >"${STDOUT}" 2>"${STDERR}"
. $asserts/strings/eq.sh "${SCRIPT}" "$?" '1'
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" $'Response error!\n'
. $asserts/files/equals.sh "${GITHUBX_DST}" "${MOCKS_CURL_DST}"
rm "${GITHUBX_DST}"

:> "${STDOUT}"
:> "${STDERR}"
GITHUBX_DST="$(mktemp)"
rm "${GITHUBX_DST}"
MOCKS_CURL_DST='{"resources":{"core":{"limit":42}}}'
PATH="${mocks}/curl/bin:${PATH}" \
 MOCKS_CURL_HTTP_CODE=200 \
 MOCKS_CURL_DST="${MOCKS_CURL_DST}" \
 "${SCRIPT}" "${GITHUBX_DST}" >"${STDOUT}" 2>"${STDERR}"
. $asserts/strings/eq.sh "${SCRIPT}" "$?" '0'
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/empty.sh "${STDERR}"
. $asserts/files/equals.sh "${GITHUBX_DST}" "${MOCKS_CURL_DST}"
rm "${GITHUBX_DST}"

#

rm "${STDOUT}"
rm "${STDERR}"
