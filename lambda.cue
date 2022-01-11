package mesh

routes: "lambda:443": {
	"domain_key": "lambda"
	"route_match": {
		"path":       "/"
		"match_type": "prefix"
	}
	"rules": [
		{
			"constraints": {
				"light": [
					{
						"cluster_key": "lambda-to-lambda:443"
						"weight":      1
					},
				]
			}
		},
	]
}

clusters: "lambda-to-lambda:443": {
	name: "lambda-to-lambda:443"
	instances: [{
		host: "e6wzyjcwga.execute-api.us-east-1.amazonaws.com/cap-one-lambda-demo"
		port: 443
	}]
	ssl_config: {
		protocols: ["TLSv1.2"]
		require_client_certs: false
		sni:                  "e6wzyjcwga.execute-api.us-east-1.amazonaws.com"
	}
	require_tls: true
}
