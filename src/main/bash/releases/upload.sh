#!/usr/local/bin/bash

if [[ $# -ne 7 ]]; then
 echo 'Wrong arguments!' >&2; exit 1; fi

GITHUBX_REP_OWNER="$1"
if [[ -z "${GITHUBX_REP_OWNER}" ]]; then
 echo 'No repository owner!' >&2; exit 1; fi

GITHUBX_REP_NAME="$2"
if [[ -z "${GITHUBX_REP_NAME}" ]]; then
 echo 'No repository name!' >&2; exit 1; fi

GITHUBX_PAT_SRC="$3"
if [[ ! "${GITHUBX_PAT_SRC}" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]; then
 echo 'Wrong token!' >&2; exit 1
elif [[ ! -v "${GITHUBX_PAT_SRC}" ]]; then
 echo 'Token is unset!' >&2; exit 1
elif [[ -z "${!GITHUBX_PAT_SRC}" ]]; then
 echo 'No token!' >&2; exit 1
fi

GITHUBX_RELEASE_ID="$4"
if [[ -z "${GITHUBX_RELEASE_ID}" ]]; then
 echo 'No release ID!' >&2; exit 1;
elif [[ ! "${GITHUBX_RELEASE_ID}" =~ ^[1-9][0-9]*$ ]]; then
 echo 'Wrong release ID!' >&2; exit 1;
fi

GITHUBX_ASSET_PATH="$5"
if [[ -z "${GITHUBX_ASSET_PATH}" ]]; then
 echo 'No asset path!' >&2; exit 1
elif [[ -L "${GITHUBX_ASSET_PATH}" ]]; then
 echo "\"${GITHUBX_ASSET_PATH}\" is a symlink!" >&2; exit 1
elif [[ ! -e "${GITHUBX_ASSET_PATH}" ]]; then
 echo "\"${GITHUBX_ASSET_PATH}\" does not exist!" >&2; exit 1
elif [[ ! -f "${GITHUBX_ASSET_PATH}" ]]; then
 echo "\"${GITHUBX_ASSET_PATH}\" is not a file!" >&2; exit 1
fi

GITHUBX_ASSET_NAME="$6"
if [[ -z "${GITHUBX_ASSET_NAME}" ]]; then
 echo 'No asset name!' >&2; exit 1; fi

GITHUBX_DST="$7"
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

GITHUBX_ASSET_SHA256="$(openssl dgst -sha256 -binary "${GITHUBX_ASSET_PATH}" | xxd -ps -c 32 -l 32)"
if [[ $? -ne 0 ]]; then
 echo 'Not implemented!' >&2; exit 1 # todo
elif [[ "${#GITHUBX_ASSET_SHA256}" != '64' ]]; then
 echo 'Not implemented!' >&2; exit 1 # todo
fi

GITHUBX_API='https://uploads.github.com'
GITHUBX_API_VERSION='2026-03-10'

# https://docs.github.com/en/rest/releases/assets#upload-a-release-asset

HTTP_CODE=$(curl -m 32 -w '%{http_code}' \
 -X POST "${GITHUBX_API}/repos/${GITHUBX_REP_OWNER}/${GITHUBX_REP_NAME}/releases/${GITHUBX_RELEASE_ID}/assets" \
 --url-query "name=${GITHUBX_ASSET_NAME}" \
 --header 'Accept: application/vnd.github+json' \
 --header "X-GitHub-Api-Version: ${GITHUBX_API_VERSION}" \
 --header @<(printf 'Authorization: Bearer %s' "${!GITHUBX_PAT_SRC}") \
 --header 'Content-Type: application/octet-stream' \
 --data-binary "@${GITHUBX_ASSET_PATH}" \
 -o "${GITHUBX_DST}" 2>/dev/null)

if [[ $? -ne 0 ]]; then
 echo 'Request error!' >&2; exit 1
elif [[ "${HTTP_CODE}" != '201' ]]; then
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

GITHUBX_ACTUAL_SHA256="$(yq -Mer -p=json -o=json '.digest' "${GITHUBX_DST}" 2>/dev/null)"
if [[ $? -ne 0 || "${GITHUBX_ACTUAL_SHA256}" != "sha256:${GITHUBX_ASSET_SHA256}" ]]; then
 echo 'Check dst error!' >&2; exit 1; fi
