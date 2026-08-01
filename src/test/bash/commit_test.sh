#!/usr/local/bin/bash

SCRIPT='src/main/bash/commit.sh'

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
"${SCRIPT}" '' '' > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" $'Wrong arguments!\n'

:> "${STDOUT}"
:> "${STDERR}"
"${SCRIPT}" '' '' '' > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" $'Wrong arguments!\n'

:> "${STDOUT}"
:> "${STDERR}"
"${SCRIPT}" '' '' '' '' '' > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" $'Wrong arguments!\n'

#

:> "${STDOUT}"
:> "${STDERR}"
GITHUBX_REP_OWNER=''
GITHUBX_REP_NAME=''
GITHUBX_REF=''
GITHUBX_DST=''
"${SCRIPT}" "${GITHUBX_REP_OWNER}" "${GITHUBX_REP_NAME}" "${GITHUBX_REF}" "${GITHUBX_DST}" > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" $'No repository owner!\n'

:> "${STDOUT}"
:> "${STDERR}"
GITHUBX_REP_OWNER='foo'
GITHUBX_REP_NAME=''
GITHUBX_REF=''
GITHUBX_DST=''
"${SCRIPT}" "${GITHUBX_REP_OWNER}" "${GITHUBX_REP_NAME}" "${GITHUBX_REF}" "${GITHUBX_DST}" > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" $'No repository name!\n'

:> "${STDOUT}"
:> "${STDERR}"
GITHUBX_REP_OWNER='foo'
GITHUBX_REP_NAME='bar'
GITHUBX_REF=''
GITHUBX_DST=''
"${SCRIPT}" "${GITHUBX_REP_OWNER}" "${GITHUBX_REP_NAME}" "${GITHUBX_REF}" "${GITHUBX_DST}" > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" $'No ref!\n'

:> "${STDOUT}"
:> "${STDERR}"
GITHUBX_REP_OWNER='foo'
GITHUBX_REP_NAME='bar'
GITHUBX_REF='42'
GITHUBX_DST=''
"${SCRIPT}" "${GITHUBX_REP_OWNER}" "${GITHUBX_REP_NAME}" "${GITHUBX_REF}" "${GITHUBX_DST}" > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" $'Wrong ref!\n'

:> "${STDOUT}"
:> "${STDERR}"
GITHUBX_REP_OWNER='foo'
GITHUBX_REP_NAME='bar'
GITHUBX_REF='a085a56c2593123dfabbaf2ca08a0743e66b356f'
GITHUBX_DST=''
"${SCRIPT}" "${GITHUBX_REP_OWNER}" "${GITHUBX_REP_NAME}" "${GITHUBX_REF}" "${GITHUBX_DST}" > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" $'No dst!\n'

#

:> "${STDOUT}"
:> "${STDERR}"
GITHUBX_REP_OWNER='foo'
GITHUBX_REP_NAME='bar'
GITHUBX_REF='a085a56c2593123dfabbaf2ca08a0743e66b356f'
GITHUBX_DST="$(mktemp)"
rm "${GITHUBX_DST}"
PATH="${mocks}/curl/bin:${PATH}" \
 MOCKS_CURL_EXIT_CODE=1 \
 "${SCRIPT}" "${GITHUBX_REP_OWNER}" "${GITHUBX_REP_NAME}" "${GITHUBX_REF}" "${GITHUBX_DST}" > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" $'Request error!\n'
rm -f "${GITHUBX_DST}"

HTTP_CODES=(2 20 22 202 2000 401 403 429 500 '' 'foo' '-1' '200 ' ' 200' $'\n200' $'\t200')
for HTTP_CODE in "${HTTP_CODES[@]}"; do
 :> "${STDOUT}"
 :> "${STDERR}"
 GITHUBX_REP_OWNER='foo'
 GITHUBX_REP_NAME='bar'
 GITHUBX_REF='a085a56c2593123dfabbaf2ca08a0743e66b356f'
 GITHUBX_DST="$(mktemp)"
 rm "${GITHUBX_DST}"
 PATH="${mocks}/curl/bin:${PATH}" \
  MOCKS_CURL_HTTP_CODE="${HTTP_CODE}" \
  "${SCRIPT}" "${GITHUBX_REP_OWNER}" "${GITHUBX_REP_NAME}" "${GITHUBX_REF}" "${GITHUBX_DST}" > "${STDOUT}" 2> "${STDERR}"
 . $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
 . $asserts/files/empty.sh "${STDOUT}"
 . $asserts/files/equals.sh "${STDERR}" $'Response error!\n'
 rm -f "${GITHUBX_DST}"
done

#

echo 'Not implemented!'; exit 1 # todo

#

rm "${STDOUT}"
rm "${STDERR}"
