#!/usr/bin/env python
import os
import pickle
import sys
from argparse import ArgumentParser
from multiprocessing.pool import Pool
from typing import List, Optional

from traceutils.file2.file2 import File2
from traceutils.progress.bar import Progress
from traceutils.radix.ip2as import IP2AS
from traceutils.scamper.hop import ICMPType
from traceutils.scamper.warts import WartsReader

_ip2as: Optional[IP2AS] = None
_tuples = False
_triplets = False


class Info:
    def __init__(self):
        self.tuples = set()
        self.triplets = set()

    def __repr__(self):
        output = []
        if _tuples:
            output.append('Tuples {:,d}'.format(len(self.tuples)))
        if _triplets:
            output.append('Triplets {:,d}'.format(len(self.triplets)))
        return ' '.join(output)

    def dump(self, filename):
        with open(filename, 'wb') as f:
            pickle.dump(self.__dict__, f)

    def update(self, info):
        self.tuples.update(info.tuples)
        self.triplets.update(info.triplets)


def candidates_parallel(files: List[str], ip2as=None, poolsize=35):
    global _ip2as
    if ip2as is not None:
        _ip2as = ip2as
    info = Info()
    pb = Progress(len(files), message='Parsing traceroutes', callback=lambda: '{}'.format(info))
    with Pool(poolsize) as pool:
        for newinfo in pb.iterator(pool.imap(candidates, files)):
            info.update(newinfo)
    return info


def candidates(filename: str, ip2as=None, info: Info = None):
    global _ip2as
    if ip2as is not None:
        _ip2as = ip2as
    if info is None:
        info = Info()
    with WartsReader(filename) as f:
        for trace in f:
            if trace.hops:
                trace.prune_private(_ip2as)
                if trace.hops:
                    # trace.prune_dups()
                    trace.prune_loops()
                    for i in range(len(trace.hops) - 1):
                        x = trace.hops[i]
                        y = trace.hops[i+1]
                        xaddr = x.addr
                        yaddr = y.addr
                        if xaddr != yaddr:
                            if x.type != ICMPType.echo_reply and y.type != ICMPType.echo_reply:
                                if _tuples:
                                    info.tuples.add((xaddr, yaddr))
                                if _triplets:
                                    waddr = None
                                    if i > 0:
                                        w = trace.hops[i-1]
                                        waddr = w.addr
                                    info.triplets.add((waddr, xaddr, yaddr))
    return info


def main():
    global _tuples, _triplets
    parser = ArgumentParser()
    parser.add_argument('-f', '--filename', required=True)
    parser.add_argument('-o', '--output', required=True)
    parser.add_argument('-p', '--poolsize', type=int, default=40)
    parser.add_argument('-2', '--twos', action='store_true')
    parser.add_argument('-3', '--threes', action='store_true')
    args = parser.parse_args()
    _tuples = args.twos
    _triplets = args.threes
    if not _tuples and not _triplets:
        print('Must select tuples or triplets.', file=sys.stderr)
        exit(1)
    files = []
    with File2(args.filename) as f:
        for line in f:
            line = line.strip()
            files.append(line)
    print('Files: {:,d}'.format(len(files)))
    ip2as = IP2AS()
    ip2as.add_private()
    info = candidates_parallel(files, ip2as=ip2as, poolsize=args.poolsize)
    directory = os.path.dirname(args.output)
    if directory:
        os.makedirs(directory, exist_ok=True)
    info.dump(args.output)


if __name__ == '__main__':
    main()
