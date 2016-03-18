# docker-git2consul

Docker image for [git2consul](https://github.com/Cimpress-MCP/git2consul)


## Instructions

This image will run `config_seeder.js` using the first alphabetically JSON file found on `/etc/git2consul.d` if one exists.

If using webhooks, you will have to expose the ports that are going to be used.

## Up and running

```bash
$ cat <<EOF > /tmp/git2consul.d/config.json
{
  "version": "1.0",
  "repos" : [{
    "name" : "sample_configuration",
    "url" : "https://github.com/ryanbreen/git2consul_data.git",
    "branches" : ["dev"],
    "hooks": [{
      "type" : "polling",
      "interval" : "1"
    }]
  }]
}
EOF

$ docker run -d -p 8400:8400 -p 8500:8500 -p 8600:53/udp -h node1 --name consul progrium/consul -server -bootstrap
$ CONSUL_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' consul)
$ docker run -d --name git2consul -v /tmp/git2consul.d:/etc/git2consul.d cimpress/git2consul --endpoint $CONSUL_IP --port 8500 --config-file /etc/git2consul.d/config.json
```

*Note: If using docker-machine, you will need to place `config.json` in the host VM.*
