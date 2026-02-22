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

---

## 🧠 Aprendizajes y Retos 1 (App Mesh + mTLS)

Este escenario fue intencionalmente retador porque no tenía experiencia previa con **AWS App Mesh** ni con **mTLS**. La mayor dificultad inicial fue entender el propósito real del Mesh (control de tráfico y seguridad entre servicios) y cómo se modela en Terraform.

Lo resolví de esta forma:

- Entendí que **App Mesh** actúa como un plano de control para el enrutamiento y políticas, mientras que **Envoy** (sidecar) aplica estas reglas en tiempo real.
- Identifiqué que **mTLS** en Mesh se logra configurando **TLS en modo `STRICT`** (solo tráfico autenticado/cifrado) para evitar conexiones “plain”.
- Integré certificados mediante un **ARN de ACM** para gestionar la identidad/certificados del nodo virtual y habilitar terminación/validación TLS.
- Documenté en comentarios del código **cómo se fuerza que el microservicio solo acepte tráfico autenticado por el Mesh**, alineado a seguridad por defecto.

## 🧠 Aprendizajes y Retos 2 (EKS + IRSA → S3)

Este escenario también fue retador porque no tenía experiencia previa desplegando identidad para workloads en **Amazon EKS**. La mayor dificultad inicial fue entender cómo EKS permite que un microservicio obtenga permisos de AWS **sin usar llaves estáticas** (IAM Users) y cómo se conecta eso con Terraform y Kubernetes.

Lo resolví de esta forma:

- Comprendí el propósito de **IRSA (IAM Roles for Service Accounts)**: asignar permisos de AWS a un *ServiceAccount* específico, para que el pod asuma un rol **de forma segura** mediante OIDC.
- Implementé la relación de confianza (**Trust Relationship**) usando el **OIDC Provider del clúster**, evitando hardcoding: el código obtiene dinámicamente el **OIDC issuer URL** y el **ARN del provider** desde el recurso/data del clúster.
- Apliqué **Least Privilege** en IAM, limitando permisos únicamente a las acciones necesarias sobre el bucket S3 (lectura/escritura) y, cuando aplica, restringiendo también por **ARN del bucket y objetos**.
- Asocié el rol al `ServiceAccount` mediante la anotación estándar de IRSA, asegurando que **solo ese microservicio** pueda asumir el rol y acceder al bucket.
- Documenté en comentarios del código cómo se evita el uso de credenciales estáticas y cómo se asegura que el acceso a S3 se obtiene únicamente a través del rol asumido por el ServiceAccount.

## 🧠 Aprendizajes y Retos 3 (DMS Aurora → S3 → Athena)

Este escenario fue retador principalmente porque no tenía mucha experiencia previa con **AWS DMS**. Aunque conozco lo basico, la dificultad inicial fue entender cómo DMS materializa la migración/replicación desde una base relacional (Aurora) hacia **S3** y qué implicaciones tiene esto para la consulta posterior en **Athena** (formato, estructura de carpetas y particiones).

Lo resolví de esta forma:

- Entendí el rol de **DMS** como servicio de migración/replicación (full load y/o CDC, según configuración), y cómo se conectan los componentes de origen (Aurora) y destino (S3) a través de endpoints y tareas.
- Aproveché mi experiencia con **S3 y Athena** para diseñar correctamente el almacenamiento de resultados y la operación del query engine, incluyendo el bucket dedicado para resultados de Athena y el Workgroup.
- Documenté una limitación importante: por defecto, el output en S3 puede generarse con rutas tipo `dms/YYYY/MM/DD/`, lo cual **no es automáticamente Hive-style** (`year=/month=/day=`).
- Para habilitar particionado estilo Hive (mejor para Athena/Glue), indiqué explícitamente que se requiere un **Glue Job posterior** que reubique/reescriba los datos a `year=/month=/day=` y luego ejecutar `MSCK REPAIR TABLE` (o actualizar particiones vía Glue Crawler) para que Athena detecte las particiones.
- Consideré buenas prácticas de operación en S3 (por ejemplo, lifecycle policies para controlar costos de almacenamiento y expiración de resultados temporales), dejando el diseño listo para extenderse a un pipeline más completo.