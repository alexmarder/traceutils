cimport cython
from libc.string cimport strchr
from libc.string cimport memcpy
# from libc.math cimport pow

@cython.initializedcheck(False)
cdef bytes inet_pton4(bytes a):
    cdef unsigned char c[4]
    inet_pton(AF_INET, a, c)
    return <bytes>c[:4]


@cython.initializedcheck(False)
cdef bytes inet_pton6(bytes a):
    cdef unsigned char c[16]
    inet_pton(AF_INET6, a, c)
    return <bytes>c[:16]


cdef bytes inet_pton_bytes(unsigned char family, bytes a):
    if family == AF_INET:
        return inet_pton4(a)
    return inet_pton6(a)


cdef bytes inet_pton_str(unsigned char family, str s):
    cdef bytes a = s.encode()
    return inet_pton_bytes(family, a)


cdef bytes inet_pton_auto(bytes a):
    cdef int family = find_family(a)
    return inet_pton_bytes(family, a)


cdef bytes inet_pton_auto_str(str s):
    cdef bytes a = s.encode()
    return inet_pton_auto(a)


cpdef unsigned char find_family(bytes addr):
    if strchr(addr, b':'):
        return AF_INET6
    return AF_INET


@cython.cdivision(True)
@cython.initializedcheck(False)
cdef void fix4(bytes a, unsigned char masklen, unsigned char *c) except *:
    cdef unsigned char i, quotient, remainder, mask
    quotient = masklen / 8
    remainder = masklen % 8
    inet_pton(AF_INET, a, c)
    for i in range(quotient+1, 4, 1):
        c[i] = 0
    # if remainder < 8:
    mask = ((~0) << (8 - remainder))
    c[quotient] &= mask


@cython.cdivision(True)
@cython.initializedcheck(False)
cdef void fix6(bytes a, unsigned char masklen, unsigned char *c) except *:
    cdef unsigned char i, quotient, remainder, mask
    quotient = masklen / 8
    remainder = masklen % 8
    inet_pton(AF_INET6, a, c)
    for i in range(quotient+1, 16, 1):
        c[i] = 0
    # if remainder > 0:
    mask = ((~0) << (8 - remainder))
    c[quotient] &= mask


cpdef bytes inet_fix(unsigned char family, bytes a, unsigned char masklen):
    cdef unsigned char c[16]
    if family == AF_INET:
        fix4(a, masklen, c)
        return <bytes>c[:4]
    fix6(a, masklen, c)
    return <bytes>c[:16]


cdef list prefix_addrs4(bytes addr, int size):
    cdef list addrs = []
    cdef unsigned char fixed[4]
    cdef bytes newaddr_b
    cdef str newaddr
    cdef char dst[16]
    cdef unsigned char old, i
    fix4(addr, 32 - size, fixed)
    old = fixed[3]
    for i in range(2 ** size):
        fixed[3] = old + i
        inet_ntop(AF_INET, fixed, dst, INET_ADDRSTRLEN)
        newaddr_b = dst
        newaddr = newaddr_b.decode()
        addrs.append(newaddr)
    return addrs


cdef list prefix_addrs6(bytes addr, int size):
    cdef list addrs = []
    cdef unsigned char fixed[16]
    cdef bytes newaddr_b
    cdef str newaddr
    cdef char dst[46]
    cdef unsigned char old, i
    fix6(addr, 128 - size, fixed)
    old = fixed[15]
    for i in range(size ** 2):
        fixed[15] = old + i
        inet_ntop(AF_INET6, fixed, dst, INET6_ADDRSTRLEN)
        newaddr_b = dst
        newaddr = newaddr_b.decode()
        addrs.append(newaddr)
    return addrs


cpdef list prefix_addrs(str addr, int size):
    cdef bytes addr_b = addr.encode()
    cdef unsigned char family = find_family(addr_b)
    if family == AF_INET:
        return prefix_addrs4(addr_b, size)
    return prefix_addrs6(addr_b, size)


cdef bytes otherside4(bytes addr, int num):
    cdef unsigned char c[4]
    cdef bytes result
    cdef char dst[46]
    inet_pton(AF_INET, addr, c)
    if num == 2:
        if c[3] % 2 == 0:
            c[3] += 1
        else:
            c[3] -= 1
    elif num == 4:
        if c[3] % 4 == 1:
            c[3] += 1
        elif c[3] % 4 == 2:
            c[3] -= 1
        else:
            raise Exception('Invalid host address {} for /30 prefix'.format(addr.decode()))
    else:
        raise Exception('Invalid number of addresses in prefix {}'.format(num))
    inet_ntop(AF_INET, c, dst, INET_ADDRSTRLEN)
    result = <bytes>dst
    return result


cdef bytes otherside6(bytes addr, int num):
    cdef unsigned char c[16]
    cdef char dst[46]
    inet_pton(AF_INET6, addr, c)
    if num == 2:
        if c[15] % 2 == 0:
            c[15] += 1
        else:
            c[15] -= 1
    elif num == 4:
        if c[15] % 4 == 1:
            c[15] += 1
        elif c[15] % 4 == 2:
            c[15] -= 1
        else:
            raise Exception('Invalid host address {} for /126 prefix'.format(addr.decode()))
    else:
        raise Exception('Invalid number of addresses in prefix {}'.format(num))
    inet_ntop(AF_INET6, c, dst, INET6_ADDRSTRLEN)
    return <bytes>dst


cpdef str otherside(str addr, int num):
    cdef bytes addr_b = addr.encode(), result
    cdef unsigned char family = find_family(addr_b)
    if family == AF_INET:
        result = otherside4(addr_b, num)
    else:
        result = otherside6(addr_b, num)
    return result.decode()

cpdef bint valid(long asn) except -1:
    return asn != 23456 and 0 < asn < 64496 or 131071 < asn < 400000

@cython.cdivision(True)
@cython.initializedcheck(False)
cdef void fix4_bytes(bytes a, unsigned char masklen, unsigned char *c) except *:
    cdef unsigned char i, quotient, remainder, mask
    # memcpy(c, <char *>a, 4)
    memcpy(c, <char *> a, 4)
    quotient = masklen / 8
    remainder = masklen % 8
    # inet_pton(AF_INET, a, c)
    for i in range(quotient+1, 4, 1):
        c[i] = 0
    # if remainder < 8:
    mask = ((~0) << (8 - remainder))
    c[quotient] &= mask


@cython.cdivision(True)
@cython.initializedcheck(False)
cdef void fix6_bytes(bytes a, unsigned char masklen, unsigned char *c) except *:
    cdef unsigned char i, quotient, remainder, mask
    memcpy(c, <char *>a, 16)
    quotient = masklen / 8
    remainder = masklen % 8
    # inet_pton(AF_INET6, a, c)
    for i in range(quotient+1, 16, 1):
        c[i] = 0
    # if remainder > 0:
    mask = ((~0) << (8 - remainder))
    c[quotient] &= mask


cpdef bytes inet_fix_bytes(unsigned char family, bytes a, unsigned char masklen):
    cdef unsigned char c[16]
    if family == AF_INET:
        fix4_bytes(a, masklen, c)
        return <bytes>c[:4]
    fix6_bytes(a, masklen, c)
    return <bytes>c[:16]