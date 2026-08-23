#!/usr/local/bin/bash

if [[ $# -ne 3 ]]; then
 echo 'Wrong arguments!' >&2; exit 1; fi

GITHUBX_REP_OWNER="$1"
if [[ -z "${GITHUBX_REP_OWNER}" ]]; then
 echo 'No repository owner!' >&2; exit 1; fi

GITHUBX_FILE_PATH="$2"
if [[ -z "${GITHUBX_FILE_PATH}" ]]; then
 echo 'No file path!' >&2; exit 1; fi

GITHUBX_DST="$3"

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

HTTP_CODE=$(curl -m 8 -w '%{http_code}' \
 "https://${GITHUBX_REP_OWNER}.github.io/${GITHUBX_FILE_PATH}" \
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
