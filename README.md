If you liked the project [docker-git2consul](https://github.com/Cimpress-MCP/docker-git2consul docker-git2consul), you'll love this. We've added suppport for more environment variables. This allows you to spin up git2consul without building a new docker images. Mearly injecting the configuration you'd like to use.

### Environment variables:

*   CFG       - to replace the git2consul config.json  
*   GIT_REPO  - to modify basic config with your git repo(basic config is listed below)  
*   NAMESPACE - specifys the namespace your objects will come up in  
*   ID        - base64 encoded string of your id_rsa key that is not password protected. (only used if using ssh for repo)  
*   IDPUB     - base64 encoded string of your id_rsa.pub  
*   CONSUL_ENDPOINT - configures what consul instance to hit  
*   CONSUL_PORT - configures what consul instance's port to hit  


### Docker Examples:
```
docker run \
        --env GIT_REPO=https://username:password@github.com/myuser/myrepo.git \
        --env NAMESPACE=config \
        --env CONSUL_ENDPOINT=192.168.0.111 \
        --env CONSUL_PORT=8500 \
        sroskelley/git2consul
```
This will download the repo https://github.com/myuser/myrepo.git and feed it into the consul server located at 192.168.0.111:8500

```
ID=$(cat ~/.ssh/id_rsa|base64)
IDPUB=$(cat ~/.ssh/id_rsa.pub|base64)
CFG='{"version":"1.0","repos":[{"name":"config","url":"git@github.com:myrepo/configs.git","source_root":"dev","mountpoint":"","branches":["master"],"include_branch_name":false,"hooks":[{"type":"polling","interval":"1"}]}]}'
docker run \
        --env CONSUL_ENDPOINT=192.168.0.111 \
        --env CONSUL_PORT=8500
        --env ID="$ID" \
        --env IDPUB="$IDPUB"\
        --env CFG="$CFG" \
        sroskelley/git2consul
```
This shows how to manually specify your own config and use ssh keys to connect to the git repo. 


Basic config embedded in this image:
```
{
 "version": "1.0",
 "repos" : [{
   "name" : "NAMESPACE",
   "url" : "GIT_REPO",
   "branches" : ["master"],
   "hooks": [{
     "type" : "polling",
     "interval" : "1"
   }]
 }]
}
```
Its very useless unless you use the NAMESPACE and GIT_REPO envronment variables. 

### Kubernetes Examples:

The 6 configs you'd need to set up a consul and its git2consul feeder. lightly borrowed some of [michael](http://www.devoperandi.com/deploying-consul-in-kubernetes/ "michael's") examples. Thanks Michael!

#### consul service definition
```
apiVersion: v1
kind: Service
metadata:
  name: consul
  labels:
    name: consul-svc
spec:
  ports:
    # the port that this service should serve on
    - name: http
      port: 8500
    - name: rpc
      port: 8400
    - name: serflan
      port: 8301
    - name: serfwan
      port: 8302
    - name: server
      port: 8300
    - name: consuldns
      port: 8600
  # label keys and values that must match in order to receive traffic for this service
  selector:
    app: consul
```

#### consul replicacontroller
```
apiVersion: v1
kind: ReplicationController
metadata:
  name: consul
spec:
  replicas: 3
  selector:
    app: consul
  template:
    metadata:
      labels:
        app: consul
    spec:
      containers:
        - name: consul
          command: [ "/bin/start", "-server", "-bootstrap-expect", "3", "-atlas", "your_user_name/consul", "-atlas-join", "-atlas-token", "yourtoken" ]
          image: progrium/consul:latest
          imagePullPolicy: Always
          ports:
          - containerPort: 8500
            name: ui-port
          - containerPort: 8400
            name: alt-port
          - containerPort: 53
            name: udp-port
          - containerPort: 443
            name: https-port
          - containerPort: 8080
            name: http-port
          - containerPort: 8301
            name: serflan
          - containerPort: 8302
            name: serfwan
          - containerPort: 8600
            name: consuldns
          - containerPort: 8300
            name: server
```

#### secrets for git2consul to connect to github
```
apiVersion: v1
kind: Secret
metadata:
  name: github
type: Opaque
data:
  idrsa: ZXZlbm1vcmVzdXBlcnNlY3JldAo=
  idrsa.pub: c3VwZXJzZWNyZXQK
```

#### git2consul replicacontroller
```
apiVersion: v1
kind: ReplicationController
metadata:
  name: git2consul
  labels:
    app: git2consul
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: git2consul
    spec:
      containers:
      - name: git2consul
        image: sroskelley/docker-git2consul:latest
        env:
        - name: ID
          valueFrom:
            secretKeyRef:
             name: github
             key: idrsa
        - name: IDPUB
          valueFrom:
            secretKeyRef:
             name: github
             key: idrsa.pub
        - name: CFG
          value: '{"version":"1.0","repos":[{"name":"config","url":"git@github.com:myrepo/myproject.git","source_root":"dev","mountpoint":"","branches":["master"],"include_branch_name":false,"hooks":[{"type":"polling","interval":"1"}]}]}'
        - name: CONSUL_ENDPOINT
          value: $(CONSUL_SERVICE_HOST)
        - name: CONSUL_PORT
          value: "8500"
```
