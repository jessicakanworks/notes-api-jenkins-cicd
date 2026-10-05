# GitHub webhook → Jenkins multibranch pipeline

1. **Expose Jenkins** to GitHub: public IP/DNS, or for a laptop use `ngrok http 8080`.
2. **GitHub token:** Settings → Developer settings → Personal access tokens → `repo`, `admin:repo_hook`.
   Add it in Jenkins as *Username with password* (username = GitHub user, password = token), ID `github-token`.
3. **Jenkins job:** New Item → *Multibranch Pipeline* → Branch Sources → GitHub → credentials `github-token`,
   repository URL → Behaviours: *Discover branches*, *Discover pull requests from origin* → Save. Jenkins scans and
   builds every branch that has a `Jenkinsfile`.
4. **Webhook:** repository → Settings → Webhooks → Add webhook
   - Payload URL: `https://<jenkins>/github-webhook/`
   - Content type: `application/json`
   - Events: *Just the push event* (add *Pull requests* if you want PR builds)
5. **Test:** push a commit → the webhook's "Recent Deliveries" shows a 200 → the branch job starts within seconds.

Troubleshooting: 403 on the webhook = CSRF crumb issue → make sure the URL ends with `/github-webhook/`;
no build triggered = repository not matched → the multibranch job must point at the same repo URL as the webhook.
