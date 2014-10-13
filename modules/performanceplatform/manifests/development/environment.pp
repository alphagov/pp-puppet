# == Define: performanceplatform::development::environment
#
# Creates a virtualenv in the virtualenvwrapper WORKON_HOME, installs the
# projects requirements.txt and sets a project dir so workon $project will
# change to the correct directory
#
# === Parameters
#
# [*namevar*]
#
# The project name. Used for setting the project directory of 
# /var/apps/$project and the virtualenv dir of 
# "/home/vagrant/.virtualenvs/${project}"
#
# [*postactivate*]
# Content of a postactivate file, which will be sourced when activating the
# virtualenv. Useful for setting required environment variables
# 
# [*requirements_path*]
# Path of a requirements.txt file to install relative to the project route.
# Defaults to requirements.txt
define performanceplatform::development::environment (
  $project = $name,
  $postactivate = false,
  $requirements_path = false
) {
  $virtual_env_dir = "/home/vagrant/.virtualenvs/${project}"
  $project_dir = "/var/apps/${project}"

  if $requirements_path {
    $full_requirements_path = "${project_dir}/${requirements_path}"
  } else {
    $full_requirements_path = "${project_dir}/requirements.txt"
  }

  python::virtualenv {  $virtual_env_dir:
    ensure       => present,
    version      => 'system',
    requirements => $full_requirements_path,
    systempkgs   => true,
    distribute   => false,
    owner        => 'vagrant',
    group        => 'vagrant',
  }

  file { "${virtual_env_dir}/.project":
    content => $project_dir,
    owner   => 'vagrant',
    group   => 'vagrant',
    require => Python::Virtualenv[$virtual_env_dir],
  }

  if $postactivate {
    file { "${virtual_env_dir}/bin/postactivate":
      content => $postactivate,
      owner   => 'vagrant',
      group   => 'vagrant',
      require => Python::Virtualenv[$virtual_env_dir],
    }
  }
}
