#!/usr/local/bin/bash

SCRIPT='src/main/bash/refs/not_exists.sh'

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
"${SCRIPT}" '' '' '' '' > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" $'Wrong arguments!\n'

#

:> "${STDOUT}"
:> "${STDERR}"
GITHUBX_REP_OWNER=''
GITHUBX_REP_NAME=''
GITHUBX_REF=''
"${SCRIPT}" "${GITHUBX_REP_OWNER}" "${GITHUBX_REP_NAME}" "${GITHUBX_REF}" > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" $'No repository owner!\n'

:> "${STDOUT}"
:> "${STDERR}"
GITHUBX_REP_OWNER='foo'
GITHUBX_REP_NAME=''
GITHUBX_REF=''
"${SCRIPT}" "${GITHUBX_REP_OWNER}" "${GITHUBX_REP_NAME}" "${GITHUBX_REF}" > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" $'No repository name!\n'

:> "${STDOUT}"
:> "${STDERR}"
GITHUBX_REP_OWNER='foo'
GITHUBX_REP_NAME='bar'
GITHUBX_REF=''
"${SCRIPT}" "${GITHUBX_REP_OWNER}" "${GITHUBX_REP_NAME}" "${GITHUBX_REF}" > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" $'No ref!\n'

#

:> "${STDOUT}"
:> "${STDERR}"
GITHUBX_REP_OWNER='foo'
GITHUBX_REP_NAME='bar'
GITHUBX_REF='qux'
PATH="${mocks}/curl/bin:${PATH}" \
 MOCKS_CURL_EXIT_CODE=1 \
 "${SCRIPT}" "${GITHUBX_REP_OWNER}" "${GITHUBX_REP_NAME}" "${GITHUBX_REF}" > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" $'Request error!\n'

HTTP_CODES=(2 20 22 202 2000 401 403 429 500 '' 'foo' '-1' '404 ' ' 404' $'\n404' $'\t404')
for HTTP_CODE in "${HTTP_CODES[@]}"; do
 :> "${STDOUT}"
 :> "${STDERR}"
 GITHUBX_REP_OWNER='foo'
 GITHUBX_REP_NAME='bar'
 GITHUBX_REF='qux'
 PATH="${mocks}/curl/bin:${PATH}" \
  MOCKS_CURL_HTTP_CODE="${HTTP_CODE}" \
  "${SCRIPT}" "${GITHUBX_REP_OWNER}" "${GITHUBX_REP_NAME}" "${GITHUBX_REF}" > "${STDOUT}" 2> "${STDERR}"
 . $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
 . $asserts/files/empty.sh "${STDOUT}"
 . $asserts/files/equals.sh "${STDERR}" $'Response error!\n'
done

:> "${STDOUT}"
:> "${STDERR}"
GITHUBX_REP_OWNER='foo'
GITHUBX_REP_NAME='bar'
GITHUBX_REF='qux'
PATH="${mocks}/curl/bin:${PATH}" \
 MOCKS_CURL_HTTP_CODE=200 \
 "${SCRIPT}" "${GITHUBX_REP_OWNER}" "${GITHUBX_REP_NAME}" "${GITHUBX_REF}" > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" "Ref \"${GITHUBX_REF}\" exists!"$'\n'

:> "${STDOUT}"
:> "${STDERR}"
GITHUBX_REP_OWNER='foo'
GITHUBX_REP_NAME='bar'
GITHUBX_REF='qux'
PATH="${mocks}/curl/bin:${PATH}" \
 MOCKS_CURL_HTTP_CODE=404 \
 "${SCRIPT}" "${GITHUBX_REP_OWNER}" "${GITHUBX_REP_NAME}" "${GITHUBX_REF}" > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 0
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/empty.sh "${STDERR}"

#

rm "${STDOUT}"
rm "${STDERR}"
