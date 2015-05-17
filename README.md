click-prediction
==============
Codes that accompany "데이터분석의 길" series by 권재명.

# Data setup
After downloading data to `./data/` directory, prepare the data by:

	python sample_splitter.py
	python sampler.py 0.04 data/train_train.gz data/train_train_sample.gz
	python sampler.py 0.04 data/train_test.gz data/train_test_sample.gz

Since `fread()` in R cannot handle gzip file, let's unzip them:

	gunzip data/train_train_sample.gz
	gunzip data/train_test_sample.gz

# R analysis
Then, analize the data in R using:

	open click-prediction.Rproj

# VW analysis
The input data needs to be in the correct for for VW to handle.
Run the script:

    python ./csv2vw.py data/train_train.gz data/train_train.vw
    python ./csv2vw.py data/train_test_sample data/train_test_sample.vw

Then install VW, following the direction on https://github.com/JohnLangford/vowpal_wabbit/wiki/Tutorial.

    vw data/train_test_sample.vw 