
module bcTextmining

        # add all packages here
        using DataFrames
        using TextAnalysis #, DimensionalityReduction, Clustering
        using Query
        using ProgressMeter

        # export
        #export searchAndFetchFullArtcles

        # load custom fx
        include("search-articles.jl")
        include("fetch-full-article.jl")
        include("clean-data.jl")
        include("plot-analysis.jl")


        function searchAndFetchFullArtcles(
                                        cancerType="breast neoplasms",
                                        researchType="diagnosis",
                                        startYear=2008, endYear=2018,
                                        limit_per_year = 10,
                                        cached = true )
            file_name ="$researchType-$startYear-to-$endYear-$limit_per_year"
            # return if cached == True and if file exists
            if(cached &&  isfile("output/$file_name.csv"))
                println("returning cached version, to fetch afresh please set cache=false")
                return(readtable("output/$file_name.csv"))
            else # fetch afresh
                # init dataframe
                df_full_text = DataFrame(
                                pmcid = [],
                                pmid = [],
                                date_published = [],
                                title = [],
                                year =Int64[],
                                pmcUrl=String[],
                                fullText=String[]
                                )

                # track progress
                n = length(startYear:endYear)
                tracker = Progress(n*2, 1)

                # iterate the dataframe
                for yr in startYear:endYear # an array
                    # search bc articles
                    search_df_temp = searchBreastCancerArticles("breast neoplasms",
                                                        "diagnosis",yr,yr,limit_per_year)
                    search_df_temp[:year] = yr
                    next!(tracker)
                    # download bc articles
                    df_full_text_temp = fetchFullArticleFromPmc(search_df_temp, yr)
                    next!(tracker)
                    #println(names(df_full_text_temp))
                    # append df
                    append!(df_full_text, df_full_text_temp)
                end
                # save it as excel
                output_file = open("output/$file_name.csv", "w")
                close(output_file)
                writetable("output/$file_name.csv",df_full_text)
                # complete tracker
                next!(tracker)
                # return df_full_text
                return(df_full_text)
            end
        end

        # example
        #df = @time searchAndFetchFullArtcles("breast neoplasms","diagnosis",2008, 2018,5, true)
end
