from collections import defaultdict
from itertools import combinations
from typing import Set

from traceutils.file2.file2 import File2
from traceutils.progress.bar import Progress


class Alias:

    def __init__(self, filename, include: Set[str] = None, increment=500000):
        self.filename = filename
        aliases = defaultdict(set)
        nids = {}
        pb = Progress(message='Reading aliases', increment=increment, callback=lambda: 'Found {:,d}'.format(len(aliases)))
        with File2(filename) as f:
            for line in pb.iterator(f):
                line = line.strip()
                if not line:
                    continue
                if line[0] == '#':
                    continue
                _, nid, *addrs = line.split()
                if include is not None:
                    if not any(a in include for a in addrs):
                        continue
                nid = nid[:-1]
                aliases[nid] = set(addrs)
                for addr in addrs:
                    nids[addr] = nid
        self.aliases = dict(aliases)
        self.nids = dict(nids)

    def addr_aliases(self, addr):
        return self.aliases[self.nids[addr]]

    def __contains__(self, item):
        return item in self.nids

    def __getitem__(self, item):
        return self.addr_aliases(item)

    def __iter__(self):
        yield from self.nids.keys()

    def pairs(self, addrs=None):
        if addrs is None:
            addrs = self.nids.keys()
        for addr in addrs:
            nid = self.nids.get(addr)
            if nid is not None:
                yield from combinations(self.aliases[nid], 2)
