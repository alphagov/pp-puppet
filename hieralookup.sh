


depending on args either:

lookup_array(){
    bundle exec hiera -c hiera.yaml -a $0 "::machine_role={$2}"
}

lookup_hash(){
    bundle exec hiera -c hiera.yaml -h $0 "::machine_role={$2}"
}
