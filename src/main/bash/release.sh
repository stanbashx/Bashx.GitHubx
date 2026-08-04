#!/usr/local/bin/bash

if [[ $# -ne 8 ]]; then
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

GITHUBX_RELEASE_SHA="$4"
if [[ -z "${GITHUBX_RELEASE_SHA}" ]]; then
 echo 'No release SHA!' >&2; exit 1;
elif [[ ! "${GITHUBX_RELEASE_SHA}" =~ ^[0-9a-f]{40}$ ]]; then
 echo 'Wrong release SHA!' >&2; exit 1;
fi

GITHUBX_RELEASE_VERSION="$5"
if [[ -z "${GITHUBX_RELEASE_VERSION}" ]]; then
 echo 'No release version!' >&2; exit 1; fi

GITHUBX_RELEASE_MESSAGE="$6"
if [[ -z "${GITHUBX_RELEASE_MESSAGE}" ]]; then
 echo 'No release message!' >&2; exit 1; fi

GITHUBX_IS_PRERELEASE="$7"
case "${GITHUBX_IS_PRERELEASE}" in
 'false'|'true');;
 *) echo 'Wrong prerelease!' >&2; exit 1;
esac

GITHUBX_DST="$8"
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

# https://docs.github.com/rest/releases/releases#create-a-release

GITHUBX_IS_DRAFT='false'

GITHUBX_REQUEST_BODY="{
 \"target_commitish\":\"${GITHUBX_RELEASE_SHA}\",
 \"draft\":${GITHUBX_IS_DRAFT},
 \"prerelease\":${GITHUBX_IS_PRERELEASE}
}"

GITHUBX_REQUEST_BODY="$(printf '%s' "${GITHUBX_REQUEST_BODY}" | \
 STR_VALUE="${GITHUBX_RELEASE_VERSION}" \
 yq -M -I=0 -p=json -o=json '.name=strenv(STR_VALUE)')"

GITHUBX_REQUEST_BODY="$(printf '%s' "${GITHUBX_REQUEST_BODY}" | \
 STR_VALUE="${GITHUBX_RELEASE_VERSION}" \
 yq -M -I=0 -p=json -o=json '.tag_name=strenv(STR_VALUE)')"

GITHUBX_REQUEST_BODY="$(printf '%s' "${GITHUBX_REQUEST_BODY}" | \
 STR_VALUE="${GITHUBX_RELEASE_MESSAGE}" \
 yq -M -I=0 -p=json -o=json '.body=strenv(STR_VALUE)')"

HTTP_CODE=$(curl -m 8 -w '%{http_code}' \
 -X POST "${GITHUBX_API}/repos/${GITHUBX_REP_OWNER}/${GITHUBX_REP_NAME}/releases" \
 --header 'Accept: application/vnd.github+json' \
 --header "X-GitHub-Api-Version: ${GITHUBX_API_VERSION}" \
 --header @<(printf 'Authorization: Bearer %s' "${!GITHUBX_PAT_SRC}") \
 -d "${GITHUBX_REQUEST_BODY}" \
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

GITHUBX_COMMIT_SHA="$(yq -Mer -p=json -o=json '.target_commitish' "${GITHUBX_DST}" 2>/dev/null)"
if [[ $? -ne 0 || "${GITHUBX_COMMIT_SHA}" != "${GITHUBX_RELEASE_SHA}" ]]; then
 echo 'Check dst error!' >&2; exit 1; fi
