a vagrant config to start a microk8s cluster for local testing purposes.

The following features are available:
* tekton
* argocd
* kubernetes dashboard

# requirements

- virtualbox
- vagrant

# howto

```
vagrant up
```

the vagrant output will display the url and the initial admin password for argocd

## Kubernetes dashboard:

Open the url provided by the vagrant output.

Login with the token provided by the vagrant output.

## argocd

example projects: <https://github.com/argoproj/argocd-example-apps>

### deploy an application on the cli
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
