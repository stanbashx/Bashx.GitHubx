#!/usr/local/bin/bash

SCRIPT='src/main/bash/release.sh'

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
"${SCRIPT}" '' '' '' '' '' '' '' > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" $'Wrong arguments!\n'

:> "${STDOUT}"
:> "${STDERR}"
"${SCRIPT}" '' '' '' '' '' '' '' '' '' > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" $'Wrong arguments!\n'

#

GITHUBX_REP_OWNER=''
GITHUBX_REP_NAME=''
GITHUBX_PAT_SRC=''
GITHUBX_RELEASE_SHA=''
GITHUBX_RELEASE_VERSION=''
GITHUBX_RELEASE_MESSAGE=''
GITHUBX_IS_PRERELEASE=''
GITHUBX_DST=''

#

:> "${STDOUT}"
:> "${STDERR}"
"${SCRIPT}" "${GITHUBX_REP_OWNER}" "${GITHUBX_REP_NAME}" "${GITHUBX_PAT_SRC}" "${GITHUBX_RELEASE_SHA}" "${GITHUBX_RELEASE_VERSION}" "${GITHUBX_RELEASE_MESSAGE}" "${GITHUBX_IS_PRERELEASE}" "${GITHUBX_DST}" \
 > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" 'No repository owner!'$'\n'

GITHUBX_REP_OWNER='foo'

:> "${STDOUT}"
:> "${STDERR}"
"${SCRIPT}" "${GITHUBX_REP_OWNER}" "${GITHUBX_REP_NAME}" "${GITHUBX_PAT_SRC}" "${GITHUBX_RELEASE_SHA}" "${GITHUBX_RELEASE_VERSION}" "${GITHUBX_RELEASE_MESSAGE}" "${GITHUBX_IS_PRERELEASE}" "${GITHUBX_DST}" \
 > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" 'No repository name!'$'\n'

GITHUBX_REP_NAME='bar'

:> "${STDOUT}"
:> "${STDERR}"
"${SCRIPT}" "${GITHUBX_REP_OWNER}" "${GITHUBX_REP_NAME}" "${GITHUBX_PAT_SRC}" "${GITHUBX_RELEASE_SHA}" "${GITHUBX_RELEASE_VERSION}" "${GITHUBX_RELEASE_MESSAGE}" "${GITHUBX_IS_PRERELEASE}" "${GITHUBX_DST}" \
 > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" 'Wrong token!'$'\n'

GITHUBX_PAT_SRC='GITHUBX_PAT'

:> "${STDOUT}"
:> "${STDERR}"
"${SCRIPT}" "${GITHUBX_REP_OWNER}" "${GITHUBX_REP_NAME}" "${GITHUBX_PAT_SRC}" "${GITHUBX_RELEASE_SHA}" "${GITHUBX_RELEASE_VERSION}" "${GITHUBX_RELEASE_MESSAGE}" "${GITHUBX_IS_PRERELEASE}" "${GITHUBX_DST}" \
 > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" 'Token is unset!'$'\n'

:> "${STDOUT}"
:> "${STDERR}"
GITHUBX_PAT='' \
 "${SCRIPT}" "${GITHUBX_REP_OWNER}" "${GITHUBX_REP_NAME}" "${GITHUBX_PAT_SRC}" "${GITHUBX_RELEASE_SHA}" "${GITHUBX_RELEASE_VERSION}" "${GITHUBX_RELEASE_MESSAGE}" "${GITHUBX_IS_PRERELEASE}" "${GITHUBX_DST}" \
 > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" 'No token!'$'\n'

:> "${STDOUT}"
:> "${STDERR}"
GITHUBX_PAT='42' \
 "${SCRIPT}" "${GITHUBX_REP_OWNER}" "${GITHUBX_REP_NAME}" "${GITHUBX_PAT_SRC}" "${GITHUBX_RELEASE_SHA}" "${GITHUBX_RELEASE_VERSION}" "${GITHUBX_RELEASE_MESSAGE}" "${GITHUBX_IS_PRERELEASE}" "${GITHUBX_DST}" \
 > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" 'No release SHA!'$'\n'

GITHUBX_RELEASE_SHA='foo'

:> "${STDOUT}"
:> "${STDERR}"
GITHUBX_PAT='42' \
 "${SCRIPT}" "${GITHUBX_REP_OWNER}" "${GITHUBX_REP_NAME}" "${GITHUBX_PAT_SRC}" "${GITHUBX_RELEASE_SHA}" "${GITHUBX_RELEASE_VERSION}" "${GITHUBX_RELEASE_MESSAGE}" "${GITHUBX_IS_PRERELEASE}" "${GITHUBX_DST}" \
 > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" 'Wrong release SHA!'$'\n'

GITHUBX_RELEASE_SHA='a085a56c2593123dfabbaf2ca08a0743e66b356f'

:> "${STDOUT}"
:> "${STDERR}"
GITHUBX_PAT='42' \
 "${SCRIPT}" "${GITHUBX_REP_OWNER}" "${GITHUBX_REP_NAME}" "${GITHUBX_PAT_SRC}" "${GITHUBX_RELEASE_SHA}" "${GITHUBX_RELEASE_VERSION}" "${GITHUBX_RELEASE_MESSAGE}" "${GITHUBX_IS_PRERELEASE}" "${GITHUBX_DST}" \
 > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" 'No release version!'$'\n'

GITHUBX_RELEASE_VERSION='test/version'

:> "${STDOUT}"
:> "${STDERR}"
GITHUBX_PAT='42' \
 "${SCRIPT}" "${GITHUBX_REP_OWNER}" "${GITHUBX_REP_NAME}" "${GITHUBX_PAT_SRC}" "${GITHUBX_RELEASE_SHA}" "${GITHUBX_RELEASE_VERSION}" "${GITHUBX_RELEASE_MESSAGE}" "${GITHUBX_IS_PRERELEASE}" "${GITHUBX_DST}" \
 > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" 'No release message!'$'\n'

GITHUBX_RELEASE_MESSAGE='test message'

:> "${STDOUT}"
:> "${STDERR}"
GITHUBX_PAT='42' \
 "${SCRIPT}" "${GITHUBX_REP_OWNER}" "${GITHUBX_REP_NAME}" "${GITHUBX_PAT_SRC}" "${GITHUBX_RELEASE_SHA}" "${GITHUBX_RELEASE_VERSION}" "${GITHUBX_RELEASE_MESSAGE}" "${GITHUBX_IS_PRERELEASE}" "${GITHUBX_DST}" \
 > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" 'Wrong prerelease!'$'\n'

GITHUBX_IS_PRERELEASE='true'

:> "${STDOUT}"
:> "${STDERR}"
GITHUBX_PAT='42' \
 "${SCRIPT}" "${GITHUBX_REP_OWNER}" "${GITHUBX_REP_NAME}" "${GITHUBX_PAT_SRC}" "${GITHUBX_RELEASE_SHA}" "${GITHUBX_RELEASE_VERSION}" "${GITHUBX_RELEASE_MESSAGE}" "${GITHUBX_IS_PRERELEASE}" "${GITHUBX_DST}" \
 > "${STDOUT}" 2> "${STDERR}"
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
 "${SCRIPT}" "${GITHUBX_REP_OWNER}" "${GITHUBX_REP_NAME}" "${GITHUBX_PAT_SRC}" "${GITHUBX_RELEASE_SHA}" "${GITHUBX_RELEASE_VERSION}" "${GITHUBX_RELEASE_MESSAGE}" "${GITHUBX_IS_PRERELEASE}" "${GITHUBX_DST}" \
 > "${STDOUT}" 2> "${STDERR}"
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
  "${SCRIPT}" "${GITHUBX_REP_OWNER}" "${GITHUBX_REP_NAME}" "${GITHUBX_PAT_SRC}" "${GITHUBX_RELEASE_SHA}" "${GITHUBX_RELEASE_VERSION}" "${GITHUBX_RELEASE_MESSAGE}" "${GITHUBX_IS_PRERELEASE}" "${GITHUBX_DST}" \
  > "${STDOUT}" 2> "${STDERR}"
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
MOCKS_CURL_DST="{\"target_commitish\":\"${GITHUBX_RELEASE_SHA}\"}"
PATH="${mocks}/curl/bin:${PATH}" \
 MOCKS_CURL_HTTP_CODE=201 \
 MOCKS_CURL_DST="${MOCKS_CURL_DST}" \
 GITHUBX_PAT='42' \
 "${SCRIPT}" "${GITHUBX_REP_OWNER}" "${GITHUBX_REP_NAME}" "${GITHUBX_PAT_SRC}" "${GITHUBX_RELEASE_SHA}" "${GITHUBX_RELEASE_VERSION}" "${GITHUBX_RELEASE_MESSAGE}" "${GITHUBX_IS_PRERELEASE}" "${GITHUBX_DST}" \
 > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 0
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/empty.sh "${STDERR}"
. $asserts/files/equals.sh "${GITHUBX_DST}" "${MOCKS_CURL_DST}"
rm "${GITHUBX_DST}"

#

rm "${STDOUT}"
rm "${STDERR}"
