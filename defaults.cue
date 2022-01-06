package mesh

import "github.com/greymatter-io/fabric"

#zone:          "default-zone"
#allInterfaces: "0.0.0.0"
#localhost:     "127.0.0.1"

// Domain 
domains: [Name=_]: fabric.#Domain & {
	name:       string | *"*"
	domain_key: Name
	zone_key:   #zone
}

// Listener
listeners: [Name=_]: fabric.#Listener & {
	name:         Name
	listener_key: Name
	zone_key:     #zone
	ip:           #allInterfaces
	protocol:     "http_auto"
}

// Cluster
clusters: [Name=_]: fabric.#Cluster & {
	name:        Name
	cluster_key: Name
	zone_key:    #zone
}

// Proxy
proxies: [Name=_]: fabric.#Proxy & {
	proxy_key: Name
	name:      Name
	zone_key:  #zone
}

// Route
routes: [Name=_]: fabric.#Route & {
	zone_key:    #zone
	route_key:   Name
	route_match: fabric.#RouteMatch | *{path: "/", match_type: "prefix"}
}
