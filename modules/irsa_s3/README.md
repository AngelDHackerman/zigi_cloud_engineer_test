# Escenario 1 — Orquestación y Seguridad de Identidad (EKS + IRSA para S3)

## Objetivo
Desplegar un microservicio en **Amazon EKS** que lea y escriba objetos en un **bucket de Amazon S3** **sin usar llaves de acceso estáticas (IAM Users)**.  
Para cumplir políticas de seguridad/compliance se implementa **IRSA (IAM Roles for Service Accounts)** usando el **OIDC Provider** del clúster.

## Prerrequisitos
* Un clúster __Amazon EKS existente__ (con OIDC habilitado).
* Terraform >= 1.5.0
* AWS Provider ~> 5.0
* Permisos para:
    * Leer el cluster EKS (eks:DescribeCluster)
    * Leer el OIDC provider (iam:GetOpenIDConnectProvider)
    * Crear IAM Role/Policy y adjuntos
* Acceso Kubernetes (cuando `enable_eks_integration=true`) para crear el ServiceAccount.

---

## Requerimientos del escenario (y cómo se cumplen)

✅ **IAM Role + política mínima necesaria para acceso a S3**  
- Se crea una policy con permisos mínimos:
  - `s3:ListBucket` sobre el bucket
  - `s3:GetObject`, `s3:PutObject`, `s3:DeleteObject` sobre un `prefix` específico del bucket

✅ **Trust Relationship usando proveedor OIDC del clúster (IRSA)**  
- `sts:AssumeRoleWithWebIdentity`
- Principal **Federated** con el ARN del OIDC provider
- Condiciones estrictas:
  - `aud = sts.amazonaws.com`
  - `sub = system:serviceaccount:<namespace>:<serviceAccount>`

✅ **OIDC URL y ARN dinámicos (sin hardcoding)**  
- El OIDC Issuer se obtiene dinámicamente del data source del clúster EKS:
  - `data.aws_eks_cluster.this_cluster.identity[0].oidc[0].issuer`
- El ARN del OIDC provider se descubre con:
  - `data.aws_iam_openid_connect_provider`

✅ **ServiceAccount de Kubernetes asociado al rol (IRSA)**  
- Se crea `kubernetes_service_account_v1` con annotation:
  - `eks.amazonaws.com/role-arn = <IAM_ROLE_ARN>`

---

## Arquitectura (conceptual)

```text
Pod (microservice) -----> ServiceAccount (K8s)
        |                     |
        |                     v
        |              IRSA (OIDC token)
        |                     |
        v                     v
   IAM Role (AssumeRoleWithWebIdentity)
                    |
                    v
               Amazon S3 (bucket/prefix)
```

## Estructura Relevante 
```
modules/
  irsa_s3/
    main.tf
    variables.tf

dev/
  main.tf
  variables.tf
```

## Input Variables (modules/irsa_s3)

* `eks_cluster_name` (string, requerido): Nombre del clúster EKS.
* `bucket_name` (string, requerido): Bucket S3 destino.
* `bucket_prefix` (string, default: `app/`): Prefix dentro del bucket para limitar permisos.
* `name_prefix` (string, default: `zigi`): Prefijo para nombres de recursos IAM.
* `k8s_namespace` (string, default: `default`): Namespace del ServiceAccount.
* `service_account_name` (string, default: `api-customer`): Nombre del ServiceAccount.

## Uso desde `dev/`

En `dev/` se usa un flag para permitir trabajar en dos modos:

### Modo “Docs/Mock” (por defecto)

No intenta leer EKS real ni crear recursos dependientes del cluster:

```h
enable_eks_integration = false
```

### Modo “Integración real con EKS”

Activa el módulo IRSA + creación del ServiceAccount:

```h
enable_eks_integration = true
eks_cluster_name       = "eks-angel-test"
irsa_bucket_name       = "bucket-name-test-angel"
irsa_bucket_prefix     = "app/"
k8s_namespace          = "default"
service_account_name   = "api-customer"
```

## Ejecutar

Desde `dev/`

```bash
terraform init
terraform plan
terraform apply
```

para integracion con EKS: 
```h
terraform plan  -var="enable_eks_integration=true"
terraform apply -var="enable_eks_integration=true"
```