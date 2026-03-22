#!/bin/bash

kubectl create namespace voting

kubectl create -n voting deploy db --image=postgres:15-alpine

kubectl -n voting scale deployment db --replicas=1

kubectl -n voting  set env deployment/db \
  POSTGRES_USER=postgres \
  POSTGRES_PASSWORD=postgres
kubectl -n voting patch deployment db --type='json' -p='[
  {
    "op": "add",
    "path": "/spec/template/spec/containers/0/ports",
    "value": [{"containerPort":5432,"name":"postgres"}]
  }
]'

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

kubectl -n voting expose deployment db \
  --port=5432 \
  --target-port=5432 \
  --name=db \
  --type=ClusterIP

kubectl -n voting patch svc db --type='json' -p='[
  {
    "op": "replace",
    "path": "/spec/ports/0/name",
    "value": "db-service"
  }
]'