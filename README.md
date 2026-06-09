# GitHubx
A few GitHub scripts.

---

## Release

`0.0.1`
| [GitHub](https://github.com/StanleyProjects/GitHubx/releases/tag/0.0.1)
| [Key](https://StanleyProjects.github.io/release-public.pem)

### Build and Install

```
$ ./assemble.sh \
 && ./src/test/bash/unit_test.sh \
 && unzip -d /opt/GitHubx-0.0.1 ./build/zip/GitHubx-0.0.1.zip
```

### Download and Install

```
$ TMP_PATH="$(mktemp)"; \
 curl -L 'https://github.com/StanleyProjects/GitHubx/releases/download/0.0.1/GitHubx-0.0.1.zip' \
  -o "${TMP_PATH}" && unzip -d /opt/GitHubx-0.0.1 "${TMP_PATH}" && rm "${TMP_PATH}"
```

---
