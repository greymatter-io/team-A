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
catalogservices: [Name=_]: {
	mesh_id:    #mesh
	service_id: Name
	enable_instance_metrics: true
	enable_historical_metrics: true
}
