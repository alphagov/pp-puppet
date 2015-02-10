class performanceplatform::checks::celery_worker() {
  sensu::check { 'celery_worker_is_down':
    command  => "/etc/sensu/community-plugins/plugins/processes/check-procs.rb -p 'celery' -C 1 -W 1",
    interval => 60,
    handlers => ['default']
  }

  performanceplatform::checks::graphite { 'check_celery_worker_error_rate':
    # Ratio of error/success over 1hr period
    target   => "divideSeries(hitcount(stats.pp.apps.backdrop.transformers.worker.run_transform.error,'1hr'), hitcount(stats.pp.apps.backdrop.transformers.worker.run_transform.success,'1hr'))",
    warning  => '0.01',
    critical => '0.05',
    interval => 60,
    handlers => ['default'],
  }
}
