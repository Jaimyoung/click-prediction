#!/usr/bin/env python
''' Random sampling of the records (lines). Usage:
    ./sampler.py sampling_rate input_file output_file
'''
import sys
import gzip
import random
import logging

LOGGER = logging.getLogger(__name__)
logging.basicConfig(format='%(asctime)s %(message)s', level=logging.DEBUG)

def main():
    ''' Main driver
    '''
    random.seed(0) # for reproducible research
    sampling_rate = float(sys.argv[1])
    file_in = gzip.open(sys.argv[2])
    file_out = gzip.open(sys.argv[3], "w")

    # handle the header
    header = file_in.readline()
    file_out.write(header)

    n = 0
    n_sampled = 0
    LOGGER.info("Start sampler with rate %f...", sampling_rate)
    for line in file_in:
        n += 1
        if n % 100000 == 0:
            LOGGER.info("n=%d (n_sampled=%d)", n, n_sampled)
        if random.random() < sampling_rate:
            file_out.write(line)
            n_sampled += 1
    file_in.close()
    file_out.close()
    LOGGER.info("Sampling complete. n=%d (n_sampled=%d)", n, n_sampled)

if __name__ == "__main__":
    main()
