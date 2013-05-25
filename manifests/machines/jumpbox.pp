class machines::jumpbox inherits machines::base {
    notify { 'Included the Jumpbox class': }
    # Proxy Jenkins to the Deploy Server
    ufw::allow { "allow-http-from-all":
        port => 80,
        ip   => 'any'
    }
    ufw::allow { "allow-ssh-from-anywhere":
        port => 22,
        ip   => 'any',
    }
    include nginx::server
    nginx::vhost::proxy { 'deploy-vhost':
        port            => 80,
        servername      => join(['deploy',hiera("domain_name")],'.'),
        ssl             => false,
        template        => 'nginx/vhost-proxy.conf.erb',
        upstream_server => 'deploy-1.management',
        upstream_port   => 8080,
    }
}
