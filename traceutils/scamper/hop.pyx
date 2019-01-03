from socket import inet_pton, AF_INET, AF_INET6

cdef class Hop:
    pass


cdef class Trace:

    cpdef list addrs(self):
        cdef Hop h
        return [h.addr for h in self.hops]

    cpdef void prune_dups(self) except *:
        cdef str prev = None
        cdef list hops = []
        cdef int i
        for i in range(len(self.hops)):
        # for hop in self.hops:
            hop = self.hops[i]
            if hop.addr != prev:
                hops.append(hop)
                prev = hop.addr
        self.hops = hops

    cpdef void prune_loops(self) except *:
        cdef set seen = set()
        cdef int end = len(self.hops), i
        cdef str addr
        for i in range(len(self.hops) - 1, -1, -1):
            addr = self.hops[i].addr
            if addr in seen:
                end = i
            else:
                seen.add(addr)
        if end < len(self.hops):
            self.hops = self.hops[:end+1]


cdef class Reader:
    cpdef void open(self) except *:
        raise NotImplementedError()

    cpdef void close(self) except *:
        raise NotImplementedError()


cpdef unsigned long iptoint(str addr) except -1:
    cdef int family
    cdef bytes packed
    if ':' in addr:
        family = AF_INET6
    else:
        family = AF_INET
    packed = inet_pton(family, addr)
    return int.from_bytes(packed, 'big', signed=False)
