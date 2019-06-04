#!/bin/python

# Download a tgz file from a pre-defined URL
# Uncompresses it and install it under a directory (e.g /shared/)
import os
import sys
import tarfile

def untar(d,f):
  fpath = d + f
  tar = tarfile.open(fpath)
  tar.extractall(d)
  tar.close()
  return

# --- * ---

def downl(u):
  os.system(wget_cmd + u)
  return u.split('/')[-1]      


# ---  Main Program --- #

url       = "https://www.dropbox.com/afile.tgz"
dest      = "/shared/"
wget_cmd  = "wget -P " + dest + " -nc -c --read-timeout=5 --tries=0 "

if __name__ == "__main__":
  fl = downl(url)
  if os.path.isfile(dest + fl):
    if fl.split('.')[-1] == "tgz":
      untar(dest,fl)
      os.system("chown -R root:root " + dest + "*")
      os.system("chmod -R 755 " + dest + "*")  
      os.system("touch " + dest + "biosoft.unpacked")
