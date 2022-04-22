package mesh

domains: "lambda": {
	port: 10808
	custom_headers: [
		{
			key:   "Host"
			value: "e6wzyjcwga.execute-api.us-east-1.amazonaws.com"
		},
	]
}

routes: {
	"lambda": {
		domain_key: "edge"
		route_match: {
			path:       "/gateways/lambda/"
			match_type: "prefix"
		}
		prefix_rewrite: "/"
		redirects: [
			{
				from:          "^/gateways/lambda$"
				to:            "/gateways/lambda/"
				redirect_type: "permanent"
			},
		]
		rules: [
			{
				constraints: {
					light: [
						{
							cluster_key: "lambda"
							weight:      1
						},
					]
				}
			},
		]
	}
	"lambda-to-lambda:443": {
		domain_key: "lambda"
		route_match: {
			path:       "/"
			match_type: "prefix"
		}
		prefix_rewrite: "/cap-one-lambda-demo"
		rules: [
			{
				constraints: {
					light: [
						{
							cluster_key: "lambda-to-lambda:443"
							weight:      1
						},
					]
				}
			},
		]
	}
}

clusters: "lambda-to-lambda:443": {
	instances: [{
		host: "BADe6wzyjcwga.execute-api.us-east-1.amazonaws.com"
		port: 443
	}]
	ssl_config: {
		protocols: ["TLSv1.2"]
		require_client_certs: false
		sni:                  "e6wzyjcwga.execute-api.us-east-1.amazonaws.com"
	}
	require_tls: true
}
