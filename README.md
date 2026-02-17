# k8s-toolbox

k8s-toolbox: container workspace for Kubernetes-related work from Windows/WSL paths.

## Tools and versions

| Tool | Version used | What it is used for | Project link |
| --- | --- | --- | --- |
| Alpine Linux | `latest` (not pinned in `Dockerfile`) | Base image for the `k8s-toolbox` container | https://www.alpinelinux.org/ |
| Helm | `3.19.0` | Kubernetes package/chart management | https://helm.sh/ |
| Helm plugin: `helm-diff` | `latest at build time` | Show changes between Helm releases before upgrade | https://github.com/databus23/helm-diff |
| Helm plugin: `helm-unittest` | `latest at build time` | Unit tests for Helm charts | https://github.com/helm-unittest/helm-unittest |
| Helm plugin: `helm-push` | `latest at build time` | Push charts to ChartMuseum-style repositories | https://github.com/chartmuseum/helm-push |
| kubectl | `1.30.2` | Kubernetes cluster CLI | https://kubernetes.io/docs/reference/kubectl/ |
| kustomize | `v5.4.2` | Kubernetes manifest customization | https://kubectl.docs.kubernetes.io/references/kustomize/ |
| eksctl | `latest at build time` | Optional AWS EKS cluster management (not required for generic Kubernetes) | https://eksctl.io/ |
| awscli | `latest at build time` | Optional AWS CLI tooling (not required for generic Kubernetes) | https://aws.amazon.com/cli/ |
| aws-iam-authenticator | `latest at build time` | IAM authentication for Kubernetes on AWS | https://github.com/kubernetes-sigs/aws-iam-authenticator |
| kubeseal | `0.26.2` | Encrypt Kubernetes Secrets for Sealed Secrets | https://github.com/bitnami-labs/sealed-secrets |
| vals | `0.37.3` | Pull secrets/values from secret backends for templating workflows | https://github.com/helmfile/vals |
| krew | `0.4.4` | kubectl plugin manager | https://krew.sigs.k8s.io/ |
| kubeconform | `0.6.6` | Fast Kubernetes manifest validation | https://github.com/yannh/kubeconform |
| jq | Alpine package (`latest at build time`) | JSON processing in scripts | https://jqlang.org/ |
| yq | Alpine package (`latest at build time`) | YAML processing in scripts | https://github.com/mikefarah/yq |
| kubectx | Alpine package (`latest at build time`) | Quick kubeconfig context/namespace switching | https://github.com/ahmetb/kubectx |
| Docker (host) | Host-installed | Build and run the container | https://www.docker.com/ |

Notes:
- Pinned versions are controlled by `ARG` values in `Dockerfile`.
- Some tools/plugins are intentionally installed from latest release at build time (not pinned).

## Build image

```bash
docker build -t k8s-toolbox .
```

## GitHub Actions

Repository includes CI workflow: `.github/workflows/build-image.yml`.

It runs Docker build on:
- push to `main` (when `Dockerfile` or workflow changes),
- pull requests (when `Dockerfile` or workflow changes),
- manual trigger (`workflow_dispatch`).

Image publish behavior:
- `pull_request`: build only (no push),
- `push` to `main` and `workflow_dispatch`: build and push to GHCR.

Published image:
- `ghcr.io/ejaszke/k8s-toolbox:latest` (default branch),
- `ghcr.io/ejaszke/k8s-toolbox:main` (branch tag),
- `ghcr.io/ejaszke/k8s-toolbox:sha-<full-git-sha>` (commit tag).

Published tarball artifact:
- For `push` to `main` and `workflow_dispatch`, workflow also exports
  `k8s-toolbox-<full-git-sha>.tar.gz`.
- Artifact name in GitHub Actions UI: `k8s-toolbox-image-tar`.
- Download it from the specific workflow run page.

Published WSL rootfs artifact:
- For `push` to `main` and `workflow_dispatch`, workflow also exports
  `k8s-toolbox-wsl-rootfs-<full-git-sha>.tar.gz`.
- Artifact name in GitHub Actions UI: `k8s-toolbox-wsl-rootfs`.
- Use it with `wsl --import` to run toolbox without Docker runtime.

Pull image from registry:

```bash
docker pull ghcr.io/ejaszke/k8s-toolbox:latest
```

Load image from downloaded tarball:

```bash
gunzip -c k8s-toolbox-<full-git-sha>.tar.gz | docker load
docker image ls | grep k8s-toolbox
```

Optional: override pinned versions during build:

```bash
docker build --no-cache \
  --build-arg KUBECTL_VERSION=1.30.2 \
  --build-arg HELM_VERSION=3.19.0 \
  --build-arg KUSTOMIZE_VERSION=v5.4.2 \
  -t k8s-toolbox .
```

## Run container (sample)

```bash
docker run -it -v /mnt/c/Users/<host-user>:/root -v ${PWD}:/work -w /work --net host k8s-toolbox
```

## Mounting under WSL (with Docker Desktop)

You do not need Docker Engine installed inside WSL distro.
Use Docker Desktop on Windows and enable WSL integration for your distro.

Basic check in WSL:

```bash
docker version
docker context ls
```

From WSL terminal, run from project directory (local build image):

```bash
docker run -it \
  -v /mnt/c/Users/<host-user>:/root \
  -v "$(pwd)":/work \
  -w /work \
  --net host \
  k8s-toolbox
```

From WSL terminal, run published image from GHCR:

```bash
docker run -it \
  -v /mnt/c/Users/<host-user>:/root \
  -v "$(pwd)":/work \
  -w /work \
  --net host \
  ghcr.io/ejaszke/k8s-toolbox:latest
```

From WSL terminal, run image loaded from Actions tarball:

```bash
docker run -it \
  -v /mnt/c/Users/<host-user>:/root \
  -v "$(pwd)":/work \
  -w /work \
  --net host \
  ghcr.io/ejaszke/k8s-toolbox:sha-<full-git-sha>
```

From Windows PowerShell (Docker Desktop):

```powershell
docker run -it --rm `
  -v C:\Users\<host-user>:/root `
  -v ${PWD}:/work `
  -w /work `
  ghcr.io/ejaszke/k8s-toolbox:latest
```

If your repo is in Linux home (for example `/home/<wsl-user>/...`), keep the same command in WSL and use `$(pwd)` for `/work`.

Recommended check after start:

```bash
pwd
ls -la /work
ls -la /root/.kube
```

## WSL portable (without Docker)

Use this flow if you want to run toolbox directly as a WSL distro, without Docker runtime.

### 1. Download artifact

From GitHub Actions run, download artifact:
- `k8s-toolbox-wsl-rootfs`

### 2. Unpack `.tar.gz` to `.tar`

From WSL or Git Bash:

```bash
gunzip -c k8s-toolbox-wsl-rootfs-<full-git-sha>.tar.gz > k8s-toolbox-wsl-rootfs-<full-git-sha>.tar
```

### 3. Import as WSL distro

From Windows PowerShell:

```powershell
$DistroName = "k8s-toolbox-portable"
$InstallDir = "C:\WSL\k8s-toolbox-portable"
New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
wsl --import $DistroName $InstallDir .\k8s-toolbox-wsl-rootfs-<full-git-sha>.tar --version 2
```

### 4. Start and use toolbox

```powershell
wsl -d k8s-toolbox-portable
```

Example start in project path:

```powershell
wsl -d k8s-toolbox-portable --cd /mnt/c/Users/<host-user>/keys/k8s
```

Inside distro you use tools directly (`kubectl`, `helm`, `kustomize`) without `docker run`.

### 5. Update or remove

Update to newer build:
1. `wsl --unregister k8s-toolbox-portable`
2. import again with new rootfs tar.

Remove distro:

```powershell
wsl --unregister k8s-toolbox-portable
```

## Where to store cluster keys/config

Because `/mnt/c/Users/<host-user>` is mounted to `/root`, keep cluster credentials on the host in:

- `/mnt/c/Users/<host-user>/.kube/config` (main kubeconfig)
- `/mnt/c/Users/<host-user>/.kube/` (certificates/keys referenced by kubeconfig)
- `/mnt/c/Users/<host-user>/.ssh/` (optional SSH keys, if needed by your workflow)

Inside the container these are available as:

- `/root/.kube/config`
- `/root/.kube/`
- `/root/.ssh/`

## Kubernetes access configuration

### 1. Use default kubeconfig path

`kubectl` reads `/root/.kube/config` by default in this container, so the host file:

- `/mnt/c/Users/<host-user>/.kube/config`

is automatically used when you start the container with:

```bash
docker run -it -v /mnt/c/Users/<host-user>:/root -v ${PWD}:/work -w /work --net host k8s-toolbox
```

### 2. Use custom kubeconfig file (optional)

If you keep configs in multiple files, set `KUBECONFIG`:

```bash
export KUBECONFIG=/root/.kube/config:/work/kubeconfigs/dev.yaml
kubectl config get-contexts
```

### 3. Add your own cluster config

Place your cluster kubeconfig at:

- `/mnt/c/Users/<host-user>/.kube/config`

or merge it into that file if you use multiple clusters/contexts.

### 4. Switch context and verify access

```bash
kubectl config get-contexts
kubectl config use-context <context-name>
kubectl cluster-info
kubectl get nodes
```

## How to get access

Use this flow when your Kubernetes admin gives access via client certificate (key + CSR).

### 1. Generate private key and CSR

```bash
mkdir -p /mnt/c/Users/<host-user>/.kube/users/<user-name>
openssl genrsa -out /mnt/c/Users/<host-user>/.kube/users/<user-name>/<user-name>.key 4096
openssl req -new \
  -key /mnt/c/Users/<host-user>/.kube/users/<user-name>/<user-name>.key \
  -out /mnt/c/Users/<host-user>/.kube/users/<user-name>/<user-name>.csr \
  -subj "/CN=<user-name>/O=<group-name>"
```

`CN` should be your Kubernetes username. `O` should be the RBAC group expected by admin (for example `developers`, `readonly`, or another team group).

### 2. Send request to Kubernetes admin

Send:
- `/mnt/c/Users/<host-user>/.kube/users/<user-name>/<user-name>.csr` file content (or file itself).
- Requested username (`CN`) and group (`O`).
- Required access scope (cluster-wide or specific namespaces).
- Required permissions (read-only, deploy, admin in namespace, etc.).

### 3. Receive files/details from admin

Ask admin to return:
- Signed user certificate (for example `<user-name>.crt`).
- Cluster API server URL (for example `https://api.example-cluster:6443`).
- Cluster CA certificate (`ca.crt`) if not already provided in existing kubeconfig.
- Cluster/context naming they want you to use (optional but recommended).

### 4. Build kubeconfig

```bash
kubectl config set-cluster <cluster-name> \
  --server=<api-server-url> \
  --certificate-authority=/mnt/c/Users/<host-user>/.kube/ca.crt

kubectl config set-credentials <user-name> \
  --client-certificate=/mnt/c/Users/<host-user>/.kube/users/<user-name>/<user-name>.crt \
  --client-key=/mnt/c/Users/<host-user>/.kube/users/<user-name>/<user-name>.key

kubectl config set-context <context-name> \
  --cluster=<cluster-name> \
  --user=<user-name> \
  --namespace=<namespace>

kubectl config use-context <context-name>
```

### 5. Verify access

```bash
kubectl auth whoami
kubectl auth can-i get pods -A
kubectl get ns
```

### 6. Security guidance

- Keep private keys and kubeconfig only under `/mnt/c/Users/<host-user>/.kube` and `/mnt/c/Users/<host-user>/.ssh`.
- Restrict file permissions on host credentials.
- Do not commit kubeconfig or private keys into this repository.

## Contributing

Contribution and commit conventions are documented in `CONTRIBUTING.md`.
Use Conventional Commits for all commit messages in this repository.
