using DataFrames
# Add all custom functions here
include("1.4.medline.jl")
include("fetch_full_article.jl")


# diagnosis for the year 2000 to  2018 (limit is 1000 for now)
df = @time  fetchBreastCancerArticles("breast cancer", "diagnosis",2015,2018,100)
println(head(df))

# Then fetch full artcile from PMC and store it as dataframe
df_full_text = fetchFullArticleFromPmc(df)
println(head(df_full_text))

# save it as excel
output_file = open("output/diagnosis_full_article.csv", "w")
close(output_file)
writetable("output/diagnosis_full_article.csv",df_full_text)
