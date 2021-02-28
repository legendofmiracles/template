{}
import requests, os, json
from bs4 import BeautifulSoup

session = requests.Session()

index_url = ''

soup = BeauifulSoup(session.get(index_url).content, 'lxml')
