# 🚀 Kubernetes Mini Project — Voting App avec Ingress & MetalLB

## 🎯 Objectif

Ce projet a pour but de maîtriser :

* Kubernetes (déploiement d’une application microservices)
* Les différents types de Services (ClusterIP, NodePort, LoadBalancer)
* L’utilisation d’un **Ingress Controller (NGINX)**
* La mise en place d’un **LoadBalancer local avec MetalLB**
* Le routing basé sur des noms de domaine (DNS local)

---

## 🧠 Architecture finale

```
Browser
   ↓
DNS (hosts file)
   ↓
MetalLB (LoadBalancer IP)
   ↓
Ingress Controller (NGINX)
   ↓
Ingress Rules (host-based routing)
   ↓
Service (ClusterIP)
   ↓
Pods
```

---

## ⚙️ Prérequis

* Minikube installé dans une VM (Vagrant)
* kubectl installé
* Accès admin au fichier hosts

---

## 🔧 Étape 1 — Démarrer Minikube

```bash
minikube start
```

---

## 🔌 Étape 2 — Activer les addons

```bash
minikube addons enable ingress
minikube addons enable metallb
```

Configurer MetalLB :

```bash
minikube addons configure metallb
```

Exemple de plage IP (doit être dans le même réseau que la VM) :

```
192.168.99.100 - 192.168.99.120
```

---

## 📦 Étape 3 — Cloner le projet

```bash
git clone https://github.com/dockersamples/example-voting-app.git
cd example-voting-app/k8s-specifications
```

---

## 🧩 Étape 4 — Modifier les Services

👉 Objectif : utiliser **ClusterIP** (car Ingress gère l’accès externe)

### vote-service.yaml

```yaml
spec:
  type: ClusterIP
```

### result-service.yaml

```yaml
spec:
  type: ClusterIP
```

⚠️ Supprimer toute ligne `nodePort`

---

## 🌐 Étape 5 — Créer l’Ingress

Créer `ingress.yaml`

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: voting-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
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
                  number: 8080

    - host: result.votingapp.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: result
                port:
                  number: 8081
```

---

## 🚀 Étape 6 — Déployer l’application

```bash
kubectl apply -f .
kubectl apply -f ingress.yaml
```

---

## 🔍 Étape 7 — Vérifications

```bash
kubectl get pods
kubectl get svc
kubectl get ingress
```

---

## ⚖️ Étape 8 — Passer l’Ingress en LoadBalancer

```bash
kubectl edit svc ingress-nginx-controller -n ingress-nginx
```

Modifier :

```yaml
type: LoadBalancer
```

---

## 🌍 Étape 9 — Récupérer l’IP MetalLB

```bash
kubectl get svc -n ingress-nginx
```

Exemple :

```
EXTERNAL-IP: 192.168.99.100
```

---

## 🧠 Étape 10 — Configurer le DNS local

Modifier le fichier hosts sur TON PC :

### Windows

```
C:\Windows\System32\drivers\etc\hosts
```

Ajouter :

```
192.168.99.100 vote.votingapp.local
192.168.99.100 result.votingapp.local
```

---

## 🧪 Étape 11 — Tester

### Navigateur

```
http://vote.votingapp.local
http://result.votingapp.local
```

### curl

```bash
curl http://vote.votingapp.local
curl http://result.votingapp.local
```

---

## 🐛 Debug

### Vérifier ingress

```bash
kubectl describe ingress voting-ingress
```

### Vérifier controller

```bash
kubectl get pods -n ingress-nginx
```

### Test avec Host header

```bash
curl -H "Host: vote.votingapp.local" http://192.168.99.100
```

---

## ⚠️ Problèmes courants

### ❌ 404 Not Found

➡️ Mauvais Host header

### ❌ Connection timeout

➡️ Mauvaise IP dans hosts

### ❌ ping ne marche pas

➡️ Normal (MetalLB ne répond pas ICMP)

---

## 🎓 Concepts appris

* ClusterIP vs NodePort vs LoadBalancer
* Ingress Controller (NGINX)
* Routing basé sur hostname
* DNS local (/etc/hosts)
* Fonctionnement de MetalLB (Layer2)
* Debug réseau Kubernetes

---

## 🚀 Conclusion

Ce projet simule une architecture réelle utilisée en entreprise :

* LoadBalancer (MetalLB)
* Reverse Proxy (Ingress)
* Microservices Kubernetes
