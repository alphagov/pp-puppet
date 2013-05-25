class machines::backend_lb inherits machines::base {
    #Loadbalance to backend-app machines
    ufw::allow { "allow-http-from-all":
        port => 80,
        ip   => 'any'
    }
    include nginx::server
    $workers = grep(keys($hosts),'backend-app')
    nginx::loadbalancer { 'backend-lb':
        port    => 80,
        workers => $workers,
        require => Host[$workers],
    }
}
