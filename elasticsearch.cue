package mesh

catalogservices: "elasticsearch": {
	name:         "Elasticsearch (AWS OpenSearch Service)"
	description:  "Search Grey Matter data plane audit log data."
	owner:        "AWS"
	owner_url:    "https://aws.amazon.com/opensearch-service/"
	api_endpoint: "/gateways/elasticsearch/"
	capability:   "Gateway"
}

routes: {
	"elasticsearch": {
		domain_key: "edge"
		route_match: {
			path:       "/gateways/elasticsearch/"
			match_type: "prefix"
		}
		prefix_rewrite: "/"
		redirects: [
			{
				from:          "^/gateways/elasticsearch$"
				to:            "/gateways/elasticsearch/"
				redirect_type: "permanent"
			},
		]
		rules: [
			{
				constraints: {
					light: [
						{
							cluster_key: "elasticsearch"
							weight:      1
						},
					]
				}
			},
		]
	}
	"elasticsearch-to-elasticsearch:443": {
		domain_key: "elasticsearch"
		rules: [
			{
				constraints: {
					light: [
						{
							cluster_key: "elasticsearch-to-elasticsearch:443"
							weight:      1
						},
					]
				}
			},
		]
	}
}

clusters: "elasticsearch-to-elasticsearch:443": {
	instances: [{
		host: "vpc-cap1-xxufxxdmeghw4oigj44dkk2j64.us-east-1.es.amazonaws.com"
		port: 443
	}]
	ssl_config: {
		protocols: ["TLSv1.2"]
		require_client_certs: false
		sni:                  "vpc-cap1-xxufxxdmeghw4oigj44dkk2j64.us-east-1.es.amazonaws.com"
	}
	require_tls: true
}
