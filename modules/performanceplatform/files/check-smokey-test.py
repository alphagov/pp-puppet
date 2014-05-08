#!/usr/bin/env python
# encoding: utf-8

"""
Download the JSON results file of pp-smokey from Jenkins. Exit with a code
which can be interpreted as a Sensu check:
http://sensuapp.org/docs/0.12/checks

Example: check-smokey-test.py smoke_test_name

To run locally, do this first:
```
export JENKINS_URL=https://deploy.preview.performance.service.gov.uk
```
Exit codes:
0 = OK
1 = WARNING
2 = CRITICAL
3+ = UNKNOWN
"""


import sys
import json
import os
import unittest
import urllib2

from collections import namedtuple
from operator import add


Step = namedtuple('Step', 'name, status')
Scenario = namedtuple('Scenario', 'name, steps')
Feature = namedtuple('Feature', 'name, uri, scenarios')


def main():
    assert len(sys.argv) == 2, "Usage: {} <feature name>"
    feature_name = sys.argv[1]

    jenkins_url = os.environ.get('JENKINS_URL', 'http://jenkins:8080')
    feature = get_feature(
        load_json(download_results_json(jenkins_url)),
        feature_name)
    if feature is None:
        raise ValueError("No such feature: {}".format(feature_name))

    print_result(feature)
    sys.exit(get_exit_status(feature))


# Utils
def ascii(value):
    return value.encode('ascii', 'ignore')


def download_results_json(jenkins_url):
    response = urllib2.urlopen(
        jenkins_url + '/job/pp-smokey/lastBuild/artifact/results.json')
    return response.read()


def load_json(json_content):
    return json.loads(json_content)


# Loading from JSON
def get_feature(smokey_json, feature_name):
    for feature_json in smokey_json:
        if feature_json['uri'] == get_feature_uri(feature_name):
            return Feature(
                ascii(feature_json['name']),
                ascii(feature_json['uri']),
                map(get_scenario, find_scenarios(feature_json)))


def get_feature_uri(feature_name):
    return 'features/{}.feature'.format(feature_name)


def find_scenarios(feature_json):
    return [element for element in feature_json['elements']
            if element['keyword'] == 'Scenario']


def get_scenario(scenario_json):
    return Scenario(
        ascii(scenario_json['name']),
        map(get_step, scenario_json['steps']))


def get_step(step):
    return Step(
        "{}{}".format(ascii(step['keyword']), ascii(step['name'])),
        step['result']['status'])


# Counting steps
def count_failing_steps(feature):
    return count_steps_by_status(feature, 'failed')


def count_passing_steps(feature):
    return count_steps_by_status(feature, 'passed')


def count_steps_by_status(feature, status):
    return len([step for step in get_feature_steps(feature)
               if step.status == status])


def get_feature_steps(feature):
    return reduce(add,
                  [scenario.steps for scenario in feature.scenarios])


# Rendering as text
def feature_message(feature):
    return ('{failing} failed, {passing} passed;\n'
            '{name} ({uri})\n{scenarios}').format(
                failing=count_failing_steps(feature),
                passing=count_passing_steps(feature),
                name=feature.name,
                uri=feature.uri,
                scenarios="\n".join(map(scenario_message, feature[2])))


def scenario_message(scenario):
    return "  Scenario: {name}\n{steps}".format(
        name=scenario.name,
        steps="\n".join(map(step_message, scenario.steps)))


def step_message(step):
    return '    Step: [{status}] {name}'.format(
        name=step.name,
        status='PASS' if step.status == "passed" else 'FAIL')


def print_result(feature):
    """
    Status message for Sensu - this will show up in any alerts.
    """
    print(feature_message(feature))


def get_exit_status(feature):
    exit_status = 2 if count_failing_steps(feature) > 0 else 0
    print("Exiting with code: {0}".format(exit_status))
    return exit_status


if __name__ == '__main__':
    main()


_PASS_JSON = """
[
  {
    "keyword": "Feature",
    "name": "admin_uploader",
    "line": 1,
    "description": "",
    "id": "admin-uploader",
    "uri": "features/admin_uploader.feature",
    "elements": [
      {
        "keyword": "Scenario",
        "name": "Quickly loading the admin home page",
        "line": 4,
        "description": "",
        "tags": [
          {
            "name": "@normal",
            "line": 3
          }
        ],
        "id": "admin-uploader;quickly-loading-the-admin-home-page",
        "type": "scenario",
        "steps": [
          {
            "keyword": "Given ",
            "name": "the admin application has booted",
            "line": 5,
            "match": {
              "arguments": [
                {
                  "offset": 5,
                  "val": "admin"
                }
              ],
              "location": "features/step_definitions/smokey_steps.rb:1"
            },
            "result": {
              "status": "passed",
              "duration": 85938650
            }
          },
          {
            "keyword": "And ",
            "name": "I am benchmarking",
            "line": 6,
            "match": {
              "location": "features/step_definitions/benchmarking_steps.rb:1"
            },
            "result": {
              "status": "passed",
              "duration": 439216
            }
          },
          {
            "keyword": "When ",
            "name": "I visit the admin home page",
            "line": 7,
            "match": {
              "location": "features/step_definitions/admin_steps.rb:11"
            },
            "result": {
              "status": "passed",
              "duration": 58540642
            }
          },
          {
            "keyword": "Then ",
            "name": "the elapsed time should be less than 1 seconds",
            "line": 8,
            "match": {
              "arguments": [
                {
                  "offset": 37,
                  "val": "1"
                }
              ],
              "location": "features/step_definitions/benchmarking_steps.rb:5"
            },
            "result": {
              "status": "passed",
              "duration": 593808
            }
          }
        ]
      }
    ]
  }
]
"""

_FAIL_JSON = """
[
  {
    "keyword": "Feature",
    "name": "admin_uploader",
    "line": 1,
    "description": "",
    "id": "admin-uploader",
    "uri": "features/admin_uploader.feature",
    "elements": [
      {
        "keyword": "Scenario",
        "name": "Quickly loading the admin home page",
        "line": 4,
        "description": "",
        "tags": [
          {
            "name": "@normal",
            "line": 3
          }
        ],
        "id": "admin-uploader;quickly-loading-the-admin-home-page",
        "type": "scenario",
        "steps": [
          {
            "keyword": "Given ",
            "name": "the admin application has booted",
            "line": 5,
            "match": {
              "arguments": [
                {
                  "offset": 5,
                  "val": "admin"
                }
              ],
              "location": "features/step_definitions/smokey_steps.rb:1"
            },
            "result": {
              "status": "failed",
              "duration": 85938650
            }
          },
          {
            "keyword": "And ",
            "name": "I am benchmarking",
            "line": 6,
            "match": {
              "location": "features/step_definitions/benchmarking_steps.rb:1"
            },
            "result": {
              "status": "passed",
              "duration": 439216
            }
          },
          {
            "keyword": "When ",
            "name": "I visit the admin home page",
            "line": 7,
            "match": {
              "location": "features/step_definitions/admin_steps.rb:11"
            },
            "result": {
              "status": "passed",
              "duration": 58540642
            }
          },
          {
            "keyword": "Then ",
            "name": "the elapsed time should be less than 1 seconds",
            "line": 8,
            "match": {
              "arguments": [
                {
                  "offset": 37,
                  "val": "1"
                }
              ],
              "location": "features/step_definitions/benchmarking_steps.rb:5"
            },
            "result": {
              "status": "passed",
              "duration": 593808
            }
          }
        ]
      }
    ]
  }
]
"""


class JsonParsingTestCase(unittest.TestCase):
    def test_correctly_identifies_successful_test(self):
        feature = get_feature(
            load_json(_PASS_JSON),
            'admin_uploader')
        assert 0 == get_exit_status(feature)

    def test_correctly_identifies_failed_test(self):
        feature = get_feature(
            load_json(_FAIL_JSON),
            'admin_uploader')
        assert 2 == get_exit_status(feature)
