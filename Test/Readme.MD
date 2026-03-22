# 📦 README – Déploiement PostgreSQL avec commandes impératives Kubernetes

## 🎯 Objectif

Ce script permet de déployer une base de données **PostgreSQL** dans Kubernetes en utilisant des **commandes impératives (`kubectl`)**, sans passer par des fichiers YAML.

Il illustre :

* la création d’un namespace
* le déploiement d’un container
* la configuration (env, ports, volumes)
* l’exposition via un Service

---

## 🧱 1. Création du namespace

```bash
kubectl create namespace voting
```

🔎 **Explication :**

* Crée un espace isolé appelé `voting`
* Permet d’organiser les ressources (pods, services, etc.)
* Évite les conflits entre applications

---

## 🚀 2. Création du Deployment

```bash
kubectl create -n voting deploy db --image=postgres:15-alpine
```

🔎 **Explication :**

* Crée un **Deployment** nommé `db`
* Utilise l’image Docker `postgres:15-alpine`
* Le Deployment va gérer automatiquement les Pods

---

## 📈 3. Définition du nombre de replicas

```bash
kubectl -n voting scale deployment db --replicas=1
```

🔎 **Explication :**

* Définit le nombre de Pods à exécuter
* Ici : 1 instance de PostgreSQL

---

## 🔐 4. Ajout des variables d’environnement

```bash
kubectl -n voting set env deployment/db \
  POSTGRES_USER=postgres \
  POSTGRES_PASSWORD=postgres
```

🔎 **Explication :**

* Configure les variables nécessaires à PostgreSQL
* `POSTGRES_USER` → utilisateur
* `POSTGRES_PASSWORD` → mot de passe

---

## 🔌 5. Ajout du port du container

```bash
kubectl -n voting patch deployment db --type='json' -p='[
  {
    "op": "add",
    "path": "/spec/template/spec/containers/0/ports",
    "value": [{"containerPort":5432,"name":"postgres"}]
  }
]'
```

🔎 **Explication :**

* Ajoute le port 5432 au container
* `containers/0` → premier container du pod
* Le port est nommé `postgres`

---

## 💾 6. Ajout du volume (stockage)

```bash
kubectl -n voting patch deployment db --type='json' -p='[
  {
    "op": "add",
    "path": "/spec/template/spec/volumes",
    "value": [{"name":"db-data","emptyDir":{}}]
  },
  {
    "op": "add",
    "path": "/spec/template/spec/containers/0/volumeMounts",
    "value": [{"name":"db-data","mountPath":"/var/lib/postgresql/data"}]
  }
]'
```

🔎 **Explication :**

* Crée un volume temporaire (`emptyDir`)
* Monte ce volume dans le container
* Permet de stocker les données PostgreSQL

⚠️ **Important :**

* `emptyDir` = stockage temporaire (supprimé si le Pod est détruit)

---

## 🌐 7. Création du Service

```bash
kubectl -n voting expose deployment db \
  --port=5432 \
  --target-port=5432 \
  --name=db \
  --type=ClusterIP
```

🔎 **Explication :**

* Expose le Deployment via un Service
* `port` → port du Service
* `target-port` → port du container
* `ClusterIP` → accessible uniquement à l’intérieur du cluster

---

## 🏷️ 8. Ajout du nom du port

```bash
kubectl -n voting patch svc db --type='json' -p='[
  {
    "op": "replace",
    "path": "/spec/ports/0/name",
    "value": "db-service"
  }
]'
```

🔎 **Explication :**

* Ajoute un nom au port du Service
* Nécessaire pour certaines configurations avancées
* Utilise `replace` car le port existe déjà

---

## 🧠 Concepts clés

### 🔹 Patch

* Permet de modifier une ressource existante
* Plus rapide que recréer un YAML complet
* Utilise des chemins JSON (`/spec/...`)

---

### 🔹 Port vs TargetPort

| Élément      | Description                |
| ------------ | -------------------------- |
| `port`       | Port exposé par le Service |
| `targetPort` | Port du container          |

👉 Flux :

```
Client → Service:5432 → Pod:5432
```

---

### 🔹 JSON Path dans les patchs

Exemple :

```
/spec/template/spec/containers/0/volumeMounts
```

* `/` → navigation dans le YAML
* `containers/0` → premier container
* correspond exactement à la structure YAML

---

## ✅ Résultat final

Après exécution du script :

* Namespace `voting` créé
* Deployment PostgreSQL opérationnel
* Volume monté
* Service accessible en interne
* Configuration complète sans YAML

---

## 🚀 Conclusion

Ce script démontre :

✔ l’utilisation des commandes impératives Kubernetes
✔ la configuration dynamique avec `kubectl patch`
✔ la compréhension des objets Deployment et Service

