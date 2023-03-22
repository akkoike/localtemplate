'''
Google で検索する
'''

import os
import sys
import time
import datetime
import logging
import argparse
import configparser

import requests
from bs4 import BeautifulSoup

# ログの設定
logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
sh = logging.StreamHandler()

# ログレベルの設定
sh.setLevel(logging.DEBUG)

# フォーマットの設定
sh.setFormatter(formatter)

# ハンドラーの追加
logger.addHandler(sh)

# パーサーの作成
parser = argparse.ArgumentParser(description='Google で検索する')

# パーサーに引数を追加
parser.add_argument('keyword', help='検索キーワード')
parser.add_argument('-c', '--config', help='設定ファイルのパス')

# 引数を解析
args = parser.parse_args()

# 設定ファイルの読み込み
config = configparser.ConfigParser()
config.read(args.config)

# Google で検索する
def search(keyword):

                                                        