# == Class: azul::repo
#
# Azul provide Zulu, which is a production-ready OpenJDK distribution.
# It looks like we should test it.
#
# === Parameters
#
# == Usage
#
# include azul::repo
#
class azul::repo (
) {
  apt::source { 'azul-repo':
    location     => "http://repos.azulsystems.com/ubuntu",
    architecture => $::architecture,
    key          => '219BD9C9',
  }
}
