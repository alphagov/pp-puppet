class performanceplatform::python_lxml_deps() {

  package { 'python-dev':
    ensure  => installed,
  }

  package { 'libxml2-dev':
    ensure  => installed,
  }

  package { 'libxstlt1-dev':
    ensure  => installed,
  }
}
