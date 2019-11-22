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
#    WORKERS=<number of worker nodes, e.g. 16 (default 2)>

import os
import json
import pprint
import sys
import argparse
import pymorpheus

parser = argparse.ArgumentParser(
    description='A tool to create kubernetes controller or worker nodes in your morpheus instance.',
    add_help=True)

parser.add_argument('-m', '--morpheus-url',
                    metavar="https://morpheus.example.com",
                    dest='url',
                    type=str,
                    required=False,
                    help='the url of your morpheus instance')

parser.add_argument('-s', '--ssl-verify',
                    choices=["true", "false"],
                    dest='sslverify',
                    default="true",
                    type=str,
                    required=False,
                    help='verify SSL certificate (default: true)')

parser.add_argument('-u', '--user',
                    metavar="your_username",
                    dest='username',
                    type=str,
                    required=False,
                    help='your morpheus username')

parser.add_argument('-p', '--pass',
                    metavar="your_password",
                    dest='password',
                    type=str,
                    required=False,
                    help='your morpheus password')

def main(username, password, morpheusUrl = "https://morpheus.ecmwf.int", sslverify=True, workers=2):
    c = pymorpheus.MorpheusClient(morpheusUrl, username=username, password=password, sslverify=sslverify)

    numdigits = str(len(str(workers-1))) # number of digits for worker number, e.g. 3 for 199 workers
    name_pattern = 'k8s-worker-{0:0' + numdigits + 'd}' # e.g. 'k8s-worker-{0:02d}'

    req = {
        'instance': {
            'name': name_pattern.format(0),
            'site': {
                'id': 6,
            },
            'instanceType': {
                # 'code': 'ewc', # CentOS 7.5, id: 75
                'code': 'UBU1804' # Ubuntu 18.04, id: 77
            },
            'layout': {
                #'id': 1177 # CentOS 7.5
                'id': 1213 # Ubuntu 18.04
            },
            'plan': {
            #    'id': 468, # m1.medium-large
                 'id': 472, # m1.xlarge
            #    'id': 473, #m1.large-xlarge
            }
        },
        'volumes': [
            {
                # /dev/vda
                #'id': -1,
                'name': 'k8s-root',
                'rootVolume': True,
                'size': 25,
            },
            {
                # /dev/vdb
                #'id': -1,
                'name': 'k8s-data-1',
                'rootVolume': False,
                'size': 100,
                #'sizeId': None,
                #'storageType': 4,
            },
            {
                # /dev/vdc
                #'id': -1,
                'name': 'k8s-data-2',
                'rootVolume': False,
                'size': 100,
                #'storageType': 4,
            }
        ],
        'networkInterfaces': [
            {
                'network': {
                    'id': 53,
                },
                'networkInterfaceTypeId': None,
            }
        ],
        # this did not work:
        # 'securityGroups': [
        #     {
        #         'id': 256,
        #     }
        # ],
        'zoneId': 9,
        'securityGroup': 'DWD-allowAll',
        'taskSetName': 'Install Kubernetes Worker',
    }

    for i in range(workers):
        req['instance']['name'] = name_pattern.format(i)
        res = c.call(
            'post',
            'instances',
            jsonpayload=json.dumps(req)
        )
        pprint.pprint(res)


if __name__ == '__main__':

    # try read from env
    username = os.environ.get('MORPHEUS_USER', None)
    password = os.environ.get('MORPHEUS_PASS', None)
    url = os.environ.get('MORPHEUS_URL', None)
    sslverify = False if os.environ.get('MORPHEUS_SSLVERIFY', "true").lower() == "false" else True
    workers = os.environ.get('WORKERS', "1")

    # override env from explicit command line options
    args = parser.parse_args()
    if args.sslverify is not None:
        sslverify = False if args.sslverify == "false" else True

    if args.url is not None:
        url = args.url
    
    if args.username is not None:
        username = args.username
    
    if args.password is not None:
        password = args.password


    # if options unset, as for input from stdin
    if sslverify:
        print("SSL certificate verification: ENABLED")
    else:
        print("SSL certificate verification: DISABLED")

    if url is None:
        url = input("Morpheus URL: ")

    if username is None:
        username = input("Username ({}): ".format(url))

    if password is None:
        password = input("Password ({}): ".format(username))

    print("Logging on to '{0}' with user '{1}' ...".format(url, username))
    sys.exit(main(username, password, url, sslverify, int(workers)))
