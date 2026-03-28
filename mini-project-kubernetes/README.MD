# 🚀 Kubernetes Mini Project — WordPress + PhpMyAdmin

## 🎯 Objectif

Déployer une application complète WordPress avec base de données MySQL et PhpMyAdmin sur Kubernetes (Minikube), en utilisant :

* Des manifests Kubernetes
* Services ClusterIP
* Ingress Controller (NGINX)
* MetalLB (LoadBalancer local)
* DNS local via fichier hosts

---

## 🧠 Architecture finale

```
Browser
   ↓
DNS (hosts)
   ↓
MetalLB (LoadBalancer IP)
   ↓
Ingress Controller (NGINX)
   ↓
Ingress Rules
   ↓
Services (ClusterIP)
   ↓
Pods (WordPress / MySQL / PhpMyAdmin)
```

---

## ⚙️ Prérequis

* Minikube installé
* kubectl installé
* Addons ingress et metallb activés

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

Exemple de plage IP :

```
192.168.99.100 - 192.168.99.120
```

---

## 🗄️ Étape 3 — Déployer MySQL

```bash
kubectl apply -f mysql-deployment.yaml
kubectl apply -f mysql-service.yaml
```

---

## 🌐 Étape 4 — Déployer WordPress

```bash
kubectl apply -f wordpress-deployment.yaml
kubectl apply -f wordpress-service.yaml
```

⚠️ IMPORTANT : Variables d’environnement obligatoires

```yaml
env:
  - name: WORDPRESS_DB_HOST
    value: mysql
  - name: WORDPRESS_DB_USER
    value: root
  - name: WORDPRESS_DB_PASSWORD
    value: root
  - name: WORDPRESS_DB_NAME
    value: wordpress
```

👉 Sans `WORDPRESS_DB_NAME`, WordPress ne peut pas se connecter à la base de données.

---

## 🛠️ Étape 5 — Déployer PhpMyAdmin

```bash
kubectl apply -f PhpMyAdmin.yaml
```

---

## 🌍 Étape 6 — Déployer l’Ingress

```bash
kubectl apply -f ingress.yaml
```

---

## ⚖️ Étape 7 — Activer LoadBalancer

```bash
kubectl edit svc ingress-nginx-controller -n ingress-nginx
```

Modifier :

```yaml
type: LoadBalancer
```

---

## 🔍 Étape 8 — Récupérer IP externe

```bash
kubectl get svc -n ingress-nginx
```

Exemple :

```
192.168.99.100
```

---

## 🌐 Étape 9 — Configurer DNS local

Modifier le fichier hosts sur votre PC :

```
192.168.99.100 wordpress.local
192.168.99.100 phpmyadmin.local
```

---

## 🧪 Étape 10 — Accès aux applications

* [http://wordpress.local](http://wordpress.local)
* [http://phpmyadmin.local](http://phpmyadmin.local)

---

## 🐛 Debug

### Vérifier les pods

```bash
kubectl get pods
```

### Vérifier les services

```bash
kubectl get svc
```

### Vérifier ingress

```bash
kubectl get ingress
kubectl describe ingress wordpress-ingress
```

### Redémarrer WordPress si MySQL était indisponible

```bash
kubectl delete pod -l app=wordpress
```

---

## ⚠️ Problèmes rencontrés

### ❌ Erreur : "Error establishing a database connection"

✔ Cause : variables d’environnement incomplètes
✔ Solution : ajouter `WORDPRESS_DB_NAME`

---

### ❌ MySQL non prêt

✔ WordPress démarre avant MySQL
✔ Solution : redémarrer le pod WordPress

---

### ❌ Erreurs YAML

✔ Indentation incorrecte
✔ Mauvaise casse (Labels vs labels)

---

## 🎓 Concepts appris

* Déploiement multi-services Kubernetes
* Communication inter-services (WordPress ↔ MySQL)
* Ingress Controller et routing HTTP
* MetalLB (LoadBalancer local)
* DNS local
* Debug Kubernetes réel

---

## 🚀 Conclusion

Ce projet permet de mettre en place une architecture complète similaire à un environnement de production :

* Application web (WordPress)
* Base de données (MySQL)
* Interface d’administration (PhpMyAdmin)
* Accès via domaine (Ingress + DNS)

👉 Niveau DevOps solide atteint 💪
