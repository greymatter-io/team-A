package mesh

catalogmeshes: "mesh-sample": {
	mesh_type: "greymatter"
	name:      "nextgen-demo.k8s.local"
	sessions: default: {
		url:  "control.greymatter.svc.cluster.local:50000"
		zone: #zone
	}
	extensions: {
		metrics: sessions: redis: {
			client_type:       "redis"
			connection_string: "redis://127.0.0.1:10910"
		}
	}
	external_links: [
		{
			title: "Grey Matter Home Page"
			url:   "https://greymatter.io"
		},
	]
}
