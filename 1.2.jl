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
    data = Dict("db" => "pubmed", "term" => "$search_terms", "retmax" => retmax,
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
    fetch_result_medline = readstring(post(base_fetch_query; data = Dict("db" => "pubmed",
    "id" => id_string, "rettype" => "medline", "retmode" => "text")))

    fetch_result_xml = readstring(post(base_fetch_query; data = Dict("db" => "pubmed",
    "id" => id_string, "rettype" => "xml", "retmode" => "text")))

    # save metadata in a file
    output_file = open("output/$researchType.txt", "w")
    write(output_file,fetch_result_medline)
    close(output_file)


    # field set
    pmid_array = [] # title set
    title_array = [] # title set
    abstract_array=[] # article abstract
    date_created_array=[] # Create Date (CRDT).
    # read through each line
    for fetch_article in split(fetch_result_medline, "PMID- ")
        # clear all field
        pmid=""
        date_created=""
        # extract PMID
        pmid_str = match(r"([0-9]+)", fetch_article)
        if pmid_str != nothing
          pmid=pmid_str[1]
        end
        for fetch_line in split(fetch_article, "\n")
            # date created
            date_created_str = match(r"CRDT- ([\w\W \r\n]+)", fetch_line)
            if date_created_str != nothing
                date_created=date_created_str[1]
            end
        end
        # push everything
        if pmid != ""
            push!(pmid_array, pmid)
            push!(date_created_array, date_created)
        end

    end

    for fetch_article in split(fetch_result_xml, "<PubmedArticle>")
        # clear all field
        pmid=""
        full_title=""
        full_abstract=""
        # extract PMID
        pmid_str = match(r"<PMID Version=\"1\">([\w\W \r\n]+)<\/PMID>", fetch_article)
        if pmid_str != nothing
          pmid=pmid_str[1]
        end
        # get Title
        title = match(r"<ArticleTitle>([\w\W \r\n]+)<\/ArticleTitle>", fetch_article)
        if title != nothing
            full_title=title[1]
        end
        # get abstract
        abstract_str = match(r"<Abstract>\n                ([\w\W \r\n]+)            <\/Abstract>", fetch_article)
        if abstract_str != nothing
            full_abstract=abstract_str[1]
        end
        # push everything
        if pmid != ""
            push!(title_array, full_title)
            push!(abstract_array, full_abstract)
        end
    end
    # return dictionary of pmid and title
    return(DataFrame(pmid=pmid_array,
                    date_created=date_created_array,
                    title=title_array,
                    main_abstract=abstract_array
                    )
            )

end

# usage
df = fetchBreastCancerArticles("breast cancer", "diagnosis",2015,2018,1000)

output_file = open("output/diagnosis.csv", "w")
close(output_file)
writetable("output/diagnosis.csv",df)


# ref
#https://www.nlm.nih.gov/bsd/mms/medlineelements.html#ab
