package mesh

catalogservices: {
	edge: {
		"name":            "Grey Matter Edge"
		"version":         "1.7.0"
		"description":     "Handles north/south traffic flowing through the mesh."
		"owner":           "Grey Matter"
		"owner_url":       "https://greymatter.io"
		"api_endpoint":    "/"
		"capability":      "mesh"
		"business_impact": "critical"
	}

	control: {
		"name":              "Grey Matter Control"
		"version":           "1.7.0"
		"description":       "Manages the configuration of the Grey Matter data plane."
		"owner":             "Grey Matter"
		"owner_url":         "https://greymatter.io"
		"api_endpoint":      "/services/control/api/v1.0/"
		"api_spec_endpoint": "/services/control/api/"
		"capability":        "mesh"
		"business_impact":   "critical"
	}

	catalog: {
		"name":              "Grey Matter Catalog"
		"version":           "3.0.0"
		"description":       "Interfaces with the control plane to expose the current state of the mesh."
		"owner":             "Grey Matter"
		"owner_url":         "https://greymatter.io"
		"api_endpoint":      "/services/catalog/"
		"api_spec_endpoint": "/services/catalog/"
		"capability":        "mesh"
		"business_impact":   "high"
	}

	dashboard: {
		"name":            "Grey Matter Dashboard"
		"version":         "6.0.0"
		"description":     "A user dashboard that paints a high-level picture of the mesh."
		"owner":           "Grey Matter"
		"owner_url":       "https://greymatter.io"
		"capability":      "mesh"
		"business_impact": "high"
	}

	"jwt-security": {
		"name":              "Grey Matter JWT Security"
		"version":           "1.3.0"
		"description":       "A JWT token generation and retrieval service."
		"owner":             "Grey Matter"
		"owner_url":         "https://greymatter.io"
		"api_endpoint":      "/services/jwt-security/"
		"api_spec_endpoint": "/services/jwt-security/"
		"capability":        "mesh"
		"business_impact":   "high"
	}
}
