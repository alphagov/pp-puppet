class machines::frontend_app inherits machines::base {
    ufw::allow { "allow-http-from-frontend-lb-1":
        port => 80,
        ip   => 'any',
        from => $hosts['frontend-lb-1.frontend']['ip'],
    }
    ufw::allow { "allow-https-from-frontend-lb-1":
        port => 443,
        ip   => 'any',
        from => $hosts['frontend-lb-1.frontend']['ip'],
    }
    include nginx::server
}
