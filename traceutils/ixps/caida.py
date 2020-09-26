import json
import os
from collections import defaultdict
from ipaddress import ip_network

from traceutils.radix.ip2as import IP2AS, create_private


class IX:
    def __init__(
            self, pch_id=None, name=None, country=None, region=None, alternatenames=None, sources=None,
            prefixes=None, pdb_id=None, url=None, pdb_org_id=None, state=None, ix_id=None, org_id=None,
            geo_id=None, latitude=None, longitude=None, **kwargs
    ):
        self.pch_id = pch_id
        self.name = name
        self.country = country
        self.region = region
        self.alternatenames = alternatenames
        self.sources = sources
        self.prefixes = prefixes
        self.pdb_id = pdb_id
        self.url = url
        self.pdb_org_id = pdb_org_id
        self.state = state
        self.ix_id = ix_id
        self.org_id = org_id
        self.geo_id = geo_id
        self.latitude = latitude
        self.longitude = longitude
        for k, v in kwargs.items():
            setattr(self, k, v)

class CaidaIXPs:
    def __init__(self):
        self.ixs = None
        self.addrs = None

    @classmethod
    def from_ixs(cls, filename):
        ixpobj = cls()
        ixpobj.read_ixs(filename)
        return ixpobj

    def all_prefixes(self, inet=None):
        for ix in self.ixs.values():
            if inet is None or inet == 4:
                for p in ix.prefixes['ipv4']:
                    yield p
            if inet is None or inet == 6:
                for p in ix.prefixes['ipv6']:
                    yield p

    def unique(self, inet):
        prefs = sorted(ip_network(p) for p in self.all_prefixes(inet=inet))
        prev = prefs[0]
        newprefs = [prev]
        for pref in prefs[1:]:
            if prev.supernet_of(pref):
                continue
            newprefs.append(pref)
            prev = pref
        return map(str, newprefs)

    def prefixes(self, inet=None):
        if inet != 6:
            yield from self.unique(4)
        if inet != 4:
            yield from self.unique(6)

    def prefix_ids(self, inet=None, pdb=False):
        for ix in self.ixs.values():
            if pdb and ix.pdb_id:
                ixid = ix.pdb_id
            else:
                ixid = ix.ix_id
            if inet is None or inet == 4:
                for p in ix.prefixes['ipv4']:
                    yield p, ixid
            if inet is None or inet == 6:
                for p in ix.prefixes['ipv6']:
                    yield p, ixid

    def totrie(self):
        ip2as = create_private()
        for prefix, ixid in self.prefix_ids():
            ip2as.add_asn(prefix, asn=-100 - ixid)
        return ip2as

    def read_ixs(self, filename):
        ixs = {}
        with open(filename) as f:
            for line in f:
                if line[0] != '#':
                    j = json.loads(line)
                    ix = IX(**j)
                    ixs[ix.ix_id] = ix
        self.ixs = ixs

    def read_ix_asns(self, filename):
        addrs = defaultdict(set)
        with open(filename) as f:
            for line in f:
                if line[0] != '#':
                    j = json.loads(line)
                    asn = j['asn']
                    for addr in j['ipv4']:
                        addrs[addr].add(asn)
                    for addr in j['ipv6']:
                        addrs[addr].add(asn)
        self.addrs = addrs
