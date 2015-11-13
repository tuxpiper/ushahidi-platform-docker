*WARNING: this project is using unstable versions of Ushahidi, so functionality
is bound to break sometimes. There will be stable releases in the near future.*

# Docker environments for Ushahidi Platform

Try out or start developing on the Ushahidi Platform without the setup hassle!

Works on:

* Linux , requires:
  * Docker Compose
  * Docker Engine

* OS X
  * Docker Toolbox recommended

Haven't really tried, but it may be possible to make it work:

* Windows
  * cygwin required with bash and standard unix tools
  * Docker Toolbox recommended

## Support note / Disclaimer

Although I am involved with Ushahidi, this is not an officially supported
method for setting up the Platform. If you find a problem with this specific
installer, please open an issue in this github repo, I'll see what I can do!

The officially supported install methods can be found here:

https://www.ushahidi.com/support/install-ushahidi

## Run it

If all you want to do is try out the Ushahidi platform, please run

    ./ush-docker.sh run

This will download docker images and set them running. We've made the images
super small for you, the total download shouldn't be more than 200 MB.

## Develop on it

... coming soon ...
