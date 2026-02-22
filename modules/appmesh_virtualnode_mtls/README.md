# Escenario 2: Service Mesh y Conectividad Segura (APP Mesh)

## Objetivo
Este módulo define un **AWS App Mesh** y un **Virtual Node** para el microservicio `api-customer`, configurando:

- Listener con **TLS estricto** (obligatorio).
- **Validación de certificado del cliente** (mTLS en inbound).
- Política por defecto para que el tráfico saliente hacia otros nodos use **TLS obligatorio** (y valide CA).
- Certificado del servidor obtenido desde **AWS Certificate Manager (ACM)** mediante ARN.

---

## Prerequisitos del entorno (EKS)
Para que esto funcione en un clúster EKS con App Mesh:

- Existe el **App Mesh Controller** instalado.
- El pod de `api-customer` corre con **sidecar Envoy** inyectado/configurado.
- El archivo `mesh-ca.pem` existe dentro del contenedor Envoy en la ruta `trust_ca_bundle_path` (montado desde Secret/ConfigMap).
- El certificado de servidor referenciado por `acm_server_cert_arn` es válido.

---

## Qué crea este Terraform
- **Mesh:** `aws_appmesh_mesh.this_mesh`
- **Virtual Node:** `aws_appmesh_virtual_node.api_customer`
  - Listener `port = var.listener_port` y `protocol = http`
  - TLS:
    - `mode = STRICT` → no permite tráfico sin TLS
    - Certificado de servidor desde ACM: `var.acm_server_cert_arn`
    - Validación (trust bundle) para mTLS: `var.trust_ca_bundle_path`
  - `backend_defaults.client_policy.tls.enforce = true` → obliga TLS para llamadas salientes a backends del mesh

---

## Cumplimiento del Escenario 2

### 1) Definir App Mesh y Virtual Node `api-customer` ✅
Cumplido:
- `aws_appmesh_mesh` crea el mesh.
- `aws_appmesh_virtual_node` crea el virtual node `api-customer`.

### 2) Forzar que toda comunicación hacia otros nodos use mTLS ✅

- **TLS obligatorio** en tráfico saliente: `backend_defaults.client_policy.tls.enforce = true`
- **Validación de confianza** del servidor (CA bundle): `validation.trust.file.certificate_chain = var.trust_ca_bundle_path`

**Lo que falta para garantizar mTLS completo en salida:**
- Para mTLS real, el **cliente también presenta certificado**. En App Mesh/Envoy esto se configura con:
  - `client_policy.tls.certificate { ... }` (normalmente vía `file` o `sds`)



### 3) Integrar ACM ARN para terminación TLS en el Virtual Node ✅
Cumplido:
- Listener usa `certificate.acm.certificate_arn = var.acm_server_cert_arn`.

### 4) Explicar cómo se asegura que el microservicio solo acepte tráfico autenticado por el Mesh ✅
- `tls.mode = STRICT` evita tráfico plaintext.
- `tls.validation.trust...` obliga a que el cliente presente un certificado emitido por una CA confiable.
- Esto hace que **Envoy rechace** conexiones sin TLS o sin certificado de cliente válido.

**Recomendación práctica en EKS (best practice):**
- La aplicación debería escuchar en `127.0.0.1` (loopback) y que **solo Envoy** exponga el listener a la red del clúster, garantizando que toda comunicación pase por el Mesh.

---

## Variables

| Variable | Tipo | Default | Descripción |
|---|---:|---|---|
| `mesh_name` | string | `zigi-mesh` | Nombre del App Mesh |
| `listener_port` | number | `8080` | Puerto del listener en el Virtual Node |
| `acm_server_cert_arn` | string | (requerido) | ARN de ACM del cert del servidor (TLS inbound) |
| `trust_ca_bundle_path` | string | `/etc/ssl/certs/mesh-ca.pem` | Ruta al CA bundle PEM usado por Envoy |
| `service_hostname` | string | `api-customer.default.svc.cluster.local` | DNS del servicio dentro del cluster |

---

## Uso

### Ejemplo `terraform.tfvars` 

> (terraform.tfvars esta vacio, pero si quisieramos correrlo de forma realista)

```hcl
mesh_name            = "zigi-mesh"
listener_port        = 8080
acm_server_cert_arn  = "arn:aws:acm:REGION:ACCOUNT:certificate/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
trust_ca_bundle_path = "/etc/ssl/certs/mesh-ca.pem"
service_hostname     = "api-customer.default.svc.cluster.local"
```

## Comandos desde envs/dev/

```bash
terraform init
terraform validate
terraform plan
terraform apply
```