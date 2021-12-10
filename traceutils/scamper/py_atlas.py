import json
from socket import AF_INET6
from socket import AF_INET
from typing import List, Any, Dict

from jsonschema import validate
from traceutils.scamper.hop import Hop, Trace, Reader

from traceutils.file2.file2 import File2


class AtlasErrorException(Exception):
    pass


class AtlasHop(Hop):
    def __init__(self, hop=-1, rtt=float('nan'), size=-1, ttl=1, err=None, itos=0, ittl=1, family=0, **kwargs):
        if not err:
            if family == AF_INET:
                icmp_type = 11
                icmp_code = 0
            else:
                icmp_type = 3
                icmp_code = 0
        else:
            icmp_type = 3 if family == AF_INET else 1
            if isinstance(err, str):
                if err == 'N':
                    icmp_code = 0 if family == AF_INET else 0
                elif err == 'H' or 'h':
                    icmp_code = 1 if family == AF_INET else 3
                elif err == 'A':
                    icmp_code = 13 if family == AF_INET else 5
                elif err == 'P':
                    icmp_code = 2 if family == AF_INET else 4
                elif err == 'p':
                    icmp_code = 3 if family == AF_INET else 4
                # elif err == 'h':
                #     raise AtlasErrorException('No clue what h means')
                else:
                    icmp_code = int(err)
                    # raise AtlasErrorException('Unknown error code: {}'.format(err))
            else:
                icmp_code = err
        addr = kwargs.get('from')
        probe_ttl = hop
        rtt = rtt
        reply_ttl = ttl
        reply_size = size
        icmp_type = icmp_type
        icmp_code = icmp_code
        reply_tos = itos
        icmp_q_ttl = ittl
        super().__init__(addr, probe_ttl, rtt, reply_ttl, reply_tos, reply_size, icmp_type, icmp_code, icmp_q_ttl, -1, -1)
        self.params = kwargs


class AtlasTrace(Trace):
    def __init__(self, dstAddress='', IpFrom='', af='4', hops=None, **kwargs):
        af = int(af)
        if af == 4:
            family = AF_INET
        else:
            family = AF_INET6
        super().__init__(IpFrom, dstAddress, create_hops(hops, family))
        self.family = family
        self.params = kwargs


def create_hops(hops: List[Dict[str, Any]], family):
    hopslist = []
    if hops is not None:
        for i in range(len(hops)):
            h = hops[i]
            results = h.get('resultHops')
            if not results:
                continue
            probe_ttl = int(h['hop'])
            for result in h['resultHops']:
                if 'from' in result:
                    try:
                        hop = AtlasHop(hop=probe_ttl, family=family, **result)
                    except:
                        print(result)
                        raise
                    hopslist.append(hop)
                    break
    return hopslist


class AtlasReader(Reader):
    def __init__(self, filename):
        super().__init__()
        self.filename = filename
        self.f = None
        with open('../traceutils/scamper/schema1.json') as f:
            self.schema = json.load(f)

    def __iter__(self):
        for line in self.f:
            j = json.loads(line)
            result = j
            if 'type' not in result or result['type'] == 'traceroute':
                # validate(j, self.schema)
                yield AtlasTrace(**result)

    def open(self):
        self.f = File2(self.filename)
        self.f.open()

    def close(self):
        self.f.close()
