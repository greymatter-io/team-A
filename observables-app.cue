package mesh

domains: "observables-app": port: 10808

listeners: "observables-app": {
	port: 10808
	domain_keys: ["observables-app"]
	active_http_filters: [
		"gm.metrics",
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
			metrics_key_depth:                          "3"
			metrics_receiver: {
				redis_connection_string: "redis://127.0.0.1:10910"
				push_interval_seconds:   10
			}
		}
	}
}

proxies: "observables-app": {
  domain_keys: ["observables-app", "observables-app-egress-tcp-to-gm-redis"]
  listener_keys: ["observables-app", "observables-app-egress-tcp-to-gm-redis"]
}

domains: "observables-app-egress-tcp-to-gm-redis": port: 10910

routes: "observables-app-to-gm-redis": {
	domain_key: "observables-app-egress-tcp-to-gm-redis"
	rules: [{
		constraints: {
			light: [{
				cluster_key: "observables-app-to-gm-redis"
				weight:      1
			}]
		}
	}]
}

listeners: "observables-app-egress-tcp-to-gm-redis": {
	port: 10910
	domain_keys: ["observables-app-egress-tcp-to-gm-redis"]
	active_network_filters: ["envoy.tcp_proxy"]
	network_filters: {
		envoy_tcp_proxy: {
			cluster:     "gm-redis"
			stat_prefix: "gm-redis"
		}
	}
}

catalogservices: "observables-app": {
  name: "Grey Matter Observables"
  description: "A standalone application that demonstrates the power of Grey Matter Observables data, allowing users to understand user activity throughout the mesh."
}
