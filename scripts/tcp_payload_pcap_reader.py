#!/usr/bin/python
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Py4Grid.  If not, see <http://www.gnu.org/licenses/>.
#
# ----------------------------------------------------------------
# Requirements:
#  1. dpkt module, available for download in:
#       https://code.google.com/p/dpkt/downloads/list
#  2. Receives as input a raw pcap file captured previously 
#     through tcpdump. 
#       $ python pcap-parser.py <file>
#     An example of how to run tcpdump capturing a pcap file is: 
#       $ tcpdump -<options> -w <file> -i <interface> <expression>
# ----------------------------------------------------------------

import dpkt
import socket
import sys
import datetime

id = 0
label = ['FIN','SYN','RST','PSH','ACK','URG','ECE','CWR']

pcapReader = dpkt.pcap.Reader(file(sys.argv[1], "rb"))

for ts, buf in pcapReader:
  # Get the Ethernet object
  # ether(src='\x00\x1a\xa0kUf', dst='\x00\x13I\xae\x84,', data=IP(src='\xc0\xa8\n\n',
  #       off=16384, dst='C\x17\x030', sum=25129, len=52, p=6, id=51105, data=TCP(seq=9632694,
  #       off_x2=128, ack=3382015884, win=54, sum=65372, flags=17, dport=80, sport=56145)))
  ether = dpkt.ethernet.Ethernet(buf)
  # Skip non IP traffic (ICMP, ARP, ...)
  if ether.type != dpkt.ethernet.ETH_TYPE_IP: 
    # raise Exception('The ethernet data type is not what was expected (IP)')
    continue

  # Get the IP object (EthernetObject.data)
  ip = ether.data
  src = socket.inet_ntoa(ip.src)
  dst = socket.inet_ntoa(ip.dst)
  proto = ip.p
  if proto != dpkt.ip.IP_PROTO_TCP:
    raise Exception('The data type is not what was expected (TCP)')

  # Get the TCP object (EthernetObject.data.data)
  tcp = ip.data
  sport = tcp.sport
  dport = tcp.dport
  dseqn = tcp.seq

  # Deal with flags
  f = []
  f.append( ( tcp.flags & dpkt.tcp.TH_FIN ) != 0 )
  f.append( ( tcp.flags & dpkt.tcp.TH_SYN ) != 0 )
  f.append( ( tcp.flags & dpkt.tcp.TH_RST ) != 0 )
  f.append( ( tcp.flags & dpkt.tcp.TH_PUSH) != 0 )
  f.append( ( tcp.flags & dpkt.tcp.TH_ACK ) != 0 )
  f.append( ( tcp.flags & dpkt.tcp.TH_URG ) != 0 )
  f.append( ( tcp.flags & dpkt.tcp.TH_ECE ) != 0 )
  f.append( ( tcp.flags & dpkt.tcp.TH_CWR ) != 0 )

  flags = ''
  for i in range(len(f)):
    if f[i] == True:
      flags = flags + ' ' + label[i]

  # The payload of this TCP segment
  tcp_payload = str(tcp.data)

  # --------------------------------------------------------------------------
  # http://www.asciitable.com/
  # "0x" represents a literal number
  # "\x" is used inside strings to represent a character
  # "\xNN" represents a character with the hexadecimal code NN (\x41 = 'A')
  # "0xNN" represents a number with the hexadecimal code NN (0x41 = 65)
  # --------------------------------------------------------------------------
  # Remove all the unwanted chars such as NULL bytes, ESC, DEL and other non relevant chars
  # Keep the '\x09' (tab),'\x0a' (newline), '\x0d' (carriage return) and all the normal
  # chars between '\x20' and '\x7e'
  list = [ '\x00','\x01','\x02','\x03','\x04','\x05','\x06','\x07','\x08',\
           '\x0b','\x0c','\x0e','\x0f','\x10','\x11','\x12','\x13',\
           '\x14','\x15','\x16','\x17','\x18','\x19','\x1a','\x1b','\x1c','\x1d',\
           '\x1e','\x1f','\x7f']
  for ch in list:
     tcp_payload = tcp_payload.replace(ch,'')
  

  print " * %s:%s --> %s:%s (%d)" % (src,sport,dst,dport,id)
  print " * TIMESTAMP     : %s (%s)" % (ts,datetime.datetime.fromtimestamp(ts).strftime('%Y-%m-%d %H:%M:%S'))
  print " * BUFFER LENGTH : %d" % (len(buf))
  print " * FLAGS         :" + flags
  print " * PAYLOAD       : " + tcp_payload
  print " * SEQ NUMBER    : %d" % (dseqn)
  print " --- * ---"
  id +=1

