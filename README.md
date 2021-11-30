# Remote dev container

Dev container with pub key ssh access

This container is mostly created to let IDEs be able to connect to a container powerful cluster to let a developer work without headphones on a head 🙉 100% times

Originally designed for [Jetbrains Gateway](https://www.jetbrains.com/remote-development/gateway/) evaluation on K8S

[![](https://www.jetbrains.com/remote-development/gateway/img/gateway-icon.svg)](https://www.jetbrains.com/remote-development/gateway/)

Test locally

```bash
pub=$(cat ~/.ssh/id_rsa.pub)
docker run --rm -it -p 2222:22 -e PUBLIC_KEY="$pub" --name gate j0rsa/remove-dev
ssh-keygen -R "[localhost]:2222"
ssh user@localhost -P 2222
```