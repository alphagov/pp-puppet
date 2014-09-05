class performanceplatform::pip($user, $group, $pip_cache_path) {
    file { $pip_cache_path:
        ensure  => directory,
        path    => $pip_cache_path,
        owner   => $user,
        group   => $group,
        recurse => true,
    }
}
