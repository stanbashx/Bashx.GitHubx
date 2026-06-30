#!/usr/local/bin/bash

SCRIPT='src/main/bash/user_gpg_keys.sh'

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
. $asserts/files/equals.sh "${STDERR}" $'Wrong arguments!\n'

:> "${STDOUT}"
:> "${STDERR}"
"${SCRIPT}" '' > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" $'Wrong arguments!\n'

:> "${STDOUT}"
:> "${STDERR}"
"${SCRIPT}" '' '' '' > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" $'Wrong arguments!\n'

#

:> "${STDOUT}"
:> "${STDERR}"
GITHUBX_PAT_SRC=''
GITHUBX_DST=''
"${SCRIPT}" "${GITHUBX_PAT_SRC}" "${GITHUBX_DST}" > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" $'Wrong token!\n'

:> "${STDOUT}"
:> "${STDERR}"
GITHUBX_PAT_SRC='GITHUBX_PAT'
GITHUBX_DST=''
"${SCRIPT}" "${GITHUBX_PAT_SRC}" "${GITHUBX_DST}" > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" $'Token is unset!\n'

VALUES=('0' '-')
for VALUE in "${VALUES[@]}"; do
 :> "${STDOUT}"
 :> "${STDERR}"
 GITHUBX_PAT_SRC="${VALUE}"
 GITHUBX_DST=''
 "${SCRIPT}" "${GITHUBX_PAT_SRC}" "${GITHUBX_DST}" > "${STDOUT}" 2> "${STDERR}"
 . $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
 . $asserts/files/empty.sh "${STDOUT}"
 . $asserts/files/equals.sh "${STDERR}" $'Wrong token!\n'
 #
 :> "${STDOUT}"
 :> "${STDERR}"
 GITHUBX_PAT_SRC="${VALUE}GITHUBX_PAT"
 GITHUBX_DST=''
 "${SCRIPT}" "${GITHUBX_PAT_SRC}" "${GITHUBX_DST}" > "${STDOUT}" 2> "${STDERR}"
 . $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
 . $asserts/files/empty.sh "${STDOUT}"
 . $asserts/files/equals.sh "${STDERR}" $'Wrong token!\n'
done

VALUES=(' ' $'\n' $'\t')
for VALUE in "${VALUES[@]}"; do
 :> "${STDOUT}"
 :> "${STDERR}"
 GITHUBX_PAT_SRC="${VALUE}"
 GITHUBX_DST=''
 "${SCRIPT}" "${GITHUBX_PAT_SRC}" "${GITHUBX_DST}" > "${STDOUT}" 2> "${STDERR}"
 . $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
 . $asserts/files/empty.sh "${STDOUT}"
 . $asserts/files/equals.sh "${STDERR}" $'Wrong token!\n'
 #
 :> "${STDOUT}"
 :> "${STDERR}"
 GITHUBX_PAT_SRC="${VALUE}GITHUBX_PAT"
 GITHUBX_DST=''
 "${SCRIPT}" "${GITHUBX_PAT_SRC}" "${GITHUBX_DST}" > "${STDOUT}" 2> "${STDERR}"
 . $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
 . $asserts/files/empty.sh "${STDOUT}"
 . $asserts/files/equals.sh "${STDERR}" $'Wrong token!\n'
 #
 :> "${STDOUT}"
 :> "${STDERR}"
 GITHUBX_PAT_SRC="GITHUBX${VALUE}PAT"
 GITHUBX_DST=''
 "${SCRIPT}" "${GITHUBX_PAT_SRC}" "${GITHUBX_DST}" > "${STDOUT}" 2> "${STDERR}"
 . $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
 . $asserts/files/empty.sh "${STDOUT}"
 . $asserts/files/equals.sh "${STDERR}" $'Wrong token!\n'
 #
 :> "${STDOUT}"
 :> "${STDERR}"
 GITHUBX_PAT_SRC="GITHUBX_PAT${VALUE}"
 GITHUBX_DST=''
 "${SCRIPT}" "${GITHUBX_PAT_SRC}" "${GITHUBX_DST}" > "${STDOUT}" 2> "${STDERR}"
 . $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
 . $asserts/files/empty.sh "${STDOUT}"
 . $asserts/files/equals.sh "${STDERR}" $'Wrong token!\n'
done

#

:> "${STDOUT}"
:> "${STDERR}"
GITHUBX_PAT_SRC='GITHUBX_PAT'
GITHUBX_DST=''
GITHUBX_PAT='' \
 "${SCRIPT}" "${GITHUBX_PAT_SRC}" "${GITHUBX_DST}" > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" $'No token!\n'

:> "${STDOUT}"
:> "${STDERR}"
GITHUBX_PAT_SRC='GITHUBX_PAT'
GITHUBX_DST=''
GITHUBX_PAT='foo' \
 "${SCRIPT}" "${GITHUBX_PAT_SRC}" "${GITHUBX_DST}" > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" $'No dst!\n'

:> "${STDOUT}"
:> "${STDERR}"
GITHUBX_PAT_SRC='GITHUBX_PAT'
GITHUBX_DST="$(mktemp -d)"
GITHUBX_PAT='foo' \
 "${SCRIPT}" "${GITHUBX_PAT_SRC}" "${GITHUBX_DST}" > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" "\"${GITHUBX_DST}\" is not a file!"$'\n'
rm -r "${GITHUBX_DST}"

:> "${STDOUT}"
:> "${STDERR}"
GITHUBX_PAT_SRC='GITHUBX_PAT'
GITHUBX_DST="$(mktemp)"
rm "${GITHUBX_DST}"
ln -s "${GITHUBX_DST}" "${GITHUBX_DST}"
GITHUBX_PAT='foo' \
 "${SCRIPT}" "${GITHUBX_PAT_SRC}" "${GITHUBX_DST}" > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" "\"${GITHUBX_DST}\" is a symlink!"$'\n'
rm -r "${GITHUBX_DST}"

:> "${STDOUT}"
:> "${STDERR}"
GITHUBX_PAT_SRC='GITHUBX_PAT'
GITHUBX_DST="$(mktemp)"
GITHUBX_PAT='foo' \
 "${SCRIPT}" "${GITHUBX_PAT_SRC}" "${GITHUBX_DST}" > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" "\"${GITHUBX_DST}\" exists!"$'\n'
rm -r "${GITHUBX_DST}"

#

:> "${STDOUT}"
:> "${STDERR}"
GITHUBX_PAT_SRC='GITHUBX_PAT'
GITHUBX_DST="$(mktemp)"
rm "${GITHUBX_DST}"
PATH="${mocks}/curl/bin:${PATH}" \
 MOCKS_CURL_EXIT_CODE=1 \
 GITHUBX_PAT='foo' \
 "${SCRIPT}" "${GITHUBX_PAT_SRC}" "${GITHUBX_DST}" > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" $'Request error!\n'
rm -f "${GITHUBX_DST}"

#

HTTP_CODES=(2 20 22 202 2000 401 403 429 500 '' 'foo' '-1' '200 ' ' 200' $'\n200' $'\t200')
for HTTP_CODE in "${HTTP_CODES[@]}"; do
 :> "${STDOUT}"
 :> "${STDERR}"
 GITHUBX_PAT_SRC='GITHUBX_PAT'
 GITHUBX_DST="$(mktemp)"
 rm "${GITHUBX_DST}"
 PATH="${mocks}/curl/bin:${PATH}" \
  MOCKS_CURL_HTTP_CODE="${HTTP_CODE}" \
  GITHUBX_PAT='foo' \
  "${SCRIPT}" "${GITHUBX_PAT_SRC}" "${GITHUBX_DST}" > "${STDOUT}" 2> "${STDERR}"
 . $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
 . $asserts/files/empty.sh "${STDOUT}"
 . $asserts/files/equals.sh "${STDERR}" $'Response error!\n'
 rm -f "${GITHUBX_DST}"
done

#

:> "${STDOUT}"
:> "${STDERR}"
GITHUBX_PAT_SRC='GITHUBX_PAT'
GITHUBX_DST="$(mktemp)"
rm "${GITHUBX_DST}"
PATH="${mocks}/curl/bin:${PATH}" \
 MOCKS_CURL_HTTP_CODE=200 \
 MOCKS_CURL_DST_TYPE='issue:empty_file' \
 GITHUBX_PAT='foo' \
 "${SCRIPT}" "${GITHUBX_PAT_SRC}" "${GITHUBX_DST}" > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" "\"${GITHUBX_DST}\" is empty!"$'\n'
rm "${GITHUBX_DST}"

:> "${STDOUT}"
:> "${STDERR}"
GITHUBX_PAT_SRC='GITHUBX_PAT'
GITHUBX_DST="$(mktemp)"
rm "${GITHUBX_DST}"
PATH="${mocks}/curl/bin:${PATH}" \
 MOCKS_CURL_HTTP_CODE=200 \
 MOCKS_CURL_DST_TYPE='issue:symlink' \
 GITHUBX_PAT='foo' \
 "${SCRIPT}" "${GITHUBX_PAT_SRC}" "${GITHUBX_DST}" > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" "\"${GITHUBX_DST}\" is a symlink!"$'\n'
rm "${GITHUBX_DST}"

:> "${STDOUT}"
:> "${STDERR}"
GITHUBX_PAT_SRC='GITHUBX_PAT'
GITHUBX_DST="$(mktemp)"
rm "${GITHUBX_DST}"
PATH="${mocks}/curl/bin:${PATH}" \
 MOCKS_CURL_HTTP_CODE=200 \
 MOCKS_CURL_DST_TYPE='issue:dir' \
 GITHUBX_PAT='foo' \
 "${SCRIPT}" "${GITHUBX_PAT_SRC}" "${GITHUBX_DST}" > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" "\"${GITHUBX_DST}\" is not a file!"$'\n'
rm -r "${GITHUBX_DST}"

:> "${STDOUT}"
:> "${STDERR}"
GITHUBX_PAT_SRC='GITHUBX_PAT'
GITHUBX_DST="$(mktemp)"
rm "${GITHUBX_DST}"
PATH="${mocks}/curl/bin:${PATH}" \
 MOCKS_CURL_HTTP_CODE=200 \
 GITHUBX_PAT='foo' \
 "${SCRIPT}" "${GITHUBX_PAT_SRC}" "${GITHUBX_DST}" > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" "\"${GITHUBX_DST}\" does not exist!"$'\n'

#

echo 'Not implemented!'; exit 1 # todo

VALUES=('foo' '{}0' '[]' 'null' '42')
for MOCKS_CURL_DST in "${VALUES[@]}"; do
 :> "${STDOUT}"
 :> "${STDERR}"
 GITHUBX_PAT_SRC='GITHUBX_PAT'
 GITHUBX_DST="$(mktemp)"
 rm "${GITHUBX_DST}"
 PATH="${mocks}/curl/bin:${PATH}" \
  MOCKS_CURL_HTTP_CODE=200 \
  MOCKS_CURL_DST="${MOCKS_CURL_DST}" \
  GITHUBX_PAT='foo' \
  "${SCRIPT}" "${GITHUBX_PAT_SRC}" "${GITHUBX_DST}" > "${STDOUT}" 2> "${STDERR}"
 . $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
 . $asserts/files/empty.sh "${STDOUT}"
 . $asserts/files/equals.sh "${STDERR}" $'Parse dst error!\n'
 rm "${GITHUBX_DST}"
done

VALUES=('{}' '{"id":null}' '{"id":{}}' '{"id":[]}' '{"id":0}' '{"id":"42"}' '{"id":-1}' '{"id":0.5}')
for MOCKS_CURL_DST in "${VALUES[@]}"; do
 :> "${STDOUT}"
 :> "${STDERR}"
 GITHUBX_PAT_SRC='GITHUBX_PAT'
 GITHUBX_DST="$(mktemp)"
 rm "${GITHUBX_DST}"
 PATH="${mocks}/curl/bin:${PATH}" \
  MOCKS_CURL_HTTP_CODE=200 \
  MOCKS_CURL_DST="${MOCKS_CURL_DST}" \
  GITHUBX_PAT='foo' \
  "${SCRIPT}" "${GITHUBX_PAT_SRC}" "${GITHUBX_DST}" > "${STDOUT}" 2> "${STDERR}"
 . $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
 . $asserts/files/empty.sh "${STDOUT}"
 . $asserts/files/equals.sh "${STDERR}" $'Check dst error!\n'
 rm "${GITHUBX_DST}"
done

:> "${STDOUT}"
:> "${STDERR}"
GITHUBX_PAT_SRC='GITHUBX_PAT'
GITHUBX_DST="$(mktemp)"
rm "${GITHUBX_DST}"
MOCKS_CURL_DST=200
PATH="${mocks}/curl/bin:${PATH}" \
 MOCKS_CURL_HTTP_CODE=201 \
 MOCKS_CURL_DST="${MOCKS_CURL_DST}" \
 GITHUBX_PAT='foo' \
 "${SCRIPT}" "${GITHUBX_PAT_SRC}" "${GITHUBX_DST}" > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" $'Response error!\n'
. $asserts/files/equals.sh "${GITHUBX_DST}" "${MOCKS_CURL_DST}"
rm "${GITHUBX_DST}"

:> "${STDOUT}"
:> "${STDERR}"
GITHUBX_PAT_SRC='GITHUBX_PAT'
GITHUBX_PAT='foo'
GITHUBX_DST="$(mktemp)"
rm "${GITHUBX_DST}"
MOCKS_CURL_HEADERS_PATH="$(mktemp)"
rm "${MOCKS_CURL_HEADERS_PATH}"
MOCKS_CURL_DST='{"id":42}'
PATH="${mocks}/curl/bin:${PATH}" \
 MOCKS_CURL_HTTP_CODE=200 \
 MOCKS_CURL_DST="${MOCKS_CURL_DST}" \
 MOCKS_CURL_HEADERS_PATH="${MOCKS_CURL_HEADERS_PATH}" \
 GITHUBX_PAT="${GITHUBX_PAT}" \
 "${SCRIPT}" "${GITHUBX_PAT_SRC}" "${GITHUBX_DST}" > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 0
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/empty.sh "${STDERR}"
. $asserts/files/equals.sh "${GITHUBX_DST}" "${MOCKS_CURL_DST}"
. $asserts/files/not_empty.sh "${MOCKS_CURL_HEADERS_PATH}" # todo mock curl headers payload
rm "${GITHUBX_DST}"
rm "${MOCKS_CURL_HEADERS_PATH}"

#

rm "${STDOUT}"
rm "${STDERR}"
