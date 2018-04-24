using DataFrames
# Add all custom functions here
include("1.4.medline.jl")
include("fetch_full_article.jl")


# diagnosis for the year 2000 to  2018 (limit is 1000 for now)
df = @time  fetchBreastCancerArticles("breast cancer", "diagnosis",2015,2018,1000)
println(head(df))

# Then fetch full artcile from PMC and store it as dataframe
df_full_text = fetchFullArticleFromPmc(df)
println(head(df_full_text))
    
