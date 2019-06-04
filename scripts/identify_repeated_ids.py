#!/usr/bin/python

# Given a list of lines with the format "name:x:identifier:...", 
# identify the ones which have repeated identifiers

def parse_file(_input_file):
  with open(_input_file,"r") as f: 
    for line in f.readlines(): # f.readlines() is a list of lines
      item = line.split(":")   # split the line 
      k = str(item[2])         # get identifier
      v = item[0]              # get name
      if k in data.keys():     # Check if key is defined in data dictionary
        data[k].append(v)      # if it is, append the new value to the list of existing values  
      else:                      
        data[k] = [v]          # if it is not, initiate with list with a single value
  return

# ---

def print_dict():
  for k,v in sorted(data.items()):
    if len(v) >= 2:
      print "The id %s has more than one name associated: %s" % (k,', '.join(v))
  return

# ---


data = {}
input_file = './identify_repeated_ids.txt'
if __name__ == "__main__":
  parse_file(input_file)
  print_dict()
