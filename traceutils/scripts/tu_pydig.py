#!/usr/bin/env python
from argparse import ArgumentParser
from multiprocessing import Pool
from subprocess import run, PIPE

from traceutils.file2.file2 import fopen
from traceutils.progress.bar import Progress


def resolve(addr):
    addr = addr.strip()
    p = run('dig +short -x ' + addr, shell=True, universal_newlines=True, stdout=PIPE)
    if ';;' in p.stdout:
        return addr, ''
    return addr, '|'.join(n[:-1] for n in p.stdout.splitlines(keepends=False))

def main():
    parser = ArgumentParser()
    parser.add_argument('-p', '--processes', type=int, default=100)
    parser.add_argument('-c', '--chunksize', type=int, default=100)
    parser.add_argument('infile')
    args = parser.parse_args()
    pb = Progress(increment=max(1000, args.chunksize))
    with Pool(args.processes) as pool, fopen(args.infile, 'rt') as f:
        for addr, name in pb.iterator(pool.imap_unordered(resolve, f, chunksize=args.chunksize)):
            if name:
                print('{}\t{}\t{}'.format(0, addr, name))

if __name__ == '__main__':
    main()
