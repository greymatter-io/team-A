package mesh

catalogservices: "elasticsearch": {
	name:         "Vector Index (Elasticsearch)"
	description:  "Search log data shipped from Vector (stored in AWS OpenSearch Service)."
	owner:        "AWS"
	owner_url:    "https://aws.amazon.com/opensearch-service/"
	api_endpoint: "/gateways/elasticsearch/"
	capability:   "Gateway"
}

routes: "elasticsearch-to-elasticsearch:443": {
	domain_key: "elasticsearch"
	route_match: {
		path:       "/"
		match_type: "prefix"
	}
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

clusters: "elasticsearch-to-elasticsearch:443": {
	name: "elasticsearch-to-elasticsearch:443"
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
