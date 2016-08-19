If you liked the project https://github.com/Cimpress-MCP/docker-git2consul, you'll love this. We've added suppport for more environment variables. This allows you to spin up git2consul without building a new docker images. Mearly injecting the configuration you'd like to use.

Supports the following environment variables:
CFG       - to replace the git2consul config.json
GIT_REPO  - to modify basic config with your git repo(basic config is listed below)
NAMESPACE - specifys the namespace your objects will come up in
ID        - base64 encoded string of your id_rsa key that is not password protected. (only used if using ssh for repo)
IDPUB     - base64 encoded string of your id_rsa.pub
CONSUL_ENDPOINT - configures what consul instance to hit
CONSUL_PORT - configures what consul instance's port to hit

Examples:
```
docker run \
        --env GIT_REPO=https://username:password@github.com/myuser/myrepo.git \
        --env NAMESPACE=config \
        --CONSUL_ENDPOINT=192.168.0.111 \
        --CONSUL_PORT=8500 \
        sroskelley/git2consul
```
This will download the repo https://github.com/myuser/myrepo.git and feed it into the consul server located at 192.168.0.111:8500

```
ID=$(cat ~/.ssh/id_rsa|base64)
IDPUB=$(cat ~/.ssh/id_rsa.pub|base64)
CFG='{"version":"1.0","repos":[{"name":"config","url":"git@github.com:myrepo/configs.git","source_root":"dev","mountpoint":"","branches":["master"],"include_branch_name":false,"hooks":[{"type":"polling","interval":"1"}]}]}'
docker run \
        --CONSUL_ENDPOINT=192.168.0.111 \
        --CONSUL_PORT=8500
        --env ID="$ID" \
        --env IDPUB="$IDPUB"\
        --env CFG="$CFG" \
        sroskelley/git2consul
```
This shows how to manually specify your own config and use ssh keys to connect to the git repo. 
