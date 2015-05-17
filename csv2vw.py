#!/usr/bin/env python
''' Convert click prediction CSV file to VW format. Usage:

    python ./csv2vw.py data/train_train.gz data/train_train.vw

    ./csv2vw.py data/train_train.gz data/train_train.vw
    ./csv2vw.py data/train_test_sample.gz data/train.vw

Based on: https://github.com/zygmuntz/kaggle-merck/blob/master/csv2vw.py
'''
import sys
import gzip
import logging
import csv

LOGGER = logging.getLogger(__name__)
logging.basicConfig(format='%(asctime)s %(message)s', level=logging.DEBUG)


def construct_line(record):
    """ Build VW line from record, a dictionary with the following keys:
    ['id', 'click', 'hour', 'C1', 'banner_pos', 'site_id', 'site_domain',
    'site_category', 'app_id', 'app_domain', 'app_category', 'device_id',
    'device_ip', 'device_model', 'device_type', 'device_conn_type', 'C14',
    'C15', 'C16', 'C17', 'C18', 'C19', 'C20', 'C21']
    """
    label = record.pop("click")
    if int(label) < 1:
        label = "-1" # VW does {+1, -1} encoding.
    tag = record.pop("id") # Won't be used
    tag = ""

    items = []
    if tag:
        items.append("%s 1 %s|" % (label, tag))
    else:
        items.append("%s |" % (label))

    for k, v in record.iteritems():
        # items.append("%s:%s" % (k, v))
        items.append("%s__%s" % (k, v))

    vw_line = " ".join(items) + "\n"
    # print vw_line
    return vw_line


def main():
    """ Main driver
    """
    input_file = sys.argv[1]
    output_file = sys.argv[2]

    if input_file.endswith(".gz"):
        file_in = gzip.open(input_file)
    else:
        file_in = open(input_file)
    file_out = open(output_file, "w")

    reader = csv.reader(file_in)
    header = reader.next()
    LOGGER.info("Header: %s", header)

    n = 0
    LOGGER.info("Starting...")
    for line in reader:
        n += 1
        if n % 100000 == 0:
            LOGGER.info("n=%d", n)
        record = dict(zip(header, line))
        file_out.write(construct_line(record))

    LOGGER.info("n=%d", n)

    file_in.close()
    file_out.close()


if __name__ == "__main__":
    main()
