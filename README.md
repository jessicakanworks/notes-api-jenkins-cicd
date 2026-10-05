# notes-api-jenkins-cicd

CI/CD for [notes-api](../notes-api): a **Jenkins multibranch pipeline** driven by a `Jenkinsfile` and triggered by **GitHub webhooks**, which tests, builds a Docker image, pushes it to a registry and deploys to a server over SSH with automatic rollback.

```
GitHub push ──webhook──► Jenkins ──► checkout → test → build image → push → deploy (main only)
```

## What's here
| File | Purpose |
|---|---|
| `Jenkinsfile` | declarative pipeline, stages below, credentials via Jenkins credential store |
| `jenkins/Dockerfile` | Jenkins LTS with Docker CLI so the agent can build images |
| `jenkins/docker-compose.yml` | run Jenkins locally with Docker socket mounted |
| `docs/webhook-setup.md` | GitHub webhook + Jenkins multibranch configuration, step by step |
| `scripts/deploy.sh` | what the deploy stage runs on the target host |

## Stages
1. **Checkout** – multibranch scan picks up every branch and PR.
2. **Test** – `pytest` inside a `python:3.12` container (no Python on the agent needed).
3. **Build** – `docker build`, tag `<branch>-<build>` and `<git sha>`.
4. **Push** – login with `registry-creds` credential, push both tags.
5. **Deploy** – only on `main`: SSH to the server, pull, `docker compose up -d`, health-check.

## Run Jenkins locally
```bash
cd jenkins && docker compose up -d
# http://localhost:8080 → unlock with: docker compose exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```
Then: New Item → Multibranch Pipeline → Git source = this repo → scan.

## Jenkins credentials used
| ID | Type | Used for |
|---|---|---|
| `registry-creds` | username/password | docker login |
| `deploy-ssh-key` | SSH private key | ssh to the target host |
| `github-token` | secret text | webhook / status updates |

