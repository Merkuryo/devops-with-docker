# Docker Examples and Practical Demonstrations

## Running Your First Container

### Hello World Example

```bash
$ docker run hello-world
```

On first run:
```
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
b8dfde127a29: Pull complete
Digest: sha256:308866a43596e83578c7dfa15e27a73011bdd402185a84c5cd7f32a88b501a24
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub (amd64).
 3. The Docker daemon created a new container from that image which runs
    the executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.
```

On subsequent runs (image is cached locally):
```
$ docker run hello-world

Hello from Docker!
...
```

### Command Variations

Long form:
```bash
docker container run hello-world
```

Short form (preferred):
```bash
docker run hello-world
```

Both do exactly the same thing. The short form is more commonly used because it requires less typing.

## Listing Images

```bash
$ docker image ls
REPOSITORY      TAG      IMAGE ID       CREATED         SIZE
hello-world     latest   d1165f221234   9 days ago      13.3kB
```

Note: When you run the same image twice, you download one image and create two separate containers from it.

## Listing Containers

Only running containers:
```bash
$ docker container ls
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```

All containers (running and stopped):
```bash
$ docker container ls -a
CONTAINER ID   IMAGE           COMMAND      CREATED          STATUS                      PORTS     NAMES
b7a53260b513   hello-world     "/hello"     5 minutes ago    Exited (0) 5 minutes ago              brave_bhabha
1cd4cb01482d   hello-world     "/hello"     8 minutes ago    Exited (0) 8 minutes ago              vibrant_bell
```

Short form:
```bash
docker ps -a
```

## Removing Containers

Common mistake—trying to remove an image that has running containers:
```bash
$ docker image rm hello-world
Error response from daemon: conflict: unable to remove repository reference "hello-world" 
(must force) - container <container ID> is using its referenced image <image ID>
```

Solution: Remove containers first, then the image:
```bash
$ docker container rm brave_bhabha vibrant_bell
$ docker image rm hello-world
```

You can also use container IDs or partial IDs:
```bash
docker container rm b7a 1cd
```

## Working with Long-Running Containers

### Problem: Blocked Terminal

```bash
$ docker run nginx
# Terminal appears frozen—the container is running and output is displayed
```

Press Ctrl+C to stop the container and regain terminal control.

### Solution: Detached Mode

```bash
$ docker run -d nginx
c7749cf989f61353c1d433466d9ed6c45458291106e8131391af972c287fb0e5
```

The `-d` flag starts the container detached (in the background) and returns the container ID.

### Viewing Running Containers

```bash
$ docker container ls
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS               NAMES
c7749cf989f6        nginx               "nginx -g 'daemon of…"   35 seconds ago      Up 34 seconds       80/tcp              blissful_wright
```

## Stopping and Removing Containers

Attempting to remove a running container:
```bash
$ docker container rm blissful_wright
Error response from daemon: You cannot remove a running container c7749cf989f6... 
Stop the container before attempting removal or force remove
```

Stop the container first:
```bash
$ docker container stop blissful_wright
blissful_wright

$ docker container rm blissful_wright
blissful_wright
```

Alternatively, force removal (use with caution):
```bash
docker container rm --force blissful_wright
```

## Cleaning Up

### Remove Stopped Containers
```bash
docker container prune
```

Removes all stopped containers, freeing up space.

### Remove Dangling Images
```bash
docker image prune
```

Dangling images are images without a name that aren't used by any containers.

### Remove Everything
```bash
docker system prune
```

Cleans up containers, images, networks, and build cache. Be careful—this is aggressive.

## Important Notes

### Security Reminder

When downloading images from the internet (Docker Hub), verify you're pulling the correct image. Always double-check what you're running.

### Filtering Containers

When you have many containers, use grep to filter:
```bash
$ docker container ls -a | grep nginx
```

### Using Container Names or IDs

For most commands, you can use:
- Full container ID: `c7749cf989f61353c1d433466d9ed6c45458291106e8131391af972c287fb0e5`
- Partial ID: `c77` (must be unique)
- Container name: `blissful_wright`

All three work with `stop`, `rm`, and `exec` commands.

### Container Maintenance

Over time, the Docker daemon accumulates stopped containers and dangling images. Regular pruning keeps your system clean and frees up disk space.
