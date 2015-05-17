click-prediction
==============
Codes that accompany "데이터분석의 길" series by 권재명.

# Setup
After downloading data to `./data/` directory, prepare the data by:

	python sample_splitter.py
	python sampler.py 0.04 data/train_train.gz data/train_train_sample.gz
	python sampler.py 0.04 data/train_test.gz data/train_test_sample.gz

Since `fread()` in R cannot handle gzip file, let's unzip them:

	gunzip data/train_train_sample.gz
	gunzip data/train_test_sample.gz

Then, analize the data in R using:

	open click-prediction.Rproj

