package mesh

catalogservices: "lambda": {
	name:         "Random Useless Facts"
	description:  "Gets a useless fact via AWS Lambda from https://uselessfacts.jsph.pl."
	api_endpoint: "/services/lambda/"
}

routes: "lambda:443": {
	"domain_key": "lambda"
	"route_match": {
		"path":       "/"
		"match_type": "prefix"
	}
	"prefix_rewrite": "/cap-one-lambda-demo"
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
		host: "e6wzyjcwga.execute-api.us-east-1.amazonaws.com"
		port: 443
	}]
	ssl_config: {
		protocols: ["TLSv1.2"]
		require_client_certs: false
		sni:                  "e6wzyjcwga.execute-api.us-east-1.amazonaws.com"
	}
	require_tls: true
}
