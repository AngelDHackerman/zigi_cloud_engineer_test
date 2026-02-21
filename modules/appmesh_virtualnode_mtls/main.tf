resource "aws_appmesh_mesh" "this_mesh" {
  name = var.mesh_name
}

resource "aws_appmesh_virtual_node" "api_customer" {
  name      = "api-customer"
  mesh_name = aws_appmesh_mesh.this_mesh.name

  spec {
    listener {
      port_mapping {
        port     = var.listener_port
        protocol = "http"
      }

      tls {
        mode = "STRICT" # Obliga a usar TLS

        certificate {
          acm {
            certificate_arn = var.acm_server_cert_arn
          }
        }

        # Validación para Trust mTLS:
        # Aquí el Virtual Node actúa como servidor y valida que el certificado 
        # del CLIENTE sea confiable según el bundle de CA local especificado.
        validation {
          trust {
            file {
              certificate_chain = var.trust_ca_bundle_path
            }
          }
        }
      }
    }

    # Forzar que TODO tráfico saliente a otros nodos use TLS (mTLS a nivel Mesh)
    backend_defaults {
      client_policy {
        tls {
          enforce = true
          validation {
            trust {
              acm {
                certificate_authority_arns = var.acm_private_ca_arns
              }
            }
          }
        }
      }
    }


  }
}