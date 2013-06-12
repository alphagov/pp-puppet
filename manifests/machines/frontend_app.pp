# A frontend application server
class machines::frontend_app inherits machines::base {
    ufw::allow { 'allow-http-from-anywhere':
        port => 80,
        ip   => 'any',
    }
    ufw::allow { 'allow-https-from-anywhere':
        port => 443,
        ip   => 'any',
    }
    include nginx::server
    nginx::vhost::proxy { 'admin-vhost':
        port            => 80,
        servername      => join(['admin',hiera('domain_name')],'.'),
        ssl             => false,
        upstream_port   => 8080,
    }
    nginx::vhost::proxy { 'www-vhost':
        port            => 80,
        servername      => join(['www',hiera('domain_name')],'.'),
        ssl             => false,
        upstream_port   => 8080,
    }
    include varnish
}
