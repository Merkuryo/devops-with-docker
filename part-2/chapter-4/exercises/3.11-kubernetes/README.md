# Exercise 3.11: Kubernetes - Complete Diagram Guide

## Overview

This exercise requires creating a comprehensive Kubernetes architecture diagram showing:
- At least 3 host machines in a cluster
- 2 applications running
- kubectl commands from your computer
- HTTP traffic from the internet
- Key Kubernetes components labeled

## Kubernetes Terminology & Architecture

### Core Concepts

**Cluster**: The entire Kubernetes infrastructure consisting of multiple nodes managed together as a single system.

**Node**: A physical or virtual machine that runs containers. Two types:
- Master/Control Plane Node: Manages the cluster
- Worker Node: Runs application containers

**Pod**: The smallest deployable unit in Kubernetes. Contains one or more containers (usually one). Pods are ephemeral and can be created/destroyed frequently.

**Container**: The Docker container running inside a Pod.

**Service**: An abstraction that exposes Pods to the network. Routes traffic to Pods and provides load balancing.

**Volume**: Persistent storage for Pods. Survives Pod restarts.

**Deployment**: A controller that manages Pod replicas, updates, and rollbacks.

**Namespace**: Logical subdivision of the cluster for resource isolation.

**Labels**: Key-value pairs for organizing and selecting Pods/Services.

**Replica Set**: Ensures a specified number of Pod replicas are running.

## Diagram Structure

### Required Elements

Your diagram MUST include:

1. **Your Computer** (with kubectl client)
   - Shows your machine sending commands to the Kubernetes API Server
   - Example: `kubectl apply -f deployment.yaml`

2. **Kubernetes Cluster** (at least 3 nodes)
   - **Master/Control Plane Node** (1)
     - API Server
     - Scheduler
     - Controller Manager
     - etcd (data store)
   - **Worker Nodes** (at least 2)
     - Container Runtime (Docker)
     - Kubelet
     - kube-proxy
     - Pods running applications

3. **Two Applications**
   - Example: Blog Website + Game Server
   - Each should have multiple Pods for redundancy

4. **Services**
   - LoadBalancer Service for public access
   - ClusterIP Service for internal communication

5. **Internet Traffic**
   - HTTP request from internet → LoadBalancer Service → Pods

6. **Volumes** (optional but recommended)
   - Persistent storage for databases or uploads
   - Shows data persistence across Pod restarts

## Step-by-Step Diagram Creation (draw.io)

### Step 1: Create Kubernetes Cluster Box

1. Go to [draw.io](https://www.draw.io/)
2. Create new diagram
3. Add large rectangle labeled "Kubernetes Cluster"
4. Add smaller rectangles for each node inside

### Step 2: Add Master Node

```
┌─ Master Node ────────────────────┐
│  - API Server                    │
│  - Scheduler                     │
│  - Controller Manager            │
│  - etcd (Persistent Data)        │
└──────────────────────────────────┘
```

### Step 3: Add Worker Node 1

```
┌─ Worker Node 1 ──────────────────┐
│  - Kubelet                       │
│  - kube-proxy                    │
│  - Container Runtime (Docker)    │
│                                  │
│  ┌─ Pod 1 (Blog Backend) ───┐  │
│  │ ┌─ Container ────────┐  │  │
│  │ │ Node.js App        │  │  │
│  │ └────────────────────┘  │  │
│  └────────────────────────┘  │
│                              │
│  ┌─ Pod 2 (Blog Database) ──┐ │
│  │ ┌─ Container ────────┐  │ │
│  │ │ PostgreSQL         │  │ │
│  │ └────────────────────┘  │ │
│  └────────────────────────┘ │
└──────────────────────────────┘
```

### Step 4: Add Worker Node 2

```
┌─ Worker Node 2 ──────────────────┐
│  - Kubelet                       │
│  - kube-proxy                    │
│  - Container Runtime (Docker)    │
│                                  │
│  ┌─ Pod 3 (Game Server) ─────┐  │
│  │ ┌─ Container ────────┐    │  │
│  │ │ Go Game Engine     │    │  │
│  │ └────────────────────┘    │  │
│  └─────────────────────────┘  │
│                               │
│  ┌─ Pod 4 (Game Server) ─────┐ │
│  │ ┌─ Container ────────┐    │ │
│  │ │ Go Game Engine     │    │ │
│  │ └────────────────────┘    │ │
│  └─────────────────────────┘ │
└──────────────────────────────┘
```

### Step 5: Add Services

```
┌─ LoadBalancer Service (Blog) ─┐
│  Port 80 → Pod 1 (Port 3000)   │
└────────────────────────────────┘

┌─ ClusterIP Service (Database) ┐
│  Port 5432 → Pod 2 (Port 5432) │
└────────────────────────────────┘

┌─ LoadBalancer Service (Game) ──┐
│  Port 9000 → Pod 3,4 (Port 8080)│
└────────────────────────────────┘
```

### Step 6: Add Your Computer

```
┌─────────────────────────────┐
│     YOUR COMPUTER           │
│  ┌──────────────────────┐  │
│  │ kubectl CLI          │  │
│  │ $ kubectl apply -f   │  │
│  │   deployment.yaml    │  │
│  └──────────────────────┘  │
└─────────────────────────────┘
        │
        │ (HTTPS API calls)
        ▼
    [API Server on Master Node]
```

### Step 7: Add Internet Traffic

```
        ┌─ Internet ─┐
        │ HTTP/HTTPS │
        └─────┬──────┘
              │
              ▼
    ┌─ LoadBalancer Service ─┐
    │  (Port 80, Port 9000)   │
    └───────────┬─────────────┘
                │
       ┌────────┴────────┐
       ▼                 ▼
   [Pod 1]           [Pod 3/4]
   (Blog)            (Game)
```

## Example Kubernetes Diagram Structure

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  YOUR COMPUTER                                                  │
│  ┌──────────────────┐                                           │
│  │  kubectl client  │                                           │
│  │  (you)           │                                           │
│  └────────┬─────────┘                                           │
│           │ HTTPS API calls                                     │
│           ▼                                                     │
│  ╔═══════════════════════════════════════════════════════════╗ │
│  ║        KUBERNETES CLUSTER                                ║ │
│  ║                                                           ║ │
│  ║  ┌─────────────────────────────────────────────────────┐ ║ │
│  ║  │         MASTER NODE (Control Plane)                │ ║ │
│  ║  │  ┌──────────────────────────────────────────────┐  │ ║ │
│  ║  │  │ API Server                                   │  │ ║ │
│  ║  │  │ Scheduler                                    │  │ ║ │
│  ║  │  │ Controller Manager                           │  │ ║ │
│  ║  │  │ etcd (Cluster Data Store)                   │  │ ║ │
│  ║  │  └──────────────────────────────────────────────┘  │ ║ │
│  ║  └─────────────────────────────────────────────────────┘ ║ │
│  ║                                                           ║ │
│  ║  ┌──────────────────────────┐ ┌─────────────────────────┐ ║ │
│  ║  │    WORKER NODE 1         │ │   WORKER NODE 2        │ ║ │
│  ║  │                          │ │                         │ ║ │
│  ║  │ Kubelet, kube-proxy      │ │ Kubelet, kube-proxy    │ ║ │
│  ║  │ Docker Runtime           │ │ Docker Runtime         │ ║ │
│  ║  │                          │ │                         │ ║ │
│  ║  │ ┌──────────────────────┐ │ │ ┌──────────────────┐   │ ║ │
│  ║  │ │ POD: Blog Backend    │ │ │ │ POD: Game Srv 1 │   │ ║ │
│  ║  │ │ ┌────────────────┐   │ │ │ │ ┌──────────────┐│   │ ║ │
│  ║  │ │ │ CONTAINER      │   │ │ │ │ │ CONTAINER  ││   │ ║ │
│  ║  │ │ │ Node.js App    │   │ │ │ │ │ Go Binary  ││   │ ║ │
│  ║  │ │ └────────────────┘   │ │ │ │ └──────────────┘│   │ ║ │
│  ║  │ └──────────────────────┘ │ │ └──────────────────┘   │ ║ │
│  ║  │                          │ │                         │ ║ │
│  ║  │ ┌──────────────────────┐ │ │ ┌──────────────────┐   │ ║ │
│  ║  │ │ POD: Blog Database   │ │ │ │ POD: Game Srv 2 │   │ ║ │
│  ║  │ │ ┌────────────────┐   │ │ │ │ ┌──────────────┐│   │ ║ │
│  ║  │ │ │ CONTAINER      │   │ │ │ │ │ CONTAINER  ││   │ ║ │
│  ║  │ │ │ PostgreSQL     │   │ │ │ │ │ Go Binary  ││   │ ║ │
│  ║  │ │ └────────────────┘   │ │ │ │ └──────────────┘│   │ ║ │
│  ║  │ └──────────────────────┘ │ │ └──────────────────┘   │ ║ │
│  ║  └──────────────────────────┘ └─────────────────────────┘ ║ │
│  ║                                                           ║ │
│  ║  ┌───────────────────────────────────────────────────────┐ ║ │
│  ║  │ SERVICES                                              │ ║ │
│  ║  │                                                        │ ║ │
│  ║  │ LoadBalancer Service: blog.example.com:80            │ ║ │
│  ║  │   → Routes to Blog Backend Pod (port 3000)           │ ║ │
│  ║  │                                                        │ ║ │
│  ║  │ ClusterIP Service: blog-db                           │ ║ │
│  ║  │   → Routes to Blog Database Pod (port 5432)          │ ║ │
│  ║  │                                                        │ ║ │
│  ║  │ LoadBalancer Service: game.example.com:9000          │ ║ │
│  ║  │   → Routes to Game Server Pods (port 8080)           │ ║ │
│  ║  └───────────────────────────────────────────────────────┘ ║ │
│  ║                                                           ║ │
│  ║  ┌───────────────────────────────────────────────────────┐ ║ │
│  ║  │ VOLUME (Persistent Storage)                           │ ║ │
│  ║  │   - Blog Database Storage (PostgreSQL data)          │ ║ │
│  ║  │   - Game Server Leaderboards (Redis)                │ ║ │
│  ║  └───────────────────────────────────────────────────────┘ ║ │
│  ╚═══════════════════════════════════════════════════════════╝ │
│           ▲                    ▲                                │
│           │                    │                                │
└───────────┼────────────────────┼────────────────────────────────┘
            │                    │
            │                    └── Internal K8s
            │                       Communication
            │
            └── kubectl commands
                (deploy, scale, update)


        ┌──────────────────┐
        │   INTERNET       │
        │ (HTTP/HTTPS)     │
        └────────┬─────────┘
                 │
                 ▼ (DNS lookup: blog.example.com)
        ┌────────────────────────┐
        │ LoadBalancer Service   │
        │ (Exposed to internet)  │
        └────────┬───────────────┘
                 │
         ┌───────┴───────┐
         ▼               ▼
    [Pod 1]         [Pod 1b]
    (Blog)          (Blog)
   :3000/          :3000/
```

## Kubernetes Components to Label

Your diagram MUST include at least 4 of these labels:

1. **Pod** ✓ (Required to show)
   - Smallest unit, contains containers
   - Show multiple Pods for each application

2. **Cluster** ✓ (Required to show)
   - Everything inside the Kubernetes system
   - Put a large box around all nodes and services

3. **Container** ✓ (Required to show)
   - Docker containers running inside Pods
   - Show inside Pod boxes

4. **Service** ✓ (Required to show)
   - LoadBalancer and ClusterIP services
   - Show routing between Services and Pods

5. **Volume** (Optional but recommended)
   - Persistent storage for databases
   - Show attached to Pods

## Applications to Show

### Option 1: Blog Website + Game Server

**Blog Website**:
- Frontend: React Pod
- Backend: Node.js Pod
- Database: PostgreSQL Pod
- Storage: Database volume

**Game Server**:
- Game Engine: Go Pod (2 replicas for load balancing)
- Cache: Redis Pod
- Storage: Leaderboard volume

### Option 2: Web Store + API Service

**Web Store**:
- Frontend: React Pod
- Backend: Python Pod
- Database: MongoDB Pod

**API Service**:
- API Server: Java Pod (2 replicas)
- Cache: Memcached Pod

### Option 3: Microservices (Recommended)

**Application 1: User Service**
- User API Pod
- User Database Pod
- User Session Cache Pod

**Application 2: Payment Service**
- Payment API Pod
- Payment Database Pod
- External API calls

## Traffic Flow to Show

### Your Computer to Cluster

```
Your Computer
    │
    │ kubectl apply -f deployment.yaml
    │ (HTTPS API call)
    ▼
[API Server]
    │
    │ Scheduler deploys Pods
    ▼
[Worker Nodes]
    │
    └─► [Pods start running]
```

### Internet to Application

```
Internet User
    │
    │ HTTP GET blog.example.com
    ▼
[DNS: resolves to LoadBalancer IP]
    │
    ▼
[LoadBalancer Service]
    │
    │ Route traffic (load balancing)
    │
    ├─► [Pod 1 - Blog Backend]
    │
    └─► [Pod 2 - Blog Backend]
            │
            │ (queries)
            ▼
        [Pod 3 - Blog Database]
```

## Required Labels Checklist

Your diagram MUST include labels for:
- [ ] Pod (with container inside)
- [ ] Cluster (large encompassing box)
- [ ] Container (inside Pods)
- [ ] Service (LoadBalancer, ClusterIP)
- [ ] Volume (optional, attached to Pods)

At least 4 of these 5 required.

## Additional Elements (Recommended)

- Node names (Master, Worker-1, Worker-2)
- Application names (Blog, GameServer)
- Port numbers (80, 3000, 5432, 8080, etc.)
- Arrows showing traffic flow
- Legend/key explaining symbols
- Namespace boundaries (optional)
- Replica counts (e.g., "2 replicas" for Game Server)

## How to Submit

1. Create diagram on draw.io
2. Save to shareable link
3. Share link in exercise submission
4. Ensure diagram clearly shows:
   - 3+ host machines
   - 2 applications
   - Your computer with kubectl
   - HTTP traffic from internet
   - 4+ Kubernetes component labels

## Important Notes

- Keep it clear and readable
- Use consistent shapes (rectangles for nodes, smaller boxes for Pods)
- Color-code different components (optional but helpful)
- Show all connections with arrows
- Label everything clearly
- Make it understandable to someone who completed this course

## Kubernetes Glossary Reference

[Kubernetes Glossary](https://kubernetes.io/docs/reference/glossary/)

Key terms to understand:
- **Pod**: Smallest deployable unit (wraps containers)
- **Deployment**: Declares desired state (number of replicas)
- **Service**: Exposes Pods to network (load balancing)
- **Ingress**: HTTP/HTTPS routing rules
- **Volume**: Storage that persists beyond Pod lifetime
- **Namespace**: Virtual cluster subdivision
- **Node**: Physical/virtual machine running Pods
- **Cluster**: All nodes managed together
- **etcd**: Key-value store with cluster data
- **API Server**: Central control point (REST API)
- **Scheduler**: Assigns Pods to Nodes
- **Controller Manager**: Runs controller processes

## Example Diagram Resources

- [Kubernetes Architecture](https://kubernetes.io/docs/concepts/architecture/)
- [Components of Kubernetes](https://kubernetes.io/docs/concepts/overview/components/)
- [Kubernetes Services](https://kubernetes.io/docs/concepts/services-networking/service/)

## Tips for Drawing

1. Start with the cluster boundary
2. Add master node (top/center)
3. Add worker nodes (bottom)
4. Add Pods inside worker nodes
5. Add Services connecting Pods
6. Add Volume storage
7. Add your computer outside cluster
8. Add internet entry point
9. Draw arrows for traffic flow
10. Label everything clearly

This will create a comprehensive diagram showing how Kubernetes orchestrates containers across multiple hosts!
