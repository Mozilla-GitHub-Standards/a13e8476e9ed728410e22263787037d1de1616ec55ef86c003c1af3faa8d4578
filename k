#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import re
import sys
sys.dont_write_bytecode = True

SCRIPTNAME = os.path.splitext(__file__)[0]

import requests
from ruamel import yaml
from argparse import ArgumentParser, RawDescriptionHelpFormatter

from pprint import pprint

from utils.format import fmt, pfmt
from utils.output import output

class Kanbanize(object):
    def __init__(self, apikey, boardid, headers=None):
        self.urlbase = 'https://webops.kanbanize.com/index.php/api/kanbanize/'
        self.apikey = apikey
        self.boardid = boardid
        self.headers = headers if headers else dict(apikey=apikey)

    def _post(self, function, fmt='/format/json', headers=None, json=None):
        headers = headers if headers else self.headers
        url = self.urlbase + function + fmt
        response = requests.post(url, headers=headers, json=json)
        return response

    def get_full_board_structure(self):
        response = self._post('get_full_board_structure', json=dict(boardid=self.boardid))
        return response.json()

    def get_all_tasks(self):
        response = self._post('get_all_tasks', json=dict(boardid=self.boardid))
        return response.json()

if __name__ == '__main__':
    parser = ArgumentParser(
        description=__doc__,
        formatter_class=RawDescriptionHelpFormatter,
        add_help=False)
    parser.add_argument(
        '--config',
        metavar='FILEPATH',
        default='%(SCRIPTNAME)s.yml' % globals(),
        help='default="%(default)s"; config filepath')
    ns, rem = parser.parse_known_args()
    try:
        config = yaml.safe_load(open(ns.config))
    except FileNotFoundError as er:
        config = dict()
    parser = ArgumentParser(
        parents=[parser])
    parser.set_defaults(**config)
    parser.add_argument(
        '--firstname',
        help='default="%(default)s"; first name')
    parser.add_argument(
        '--lastname',
        help='default="%(default)s"; last name')
    parser.add_argument(
        '--age',
        help='default="%(default)s"; age')
    ns = parser.parse_args(rem)
    print(ns)

    k = Kanbanize(ns.apikey, ns.boardid)
    structure = k.get_full_board_structure()
    tasks = k.get_all_tasks()

    print(len(tasks))
    output(structure)
    output(tasks)
