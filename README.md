NAME
    scanner - TCP port scanner
SYNOPSIS
    ./scan [IP ADDRESS 1] [IP ADDRESS 2] [NETMASK] [PORT1]-[PORT2]
DESCRIPTION
    Scans a range of ports across an array of communicable IPv4 addresses.
    Four mandetory arguments:
        [IP ADDRESS 1] - First IP in address range
        [IP ADDRESS 2] - Last IP address in range
        [NETMASK] - Subnet mask In the format of a single integer 8 - 30
        [PORT1]-[PORT2] - Range of Ports to be in the format of two integers separated by "-"
AUTHOR
    Kevin W. Brown Jr.