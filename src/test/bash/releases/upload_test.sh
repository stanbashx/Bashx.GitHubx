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
unset GITHUBX_PAT
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

:> "${STDOUT}"
:> "${STDERR}"
GITHUBX_PAT='42' \
 "${SCRIPT}" "${GITHUBX_REP_OWNER}" "${GITHUBX_REP_NAME}" "${GITHUBX_PAT_SRC}" "${GITHUBX_RELEASE_ID}" "${GITHUBX_ASSET_PATH}" "${GITHUBX_ASSET_NAME}" "${GITHUBX_DST}" > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" 'No release ID!'$'\n'

GITHUBX_RELEASE_ID='a'

:> "${STDOUT}"
:> "${STDERR}"
GITHUBX_PAT='42' \
 "${SCRIPT}" "${GITHUBX_REP_OWNER}" "${GITHUBX_REP_NAME}" "${GITHUBX_PAT_SRC}" "${GITHUBX_RELEASE_ID}" "${GITHUBX_ASSET_PATH}" "${GITHUBX_ASSET_NAME}" "${GITHUBX_DST}" > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" 'Wrong release ID!'$'\n'

GITHUBX_RELEASE_ID='1'

:> "${STDOUT}"
:> "${STDERR}"
GITHUBX_PAT='42' \
 "${SCRIPT}" "${GITHUBX_REP_OWNER}" "${GITHUBX_REP_NAME}" "${GITHUBX_PAT_SRC}" "${GITHUBX_RELEASE_ID}" "${GITHUBX_ASSET_PATH}" "${GITHUBX_ASSET_NAME}" "${GITHUBX_DST}" > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" 'No asset path!'$'\n'

GITHUBX_ASSET_PATH="$(mktemp)"
printf '%s' 'foobarbaz' > "${GITHUBX_ASSET_PATH}"

:> "${STDOUT}"
:> "${STDERR}"
GITHUBX_PAT='42' \
 "${SCRIPT}" "${GITHUBX_REP_OWNER}" "${GITHUBX_REP_NAME}" "${GITHUBX_PAT_SRC}" "${GITHUBX_RELEASE_ID}" "${GITHUBX_ASSET_PATH}" "${GITHUBX_ASSET_NAME}" "${GITHUBX_DST}" > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" 'No asset name!'$'\n'

GITHUBX_ASSET_NAME='test_asset.txt'

:> "${STDOUT}"
:> "${STDERR}"
GITHUBX_PAT='42' \
 "${SCRIPT}" "${GITHUBX_REP_OWNER}" "${GITHUBX_REP_NAME}" "${GITHUBX_PAT_SRC}" "${GITHUBX_RELEASE_ID}" "${GITHUBX_ASSET_PATH}" "${GITHUBX_ASSET_NAME}" "${GITHUBX_DST}" > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" 'No dst!'$'\n'

#

:> "${STDOUT}"
:> "${STDERR}"
GITHUBX_DST="$(mktemp)"
rm "${GITHUBX_DST}"
PATH="${mocks}/curl/bin:${PATH}" \
 MOCKS_CURL_EXIT_CODE=1 \
 GITHUBX_PAT='42' \
 "${SCRIPT}" "${GITHUBX_REP_OWNER}" "${GITHUBX_REP_NAME}" "${GITHUBX_PAT_SRC}" "${GITHUBX_RELEASE_ID}" "${GITHUBX_ASSET_PATH}" "${GITHUBX_ASSET_NAME}" "${GITHUBX_DST}" > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" 'Request error!'$'\n'
rm -f "${GITHUBX_DST}"

HTTP_CODES=(2 20 22 200 202 2000 401 403 429 500 '' 'foo' '-1' '201 ' ' 201' $'\n201' $'\t201')
for HTTP_CODE in "${HTTP_CODES[@]}"; do
 :> "${STDOUT}"
 :> "${STDERR}"
 GITHUBX_DST="$(mktemp)"
 rm "${GITHUBX_DST}"
 PATH="${mocks}/curl/bin:${PATH}" \
  MOCKS_CURL_HTTP_CODE="${HTTP_CODE}" \
  GITHUBX_PAT='42' \
  "${SCRIPT}" "${GITHUBX_REP_OWNER}" "${GITHUBX_REP_NAME}" "${GITHUBX_PAT_SRC}" "${GITHUBX_RELEASE_ID}" "${GITHUBX_ASSET_PATH}" "${GITHUBX_ASSET_NAME}" "${GITHUBX_DST}" > "${STDOUT}" 2> "${STDERR}"
 . $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
 . $asserts/files/empty.sh "${STDOUT}"
 . $asserts/files/equals.sh "${STDERR}" $'Response error!\n'
 rm -f "${GITHUBX_DST}"
done

#

:> "${STDOUT}"
:> "${STDERR}"
GITHUBX_DST="$(mktemp)"
rm "${GITHUBX_DST}"
MOCKS_CURL_DST="{\"digest\":\"sha256:97df3588b5a3f24babc3851b372f0ba71a9dcdded43b14b9d06961bfc1707d9d\"}"
PATH="${mocks}/curl/bin:${PATH}" \
 MOCKS_CURL_HTTP_CODE=201 \
 MOCKS_CURL_DST="${MOCKS_CURL_DST}" \
 GITHUBX_PAT='42' \
 "${SCRIPT}" "${GITHUBX_REP_OWNER}" "${GITHUBX_REP_NAME}" "${GITHUBX_PAT_SRC}" "${GITHUBX_RELEASE_ID}" "${GITHUBX_ASSET_PATH}" "${GITHUBX_ASSET_NAME}" "${GITHUBX_DST}" > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 0
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/empty.sh "${STDERR}"
. $asserts/files/equals.sh "${GITHUBX_DST}" "${MOCKS_CURL_DST}"
rm "${GITHUBX_DST}"

#

rm "${GITHUBX_ASSET_PATH}"

rm "${STDOUT}"
rm "${STDERR}"
