package mesh

domains: "lambda2": {
	port: 10808
	custom_headers: [
		{
			key:   "Host"
			value: "e6wzyjcwga.execute-api.us-east-1.amazonaws.com"
		},
	]
}

routes: {
	"lambda2": {
		domain_key: "edge"
		route_match: {
			path:       "/gateways/lambda2/"
			match_type: "prefix"
		}
		prefix_rewrite: "/"
		redirects: [
			{
				from:          "^/gateways/lambda2$"
				to:            "/gateways/lambda2/"
				redirect_type: "permanent"
			},
		]
		rules: [
			{
				constraints: {
					light: [
						{
							cluster_key: "lambda2"
							weight:      1
						},
					]
				}
			},
		]
	}
	"lambda2-to-lambda2:443": {
		domain_key: "lambda2"
		route_match: {
			path:       "/"
			match_type: "prefix"
		}
		prefix_rewrite: "/cap-one-lambda2-demo"
		rules: [
			{
				constraints: {
					light: [
						{
							cluster_key: "lambda2-to-lambda2:443"
							weight:      1
						},
					]
				}
			},
		]
	}
}

clusters: "lambda2-to-lambda2:443": {
	instances: [{
		host: "e6wzyjcwga.execute-api.us-east-1.amazonaws.com"
		port: 443
	}]
	ssl_config: {
		protocols: ["TLSv1.2"]
		require_client_certs: false
		sni:                  "e6wzyjcwga.execute-api.us-east-1.amazonaws.com"
	}
	require_tls: true
	// circuit_breakers: {
	//  max_connections:      1
	//  max_pending_requests: 1
	//  max_retries:          1
	//  max_requests:         1
	//  max_connection_pools: 1
	//  track_remaining:      true
	//  high: {
	//   max_connections:      1
	//   max_pending_requests: 1
	//   max_retries:          1
	//   max_requests:         1
	//   max_connection_pools: 1
	//   track_remaining:      true
	//  }
	// }
}
