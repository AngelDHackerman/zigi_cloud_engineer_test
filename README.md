# zigi_cloud_engineer_test


## Escenario 2:

El cert del servidor viene de ACM; el trust bundle (CA) se monta en el sidecar Envoy y se referencia por file. En producción, preferiría SDS con Kubernetes Secret para rotación.