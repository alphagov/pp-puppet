class performanceplatform::development {
  postgresql::server::role { 'stagecraft':
    createdb => true,
  }
}
