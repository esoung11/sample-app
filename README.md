# sample-app

> The smallest possible app, used to build and prove my self-hosted CI/CD
> pipeline before anything real ran on it. The "app" is a three-line bash script;
> the pipeline around it is the point.

**Status:** complete, kept as a record of stages 02–03. The real workload is now
[`ledger-api`](https://github.com/esoung11/ledger-api), deployed via
[`platform`](https://github.com/esoung11/platform).

## What the pipeline does
Runs on self-hosted GitLab CE with a self-hosted runner (Docker executor):

| Stage | Job | What it proves |
|---|---|---|
| lint | `shellcheck` on both scripts | Static analysis as a merge gate |
| test | `test_hello.sh` checks the exact output | A failing test blocks the merge |
| build | Packages the script as a `.tar.gz` artifact | CI artifacts, downloadable per pipeline |
| dockerize | Builds an image and pushes it to the GitLab registry | Container builds in CI |

Merges to `main` require a green pipeline (branch protection + merge check).

## Image tagging
- Every pipeline pushes `sample-app:<short-sha>`: an immutable tag that maps
  straight back to the commit that built it.
- Only `main` also moves `:latest`, so feature branches can never overwrite it.
- The registry login uses the pipeline's per-job token (`CI_REGISTRY_PASSWORD`),
  which expires with the job. No long-lived secret is stored in CI.

## Trade-offs I'd change for production
- **Privileged Docker-in-Docker:** the build job needs a privileged runner, which
  can reach the host. Kaniko or Buildah build images without a privileged daemon;
  this is next on the roadmap.
- **Plain-HTTP registry:** acceptable inside an isolated lab network; production
  needs TLS (Docker refuses plaintext registries by default for good reason).

## Why it never ran on Kubernetes
`hello.sh` prints one line and exits. A Kubernetes Deployment expects a
long-running process, so it would restart the container forever
(`CrashLoopBackOff`). That's why the cluster runs `ledger-api`, a real HTTP
service with health checks, instead.

## Run it
```bash
./test_hello.sh                      # PASS
docker build -t sample-app . && docker run --rm sample-app
```
