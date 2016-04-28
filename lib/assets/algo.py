import json
from pprint import pprint

with open('lib/assets/training.json') as data_file:
  data = json.load(data_file)


# OUTPUT A JSON FILE
print json.dumps(data)
