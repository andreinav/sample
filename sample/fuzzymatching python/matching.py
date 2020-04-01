from fuzzywuzzy import process, fuzz
#import fuzzy_pandas as fpd
import pandas as pd 
import re

import nltk
nltk.download('stopwords')

from nltk.corpus import stopwords
stoplist = stopwords.words('english')


coi = pd.read_csv('COI_indicators_short.csv',encoding= 'unicode_escape')
leg = pd.read_csv ('leg_ind_short.csv', encoding= 'unicode_escape')

coi = coi.sample(frac = 0.10) 
leg = leg.sample(frac = 0.10) 


# removing null values to avoid errors   
coi.dropna(inplace = True)
leg.dropna(inplace = True)


# replace to lower case

coi['ind_name'] = coi['ind_name'].str.lower() 
leg['ind_name'] = leg['ind_name'].str.lower() 


#remove stopwords
coi['ind_name'] = coi['ind_name'].apply(lambda x: ' '.join([word for word in x.split() if word not in (stoplist)]))
leg['ind_name'] = leg['ind_name'].apply(lambda x: ' '.join([word for word in x.split() if word not in (stoplist)]))


coi['ind_name'] = coi['ind_name'].apply(lambda elem: re.sub(r"(@[A-Za-z0-9]+)|([^0-9A-Za-z \t])|(\w+:\/\/\S+)|^rt|http.+?", "", elem))  
   
# remove numbers
coi['ind_name'] = coi['ind_name'].apply(lambda elem: re.sub(r"\d+", "", elem))


leg['ind_name'] = leg['ind_name'].apply(lambda elem: re.sub(r"(@[A-Za-z0-9]+)|([^0-9A-Za-z \t])|(\w+:\/\/\S+)|^rt|http.+?", "", elem))  
   
# remove numbers
leg['ind_name'] = leg['ind_name'].apply(lambda elem: re.sub(r"\d+", "", elem))





## create dictionary with scoring types
scorer_dict = { 'R':fuzz.ratio, 
                'PR': fuzz.partial_ratio, 
                'TSeR': fuzz.token_set_ratio, 
                'TSoR': fuzz.token_sort_ratio,
                'PTSeR': fuzz.partial_token_set_ratio, 
                'PTSoR': fuzz.partial_token_sort_ratio, 
                'WR': fuzz.WRatio, 
                'QR': fuzz.QRatio,
                'UWR': fuzz.UWRatio, 
                'UQR': fuzz.UQRatio }

# create test
scorer_test = leg[['ind_name']].copy()
scorer_test.head(3)


#function
def scorer_tester_function(x) :
    actual_ind = []
    similarity = []
    score_type = []
    
    for i in scorer_test['ind_name']:
        ratio = process.extract( i, coi.ind_name, limit=1,
                                 scorer=scorer_dict[x])
        actual_ind.append( ratio[0][0] )
        similarity.append( ratio[0][1] )
        score_type = str(x)
        scorer_test['actual_ind'] = pd.Series(actual_ind)
        scorer_test['actual_ind'] = scorer_test['actual_ind'] 
        scorer_test['similarity'] = pd.Series(similarity)
        scorer_test['score_type'] = score_type
        
    return scorer_test


    

#testing different algorithms
scorer_tester_function('R')
scorer_test[scorer_test.ind_name.str.contains('.', regex=False)]
scorer_test_R = scorer_test
scorer_test_R.to_csv ("scorer_test_R.csv")

scorer_tester_function('WR')
scorer_test[scorer_test.ind_name.str.contains('.', regex=False)]
scorer_test_WR = scorer_test
scorer_test_WR.to_csv ("scorer_test_WR.csv")


scorer_tester_function('PR')
scorer_test[scorer_test.ind_name.str.contains('.', regex=False)]
scorer_test_PR = scorer_test
scorer_test_PR.to_csv ("scorer_test_PR.csv")

scorer_tester_function('PTSeR')
scorer_test[scorer_test.ind_name.str.contains('.', regex=False)]
scorer_test_PTSeR = scorer_test
scorer_test_PTSeR.to_csv ("scorer_test_PTSeR.csv")

scorer_tester_function('TSoR')
scorer_test[scorer_test.ind_name.str.contains('.', regex=False)]
scorer_test_TSoR = scorer_test
scorer_test_TSoR.to_csv ("scorer_test_TSoR.csv")

scorer_tester_function('PTSeR')
scorer_test[scorer_test.ind_name.str.contains('.', regex=False)]
scorer_test_PTSeR = scorer_test
scorer_test_PTSeR.to_csv ("scorer_test_PTSeR.csv")

scorer_tester_function('PTSoR')
scorer_test[scorer_test.ind_name.str.contains('.', regex=False)]
scorer_test_PTSoR = scorer_test
scorer_test_PTSoR.to_csv ("scorer_test_PTSoR.csv")





                   
