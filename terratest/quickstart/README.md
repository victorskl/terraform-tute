# terratest quickstart

> tl;dr – it requires running in the real cloud (e.g. AWS) account

- https://terratest.gruntwork.io/docs/getting-started/quick-start/

```bash
bash getsrc.sh
```

```
cd test
go mod init github.com/victorskl/terraform-tute/terratest/quickstart 
go get github.com/gruntwork-io/terratest@latest
go mod tidy
go test -v -timeout 30m
```

```
go test 2>&1 | tee test.log
```

## more

- https://github.com/gruntwork-io/terratest
- https://terratest.gruntwork.io/docs/
