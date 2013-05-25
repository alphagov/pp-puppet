class machines::backend_lb inherits machines::base {
    notify { 'Included the Backend-lb class': }
    #Loadbalance to backend-app machines
    ufw::allow { "allow-http-from-all":
        port => 80,
        ip   => 'any'
    }
    include nginx::server
    nginx::loadbalancer { 'backend-lb':
        port    => 80,
        workers => grep(keys($hosts),'backend-app')
    }
}
