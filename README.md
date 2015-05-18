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

Then install VW, following the direction on
[the VW webpage](https://github.com/JohnLangford/vowpal_wabbit/wiki/Tutorial).
Train the model on `train_train.vw` data
and store the model coefficients to `click-prediction.model` file:

    vw data/train_train.vw \
        -f click-prediction.model --loss_function=logistic --link=logistic -c

    # -------------------------
        final_regressor = click-prediction.model
        Num weight bits = 18
        learning rate = 0.5
        initial_t = 0
        power_t = 0.5
        can't open: data/train_train.vw.cache, error = No such file or directory
        creating cache_file = data/train_train.vw.cache
        Reading datafile = data/train_train.vw
        num sources = 1
        average    since         example     example  current  current  current
        loss       last          counter      weight    label  predict features
        0.693147   0.693147            1         1.0  -1.0000   0.5000       23
        0.469862   0.246577            2         2.0  -1.0000   0.2185       23
        0.346750   0.223637            4         4.0  -1.0000   0.1700       23
        0.586883   0.827015            8         8.0  -1.0000   0.2076       23
        0.528342   0.469802           16        16.0   1.0000   0.0675       23
        0.601245   0.674148           32        32.0  -1.0000   0.3604       23
        0.518773   0.436301           64        64.0  -1.0000   0.0996       23
        0.532510   0.546246          128       128.0  -1.0000   0.2749       23
        0.483422   0.434334          256       256.0  -1.0000   0.1359       23
        0.438251   0.393080          512       512.0  -1.0000   0.1303       23
        0.454736   0.471222         1024      1024.0  -1.0000   0.1391       23
        0.449608   0.444480         2048      2048.0  -1.0000   0.3438       23
        0.439428   0.429248         4096      4096.0  -1.0000   0.5675       23
        0.423117   0.406806         8192      8192.0  -1.0000   0.0403       23
        0.418968   0.414819        16384     16384.0   1.0000   0.0639       23
        0.418621   0.418274        32768     32768.0  -1.0000   0.1437       23
        0.408519   0.398418        65536     65536.0  -1.0000   0.2186       23
        0.405289   0.402058       131072    131072.0  -1.0000   0.3468       23
        0.386067   0.366846       262144    262144.0  -1.0000   0.0418       23
        0.381572   0.377077       524288    524288.0   1.0000   0.6570       23
        0.378561   0.375549      1048576   1048576.0  -1.0000   0.0855       23
        0.399855   0.421150      2097152   2097152.0   1.0000   0.1282       23
        0.387015   0.374174      4194304   4194304.0  -1.0000   0.0434       23
        0.396856   0.406697      8388608   8388608.0  -1.0000   0.0709       23
        0.403673   0.410489     16777216  16777216.0   1.0000   0.0684       23

        finished run
        number of examples per pass = 24258700
        passes used = 1
        weighted example sum = 2.42587e+07
        weighted label sum = -1.60222e+07
        average loss = 0.395268
        best constant = -0.660474
        total feature number = 557950100

Scoring / prediction could be done via:

    vw data/train_test_sample.vw \
        -i click-prediction.model \
        -c -t --loss_function=logistic \
        --predictions data/predictions \
        --raw_predictions data/raw_predictions

    # -------------------------
        only testing
        Num weight bits = 18
        learning rate = 10
        initial_t = 1
        power_t = 0.5
        predictions = data/predictions
        raw predictions = data/raw_predictions
        using cache_file = data/train_test_sample.vw.cache
        ignoring text input in favor of cache input
        num sources = 1
        average    since         example     example  current  current  current
        loss       last          counter      weight    label  predict features
        0.292193   0.292193            1         1.0  -1.0000   0.2534       23
        0.365364   0.438535            2         2.0   1.0000   0.6450       23
        0.548900   0.732435            4         4.0  -1.0000   0.0515       23
        0.530342   0.511784            8         8.0  -1.0000   0.0896       23
        0.461550   0.392758           16        16.0  -1.0000   0.2151       23
        0.400503   0.339456           32        32.0  -1.0000   0.0253       23
        0.425530   0.450556           64        64.0   1.0000   0.2066       23
        0.402067   0.378604          128       128.0  -1.0000   0.0672       23
        0.381912   0.361757          256       256.0  -1.0000   0.1276       23
        0.405769   0.429625          512       512.0  -1.0000   0.2579       23
        0.418522   0.431275         1024      1024.0  -1.0000   0.1257       23
        0.416044   0.413567         2048      2048.0  -1.0000   0.4204       23
        0.403952   0.391860         4096      4096.0  -1.0000   0.2323       23
        0.383483   0.363015         8192      8192.0   1.0000   0.2356       23
        0.377914   0.372345        16384     16384.0  -1.0000   0.0801       23
        0.383748   0.389583        32768     32768.0   1.0000   0.2829       23
        0.406377   0.429005        65536     65536.0   1.0000   0.6483       23
        0.390007   0.373638       131072    131072.0  -1.0000   0.1431       23
        0.405720   0.421432       262144    262144.0   1.0000   0.3209       23
        0.401897   0.398075       524288    524288.0   1.0000   0.3169       23

        finished run
        number of examples per pass = 647209
        passes used = 1
        weighted example sum = 647209
        weighted label sum = -427383
        average loss = 0.399608
        best constant = -0.66035
        total feature number = 14885807

See the R codes for calculation of ROC and AUC.
