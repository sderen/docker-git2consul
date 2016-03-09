# Docker image for git2consul

Docker image for [git2consul](https://github.com/Cimpress-MCP/git2consul)

## Instructions

```
docker run -p 8400:8400 -p 8500:8500 -p 8600:53/udp -h node1 progrium/consul -server -bootstrap
docker run -d --name git2consul -v /etc/git2consul.d:/etc/git2consul.d cimpress/git2consul --endpoint 172.17.0.2 --port 8500
```
