#!/usr/local/bin/bash

if [[ $# -ne 2 ]]; then
 echo 'Wrong arguments!' >&2; exit 1; fi

GITHUBX_PAT_SRC="$1"

if [[ ! "${GITHUBX_PAT_SRC}" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]; then
 echo 'Wrong token!' >&2; exit 1
elif [[ ! -v "${GITHUBX_PAT_SRC}" ]]; then
 echo 'Token is unset!' >&2; exit 1
fi

if [[ -z "${!GITHUBX_PAT_SRC}" ]]; then
 echo 'No token!' >&2; exit 1; fi

GITHUBX_DST="$2"

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

# https://docs.github.com/en/rest/users/gpg-keys#list-gpg-keys-for-the-authenticated-user

HTTP_CODE=$(curl -m 8 -w '%{http_code}' \
 "${GITHUBX_API}/user/gpg_keys" \
 --header @<(printf 'Authorization: token %s' "${!GITHUBX_PAT_SRC}") \
 -o "${GITHUBX_DST}" 2>/dev/null); CODE=$?

if [[ ${CODE} -ne 0 ]]; then
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

GITHUBX_USER_ID="$(yq -Me -p=json -o=json '.id' "${GITHUBX_DST}" 2>/dev/null)"
if [[ $? -ne 0 || ! "${GITHUBX_USER_ID}" =~ ^[1-9][0-9]*$ ]]; then
 echo 'Check dst error!' >&2; exit 1; fi
