# Bashx.GitHubx
A few GitHub scripts.

---

## Release

`0.0.4`
| [GitHub](https://github.com/stanbashx/Bashx.GitHubx/releases/tag/0.0.4)
| [Key](https://stanbashx.github.io/release-public.pem)

### Build and Install

```
$ ./assemble.sh \
 && ./src/test/bash/unit_test.sh \
 && unzip -d /opt/Bashx.GitHubx-0.0.4 ./build/zip/Bashx.GitHubx-0.0.4.zip
```

### Download and Install

```
$ TMP_PATH="$(mktemp)"; \
 curl -L 'https://github.com/stanbashx/Bashx.GitHubx/releases/download/0.0.4/Bashx.GitHubx-0.0.4.zip' \
  -o "${TMP_PATH}" && unzip -d /opt/Bashx.GitHubx-0.0.4 "${TMP_PATH}" && rm "${TMP_PATH}"
```

---
