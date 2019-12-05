import json
from collections import defaultdict

from traceutils.radix.ip2as import IP2AS


class IX:
    def __init__(self, city, country, created, id, media, name, name_long, notes, org_id, policy_email, policy_phone, proto_ipv6, proto_multicast, proto_unicast, region_continent, status, tech_email, tech_phone, updated, url_stats, website, **kwargs):
        self.city = city
        self.country = country
        self.created = created
        self.id = id
        self.media = media
        self.name = name
        self.name_long = name_long
        self.notes = notes
        self.org_id = org_id
        self.policy_email = policy_email
        self.policy_phone = policy_phone
        self.proto_ipv6 = proto_ipv6
        self.proto_multicast = proto_multicast
        self.proto_unicast = proto_unicast
        self.region_continent = region_continent
        self.status = status
        self.tech_email = tech_email
        self.tech_phone = tech_phone
        self.updated = updated
        self.url_stats = url_stats
        self.website = website
        self.kwargs = kwargs

    def __repr__(self):
        return '<IX {}>'.format(self.name)


class IXLAN:
    def __init__(self, ix, arp_sponge, created, descr, dot1q_support, id, ix_id, mtu, name, rs_asn, status, updated):
        self.ix = ix
        self.arp_sponge = arp_sponge
        self.created = created
        self.descr = descr
        self.dot1q_support = dot1q_support
        self.id = id
        self.ix_id = ix_id
        self.mtu = mtu
        self.name = name
        self.rs_asn = rs_asn
        self.status = status
        self.updated = updated


class IXPFX:
    def __init__(self, ixlan, created, id, ixlan_id, prefix, protocol, status, updated):
        self.ixlan = ixlan
        self.created = created
        self.id = id
        self.ixlan_id = ixlan_id
        self.prefix = prefix
        self.protocol = protocol
        self.status = status
        self.updated = updated

    def __repr__(self):
        return '<IXPFX Name={}, Prefix={}>'.format(self.ixlan.ix.name, self.prefix)


class NetIXLAN:
    def __init__(self, ixlan, asn, created, id, ipaddr4, ipaddr6, is_rs_peer, ix_id, ixlan_id, name, net_id, notes, speed,
                 status, updated):
        self.ix = ixlan.ix
        self.ixlan = ixlan
        self.asn = asn
        self.created = created
        self.id = id
        self.ipaddr4 = ipaddr4
        self.ipaddr6 = ipaddr6
        self.is_rs_peer = is_rs_peer
        self.ix_id = ix_id
        self.ixlan_id = ixlan_id
        self.name = name
        self.net_id = net_id
        self.notes = notes
        self.speed = speed
        self.status = status
        self.updated = updated

    def __repr__(self):
        return '<NetIXLAN ASN={}, IX={}>'.format(self.asn, self.ix.name)


class PeeringDB:

    def __init__(self, filename):
        with open(filename) as f:
            j = json.load(f)
        self.ixs = {ix['id']: IX(**ix) for ix in j['ix']['data']}
        self.ixlans = {ixlan['id']: IXLAN(self.ixs[ixlan['ix_id']], **ixlan) for ixlan in j['ixlan']['data']}
        self.ixpfxs = {ixpfx['id']: IXPFX(self.ixlans[ixpfx['ixlan_id']], **ixpfx) for ixpfx in j['ixpfx']['data']}
        self.netixlans = {netixlan['id']: NetIXLAN(self.ixlans[netixlan['ixlan_id']], **netixlan) for netixlan in j['netixlan']['data']}
        self.prefixes = {ixpfx.prefix: ixpfx.ixlan.ix.id for ixpfx in self.ixpfxs.values()}
        self.addrs = {}
        self.new_prefixes = {}
        self.addr_ixid = {}
        self.asn_ixid = defaultdict(set)
        self.ixid_addrasns = defaultdict(set)
        trie = IP2AS()
        trie.add_private()
        # print('added private')
        for prefix in self.prefixes:
            trie.add_asn(prefix, asn=1)
        # print('added prefixes')
        for netixlan in self.netixlans.values():
            ixid = netixlan.ix.id
            self.asn_ixid[netixlan.asn].add(ixid)
            if netixlan.ipaddr4:
                asn = trie[netixlan.ipaddr4]
                if asn == 0:
                    prefix = netixlan.ipaddr4.rpartition('.')[0]
                    self.new_prefixes['{}.0/24'.format(prefix)] = ixid
                    self.prefixes['{}.0/24'.format(prefix)] = ixid
                self.addrs[netixlan.ipaddr4] = netixlan.asn
                self.addr_ixid[netixlan.ipaddr4] = ixid
                self.ixid_addrasns[ixid].add((netixlan.ipaddr4, netixlan.asn))
            if netixlan.ipaddr6:
                asn = trie[netixlan.ipaddr6]
                if asn == 0:
                    prefix = netixlan.ipaddr6.rpartition(':')[0]
                    self.new_prefixes['{}:0/64'.format(prefix)] = ixid
                    self.prefixes['{}:0/64'.format(prefix)] = ixid
                self.addrs[netixlan.ipaddr6] = netixlan.asn
                self.addr_ixid[netixlan.ipaddr6] = ixid
                self.ixid_addrasns[ixid].add((netixlan.ipaddr6, netixlan.asn))
        self.asn_ixid.default_factory = None
        self.ixid_addrasns.default_factory = None

    def addr_asns(self, asn):
        if asn in self.asn_ixid:
            for ixid in self.asn_ixid[asn]:
                for addr, asn in self.ixid_addrasns[ixid]:
                    yield addr, asn
