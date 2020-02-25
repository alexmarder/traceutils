cimport cython
from socket import inet_ntop
from libc.string cimport strchr, strtok
from libc.stdlib cimport atoi


cdef class RadixPrefix:
    # def __init__(self, bytes addr=None, unsigned char bitlen=0, unsigned char family=0):
    #     self.addr = addr
    #     self.bitlen = bitlen
    #     self.family = family

    def __repr__(self):
        return self.network()

    cpdef str network(self):
        cdef addr = inet_ntop(self.family, self.addr)
        return '{}/{}'.format(addr, self.bitlen)


@cython.cdivision(True)
@cython.initializedcheck(False)
cdef bytes fix4(bytes a, unsigned char masklen):
    cdef unsigned char c[20]
    cdef unsigned char i, quotient, remainder, mask
    quotient = masklen / 8
    remainder = masklen % 8
    inet_pton(AF_INET, a, c)
    for i in range(quotient+1, 4, 1):
        c[i] = 0
    # if remainder > 0:
    mask = ((~0) << (8 - remainder))
    c[quotient] &= mask
    return <bytes>c[:4]


@cython.cdivision(True)
@cython.initializedcheck(False)
cdef bytes fix6(bytes a, unsigned char masklen):
    cdef unsigned char c[20]
    cdef unsigned char i, quotient, remainder, mask
    # print('reached')
    quotient = masklen / 8
    remainder = masklen % 8
    inet_pton(AF_INET6, a, c)
    for i in range(quotient+1, 16, 1):
        c[i] = 0
    # if remainder > 0:
    mask = ((~0) << (8 - remainder))
    c[quotient] &= mask
    # print(test)
    # test = <bytes>c[:16]
    return bytes(<bytes>c[:16])
    # return bytes(test)


cdef bytes inet_fix(unsigned char family, bytes a, unsigned char masklen):
    if family == AF_INET:
        return fix4(a, masklen)
    return fix6(a, masklen)


cdef unsigned char find_family(bytes network):
    if strchr(network, b':'):
        return AF_INET6
    return AF_INET


cdef (char*, char*) partition(bytes b):
    cdef char *net
    cdef char *mask
    net = strtok(b, b'/')
    if net != NULL:
        mask = strtok(NULL, b'/')
        if mask == NULL:
            mask = b''
    else:
        net = b''
        mask = b''
    return net, mask


def fake():
    pass


cdef RadixPrefix from_network(str s, char masklen=-1):
    cdef bytes a = s.encode()
    cdef bytes net, mask
    net, mask = partition(a)
    # print(net, mask)
    # net, _, mask = a.partition(b'/')
    # cdef Network net = partition(a)
    family = find_family(net)
    # print(family)
    if mask:
        if masklen >= 0:
            raise ValueError('masklen is set twice')
        masklen = atoi(mask)
    elif masklen < 0:
        if family == AF_INET:
            masklen = 32
        else:
            masklen = 128
    cdef bytes addr = inet_fix(family, net, masklen)
    # if family == AF_INET6:
    #     print(addr, len(addr))
    cdef RadixPrefix prefix = RadixPrefix()
    prefix.addr = addr
    prefix.bitlen = masklen
    prefix.family = family
    return prefix


cdef RadixPrefix from_address(str s):
    cdef bytes a = s.encode()
    cdef unsigned char c[16]
    cdef unsigned char family = find_family(a)
    cdef RadixPrefix prefix = RadixPrefix()
    inet_pton(family, a, c)
    if family == AF_INET:
        prefix.addr = <bytes>c[:4]
        prefix.bitlen = 32
    else:
        prefix.addr = <bytes>c[:16]
        prefix.bitlen = 128
    prefix.family = family
    return prefix


cdef RadixPrefix from_packed(bytes addr, char masklen=-1):
    cdef RadixPrefix prefix = RadixPrefix()
    prefix.addr = addr
    if len(addr) == 4:
        if masklen >= 0:
            prefix.bitlen = masklen
        else:
            prefix.bitlen = 32
        prefix.family = AF_INET
    else:
        if masklen >= 0:
            prefix.bitlen = masklen
        else:
            prefix.bitlen = 128
        prefix.family = AF_INET6
    return prefix
