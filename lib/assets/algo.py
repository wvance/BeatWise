import json
from pprint import pprint
import requests
import urllib2
import sys


# TO GET JSON FOR CLASSIFICATION GO TO 'http://lvh.me:3000/channels/fitbit.json'
def main():

  # CHANGE THIS FOR PRODUCTION: USER ID REQUIRED
  # POINTS IS A JSON FORMATTED OBJECT WITH ID, BODY AND DATETIME
  url_string = "http://lvh.me:3000/users/" + str(sys.argv[1:][0]) + "/get_all_fitbit.json"
  points = json.load(urllib2.urlopen(url_string))

  # OPENS A JSON FILE FROM THE FILE STRUCTURE
  # with open('lib/assets/training.json') as data_file:
  #   data = json.load(data_file)

  # OUTPUT A JSON FILE
  print json.dumps(points)

main()
