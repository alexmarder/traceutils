from traceutils.radix import create_private


class AbstractIX:
    def __init__(self, city, country, id, media, name, name_long, policy_email, policy_phone, proto_ipv6, proto_multicast, proto_unicast, region_continent, tech_email, tech_phone, url_stats, website, **kwargs):
        self.city = city
        self.country = country
        self.id = id
        self.media = media
        self.name = name
        self.name_long = name_long
        self.policy_email = policy_email
        self.policy_phone = policy_phone
        self.proto_ipv6 = proto_ipv6
        self.proto_multicast = proto_multicast
        self.proto_unicast = proto_unicast
        self.region_continent = region_continent
        self.tech_email = tech_email
        self.tech_phone = tech_phone
        self.url_stats = url_stats
        self.website = website
        self.kwargs = kwargs

    def __repr__(self):
        return '<IX {}>'.format(self.name)

class AbstractPeeringDB:
    def __init__(self, filename):
        self.filename = filename
        self.addrs = {}
        self.ixs = {}
        self.prefixes = {}

    def totrie(self):
        ip2as = create_private()
        for prefix, pdbid in self.prefixes.items():
            ip2as.add_asn(prefix, asn=-100 - pdbid)
        return ip2as
