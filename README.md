a simple vagrant file to start a microk8s cluster with argocd installed for local testing purposes

# requirements

- virtualbox
- vagrant

# howto

```
vagrant up
```

the vagrant output will display the url and the initial admin password for argocd

# argocd

example projects: <https://github.com/argoproj/argocd-example-apps>

## deploy an application on the cli
Login with argocd
```
argocd login https://<ip>
```

Create the application
```
argocd app create helm-guestbook --repo https://github.com/argoproj/argocd-example-apps.git --path helm-guestbook --dest-server https://kubernetes.default.svc --dest-namespace default
```

Sync the application
```
argocd app sync helm-guestbook
```
