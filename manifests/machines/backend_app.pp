class machines::backend_app inherits machines::base {
    notify { 'Included the Backend-App class': }
    ufw::allow { "allow-http-from-backend-lb-1":
        port => 80,
        ip   => 'any'
        from => $hosts['backend-lb-1']['ip']
    }
    ufw::allow { "allow-https-from-backend-lb-1":
        port => 443,
        ip   => 'any'
        from => $hosts['backend-lb-1']['ip']
    }
    include nginx::server
}
