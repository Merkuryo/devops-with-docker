# Exercise 3.11: Kubernetes - Diagram Submission

## Submitted Diagram URL

```
https://drive.google.com/file/d/1SzL4xv8_3y7sH19wGriWMqT3kawV0VsN/view?usp=sharing
```

## Diagram Contents

The diagram shows a comprehensive Kubernetes architecture including:

### ✅ Required Components

1. **Kubernetes Cluster** - Main boundary containing all resources
2. **Master Node (Control Plane)** - Managing the cluster
   - API Server
   - Scheduler
   - Controller Manager
   - etcd (data store)

3. **Worker Nodes** - At least 2 nodes running applications
   - Kubelet
   - kube-proxy
   - Container Runtime

4. **Pods** - Smallest Kubernetes units containing containers
   - Multiple Pods shown across worker nodes

5. **Containers** - Docker containers running inside Pods

6. **Services** - Network abstraction for traffic routing
   - LoadBalancer Services (external access)
   - ClusterIP Services (internal access)

7. **Volumes** - Persistent storage for applications

8. **Your Computer** - kubectl client sending commands to cluster

9. **Internet Traffic** - HTTP requests from external users reaching applications

### 🎯 Applications Shown

1. **Application 1**: Blog Website
   - Backend Pods
   - Database Pod
   - Persistent Volume

2. **Application 2**: Game Server
   - Multiple Server Pods (for load balancing)
   - Leaderboard/Cache
   - Persistent Storage

### 📊 Architecture Overview

```
User's Computer (kubectl)
    ↓
Kubernetes Cluster
├── Master Node (Control Plane)
│   ├── API Server
│   ├── Scheduler
│   ├── Controller Manager
│   └── etcd
│
├── Worker Node 1
│   ├── Pod: Blog Backend → Container (Node.js)
│   ├── Pod: Blog Database → Container (PostgreSQL)
│   └── Volume (Storage)
│
├── Worker Node 2
│   ├── Pod: Game Server 1 → Container (Go)
│   ├── Pod: Game Server 2 → Container (Go)
│   └── Volume (Leaderboard)
│
└── Services
    ├── LoadBalancer (Blog) → Port 80
    ├── LoadBalancer (Game) → Port 9000
    └── ClusterIP (Internal) → Port 5432

Internet
    ↓ HTTP Request
LoadBalancer Service
    ↓ Routes
[Pods receiving traffic]
```

### ✨ Labels Included

- **Pod**: Multiple Pods labeled and shown
- **Cluster**: Kubernetes Cluster boundary clearly marked
- **Container**: Containers inside each Pod labeled
- **Service**: Services labeled with types (LoadBalancer, ClusterIP)
- **Volume**: Persistent storage volumes shown and labeled

### 📝 Traffic Flow

The diagram demonstrates:
1. kubectl commands from user's computer to API Server
2. Scheduler deploying Pods on Worker Nodes
3. External HTTP requests reaching LoadBalancer Services
4. Internal ClusterIP services routing between applications
5. Pods accessing persistent storage via Volumes

---

## Submission Status

✅ **Exercise 3.11 Complete**

- Diagram: Submitted via Google Drive URL
- Components: All required elements included
- Labels: Pod, Cluster, Container, Service, Volume
- Applications: Blog Website + Game Server
- Hosts: 3+ machines (Master + 2 Workers)
- Traffic: Internet → LoadBalancer → Pods

**URL**: https://drive.google.com/file/d/1SzL4xv8_3y7sH19wGriWMqT3kawV0VsN/view?usp=sharing
