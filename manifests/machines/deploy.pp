class machines::deploy inherits machines::base {
    notify { 'Included the Deploy class': }
    # Install Jenkins
    include jenkins
    ufw::allow { "allow-jenkins-from-jumpbox":
        port => 8080,
        ip   => 'any',
        from => $hosts['jumpbox-1.management']['ip']
    }
}
