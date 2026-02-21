resource "aws_appmesh_mesh" "this_mesh" {
  name = var.mesh_name
}

resource "aws_appmesh_virtual_node" "api_customer" {
    name = "api-customer"
    mesh_name = aws_appmesh_mesh.this_mesh.name

    spec {
      listener {
        port_mapping {
        port     = var.listener_port
        protocol = "http"
      }
      }

      # TLS para terminación en el Virtual Node usando ACM (requerimiento)
      tls {
        mode = "STRICT"

        certificate {
            acm {
                certificate_arn = var.acm_server_cert_arn
            }
        }
      }
    }
}