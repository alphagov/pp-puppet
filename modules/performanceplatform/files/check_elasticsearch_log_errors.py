#!/usr/bin/env python
# encoding: utf-8

import datetime
import json
import requests


JSON_REQUEST = {
  "query": {
    "filtered": {
      "query": {
        "bool": {
          "should": [
            {
              "query_string": {
                "query": "*"
              }
            }
          ]
        }
      },
      "filter": {
        "bool": {
          "must": [
            {
              "range": {
                "@timestamp": {
                  "from": "now-1h",
                  "to": "now"
                }
              }
            },
            {
              "fquery": {
                "query": {
                  "field": {
                    "@fields.levelname": {
                      "query": "\"ERROR\""
                    }
                  },
                },
                "_cache": True
              }
            },
            {
              "fquery": {
                "query": {
                  "field": {
                    "@tags": {
                      "query": "\"collector\""
                    }
                  }
                },
                "_cache": True
              }
            },
          ]
        }
      }
    }
  },
  "size": 500,
  "sort": [
    {
      "@timestamp": {
        "order": "desc"
      }
    }
  ]
}


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
    now = datetime.datetime.now().date()
    es_host = 'elasticsearch:9200'
    #uncomment to run locally
    #es_host = 'elasticsearch.production.performance.service.gov.uk'
    es_index = 'logstash-{year:04}.{month:02}.{day:02}'.format(
        year=now.year, month=now.month, day=now.day)

    response = requests.post(
        'http://{}/{}/_search'.format(es_host, es_index),
        #uncomment to run locally
        #'https://{}/{}/_search'.format(es_host, es_index),
        headers={'Content-Type': 'application/json'},
        data=json.dumps(JSON_REQUEST))
    response.raise_for_status()
    return get_exit_status(response.content)

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
