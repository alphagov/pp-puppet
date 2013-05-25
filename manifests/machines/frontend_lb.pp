# A dumb frontend loadbalancer class
class machines::frontend_lb inherits machines::base {
    #Loadbalance to frontend-app machines
    ufw::allow { 'allow-http-from-all':
        port => 80,
        ip   => 'any'
    }
    include nginx::server
    $workers = grep(keys($hosts),'frontend-app')
    nginx::loadbalancer { 'frontend-lb':
        port    => 80,
        workers => $workers,
        require => Host[$workers],
    }
}
