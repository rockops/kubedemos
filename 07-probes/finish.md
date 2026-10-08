<br>

### Congratulations!

You have completed the **Kubernetes Pod Probes Lifecycle** scenario!

---

### Summary of Key Concepts Learned:

#### 1. The Three Probe Types at a Glance

| Probe | Primary Question | Action on Failure | Typical Use Case |
|---|---|---|---|
| **`startupProbe`** | *"Has the container finished booting up?"* | Kubelet kills and restarts the container | Slow initialization, JVM warmup, schema migrations, cache pre-loading. |
| **`readinessProbe`** | *"Can the container accept network traffic right now?"* | Removes Pod IP from Service/Endpoints without restarting container | Overloaded servers, cache warmup, temporary downstream outages. |
| **`livenessProbe`** | *"Is the container process still healthy and functional?"* | Kubelet kills and restarts the container | Deadlocks, memory leaks, unrecoverable internal hangs. |

<br>

#### 2. Probe Lifecycle Interplay

```
Container Boot
      │
      ▼
┌───────────────────────────┐
│       startupProbe        │◄──┐
└─────────────┬─────────────┘   │
              │                 │
     Success? │ No (kill/retry) │
              ├─────────────────┘
              ▼ Yes
 ┌─────────────────────────┐     ┌─────────────────────────┐
 │     readinessProbe      │     │      livenessProbe      │
 └────────────┬────────────┘     └────────────┬────────────┘
              │                               │
     Success? │                      Success? │
      ┌───────┴───────┐                       │
      │               │                       ├──────────────┐
     Yes              No                     Yes             No (Fail)
      │               │                       │              │
      ▼               ▼                       ▼              ▼
Add to Service   Remove from Service      Keep Running  Kubelet Kills
  Endpoints        Endpoints                            & Restarts Container
                                                             │
                                                             └───► (Resets back to Boot)
```

<br>

#### 3. Why the Startup Probe is Essential

Before `startupProbe` was introduced in Kubernetes, developers had to set long `initialDelaySeconds` on `livenessProbe` to accommodate slow startup times.
- If `initialDelaySeconds` was too short, the container was killed in an endless crash loop.
- If `initialDelaySeconds` was too long, deadlocks occurring after startup went undetected for minutes.

A **`startupProbe`** solves this cleanly:
- It runs exclusively until the application signals readiness.
- It disables both `livenessProbe` and `readinessProbe` until it passes.
- Once it passes, `livenessProbe` and `readinessProbe` take over immediately with short, responsive intervals!

<br>

#### 4. Supported Probe Handlers

Kubernetes supports four probe mechanisms:
1. **`exec`**: Runs a diagnostic command inside the container (exit code `0` is success).
2. **`httpGet`**: Sends an HTTP request to the container IP on a specified port and path (status `200`–`399` is success).
3. **`tcpSocket`**: Attempts to establish a TCP connection to the container port.
4. **`grpc`**: Uses standard gRPC health-checking protocol (`grpc.health.v1.Health`).
