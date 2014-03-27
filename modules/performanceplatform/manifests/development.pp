class performanceplatform::development (
  $stagecraft_password
) {
  postgresql::server::role { 'stagecraft':
    createdb => true,
    password_hash => postgresql_password('stagecraft', $stagecraft_password),
  }
}
