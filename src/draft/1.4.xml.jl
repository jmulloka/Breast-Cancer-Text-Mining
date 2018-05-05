using Requests
using DataFrames
################################################################################
# this function returns a DataFrame of articles (pmid, title, abstract)
function fetchBreastCancerArticles(cancerType="breast cancer", researchType="diagnosis",
                                    minDate=1990,maxDate=2030, retmax=1000)

    search_terms = "\"$cancerType\"[ti] and \"$researchType\"[mh]"

    # Retrieve number of results - from ESearch results
    # define base search query for eutils
    base_search_query = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi"

    # run esearch to get pmids
    search_result = readstring(post(base_search_query;
    data = Dict("db" => "pmc", "term" => "$search_terms", "retmax" => retmax,
                 "mindate"=>minDate, "maxdate"=>maxDate)))
    # println(search_result)

    # retrieve the pmids into an array
    pmids = []
    for result_line in split(search_result, "\n")
      # get list of pmids
      pmid = match(r"<Id>(\d+)<\/Id>", result_line)
      if pmid != nothing
        push!(pmids,pmid[1])
      end
    end

    # concatenate pmids into a single comma separated string
    id_string = join(collect(pmids), ",")

    # define base fetch query for eutils
    base_fetch_query = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi"

    # retrieve metadata for pmid Set
    fetch_result_medline = readstring(post(base_fetch_query; data = Dict("db" => "pmc",
    "id" => id_string, "rettype" => "medline", "retmode" => "text")))

    fetch_result_xml = readstring(post(base_fetch_query; data = Dict("db" => "pmc",
      "id" => id_string, "rettype" => "xml", "retmode" => "text")))

    # save metadata in a file
    output_file = open("output/$researchType.txt", "w")
    write(output_file,fetch_result_medline)
    close(output_file)


    # field set
    pmcid_array =[] # pmcid set
    pmid_array = [] # pmid set
    title_array = [] # title set
    abstract_array=[] # article abstract
    date_published_array=[] # published online Date (DEP).


   for fetch_article in split(fetch_result_xml, "<front>")
        # clear all field
        full_title=""
        full_abstract=""

       # get Title
       if fetch_article != nothing
        title = match(r" <article-title>([\w\W \r\n]+)<\/article-title>", fetch_article)
        if title != nothing
            full_title=title[1]
        end
        # get abstract
        abstract_str = match(r"<abstract>([\w\W \r\n]+)<\/abstract>", fetch_article)
        if abstract_str != nothing
            full_abstract=abstract_str[1]
        end
           push!(title_array, full_title)
           push!(abstract_array, full_abstract)
        end     
    end
 # return dictionary of pmid and title
    return(DataFrame(title = title_array,
                     main_abstract = abstract_array
                    )
            )
end

# usage
df = fetchBreastCancerArticles("breast cancer", "diagnosis",2015,2018,10)

output_file = open("output/diagnosis.csv", "w")
close(output_file)
writetable("output/diagnosis.csv",df)


# ref
#https://www.nlm.nih.gov/bsd/mms/medlineelements.html#ab
