# Breast-Cancer-Text-Mining
## Introduction
Breast cancer is the most common type of cancer diagnosed among women and is the second leading cause of cancer death. The aims of this study include: 1) the progress and overlap made in research related to diagnosis and treatment of this disease 2) to what extent can computational methods convert text data into useful clinical information 3) which knowledge resources can manage text mining of cancer related information 4) how Natural Language Processing (NLP) can be used to structure information from free text reports. With the amount of articles published it is not uncommon for researchers to encounter new insights they were unaware of. Text mining is used to discover these knowledge patterns or hypotheses in helping to solve biomedical questions. 

## Methods
In this study, we utilized Julia, PubMed Central (PMC), and text mining to conduct the necessary research. E-Utilities pulled articles from PMC based on the eligibility criteria. The selected data was output into a dataframe based on the MEDLINE format. We fetched the full text article. The Taro package was then applied to transform the pdf of the full articles into raw text for data to be extracted. We cleaned the data with the TextAnalysis package. Finally, we used Gadfly, Plotly, and Vega to assist in efficiently plotting the data with distinguished visualizations.   


## Using Jupyter Notebook
To see example of analysis done on breast cancer treatment and diagnosis please follow these
3 steps:

### 1. First initialize the app by running:
```
julia src/init.jl
```
### 2. Run Notebook
```
julia start_app.jl
```
### 3. Open Notebook: navigate to either
* Breast Cancer Diagnosis  Text Mining and NLP.ipynp
* Breast Cancer Treatment  Text Mining and NLP.ipynb

## Using this project as package (Not yet published)
install from git or clone  this repository and consume the various functions that
is shipped with this package

``` julia
# init project: this will install missing packages - run it once
include("src/init.jl")
# Add all custom functions here
include("src/main.jl")
using bcTextmining # our package

# now start analysis
df_full_text = bcTextmining.searchAndFetchFullArtcles("breast neoplasms","therapy",2008, 2018,100, true)

# # display all field except df_full_text
df_full_text[:, filter(x -> x != :fullText, names(df_full_text))]
```

## Core functions of this package

### 1. Search and fetch full articles from pubmed central - searchAndFetchFullArtcles()
``` julia
# calling this function will  return a dataframe of articles
 df = bcTextmining.searchAndFetchFullArtcles(
                                          topicParam, # e.g breast cancer (mesh term)
                                          topicSubTypeParam, # e.g treatment (mesh term)
                                          startYearParam, # start year of publication
                                          endYearParam, # end year of publication
                                          numArticles, # e.g 100
                                          cacheParam # set it to false to fetch a fresh
                                          )


# example  
 df = bcTextmining.searchAndFetchFullArtcles("breast neoplasms","therapy",2008, 2018,100, true)
```


### 2. function for data cleaning - cleanText()
```julia
# usage
cleanStrng = bcTextmining.cleanText(dirtyStringParam)

# example - cleaning the above dataframe df
    arrayOfSdDoc = []
    arrayOfStrText = []
    for row in eachrow(df)
        sd,tx=bcTextmining.cleanText(row[:fullText]) # call the function
        push!(arrayOfSdDoc,sd)
        push!(arrayOfStrText,tx)
    end

```

### 3. function for top n topics (lexicon) - fetchTopNTopic()
returns dataframe and gadly plot object
```julia
# usage
lex_df=bcTextmining.fetchTopNTopic(lexicon_df,count_param)

# example
    # from step 2 convert arrayOfSdDoc to corpus
    corpus = Corpus(arrayOfSdDoc)
    #standardize
    standardize!(corpus, StringDocument)
    #create lexicon
    update_lexicon!(corpus)
    #update_inverse_index!(corpus)
    lexicon_df = DataFrame(term=collect(keys(corpus.lexicon)), count=collect(values(corpus.lexicon)))
    lexicon_df,plot =bcTextmining.fetchTopNTopic(lexicon_df,4000)
    plot
```

### 4. function for ngram topic - fetchNgramTopic()
returns dataframe and gadly plot object
```julia
# usage
two_grams==bcTextmining.fetchNgramTopic(full_text_array,1000,2) # 2 grams
three_grams==bcTextmining.fetchNgramTopic(full_text_array,1000,3) # 3 grams
four_grams==bcTextmining.fetchNgramTopic(full_text_array,1000,4) # 4 grams

# example
    # merge all articles
    full_text_array = Array(df[:fullText])
    # generate plot
    df_full_n2,plot =bcTextmining.fetchNgramTopic(full_text_array,1000,2)
    plot


```

## 5. function for generating trends - generateTrends()
This function return a dataframe off 3 columns: year, term, and count.
Here is how to generate trend analysis
```julia
# usage
 #first define an array of terms/concepts/cells/genes e.t.c
 terms = ["surgery","radiation","chemotherapy", "hormonal", "targeted", "systemic"]
 # call the function
 trend_df = bcTextmining.generateTrends(df_full_text,terms,2008,2018 )
 # plot it  out
 Gadfly.plot(trend_df, x="year", y="count", color="term", Geom.point, Geom.line)

```
## Contributors
* Allan Kimaina
* Julia Mullokandova
* Wei Wang

## TODO
* Unit test

## Sample Analysis

* [Diagnosis](output/Breast%20Cancer%20Diagnosis%20Text%20Mining%20and%20NLP.pdf);

* [Treatment](output/Breast%20Cancer%20Treatment%20Text%20Mining%20and%20NLP.pdf);
