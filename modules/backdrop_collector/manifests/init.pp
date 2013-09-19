class backdrop_collector {

    # Set up directories and whatnot for the collectors
    $backdrop_collectors = hiera_hash( 'backdrop_collectors', {} )
    if !empty($backdrop_collectors) {
        create_resources( 'backdrop_collector::app', $backdrop_collectors )
    }

}
