# Escenario 3 — Movilidad y Análisis de Datos (DMS + S3 + Athena)

Este módulo implementa el **Escenario 3**: replicación de datos desde **Aurora PostgreSQL** hacia un **Data Lake en S3** usando **AWS DMS**, para luego consultar bajo demanda con **Amazon Athena** sin impactar el rendimiento de producción.

## Arquitectura (alto nivel)

1. **AWS DMS Replication Instance** ejecuta una tarea `full-load-and-cdc`.
2. **Endpoint Source (Aurora PostgreSQL)**: conexión segura con `ssl_mode = require`.
3. **Endpoint Target (S3)**: escribe datasets en **Parquet** comprimido **GZIP**.
4. **Athena Workgroup** con bucket/prefix dedicado para resultados de queries.

## Requerimientos del enunciado y cómo se cumplen

### 1) DMS replication instance + endpoints (source Aurora, target S3)
- `aws_dms_replication_instance.this_dms`
- `aws_dms_endpoint.source_aurora`
- `aws_dms_endpoint.target_s3`

> Nota: Para un despliegue real, DMS normalmente requiere conectividad de red (subnets/SG/rutas) hacia Aurora y hacia S3 (NAT o VPC endpoint). Este escenario se enfoca en los recursos pedidos por el enunciado.

### 2) Table mappings en JSON filtrando `public.trx_*`
El módulo define `table_mappings` en Terraform con JSON (`jsonencode`) para replicar únicamente:
- schema: `public`
- tablas: `trx_%`

### 3) Workgroup Athena + bucket de resultados
- `aws_s3_bucket.athena_results`
- `aws_athena_workgroup.this_dms` con `output_location` en `s3://<bucket>/<prefix>/`

### 4) Optimización: particionar por fecha para optimizar scans en Athena
En el endpoint target S3:
- `date_partition_enabled = true`
- `date_partition_sequence = "YYYYMMDD"`
- `date_partition_delimiter = "SLASH"`

Esto genera carpetas por fecha con estructura tipo `YYYY/MM/DD/`, reduciendo el escaneo y el costo al consultar en Athena (cuando tus queries filtran por rutas/fechas).



---

## Archivos del módulo

- `main.tf`: recursos DMS + endpoint S3 + Workgroup Athena + bucket resultados
- `variables.tf`: variables y validaciones para inputs

## Inputs (Variables)

### Athena
- `athena_results_bucket` (string, requerido): bucket para resultados Athena
- `athena_workgroup_name` (string, default: `zigi-wg`)
- `athena_results_prefix` (string, default: `athena/results/`)

### DMS
- `dms_replication_instance_id` (string, default: `zigi-dms`)
- `dms_instance_class` (string, default: `dms.t3.medium`)
- `dms_allocated_storage_gb` (number, default: `50`)
- `dms_task_id` (string, default: `zigi-aurora-to-s3`)
- `name_prefix` (string, default: `zigi`)

### Aurora (Source)
- `aurora_endpoint` (string, requerido)
- `aurora_port` (number, default: `5432`)
- `aurora_username` (string, requerido)
- `aurora_password` (string, requerido, sensitive)
- `aurora_db_name` (string, default: `postgres`)

### S3 Data Lake (Target)
- `datalake_bucket` (string, requerido): bucket destino del data lake
- `datalake_prefix` (string, default: `dms/aurora/`)
- `dms_s3_access_role_arn` (string): IAM role que DMS usa para escribir en S3

> Recomendación: en entornos reales, `aurora_password` debería venir desde __Secrets Manager/SSM y no desde tfvars planos.__

## ⚠️ IMPORTANTE — Particionado por fecha en S3 (DMS) vs Hive-style (Athena/Glue)

Este escenario usa **AWS DMS** para escribir en S3 con particionado por fecha habilitado:

- `date_partition_enabled = true`
- `date_partition_sequence = "YYYYMMDD"`
- `date_partition_delimiter = "SLASH"`

✅ **Resultado:** DMS creará la estructura de carpetas en S3 como:

`.../YYYY/MM/DD/`

Esto optimiza costos de escaneo en Athena cuando consultas por rangos de fechas y reduces el volumen de datos leído.

### Si se requiere Hive-style: `year=YYYY/month=MM/day=DD/` (Athena/Glue partitions)

⚠️ **DMS no genera nativamente el formato Hive-style `key=value`** (`year=`, `month=`, `day=`).
Si el proyecto requiere ese formato (por ejemplo para descubrimiento automático de particiones con Glue/Athena),
se debe agregar un paso posterior:

1. **Glue Job (post-proceso)** que reubique o reescriba los archivos desde:
   - `.../YYYY/MM/DD/`
   hacia:
   - `.../year=YYYY/month=MM/day=DD/`

2. Luego, en Athena, ejecutar:

```sql
MSCK REPAIR TABLE <database>.<table>;