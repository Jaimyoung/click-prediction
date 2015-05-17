#!/usr/bin/env python
''' Split the sample randomly into training set (60%) and test set (40%).
'''
import gzip
import random
import logging

LOGGER = logging.getLogger(__name__)
logging.basicConfig(format='%(asctime)s %(message)s', level=logging.DEBUG)

def main():
    ''' Main driver
    '''

    training_set_rate = 0.6 # hardcoded
    file_in = gzip.open("data/train.gz")
    file_out1 = gzip.open("data/train_train.gz", "w")
    file_out2 = gzip.open("data/train_test.gz", "w")

    # handle the header
    header = file_in.readline()
    file_out1.write(header)
    file_out2.write(header)

    n = 0
    nlines_train = 0
    nlines_test = 0
    random.seed(0) # for reproducible research
    LOGGER.info("Start sample splitting")
    for line in file_in:
        n += 1
        if n % 100000 == 0:
            LOGGER.info("n=%d (nlines_train=%d, nlines_test=%d)",
                        n, nlines_train, nlines_test)
        if random.random() < training_set_rate:
            file_out1.write(line)
            nlines_train += 1
        else:
            file_out2.write(line)
            nlines_test += 1
    file_in.close()
    file_out1.close()
    file_out2.close()

    LOGGER.info("Complete. n=%d (nlines_train=%d, nlines_test=%d)",
                n, nlines_train, nlines_test)

if __name__ == "__main__":
    main()
