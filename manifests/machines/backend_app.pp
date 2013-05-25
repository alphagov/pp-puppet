class machines::backend_app inherits machines::base {
    ufw::allow { "allow-http-from-backend-lb-1":
        port => 80,
        ip   => 'any',
        from => $hosts['backend-lb-1.backend']['ip'],
    }
    ufw::allow { "allow-https-from-backend-lb-1":
        port => 443,
        ip   => 'any',
        from => $hosts['backend-lb-1.backend']['ip'],
    }
    include nginx::server
    nginx::vhost::proxy { 'backdrop-read-vhost':
        port            => 80,
        servername      => join(['read.backdrop',hiera("domain_name")],'.'),
        ssl             => false,
        upstream_port   => 3038,
    }
    nginx::vhost::proxy { 'backdrop-write-vhost':
        port            => 80,
        servername      => join(['write.backdrop',hiera("domain_name")],'.'),
        ssl             => false,
        upstream_port   => 3039,
    }
}
