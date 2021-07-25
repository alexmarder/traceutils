IF UNAME_SYSNAME == 'Windows':
    cdef extern from '<ws2tcpip.h>':
        # ctypedef int socklen_t
        ctypedef int size_t
        cdef size_t INET_ADDRSTRLEN, INET6_ADDRSTRLEN
        cdef int AF_INET, AF_INET6
        cdef int inet_pton(int, char*, void*)
        cdef char *inet_ntop(int, void*, char*, size_t)
ELSE:
    cdef extern from '<arpa/inet.h>':
        ctypedef int socklen_t
        cdef socklen_t INET_ADDRSTRLEN, INET6_ADDRSTRLEN
        cdef int AF_INET, AF_INET6
        cdef int inet_pton(int, char*, void*)
        cdef char *inet_ntop(int, void*, char*, socklen_t)

cdef bytes inet_pton4(bytes a);
cdef bytes inet_pton6(bytes a);
cdef bytes inet_pton_bytes(unsigned char family, bytes a);
cdef bytes inet_pton_str(unsigned char family, str s);
cdef bytes inet_pton_auto(bytes a);
cdef bytes inet_pton_auto_str(str s);
cpdef unsigned char find_family(bytes addr);
cdef void fix4(bytes a, unsigned char masklen, unsigned char *c) except *;
cdef void fix6(bytes a, unsigned char masklen, unsigned char *c) except *;
cpdef bytes inet_fix(unsigned char family, bytes a, unsigned char masklen);
cdef list prefix_addrs4(bytes addr, int size);
cdef list prefix_addrs6(bytes addr, int size);
cpdef list prefix_addrs(str addr, int size);
cdef bytes otherside4(bytes addr, int num);
cdef bytes otherside6(bytes addr, int num);
cpdef str otherside(str addr, int num);
cpdef bint valid(long asn) except -1;
cdef void fix4_bytes(bytes a, unsigned char masklen, unsigned char *c) except *;
cdef void fix6_bytes(bytes a, unsigned char masklen, unsigned char *c) except *;
cpdef bytes inet_fix_bytes(unsigned char family, bytes a, unsigned char masklen);
