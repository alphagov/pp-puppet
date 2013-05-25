class machines::frontend_lb inherits machines::base {
    notify { 'Included the Frontend-lb class': }
    #Loadbalance to frontend-app machines
    ufw::allow { "allow-http-from-all":
        port => 80,
        ip   => 'any'
    }
    include nginx::server
    nginx::loadbalancer { 'frontend-lb':
        port    => 80,
        workers => grep(keys($hosts),'frontend-app')
    }
}
