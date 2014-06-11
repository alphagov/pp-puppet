#!/bin/bash -e

function run_rake_tests {
    bundle exec rake
    echo "Rake tests successful."
}

function run_python_tests {
    cd modules/performanceplatform/files
    python -m unittest check-smokey-test check_elasticsearch_log_errors

    echo "Python tests successful."
}

run_rake_tests
run_python_tests
