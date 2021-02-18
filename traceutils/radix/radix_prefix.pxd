IF UNAME_SYSNAME == 'Windows':
    cdef extern from '<ws2tcpip.h>':
        cdef int AF_INET, AF_INET6
        cdef int inet_pton(int, char*, void*)
ELSE:
    cdef extern from '<arpa/inet.h>':
        cdef int AF_INET, AF_INET6
        cdef int inet_pton(int, char*, void*)

cdef class RadixPrefix:
    cdef readonly bytes addr
    cdef readonly unsigned char bitlen
    cdef readonly unsigned char family

    cpdef str network(self);

cdef bytes fix4(bytes a, unsigned char masklen);
cdef bytes fix6(bytes a, unsigned char masklen);
cdef bytes inet_fix(unsigned char family, bytes a, unsigned char masklen);
cdef unsigned char find_family(bytes network);
# cdef Network partition(bytes b);
cdef RadixPrefix from_network(str s, char masklen=*);
cdef RadixPrefix from_address(str s);
cdef RadixPrefix from_packed(bytes addr, char masklen=*);
cdef (char*, char*) partition(bytes b);
