from collections import defaultdict
from traceutils.file2.file2 cimport File2
from traceutils.utils.dicts cimport EmptyDict, ZeroDict

cdef class BGP:

    def __init__(self, str rels, str cone, str extras = None):
        cdef str line
        cdef int x, y, rel
        cdef list customers
        self.rels = set()
        _customers = defaultdict(set)
        _providers = defaultdict(set)
        _peers = defaultdict(set)
        self.cone = EmptyDict()
        self.conesize = ZeroDict()
        with File2(rels) as f:
            for line in f:
                if not line.startswith('#'):
                    x, y, rel = map(int, line.strip().split('|'))
                    self.rels.add((x, y))
                    self.rels.add((y, x))
                    if rel == -1:
                        _customers[x].add(y)
                        _providers[y].add(x)
                    elif rel == 0:
                        _peers[x].add(y)
                        _peers[y].add(x)
        if extras is not None:
            with File2(extras) as f:
                for line in f:
                    if not line.startswith('#'):
                        x, y, rel = map(int, line.strip().split('|'))
                        self.rels.add((x, y))
                        self.rels.add((y, x))
                        if rel == -1:
                            _customers[x].add(y)
                            _providers[y].add(x)
                        elif rel == 0:
                            _peers[x].add(y)
                            _peers[y].add(x)
        with File2(cone) as f:
            for line in f:
                if not line.startswith('#'):
                    provider, *customers = map(int, line.split())
                    self.cone[provider] = set(customers)
                    self.conesize[provider] = len(customers)
        self.customers = EmptyDict(_customers)
        self.providers = EmptyDict(_providers)
        self.peers = EmptyDict(_peers)

    cpdef bint customer_rel(self, int x, int y) except *:
        return x in self.customers[y]

    cpdef set multi_customers(self, asns):
        return {a for asn in asns for a in self.customers[a]}

    cpdef set multi_peers(self, asns):
        return {a for asn in asns for a in self.peers[a]}

    cpdef set multi_providers(self, asns):
        return {a for asn in asns for a in self.providers[a]}

    cpdef bint multi_rels(self, asn, others) except *:
        for other in others:
            if self.rel(asn, other):
                return True
        return False

    cpdef bint peer_rel(self, int x, int y) except *:
        return y in self.peers[x]

    cpdef bint provider_rel(self, int x, int y) except *:
        return x in self.providers[y]

    cpdef bint rel(self, int x, int y) except *:
        return (x, y) in self.rels

    cpdef RelType reltype(self, int x, int y):
        if y in self.customers[x]:
            return RelType.provider
        elif y in self.providers[x]:
            return RelType.customer
        elif y in self.peers[x]:
            return RelType.peer
        return RelType.none
