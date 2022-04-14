# Generate WSL Ubuntu developement environments

Create up to date WSL2 Ubuntu distribution for offline usage.

# Import Linux distribution to use with WSL (Online machine)

It is possible to import any Linux distribution to use with WSL by obtaining its tar file using a Docker container. More [here](https://docs.microsoft.com/en-us/windows/wsl/use-custom-distro).

# Create the distribution from a Dockerfile (Online machine)

Reference from [here](https://source.coveo.com/2019/10/18/wsl-from-dockerfile/).

## Build the container (Online machine)
```console
docker build --file=Dockerfile --build-arg BASE_REGISTRY=<base registry> -t <myrepo:mytag> .
```
```
e.g. docker build --file=Dockerfile --build-arg BASE_REGISTRY=docker.io -t custom-ubuntu-bionic:bionic-20220401
```
The repository name will be `custom-ubuntu-bionic` and the tag will be `bionic-20220401`

## Export the container (Online machine)
```console
docker export $(docker create <myrepo:mytag>) --output="output/mydistro.tar"
```
```
e.g. docker export $(docker create custom-ubuntu-bionic:bionic-20220401) --output="output/Ubuntu-18.04.tar"
```
Works with `<imageid>`.

## Import the tar file into WSL (Offline machine)
```console
wsl --import <mydistro> <install location> <filename>
```
```
e.g. wsl --import Ubuntu-18.04 "c:\wslDistroStorage\Ubuntu-18.04" "output\Ubuntu-18.04.tar"
```

## To add default user

### Boot into the Linux distro
```console
wsl -d <mydistro>
```

### Create user account and set as default user (Ubuntu)
```console
myUsername=user
su -c "useradd $myUsername -s /bin/bash"
usermod -aG sudo $myUsername
echo -e "[user]\ndefault=$myUsername" >> /etc/wsl.conf
passwd $myUsername
```

### Verify default user
```console
wsl --terminate <mydistro>
wsl -d <mydistro>
```

## Remove Linux distro from WSL

To get the name for the distro
```console
wsl -l -v
```
```console
wsl --unregister <distro>
```