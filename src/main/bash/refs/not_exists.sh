#!/usr/local/bin/bash

if [[ $# -ne 3 ]]; then
 echo 'Wrong arguments!' >&2; exit 1; fi

GITHUBX_REP_OWNER="$1"
if [[ -z "${GITHUBX_REP_OWNER}" ]]; then
 echo 'No repository owner!' >&2; exit 1; fi

GITHUBX_REP_NAME="$2"
if [[ -z "${GITHUBX_REP_NAME}" ]]; then
 echo 'No repository name!' >&2; exit 1; fi

GITHUBX_REF="$3"
if [[ -z "${GITHUBX_REF}" ]]; then
 echo 'No ref!' >&2; exit 1; fi

GITHUBX_API='https://api.github.com'
GITHUBX_API_VERSION='2026-03-10'

# https://docs.github.com/en/rest/git/refs

HTTP_CODE=$(curl -m 8 -w '%{http_code}' \
 "${GITHUBX_API}/repos/${GITHUBX_REP_OWNER}/${GITHUBX_REP_NAME}/git/refs/${GITHUBX_REF}" \
 --header 'Accept: application/vnd.github+json' \
 --header "X-GitHub-Api-Version: ${GITHUBX_API_VERSION}" \
 -o /dev/null 2>/dev/null)

if [[ $? -ne 0 ]]; then
 echo 'Request error!' >&2; exit 1
elif [[ "${HTTP_CODE}" == '200' ]]; then
 echo "Ref \"${GITHUBX_REF}\" exists!" >&2; exit 1
elif [[ "${HTTP_CODE}" != '404' ]]; then
 echo 'Response error!' >&2; exit 1
fi
