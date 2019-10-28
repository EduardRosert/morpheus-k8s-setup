#!/usr/bin/env python
# Provision Kubernetes Instances for the European Weather Cloud using Morpheus API 
# see https://docs.morpheusdata.com/en/3.6.4/api/includes/_provisioning.html
#
# requires python3
# requires pymorpheus (https://pypi.org/project/pymorpheus/):  pip install pymorpheus==0.1.5
#
# Make sure to set the following environment variables before running this script:
#    MORPHEUS_USER=<your morpheus username>
#    MORPHEUS_PASS=<your morpheus password>
#    MORPHEUS_URL=<morpheus service url, e.g. https://morpheus.example.com>
#    MORPHEUS_SSLVERIFY=<true to verify ssl cert or false>

import os
import json
import pprint
import sys

import pymorpheus


def main(username, password, morpheusUrl = "https://morpheus.ecmwf.int", sslverify=True):
    c = pymorpheus.MorpheusClient(morpheusUrl, username=username, password=password, sslverify=sslverify)

    req = {
        "name" : "k8s"
    }

    res = c.call(
        'get',
        'instances',
        jsonpayload=json.dumps(req)
    )
    pprint.pprint(res)


if __name__ == '__main__':
    username = os.environ.get('MORPHEUS_USER', "<env 'MORPHEUS_USER' not set>")
    password = os.environ.get('MORPHEUS_PASS', "<env 'MORPHEUS_PASS' not set>")
    url = os.environ.get('MORPHEUS_URL', "https://morpheus.ecmwf.int")
    sslverify = True if os.environ.get('MORPHEUS_SSLVERIFY', "true").lower() == "true" else False
    print("Logging on to '{0}' with user '{1}' ...".format(url, username))
    sys.exit(main(username, password, url, sslverify))