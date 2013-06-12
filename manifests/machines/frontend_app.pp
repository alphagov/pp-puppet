# A frontend application server
class machines::frontend_app inherits machines::base {
    ufw::allow { 'allow-http-from-frontend-lb-1':
        port => 80,
        ip   => 'any',
        from => $hosts['frontend-lb-1.frontend']['ip'],
    }
    ufw::allow { 'allow-https-from-frontend-lb-1':
        port => 443,
        ip   => 'any',
        from => $hosts['frontend-lb-1.frontend']['ip'],
    }
    include nginx::server
    include varnish
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
}
