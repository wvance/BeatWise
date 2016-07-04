import sys, datetime, time, math, json
from pprint import pprint
from math import*
import requests
import urllib2

a = []
h1 = []

#for developing purposes only
def read_json(file):
  with open(file) as json_data:
    data = json.load(json_data)
    json_data.close()
  return data

#scoring functions
def error(x, y): return (abs(x-y)/(max(x,y)))

def slope(x1, y1, x2, y2):
  if (x1-x2) != 0:
    return (y1 - y2) / (x1 - x2) if (x1 - x2) != 0 else 0

def average (s): return (sum(s) /len(s))
def std (s):
  z = []
  num = average(s)
  for r in s:
    z.append((r - num)**2)
  return math.sqrt(average(z))

def avgrate (s):
  n = 0.0
  for x in range(0,len(s)-2):
    n += abs(slope(s[x][0],s[x][1],s[x+1][0],s[x+1][1]))
  return (n/len(s))

def peaks (r, s, t):
  n = 0
  for u in r:
    if u > (s + t):
      n+=1
    if u < (s - t):
      n+=1
    n = (n/(len(r)))
  return n

def hDiff(s):
  z = abs((s[int(len(s)/2)][0]) - 43200)
  return z

def score (reader):

  a = []
  h1 = []
  for row in reader:
    x = time.strptime(row["datetime"],'%Y-%m-%dT%H:%M:%S.000Z') #nick
    #x = time.strptime(row["created_at"],'%Y-%m-%d %H:%M:%S %Z')  #wesley
    a.append ([datetime.timedelta(hours=x.tm_hour,minutes=x.tm_min,seconds=x.tm_sec).total_seconds() , int(row["body"])])
    h1.append(int(row["body"]))

  s = std(h1)
  return ([average(h1), s, avgrate(a), peaks(h1, average(h1),s), hDiff(a)])



 #cosine
def square_rooted(x):
   return round(sqrt(sum([a*a for a in x])),8)

def cosine_similarity(x,y):
   numerator = sum(a*b for a,b in zip(x,y))
   denominator = square_rooted(x)*square_rooted(y)
   return round(numerator/float(denominator),8)


def euclidean (x,y):
  # 10,1,1,1,and 5
  # 15, 20, 1, 1, 1
  #  8,1,5,8,0.7
  a = (8.0) * (abs(x[0] -y[0])/ max(x[0],y[0]))
  b = (1.0) * (abs(x[1] -y[1])/ max(x[1],y[1]))
  c = (5.0) * (abs(x[2] -y[2])/ max(x[2],y[2]))
  d = (8.0) * (abs(x[3] -y[3])/ max(x[3],y[3]))
  e = (0.7) * (abs(x[4] -y[4])/ max(x[4],y[4]))
  #print (str(a) + "," + str(b) + "," + str(c) + "," + str(d) + "," + str(e))
  return round(a+b+c+d+e)


# TO GET JSON FOR CLASSIFICATION GO TO 'http://lvh.me:3000/channels/fitbit.json'
def main():
  url_string = "http://lvh.me:3000/users/" + str(sys.argv[1:][0]) + "/get_all_fitbit.json"
  points = json.load(urllib2.urlopen(url_string))
  # points = read_json('data.json')
  results = []

  for point in points:
    results.append({"id": point["id"], "tag":" "})

  centers = read_json('lib/assets/centers.json')

  # prepare centers data before hand for efficiency
  centers_dict = {}
  for center in centers:
    centers_dict[center["tag"]] = [float(center["score1"]), float(center["score2"]), float(center["score3"]), float(center["score4"]), float(center["score5"])]

  size = len(points)
  end = size - 1
  split = 1

  while size > 15:
    results = []
    chunk = end/split

    for i in range(split):
      # start_time = time.time() #start time 0
      k = i + 1

      if k == 1:
        a = 0
        b = chunk
        #print "%d to %d " % (a, b)
      elif k == split:
        a = ((k - 1) * chunk)+1
        b = end
        #print "%d to  %d" % ( a , b)
      else:
        a = ((k - 1) * chunk)+1
        b = k *chunk
        #print "%d to %d" % (a , b )

      #print score(points[a:b])
      tag = ""
      cosine = 1000

      for center_tag, center in centers_dict.iteritems():
        # new_cos = cosine_similarity(center, score(points[a:b]))
        new_cos = euclidean(center, score(points[a:b]))

        #print "%s -> %f " % (center_tag, new_cos )

        if new_cos < cosine:
          cosine = new_cos
          tag = center_tag


      for point in points[a:b]:
        results.append({"id": point["id"], "tag": tag})

      # print "%s [%d:%d] %.3f s TOTAL: %.3f s" % (tag, a, b, time.time() - start_time, time.time() - program_start_time)

    size = end / split
    split *= 2

  with open('lib/assets/results.json', 'w') as outfile:
    json.dump(results, outfile)

  print json.dumps(results)
main()
