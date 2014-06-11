#!/usr/bin/env python
# encoding: utf-8

import datetime
import json
import urllib2
import sys


def get_exit_status(response_json):
    response_data = json.loads(response_json)
    from pprint import pprint
    hits = response_data['hits']['hits']
    print("{} log matches".format(len(hits)))
    for i, hit in enumerate(hits):
        print("--- Log message #{} --- ".format(i + 1))
        pprint(hit['_source'])

    #we will have alot to begin with
    return 1 if len(hits) > 0 else 0


def main():
    assert len(sys.argv) == 2, "Usage: {} <query json>"
    with open(sys.argv[1], 'r') as file:
        query_json = json.loads(file.read())
    now = datetime.datetime.now().date()
    es_host = 'elasticsearch:9200'
    #uncomment to run locally
    #es_host = 'elasticsearch.production.performance.service.gov.uk'
    es_index = 'logstash-{year:04}.{month:02}.{day:02}'.format(
        year=now.year, month=now.month, day=now.day)

    request = urllib2.Request(
        'http://{}/{}/_search'.format(es_host, es_index),
        #uncomment to run locally
        #'https://{}/{}/_search'.format(es_host, es_index),
        data=json.dumps(query_json),
        headers={'Content-Type': 'application/json'})
    response = urllib2.urlopen(request)
    sys.exit(get_exit_status(response.read()))

if __name__ == '__main__':
    main()

import unittest
PASS_JSON = """
{
  "took":28,
  "timed_out":false,
  "_shards":{
    "total":5,
    "successful":5,
    "failed":0
  },
  "hits":{
    "total":8,
    "max_score":null,
    "hits":[]
  }
}
"""
FAIL_JSON = """
{
  "took":28,
  "timed_out":false,
  "_shards":{
    "total":5,
    "successful":5,
    "failed":0
  },
  "hits":{
    "total":8,
    "max_score":null,
    "hits":[{"_source": "a source"}]
  }
}
"""


class ElasticSearchLogErrorsTestCase(unittest.TestCase):
    def test_correctly_identifies_no_error_response(self):
        assert 0 == get_exit_status(PASS_JSON)

    def test_correctly_identifies_error_resonse(self):
        assert 1 == get_exit_status(FAIL_JSON)
