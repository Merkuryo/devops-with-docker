# Exercise 1.1: Getting Started

## Objective

Start 3 containers from an image that does not automatically exit (such as nginx) in detached mode. Stop two of the containers and leave one container running.

## Solution

### Step 1: Start three nginx containers in detached mode

```bash
docker run -d nginx
docker run -d nginx
docker run -d nginx
```

This will download the nginx image (if not already present) and start three separate containers.

### Step 2: Verify all containers are running

```bash
docker ps
```

At this point, all three containers should show as "Up".

### Step 3: Stop two of the containers

Get the container names or IDs from the previous command and stop two of them:

```bash
docker stop <container_name_1> <container_name_2>
```

For example, with our containers:
```bash
docker stop bold_faraday zen_greider
```

### Step 4: Display the final state

```bash
docker ps -a --filter ancestor=nginx
```

## Output

```
CONTAINER ID   IMAGE     COMMAND                  CREATED              STATUS                    PORTS     NAMES
e224106e17b0   nginx     "/docker-entrypoint.…"   47 seconds ago       Exited (0) 20 seconds ago           bold_faraday
8d022b680006   nginx     "/docker-entrypoint.…"   59 seconds ago       Exited (0) 21 seconds ago           zen_greider
6db23150ab14   nginx     "/docker-entrypoint.…"   About a minute ago   Up About a minute         80/tcp    crazy_wing
```

As you can see, we have:
- **2 stopped containers** (`bold_faraday` and `zen_greider` with status "Exited (0)")
- **1 running container** (`crazy_wing` with status "Up")

## Key Concepts Demonstrated

- **Detached mode (`-d`)**: Containers run in the background
- **Container lifecycle**: Starting, running, and stopping containers
- **Docker ps**: Listing containers with various filters
- **Image reuse**: The same image (nginx) can spawn multiple containers

## Cleanup

To remove the containers after the exercise:

```bash
docker container rm bold_faraday zen_greider crazy_wing
```

To remove the image:

```bash
docker image rm nginx
```
