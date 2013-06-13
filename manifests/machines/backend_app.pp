# Setup a backend application server
class machines::backend_app inherits machines::base {
    class { 'python':
        version    => '2.7',
        dev        => true,
        virtualenv => true,
    }
    backdrop::app {'read.backdrop':
        port        => 3038,
        app_module  => 'backdrop.read.api:app',
        user        => 'deploy',
        group       => 'deploy',
    }

    backdrop::app {'write.backdrop':
        port        => 3039,
        app_module  => 'backdrop.write.api:app',
        user        => 'deploy',
        group       => 'deploy',
    }

}
