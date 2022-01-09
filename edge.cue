package mesh

domains: edge: {
	port: 10808
	custom_headers: [
		{
			key: "x-forwarded-proto",
			value: "https"
		}
	]
}

listeners: edge: {
	port: 10808
	domain_keys: ["edge"]
	active_http_filters: [
		"gm.metrics",
		// "gm.oidc-authentication",
		// "gm.ensure-variables",
	]
	http_filters: {
		gm_metrics: {
			metrics_host:                               "0.0.0.0"
			metrics_port:                               8081
			metrics_dashboard_uri_path:                 "/metrics"
			metrics_prometheus_uri_path:                "prometheus"
			metrics_ring_buffer_size:                   4096
			prometheus_system_metrics_interval_seconds: 15
			metrics_key_function:                       "depth"
			metrics_key_depth:                          "1"
			metrics_receiver: {
				redis_connection_string: "redis://127.0.0.1:10910"
				push_interval_seconds:   10
			}
		}
		"gm_oidc-authentication": {
			"accessToken": {
				"location": 1
				"key":      "access_token"
				"cookieOptions": {
					"httpOnly": true
					"maxAge":   "6h"
					"domain":   "a12f7eb7bb4464e45a0d18700e0d177b-2141129942.us-east-1.elb.amazonaws.com"
					// "domain":   "subdomain.greymatter.services"
					"path": "/"
				}
			}
			"idToken": {
				"location": 1
				"key":      "authz_token"
				"cookieOptions": {
					"httpOnly": true
					"maxAge":   "6h"
					"domain":   "a12f7eb7bb4464e45a0d18700e0d177b-2141129942.us-east-1.elb.amazonaws.com"
					// "domain":   "subdomain.greymatter.services"
					"path": "/"
				}
			}
			"tokenRefresh": {
				"enabled":   true
				"endpoint":  "http://keycloak.greymatter.services:8080"
				"realm":     "greymatter"
				"timeoutMs": 5000
				"useTLS":    false
			}
			"serviceUrl":   "http://a12f7eb7bb4464e45a0d18700e0d177b-2141129942.us-east-1.elb.amazonaws.com:10808"
			"callbackPath": "/oauth"
			"provider":     "http://keycloak.greymatter.services:8080/auth/realms/greymatter"
			"clientId":     "edge"
			"clientSecret": "3a4522e4-6ed0-4ba6-9135-13f0027c4b47"
			"additionalScopes": ["openid"]
		}
		"gm_ensure-variables": {
			"rules": [
				{
					"location": "header"
					"key":      "Authorization"
					"value": {
						"matchType":   "regex"
						"matchString": "Bearer\\s+(\\S+).*"
					}
					"copyTo": [
						{
							"location": "header"
							"key":      "access_token"
						},
					]
				},
				{
					"location": "cookie"
					"key":      "access_token"
					"copyTo": [
						{
							"location": "header"
							"key":      "access_token"
						},
					]
				},
				{
					"location": "cookie"
					"key":      "authz_token"
					"copyTo": [
						{
							"location": "header"
							"key":      "authz_token"
						},
					]
				},
				{
					"location": "cookie"
					"key":      "refresh_token"
					"copyTo": [
						{
							"location": "header"
							"key":      "refresh_token"
						},
					]
				},
			]
		}
	}
}

proxies: edge: {
	domain_keys: ["edge", "edge-egress-tcp-to-gm-redis"]
	listener_keys: ["edge", "edge-egress-tcp-to-gm-redis"]
}

domains: "edge-egress-tcp-to-gm-redis": port: 10910

routes: "edge-to-gm-redis": {
	domain_key: "edge-egress-tcp-to-gm-redis"
	rules: [{
		constraints: {
			light: [{
				cluster_key: "gm-redis"
				weight:      1
			}]
		}
	}]
}

listeners: "edge-egress-tcp-to-gm-redis": {
	port: 10910
	domain_keys: ["edge-egress-tcp-to-gm-redis"]
	active_network_filters: ["envoy.tcp_proxy"]
	network_filters: {
		envoy_tcp_proxy: {
			cluster:     "gm-redis"
			stat_prefix: "gm-redis"
		}
	}
}

// Edge to AWS Elasticsearch (egress)

routes: "edge-to-aws-es": {
	domain_key: "edge"
  route_match: {
    path: "/gateways/aws-es/"
    match_type: "prefix"
  }
  redirects: [
    {
      from: "^/gateways/aws-es$"
      to: route_match.path
      redirect_type: "permanent"
    }
  ]
  prefix_rewrite: "/"
	rules: [{
		constraints: {
			light: [{
				cluster_key: "edge-to-aws-es"
				weight:      1
			}]
		}
	}]
}

clusters: "edge-to-aws-es": {
	name: "edge-to-aws-es"
	instances: [{
		host: "vpc-cap1-xxufxxdmeghw4oigj44dkk2j64.us-east-1.es.amazonaws.com",
		port: 443
	}]
	ssl_config:{
		protocols: ["TLSv1.2"]
		require_client_certs: false
		sni: "vpc-cap1-xxufxxdmeghw4oigj44dkk2j64.us-east-1.es.amazonaws.com"
	}
	require_tls: true
}
