class performanceplatform::backdrop_checks (
) {
    $check_data_path = '/etc/sensu/community-plugins/plugins/http/check-http.rb'

    sensu::check { abackdrop_heath_check:
      command  => "${check_data_path}  -u http://localhost/_status",
    }
}
