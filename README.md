# zigi_cloud_engineer_test

# 🚀 Escenarios de Arquitectura AWS con Terraform

## 📘 Descripción General

Este repositorio contiene tres escenarios de infraestructura implementados con **Terraform** sobre **AWS**, enfocados en buenas prácticas de arquitectura en la nube, seguridad y automatización.

Cada escenario demuestra patrones reales utilizados en entornos productivos, incluyendo:

- Gestión segura de identidad para workloads en Kubernetes (EKS + IRSA)
- Comunicación cifrada entre microservicios mediante Service Mesh (App Mesh con mTLS)
- Pipeline de migración y analítica de datos (DMS → S3 → Athena)

El objetivo de este proyecto es demostrar habilidades sólidas como **Cloud Engineer**, aplicando principios de:

- 🔐 Least Privilege (mínimos privilegios IAM)
- 🚫 Eliminación de hardcoding (uso dinámico de recursos)
- 🧱 Infraestructura como Código (IaC)
- 📊 Arquitectura preparada para producción

---

## 📂 Estructura del Proyecto

```bash
.
├── irsa_s3/
│ └── README.md
│ └── main.tf
│ └── variables.tf
├── appmesh_virtualnode_mtls/
│ └── README.md
│ └── main.tf
│ └── variables.tf
├── dms_aurora_to_s3_athena/
│ └── README.md
│ └── main.tf
│ └── variables.tf
└── README.md
```


---

## 🔗 Escenarios

- [Escenario 1 – Orquestación e Identidad Segura (EKS + IRSA)](./modules/irsa_s3/README.md)
- [Escenario 2 – Service Mesh y mTLS (App Mesh)](./modules/appmesh_virtualnode_mtls/README.md)
- [Escenario 3 – Migración y Analítica (DMS → S3 → Athena)](./modules/dms_aurora_to_s3_athena/README.md)

> Cada escenario incluye explicación arquitectónica, código Terraform y consideraciones de seguridad.

---

## 🛠 Tecnologías Utilizadas

- AWS EKS
- AWS IAM (IRSA)
- AWS App Mesh
- AWS Certificate Manager (ACM)
- AWS DMS
- Amazon S3
- Amazon Athena
- Terraform

---

## 🎯 Propósito

Este repositorio forma parte de un portafolio técnico enfocado en demostrar capacidades reales en:

- Diseño de arquitecturas seguras en AWS
- Implementación de Service Mesh con mTLS
- Automatización de infraestructura con Terraform
- Buenas prácticas de seguridad y cumplimiento

