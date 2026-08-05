#!/usr/local/bin/bash

if [[ $# -ne 4 ]]; then
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

GITHUBX_DST="$4"

if [[ -z "${GITHUBX_DST}" ]]; then
 echo 'No dst!' >&2; exit 1
elif [[ -L "${GITHUBX_DST}" ]]; then
 echo "\"${GITHUBX_DST}\" is a symlink!" >&2; exit 1
elif [[ -e "${GITHUBX_DST}" ]]; then
 if [[ -f "${GITHUBX_DST}" ]]; then
  echo "\"${GITHUBX_DST}\" exists!" >&2; exit 1
 else
  echo "\"${GITHUBX_DST}\" is not a file!" >&2; exit 1
 fi
fi

GITHUBX_API='https://api.github.com'
GITHUBX_API_VERSION='2026-03-10'

# https://docs.github.com/en/rest/git/refs

HTTP_CODE=$(curl -m 8 -w '%{http_code}' \
 "${GITHUBX_API}/repos/${GITHUBX_REP_OWNER}/${GITHUBX_REP_NAME}/git/ref/${GITHUBX_REF}" \
 --header 'Accept: application/vnd.github+json' \
 --header "X-GitHub-Api-Version: ${GITHUBX_API_VERSION}" \
 -o "${GITHUBX_DST}" 2>/dev/null)

if [[ $? -ne 0 ]]; then
 echo 'Request error!' >&2; exit 1
elif [[ "${HTTP_CODE}" != '200' ]]; then
 echo 'Response error!' >&2; exit 1
fi

if [[ -L "${GITHUBX_DST}" ]]; then
 echo "\"${GITHUBX_DST}\" is a symlink!" >&2; exit 1
elif [[ ! -e "${GITHUBX_DST}" ]]; then
 echo "\"${GITHUBX_DST}\" does not exist!" >&2; exit 1
elif [[ ! -f "${GITHUBX_DST}" ]]; then
 echo "\"${GITHUBX_DST}\" is not a file!" >&2; exit 1
elif [[ ! -s "${GITHUBX_DST}" ]]; then
 echo "\"${GITHUBX_DST}\" is empty!" >&2; exit 1
fi

GITHUBX_DST_TAGS="$(yq -Mer -p=json -o=json 'tag' "${GITHUBX_DST}" 2>/dev/null)"
if [[ $? -ne 0 || "${GITHUBX_DST_TAGS}" != '!!map' ]]; then
 echo 'Parse dst error!' >&2; exit 1; fi

GITHUBX_REF_ACTUAL="$(yq -Mer -p=json -o=json '.ref' "${GITHUBX_DST}" 2>/dev/null)"
if [[ $? -ne 0 || "refs/${GITHUBX_REF}" != "${GITHUBX_REF_ACTUAL}" ]]; then
 echo 'Check dst error!' >&2; exit 1; fi
