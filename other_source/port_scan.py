import socket

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.settimeout(2)
result = sock.connect_ex(('172.16.196.102',1523))

if result == 0:
    print('open')
else:
    print('false')
