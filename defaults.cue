package mesh

import "github.com/greymatter-io/greymatter"

#mesh:          "mesh-sample"
#zone:          "default-zone"
#allInterfaces: "0.0.0.0"
#localhost:     "127.0.0.1"

// Domain
domains: [Name=_]: greymatter.#Domain & {
  name:       string | *"*"
  domain_key: Name
  zone_key:   #zone
}

// Listener
listeners: [Name=_]: greymatter.#Listener & {
  name:         Name
  listener_key: Name
  zone_key:     #zone
  ip:           #allInterfaces
  protocol:     "http_auto"
}

// Cluster
clusters: [Name=_]: greymatter.#Cluster & {
  name:        Name
  cluster_key: Name
  zone_key:    #zone
}

// Proxy
proxies: [Name=_]: greymatter.#Proxy & {
  proxy_key: Name
  name:      Name
  zone_key:  #zone
}

// Route
routes: [Name=_]: greymatter.#Route & {
  zone_key:    #zone
  route_key:   Name
  route_match: greymatter.#RouteMatch | *{path: "/", match_type: "prefix"}
}

// Catalog Service
catalogservices: [Name=_]: #CatalogService & {
  mesh_id:                   #mesh
  service_id:                Name
  enable_instance_metrics:   true
  enable_historical_metrics: false
}

#CatalogService: {
  mesh_id:                   string
  service_id:                string
  name:                      *service_id | string
  version?:                  string
  description?:              string
  api_endpoint?:             string
  api_spec_endpoint?:        string
  business_impact?:          string
  capability?:               string
  owner?:                    string
  owner_url?:                string
  enable_instance_metrics:   true
  enable_historical_metrics: false
}

#gm_metrics_filter: {
  gm_metrics: {
    metrics_host:                               "0.0.0.0"
    metrics_port:                               8081
    metrics_dashboard_uri_path:                 "/metrics"
    metrics_prometheus_uri_path:                "/prometheus"
    metrics_ring_buffer_size:                   4096
    prometheus_system_metrics_interval_seconds: 15
    metrics_key_function:                       "depth"
    metrics_key_depth:                          "3"
    metrics_receiver: {
      redis_connection_string: "redis://127.0.0.1:10910"
      push_interval_seconds:   10
    }
  }
}
