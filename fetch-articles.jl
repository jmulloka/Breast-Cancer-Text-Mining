using Requests
using DataFrames
################################################################################
# this function returns a DataFrame of articles (pmid, title, abstract)
function fetchBreastCancerArticles(cancerType="breast cancer", researchType="diagnosis",
                                    minDate=1990,maxDate=2030, retmax=1000)

    search_terms = "\"$cancerType\"[ad] and \"$researchType\"[mh]"

    # Retrieve number of results - from ESearch results
    # define base search query for eutils
    base_search_query = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi"

    # run esearch to get pmids
    search_result = readstring(post(base_search_query;
    data = Dict("db" => "pubmed", "term" => "$search_terms", "retmax" => retmax,
                 "mindate"=>minDate, "maxdate"=>maxDate)))
    #print(search_result)

    # retrieve the pmids into an array
    pmid_array = []
    for result_line in split(search_result, "\n")
      # get list of pmids
      pmid = match(r"<Id>(\d+)<\/Id>", result_line)
      if pmid != nothing
        push!(pmid_array,pmid[1])
      end
    end

    # concatenate pmids into a single comma separated string
    id_string = join(collect(pmid_array), ",")

    # define base fetch query for eutils
    base_fetch_query = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi"

    # retrieve metadata for pmid Set
    fetch_result = readstring(post(base_fetch_query; data = Dict("db" => "pubmed",
    "id" => id_string, "rettype" => "medline", "retmode" => "text")))

    # save metadata in a file
    output_file = open("output/$researchType.txt", "w")
    write(output_file,fetch_result)
    close(output_file)

    # field set
    title_array = [] # title set
    abstract_array=[] # article abstract
    date_created_array=[] # Create Date (CRDT).
    # read through each line
    for fetch_line in split(fetch_result, "\n")

      # get Title
      title = match(r"TI  - ([\w\W \r\n]+)", fetch_line)
      if title != nothing
          full_title=  title[1]
          push!(title_array,full_title)
          #println("$full_title")
      end

      # get abstract
      abstract_str = match(r"AB  - ([\w\W \r\n]+)", fetch_line)
      if abstract_str != nothing
          push!(abstract_array, abstract_str[1])
        #println("$(abstract_str[1])")
      end

      # date created
      date_created_str = match(r"CRDT- ([\w\W \r\n]+)", fetch_line)
      if date_created_str != nothing
          push!(date_created_array, date_created_str[1])
        #println("$(abstract_str[1])")
      end
    end

    println("pmid_array: $(length(pmid_array))")
    println("title_array: $(length(title_array))")
    println("abstract_array: $(length(abstract_array))")
    println("date_created_array: $(length(date_created_array))")


    # return dictionary of pmid and title
    return(DataFrame(pmid=pmid_array,
                    title=title_array,
                    date_created=date_created_array
                    )
            )

end

# usage
#df = fetchBreastCancerArticles("breast cancer", "diagnosis",2015,2018)

# ref
#https://www.nlm.nih.gov/bsd/mms/medlineelements.html#ab
