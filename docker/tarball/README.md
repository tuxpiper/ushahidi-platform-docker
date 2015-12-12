# Ushahidi Platfrom release package

## Run on Docker

*Requirements*

* Docker Compose

*Procedure*

1. Create a `.github_token` file containing a token generated with your github account
    * See instructions for generating the token [here](https://help.github.com/articles/creating-an-access-token-for-command-line-use/))
1. Edit `docker-compose.yml`
    * You may adjust port `8000` to whatever port of your choice (leave the `80` alone)
    * Ensure the `ACCESS_URL` variable points to the IP of your docker engine server, and the port of your choice
1. Start with `docker-compose up`
1. Open your site at the configured `ACCESS_URL`
1. Login using the default credentials: `admin` / `admin`

## Run on (insert your popular host here)

1. database setup
1. composer setup
1. running the migrations
1. config.js adjustment
1. apache config
  1. virtual host config
  1. htaccess config
1. ensuring writable folders
  * cache
  * logs
1. set up cron jobs

# TODO

* Docker cron jobs runner

