from collections import defaultdict
from file2 cimport File2


cdef class EmptyDict(dict):
    def __missing__(self, key):
        return set()


cdef class ZeroDict(dict):

    def __getstate__(self):
        return dict(self)

    def __setstate__(self, state):
        self.update(state)

    def __reduce__(self):
        return ZeroDict, (), self.__getstate__()

    def __missing__(self, key):
        return 0


cdef class BGP:

    def __init__(self, str rels, str cone):
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
        with File2(cone) as f:
            for line in f:
                if not line.startswith('#'):
                    provider, *customers = map(int, line.split())
                    self.cone[provider] = set(customers)
                    self.conesize[provider] = len(customers)
        self.customers = EmptyDict(_customers)
        self.providers = EmptyDict(_providers)
        self.peers = EmptyDict(_peers)

    cpdef RelType reltype(self, int x, int y):
        if y in self.customers[x]:
            return RelType.provider
        elif y in self.providers[x]:
            return RelType.customer
        elif y in self.peers[x]:
            return RelType.peer
        return RelType.none
