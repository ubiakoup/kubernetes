# 🚀 Kubernetes Voting App — Projet Complet (Ingress + MetalLB + Persistence + pgAdmin)

---

## 🎯 Objectif

Ce projet a pour but de déployer une application microservices (Voting App) sur Kubernetes avec :

* Ingress Controller (NGINX)
* LoadBalancer local (MetalLB)
* Persistance des données (PV / PVC)
* Interface d’administration PostgreSQL (pgAdmin)
* DNS local via fichier hosts

---

## 🧠 Architecture

```
Browser
   ↓
DNS (hosts)
   ↓
MetalLB (LoadBalancer IP)
   ↓
Ingress Controller
   ↓
Ingress Rules
   ↓
Services (ClusterIP)
   ↓
Pods (vote / result / worker / db / redis / pgadmin)
```

---

## ⚙️ Prérequis

* Minikube installé
* kubectl installé
* VM avec réseau accessible (ex: 192.168.99.x)

---

## 🔧 1. Démarrage du cluster

```bash
minikube start
```

---

## 🔌 2. Activation des addons

```bash
minikube addons enable ingress
minikube addons enable metallb
```

---

## ⚖️ 3. Configuration MetalLB

```bash
minikube addons configure metallb
```

👉 Exemple de plage IP :

```
192.168.99.100 - 192.168.99.120
```

---

## 💾 4. Persistance (PV / PVC)

### 📦 PostgreSQL PV

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: db-pv
spec:
  storageClassName: manual
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/data-pv"
```

---

### 📦 PostgreSQL PVC

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: db-pvc
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi
```

---

### 📦 Redis PV

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: redis-pv
spec:
  storageClassName: manual
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/dataredis-pv"
```

---

### 📦 Redis PVC

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: redis-pvc
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi
```

---

## 🐘 5. Déploiement pgAdmin

### Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: pgadmin
spec:
  selector:
    matchLabels:
      app: pgadmin
  template:
    metadata:
      labels:
        app: pgadmin
    spec:
      containers:
        - name: pgadmin
          image: dpage/pgadmin4:9.8
          env:
            - name: PGADMIN_DEFAULT_EMAIL
              value: admin@mail.com
            - name: PGADMIN_DEFAULT_PASSWORD
              value: secret
          ports:
            - containerPort: 5050
```

---

### Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: pgadmin
spec:
  type: ClusterIP
  selector:
    app: pgadmin
  ports:
    - port: 80
      targetPort: 80
```

---

## 🌐 6. Ingress

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: voting-ingress
spec:
  rules:
    - host: vote.votingapp.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: vote
                port:
                  number: 80

    - host: result.votingapp.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: result
                port:
                  number: 80

    - host: pgadmin.votingapp.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: pgadmin
                port:
                  number: 80
```

---

## 🌍 7. DNS local (hosts)

Sur ton PC :

```
192.168.99.100 vote.votingapp.local
192.168.99.100 result.votingapp.local
192.168.99.100 pgadmin.votingapp.local
```

---

## 🧪 8. Accès aux applications

* http://vote.votingapp.local
* http://result.votingapp.local
* http://pgadmin.votingapp.local

---

## 🧠 9. Concepts clés

### 🔥 Routing Kubernetes

```
Ingress → Service → Endpoints → Pod
```

---

### ⚠️ Règle fondamentale

```text
targetPort = port réel du container
```

---

### ❗ Important

```text
containerPort = informatif seulement
```

---

## 🔍 10. Debug (502 / 503)

### ❌ 502 Bad Gateway

* mauvais port (targetPort incorrect)

### ❌ 503 Service Unavailable

* pod non READY
* endpoints vides

---

## 🔧 11. Commandes utiles

### 📦 Vérification

```bash
kubectl get pods
kubectl get svc
kubectl get ingress
kubectl get endpoints
kubectl get pvc
kubectl get pv
```

---

### 🔍 Détails

```bash
kubectl describe pod <pod>
kubectl describe svc <service>
kubectl describe ingress <ingress>
```

---

### 📜 Logs

```bash
kubectl logs <pod>
kubectl logs -l app=pgadmin
```

---

### 🔄 Restart

```bash
kubectl delete pod -l app=pgadmin
```

---

### 🔗 Test service

```bash
kubectl port-forward svc/pgadmin 8080:80
```

---

### 🌐 Test ingress

```bash
curl -H "Host: pgadmin.votingapp.local" http://192.168.99.100
```

---

### 🔍 Endpoints (CRITIQUE)

```bash
kubectl get endpoints pgadmin
```

---

### 🔍 Vérifier port réel

```bash
kubectl logs <pod> | grep Listening
```

---

### 🔄 Restart ingress

```bash
kubectl rollout restart deployment ingress-nginx-controller -n ingress-nginx
```

---

## 🧠 12. Leçons apprises

* Kubernetes networking
* Ingress Controller
* MetalLB
* Persistent storage
* Debug avancé (502 / 503)
* Routing interne Kubernetes

---

## 🚀 Conclusion

Ce projet permet de maîtriser :

* Déploiement d’applications multi-services
* Exposition externe via Ingress
* Persistance des données
* Debug réel en environnement Kubernetes
