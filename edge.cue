package mesh

domains: edge: {
	port: 10808
	custom_headers: [
		{
			key:   "x-forwarded-proto"
			value: "https"
		},
	]
}

listeners: edge: {
	port: 10808
	domain_keys: ["edge"]
	active_http_filters: [
		"gm.metrics",
		"gm.observables",
		"gm.oidc-authentication",
		"gm.ensure-variables",
		"envoy.jwt_authn",
		"envoy.lua",
		"envoy.rbac"
	]
	http_filters: {
		gm_metrics: {
			metrics_host:                               "0.0.0.0"
			metrics_port:                               8081
			metrics_dashboard_uri_path:                 "/metrics"
			metrics_prometheus_uri_path:                "/prometheus"
			metrics_ring_buffer_size:                   4096
			prometheus_system_metrics_interval_seconds: 15
			metrics_key_function:                       "depth"
			metrics_key_depth:                          "1"
			metrics_receiver: {
				redis_connection_string: "redis://127.0.0.1:10910"
				push_interval_seconds:   10
			}
		}
		gm_observables: {
			topic: "edge"
		}
		"gm_oidc-authentication": {
			accessToken: {
				location: 1
				key:      "access_token"
				cookieOptions: {
					httpOnly: true
					maxAge:   "6h"
					domain:   "next-gen-demo.greymatter.services"
					path: "/"
				}
			}
			idToken: {
				location: 1
				key:      "authz_token"
				cookieOptions: {
					httpOnly: true
					maxAge:   "6h"
					domain:   "next-gen-demo.greymatter.services"
					path: "/"
				}
			}
			tokenRefresh: {
				enabled:   true
				endpoint:  "https://keycloak.greymatter.services:8553"
				realm:     "greymatter"
				timeoutMs: 5000
				useTLS:    false
			}
			serviceUrl:   "https://next-gen-demo.greymatter.services:10808"
			callbackPath: "/oauth"
			provider:     "https://keycloak.greymatter.services:8553/auth/realms/greymatter"
			clientId:     "edge"
			clientSecret: "3a4522e4-6ed0-4ba6-9135-13f0027c4b47"
			additionalScopes: ["openid"]
		}
		"gm_ensure-variables": {
			rules: [
				{
					location: "cookie"
					key:      "access_token"
					copyTo: [
						{
							location: "header"
							key:      "access_token"
						}
					]
				}]
		}
		"envoy_jwt_authn": {
			providers: {
				keycloak: {
					issuer: "https://keycloak.greymatter.services:8553/auth/realms/greymatter",
					audiences: [
						"edge"
					],
					// remote_jwks: {
					// 	http_uri: {
					// 		uri: "https://keycloak.greymatter.services:8553/auth/realms/greymatter/protocol/openid-connect/certs"
					// 		cluster: "edge-to-keycloak",
					// 		timeout: "1s"
					// 	}
					// 	cache_duration: "300s"
					// }
					local_jwks: {
						inline_string: #"""
						{"keys":[{"kid":"-wqLIfvKPA-nzfizy97BzXW-ZNmNEL5vuNA7IteQqRw","kty":"RSA","alg":"RS256","use":"enc","n":"m-qEAv-dqehkBnqMrSn-feu7g_C3hZkTlPB1xpoghacR1MidBYuAp82pCwG0qhG0NEsT76nit4pS3V9gMTXg331kKJtELewDWbyim1v3oU5Tsn2uQJ8tu8FqY7DnnUoZsoxlqRn3mVYDOg7I5qej2nqu8hBPPzWauqNt6YmwUMnkkdX7YYe-LZTgVhhFzwx8inNuGLFDE93L6f-2GnyjLubtMy7XZ32FC9GIWzZqy8KYgDGKkcPt69OsJPUgmaMjBx_k4ZXrUYPKGtCTZJBqK_awXAWDXKub-c3zI2sz8p08EwvMsj5E9CnNr7vR0nukqMvW66LJJoglqJMYTnqN5Q","e":"AQAB","x5c":["MIICozCCAYsCBgF7MffL8jANBgkqhkiG9w0BAQsFADAVMRMwEQYDVQQDDApncmV5bWF0dGVyMB4XDTIxMDgxMDIxMjcwOFoXDTMxMDgxMDIxMjg0OFowFTETMBEGA1UEAwwKZ3JleW1hdHRlcjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAJvqhAL/nanoZAZ6jK0p/n3ru4Pwt4WZE5TwdcaaIIWnEdTInQWLgKfNqQsBtKoRtDRLE++p4reKUt1fYDE14N99ZCibRC3sA1m8optb96FOU7J9rkCfLbvBamOw551KGbKMZakZ95lWAzoOyOano9p6rvIQTz81mrqjbemJsFDJ5JHV+2GHvi2U4FYYRc8MfIpzbhixQxPdy+n/thp8oy7m7TMu12d9hQvRiFs2asvCmIAxipHD7evTrCT1IJmjIwcf5OGV61GDyhrQk2SQaiv2sFwFg1yrm/nN8yNrM/KdPBMLzLI+RPQpza+70dJ7pKjL1uuiySaIJaiTGE56jeUCAwEAATANBgkqhkiG9w0BAQsFAAOCAQEAmxHyFXutsgeNHpzjYEWnsLlWuEGENU7uy3OP5Yg44Bck5eSMImVczLq1EL/tyOsH0omEL5i3re0g09Tdr4fM2bslQnekWDKQhl8IuKrnzNm5AmtDhItgXF6jjeEV4YiNfKxERFOKQj07lHyd/a02DZAoVYF5FkDYG8rFhl8U5aRLUKahPJ8XKLANb5UJ+Jw7O/HbE7dEqopd/8JltTTpWxmE7Uwb/C6R5eUUi2h9ctH+XT6PRWtGYvGGqaI42ED6Wg107GpQgG9/Pc/6P5/7JaIJoR0gSnh6ZMCWYvczfQD8Nz3GoN+2vKzL7kFTYxAvMSO9FdyRoOW1QXU2zRdz9A=="],"x5t":"h4gM4aFODnGQqHcQnpgfnVS8Sn4","x5t#S256":"34ikv_gX-UF_3IooQlRQs0CDg9nxnFAW3ccqt1ce8Mo"},{"kid":"qvyQDIVLm8HSawo-QR_EWgzVNkjjzUM7yVegEq_vg3o","kty":"RSA","alg":"RS256","use":"sig","n":"ofgOqqkaop-9RGXiQ3NYi6GVqciApRBy7kwxgrRS28Evv-c0egiqxBya3TBrkuYbXEMwtYQK6RVrpiHcMbTMmWUCc7e06bsDHINQiZ-8lzSkchcyvHrtM0yT9R6XeWOZ3TFE1hGLbNgOss3CoXyuZCNY2nk9ijGT2hgPVp1PZTWsW7MsJ6ESUSNVA5-PrgtdxECRmowjjx05iaP_nLOnEcd7hOyhmuDcPRuOJ3fku3tSPBLlmX8p-0qxBM45EkUjL3uhV2fDaGF-IdHEKiwXjcw4_m30YW1IEOp8SEJuaHC_ZuhfiuQIgarXEVYNpDNGtBDf7rrqaieQIT5Gfv1bRQ","e":"AQAB","x5c":["MIICozCCAYsCBgF7MffLrDANBgkqhkiG9w0BAQsFADAVMRMwEQYDVQQDDApncmV5bWF0dGVyMB4XDTIxMDgxMDIxMjcwOFoXDTMxMDgxMDIxMjg0OFowFTETMBEGA1UEAwwKZ3JleW1hdHRlcjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKH4DqqpGqKfvURl4kNzWIuhlanIgKUQcu5MMYK0UtvBL7/nNHoIqsQcmt0wa5LmG1xDMLWECukVa6Yh3DG0zJllAnO3tOm7AxyDUImfvJc0pHIXMrx67TNMk/Uel3ljmd0xRNYRi2zYDrLNwqF8rmQjWNp5PYoxk9oYD1adT2U1rFuzLCehElEjVQOfj64LXcRAkZqMI48dOYmj/5yzpxHHe4TsoZrg3D0bjid35Lt7UjwS5Zl/KftKsQTOORJFIy97oVdnw2hhfiHRxCosF43MOP5t9GFtSBDqfEhCbmhwv2boX4rkCIGq1xFWDaQzRrQQ3+666monkCE+Rn79W0UCAwEAATANBgkqhkiG9w0BAQsFAAOCAQEAoIuSxzI3lvbxSZaIZlPOtMi4lWm7Y4lbXaDVGsIUn0oqVMDYGU7+qVwcTXrXBKm93IliA5QKg89mtvAFcSp9pD7U9ZPYRy0kdLFVDsyQZpqWq991uEamPa5A2mJrIbLJphQgE/OmKUGNAZ8EtuMTdCCanECsAUrquTV/3mjF+AFVOvn3fsgd67sk9TLnpkZRNpeToY7TTqkP1br1UQOspw4AaVkCZjn8Mu3OzQ9Oo0OiROAD44QRp9Ll9I0leSI8npIPR/Q1jlfmimn22B00d4i5SwgiqciMZAWNmOHWXqq1qidO15L+4V7yCIuLPXjyWHDEFqolOdm1sh2Qv7spdg=="],"x5t":"qgqM1xQkNt_DGOtVuIHhprB1Ogs","x5t#S256":"54pnvk_g1Hl3G15KeaXiyXe0mRQtqHtclwvBqIUTq2A"}]}
						"""#
					}
					forward: true
					from_headers: [{name: "access_token"}],
					payload_in_metadata: "claims"
				}
			}
			rules: [
				{
					match: { prefix: "/"}
					requires: { provider_name: "keycloak" }
				}
			]
		}
		"envoy_lua": {
			inline_code: """
			  function envoy_on_request(request_handle)
					local access_token = request_handle:headers():get('access_token')
					request_handle:logInfo('access_token: ' .. access_token)

			    local jwt = request_handle:streamInfo():dynamicMetadata():get('envoy.filters.http.jwt_authn')
			  	request_handle:logInfo('extracted email: ' .. jwt.claims.email)
			  end
			"""
		},
    "envoy_rbac":{
      "rules":{
         "action":0,
         "policies":{
            "0-admin":{
               "permissions":[
                  {
                     "any":true
                  }
               ],
               "principals":[
                  {
                     "metadata":{
                        "filter":"envoy.filters.http.jwt_authn",
                        "path":[
                           {
                              "key":"claims"
                           },
                           {
                              "key":"email"
                           }
                        ],
                        "value":{
                           "list_match":{
                              "one_of":{
                                 "string_match":{
                                    "exact":"daniel.cox@gmail.com"
                                 }
                              }
                           }
                        }
                     }
                  }
               ]
            },
            "1-readonly":{
               "permissions":[{
                     "header":{
                        "name":":method",
                        "exact_match":"GET"
                     }
							  }],
               "principals":[ { "any": true } ]
            }
				 }
			}
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
				cluster_key: "edge-to-gm-redis"
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
		path:       "/gateways/aws-es/"
		match_type: "prefix"
	}
	redirects: [
		{
			from:          "^/gateways/aws-es$"
			to:            route_match.path
			redirect_type: "permanent"
		},
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

clusters: {
	"edge-to-aws-es": {
		name: "edge-to-aws-es"
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
	"edge-to-keycloak": {
		name: "edge-to-keycloak"
		instances: [{
			host: "keycloak.greymatter.services"
			port: 8553
		}]
		ssl_config: {
			protocols: ["TLSv1.2"]
			require_client_certs: false
			sni:                  "keycloak.greymatter.services"
		}
		require_tls: true
	}
}
