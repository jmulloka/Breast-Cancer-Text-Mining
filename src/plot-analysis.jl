
# add all packages here
using DataFrames
using Gadfly
using Vega # for word cloud
using TextAnalysis #, DimensionalityReduction, Clustering
using Plotly
using Query

#include("clean-data.jl")

    function fetchTopNTopic(df, min_count = 100 )
        # define min count
        # filter out
        df = df |> @query(i, begin
                    @where i.count>min_count
                    @orderby descending(i.count)
                    @select {i.term, i.count}
                  end) |> DataFrame

         plot = @time Gadfly.plot(df,y="count", x="term", Geom.bar, color="term")
        # save plot
        #draw(PNG("plot/diagnosis_top_n.png", 3inch, 3inch), plot)
        # return
         return(df,plot)
     end

     function fetchNgramTopic(full_text_array, min_count = 100, ngram =3 )
         # define min count
         # filter out
         full_text_sd, full_text_tx= cleanText( join(full_text_array,"\n"))

        # create ngrams
        full_text_ng=ngrams(full_text_sd, ngram)
        # convert to dataframe
        full_text_ng_df = DataFrame(term=collect(keys(full_text_ng)), count=collect(values(full_text_ng)))


        # add new column size
        full_text_ng_df = full_text_ng_df |> @query(i, begin
                            @orderby descending(i.count)
                            @select {i.term, i.count, size=length(split(get(i.term)))}
                          end) |> DataFrame


        # filter out < min_count
        full_text_ng_df = full_text_ng_df |> @query(i, begin
                            @where i.count>min_count && i.size==ngram
                            @select {i.term, i.count,i.size }
                          end) |> DataFrame


        # plot graph
        plot = @time Gadfly.plot(full_text_ng_df,y="count", x="term",
                Geom.bar(orientation= :vertical), color="term",
                #Guide.xlabel(nothing),
                #Guide.ylabel(nothing),
                Theme(key_position = :none))
        # save plot
         #draw(PNG("plot/diagnosis_top_n.png", 3inch, 3inch), plot)
         # return
          return(full_text_ng_df,plot)
      end
