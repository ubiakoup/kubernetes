# 📦 README – Comprendre le stockage Kubernetes (PV / PVC)

## 🎯 Objectif

Ce document explique le fonctionnement du stockage dans Kubernetes :

* PersistentVolume (**PV**)
* PersistentVolumeClaim (**PVC**)
* Binding automatique
* StorageClass
* Access Modes

---

# 🧠 1. Concepts de base

## 🔹 PersistentVolume (PV)

👉 Représente un **espace de stockage réel** (disque, NFS, cloud…)

```text
PV = ressource de stockage disponible
```

---

## 🔹 PersistentVolumeClaim (PVC)

👉 Représente une **demande de stockage**

```text
PVC = demande de stockage
```

---

## 🔗 Relation PV / PVC

```text
PVC → demande
PV  → fournit
```

👉 Kubernetes fait le lien automatiquement = **binding**

---

# ⚙️ 2. Comment Kubernetes fait le matching

Lorsqu’un PVC est créé, Kubernetes :

### 🔹 Étape 1 : filtre les PV compatibles

Critères :

* ✅ **storageClassName**
* ✅ **capacité suffisante**
* ✅ **accessModes compatibles**
* ✅ **volumeMode (si défini)**

---

### 🔹 Étape 2 : sélection

👉 Kubernetes choisit :

```text
le plus petit PV suffisant (best fit)
```

---

### 🔹 Étape 3 : binding

```text
PVC → PV
```

* le PV devient **Bound**
* il est réservé à ce PVC

---

# 🔥 Exemple

```text
PV1 → 1Gi
PV2 → 5Gi

PVC → demande 1Gi
```

👉 Kubernetes choisit :

```text
PV1 (meilleur fit)
```

---

# ⚠️ Cas d’échec

PVC reste en `Pending` si :

* ❌ aucun PV disponible
* ❌ storageClass différent
* ❌ taille insuffisante
* ❌ accessModes incompatibles

---

# 🧩 3. StorageClass

## 🔹 Définition

👉 Définit **le type de stockage utilisé**

```yaml
storageClassName: manual
```

---

## 🔹 Deux types

### ✔ Manuel

* PV créé à la main
* PVC se lie à un PV existant

---

### ✔ Dynamique

* Kubernetes crée automatiquement le PV
* utilisé en cloud (AWS, GCP, Azure)

---

# 🔐 4. Access Modes (TRÈS IMPORTANT)

👉 Définit **comment le volume peut être utilisé**

---

## 🔹 1. ReadWriteOnce (RWO)

```text
✔ Lecture/écriture par UN seul node
```

👉 le plus courant

---

## 🔹 2. ReadOnlyMany (ROX)

```text
✔ Lecture seule par plusieurs nodes
```

---

## 🔹 3. ReadWriteMany (RWX)

```text
✔ Lecture/écriture par plusieurs nodes
```

👉 nécessite stockage partagé (NFS, etc.)

---

## 🔹 4. ReadWriteOncePod (RWOP)

```text
✔ Un seul Pod (même sur un node)
```

👉 plus strict que RWO

---

# ⚠️ Important

👉 Les accessModes doivent être compatibles :

```text
PVC ⊆ PV
```

---

# 🔗 5. Utilisation dans un Pod

Une fois le PVC lié :

```text
Pod → PVC → PV → stockage réel
```

👉 Exemple :

```yaml
volumes:
- name: data
  persistentVolumeClaim:
    claimName: pvc
```

---

# 🧠 6. Types de volumes (rappel)

| Type     | Description          |
| -------- | -------------------- |
| emptyDir | temporaire           |
| hostPath | disque local du node |
| PV/PVC   | stockage persistant  |

---

# ⚠️ Points critiques

* un PV = **un seul PVC**
* binding = **exclusif**
* suppression du Pod ≠ suppression des données (si PV)
* `emptyDir` = données perdues

---

# 🔥 Debug utile

```bash
kubectl get pv
kubectl get pvc
kubectl describe pvc pvc
kubectl describe pv pv
```

---

# 🚀 Résumé global

```text
1. PVC demande du stockage
2. Kubernetes cherche un PV compatible
3. Il sélectionne le meilleur (best fit)
4. Il fait le binding
5. Le Pod utilise le PVC
```

---

# 🧠 Phrase magique (examen)

👉
**"Un PVC demande du stockage, Kubernetes sélectionne automatiquement un PV compatible et établit un binding exclusif entre les deux."**

---

# 💥 Conclusion

✔ Kubernetes gère automatiquement le stockage
✔ Matching basé sur des critères stricts
✔ Access modes contrôlent l’utilisation
✔ StorageClass définit le type de provisionnement

---

👉 Ce mécanisme permet :

* une gestion flexible du stockage
* une abstraction complète de l’infrastructure
* une automatisation en production

---
