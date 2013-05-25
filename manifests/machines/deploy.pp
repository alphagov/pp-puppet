class machines::deploy inherits machines::base {
    notify { 'Included the Deploy class': }
    # Install Jenkins
    include jenkins
    ufw::allow { "allow-jenkins-from-jumpbox":
        port => 8080,
        ip   => 'any',
        from => '10.0.0.11'
    }
}
