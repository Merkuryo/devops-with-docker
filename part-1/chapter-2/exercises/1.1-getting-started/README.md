# Exercise 1.1: Getting Started

This is the first practical exercise in the DevOps with Docker course. It's designed to help you get comfortable with the basic Docker commands.

## What the Exercise Asks

- Start 3 containers from an image that keeps running (nginx works well for this)
- Use detached mode so they run in background
- Stop 2 of the 3 containers
- Show the output of `docker ps -a` with the results

## Solution Approach

The key here is understanding that:
1. `docker run -d <image>` starts a container in the background
2. Each run creates a separate container, even from the same image
3. `docker stop` gracefully stops a running container
4. `docker ps -a` shows all containers regardless of state

## Things I Learned

After doing this exercise, it becomes clear that:
- Docker assigns random names to containers if you don't specify one
- The same image can run multiple times as different containers
- Containers can be managed individually even when created from the same image
- The `-d` flag is crucial when you want a container to run without blocking the terminal

## Related Commands

If you need to be more explicit with naming:
```bash
docker run -d --name web1 nginx
docker run -d --name web2 nginx
docker run -d --name web3 nginx
```

This exercise is a good foundation for understanding container lifecycle management.
