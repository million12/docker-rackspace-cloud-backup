# Rackspace backup agent, driveclient | Docker image
[![Circle CI](https://circleci.com/gh/million12/docker-rackspace-cloud-backup.svg?style=svg)](https://circleci.com/gh/million12/docker-rackspace-cloud-backup)

Docker image [million12/rackspace-cloud-backup]() with Rackspace cloud backup agent, driveclient.

Contains installed `driveclient`. Once you run it and provide required ENV variables (see below), in the Rackspace Cloud Panel for given server, you should see **Backup Agent: Installed** status. Now you can configure your backup routines.

Few notes:
* driveclient randomly hits Rackspace HTTP(s) error 403 which results in lack of connection with Cloud Backup. The run script tries to handle that and checks logs for `HTTP(s) error code = 403` or `Could not post an event`. If it happens, it restarts the daemon automatically. And it does so until success.
* The script handles also error 400 which indicates connection problem (make sure you run this container with `--net=host` option!), errors with agent registration (bad credentials). In case of these errors, the container exists and you must fix the issue.

See [Rackspace Cloud Backup - Install the agent on Linux](http://www.rackspace.com/knowledge_center/article/rackspace-cloud-backup-install-the-agent-on-linux) for more info.

## Usage

You will need to set the following ENV variables:  
> `API_HOST`: cloud backup API hostname for your region (check Rackspace website)  
> `API_KEY`: 32-char length API key to your account  
> `ACCOUNT_ID`: your Rackspace account ID  
> `USERNAME`: Rackspace account username

```
docker pull million12/rackspace-cloud-backup:latest

docker run \
  --name=driveclient \
  --net=host \
  -v /:/mnt/host \
  --volumes-from=some-other-container \
  --env="API_HOST=lon.backup.api.rackspacecloud.com" \
  --env="API_KEY=32lengthApiKeyFromYourRaxAccount" \
  --env="ACCOUNT_ID=01234567" \
  --env="USERNAME=account-username" \
  million12/rackspace-cloud-backup
```

## Acknowledgments

* Author: Marcin Ryzycki <marcin@m12.io>
* Development sponsored by [Megabuyte](http://megabuyte.com/)

## License

Licensed under MIT, see LICENSE.
