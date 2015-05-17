#!/usr/bin/env python
''' Split the sample randomly into training set (60%) and test set (40%).
'''
import gzip
import random

def main():
    ''' Main driver
    '''
    random.seed(0) # for reproducible research
    training_set_rate = 0.6 # hardcoded
    file_in = gzip.open("data/train.gz")
    file_out1 = gzip.open("data/train_train.gz", "w")
    file_out2 = gzip.open("data/train_test.gz", "w")
    for line in file_in:
    	if random.random() < 0.6:
    		file_out1.write(line)
    	else:
    		file_out2.write(line)
    file_in.close()
    file_out1.close()
    file_out2.close()

if __name__ == "__main__":
    main()
