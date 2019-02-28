from collections import Counter
from subprocess import Popen, PIPE

from libc.stdio cimport *
from libc.string cimport *
from libc.stdlib cimport *
        

cdef bint valid(long asn):
    return asn != 23456 and 0 < asn < 64496 or 131071 < asn < 400000


cdef char *next_split(char *delimeters, int n):
    cdef int i
    for i in range(n):
        tok = strtok(NULL, delimeters)
        if tok == NULL:
            raise ValueError('Not enough splits')
    return tok


cdef list handle_sets(bytes asset):
    cdef long asn
    cdef list ases, splits
    ases = []
    splits = asset[1:-1].split(b',')
    for asn_s in splits:
        asn = atol(asn_s)
        if valid(asn):
            ases.append(asn_s)
    return ases


cpdef read(str filename):
    cdef char *line = NULL
    cdef char *tok
    cdef char* prefix
    cdef char* origin_ases
    cdef char* ases[100]
    cdef char* asn_s
    cdef size_t l = 0
    cdef unsigned char i
    cdef int read
    cdef bytes fname = filename.encode()
    cdef FILE *cfile
    cdef list asset
    cdef bytes asn_ss
    cdef str cmd
    counter = Counter()
    
    cmd = 'bgpreader -d singlefile -o rib-file,{} -w 0,2147483648'.format(filename)
    reader = Popen(cmd, shell=True, stdout=PIPE)
    cfile = fdopen(reader.stdout.fileno(), 'rb')

    while True:
        read = getline(&line, &l, cfile)
        if read == -1:
            break
        tok = strtok(line, b'|')
        if tok == NULL:
            raise Exception('Invalid input')
        tok = strtok(NULL, b'|')
        if tok == b'B' or tok == b'E':
            continue
        prefix = next_split(b'|', 6)
        origin_ases = next_split(b'|', 2)
        asn_s = strtok(origin_ases, b' ')
        for i in range(100):
            if asn_s == NULL:
                break
            ases[i] = asn_s
            asn_s = strtok(NULL, b' ')
        for i in range(i-1, -1, -1):
            asn_s = ases[i]
            if asn_s[0] == b'{':
                asset = handle_sets(asn_s)
                if asset:
                    if len(asset) == 1:
                        asn_ss = asset[0]
                    else:
                        asn_ss = b'{' +  b','.join(asset) + b'}'
                    counter[prefix, asn_ss] += 1
                    break
            else:
                asn = atol(asn_s)
                if valid(asn):
                    counter[prefix, asn_s] += 1
                    break
    fclose(cfile)
    reader.wait()
    return counter
