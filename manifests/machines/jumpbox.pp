class machines::jumpbox inherits machines::base {
    # Proxy Jenkins to the Deploy Server
    ufw::allow { "allow-http-from-all":
        port => 80,
        ip   => 'any'
    }
    if $environment != 'development' {
        # In development, this rule already exists
        ufw::allow { "allow-ssh-from-anywhere-to-jumpbox":
            port => 22,
            ip   => 'any',
        }
    }
    include nginx::server
    nginx::vhost::proxy { 'deploy-vhost':
        port            => 80,
        servername      => join(['deploy',hiera("domain_name")],'.'),
        ssl             => false,
        upstream_server => 'deploy-1.management',
        upstream_port   => 8080,
    }
}
