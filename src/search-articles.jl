using Requests
using DataFrames
################################################################################
# this function returns a DataFrame of articles (pmid, title, abstract)
function searchBreastCancerArticles(cancerType="breast neoplasms", researchType="diagnosis",
                                    minDate=1990,maxDate=2030, retmax=1000)

    search_terms = "\"$cancerType\"[mh] and \"$researchType\"[mh]"

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
    # read through each line
    for fetch_article in split(fetch_result_medline, "PMC - ")
        # clear all field
        pmcid =""
        pmid=""
        date_published=""
        title=""

        for fetch_line in split(fetch_article, "\n")
            # extract PMCID
            pmcid_str = match(r"(PMC[0-9]+)", fetch_line)
            if pmcid_str != nothing
              pmcid = pmcid_str[1]
            end

            # extract PMID
            pmid_str = match(r"PMID- ([\w\W \r\n]+)", fetch_line)
            if pmid_str != nothing
              pmid = pmid_str[1]
            end

            # date published
            date_published_str = match(r"DEP - ([\w\W \r\n]+)", fetch_line)
            if date_published_str != nothing
                date_published = date_published_str[1]
            end

            # date published
            title_str = match(r"TI  - ([\w\W \r\n]+)", fetch_line)
            if title_str != nothing
                title = title_str[1]
            end

        end
        # push everything
        if pmid != ""
            push!(pmcid_array, pmcid)
            push!(pmid_array, pmid)
            push!(date_published_array, date_published)
            push!(title_array, title)

        end

    end

#=    for fetch_article in split(fetch_result_xml, "<front>")
        # clear all field
        full_title=""
        full_abstract=""

       # get Title
        title = match(r"<title-group>([\w\W \r\n]+)</title-group>", fetch_article)
        if title != nothing
            full_title=title[1]
        end
        # get abstract
        abstract_str = match(r"<abstract>([\w\W \r\n]+)<\/abstract>", fetch_article)
        if abstract_str != nothing
            full_abstract=abstract_str[1]
        end
            push!(title_array, full_title)
#            push!(abstract_array, full_abstract)
#        end
    end
=# # return dictionary of pmid and title
    return(DataFrame(pmcid = pmcid_array,
                     pmid = pmid_array,
                     date_published = date_published_array,
                     title = title_array
#                    main_abstract = abstract_array
                    )
            )
end

# usage
#df = fetchBreastCancerArticles("breast cancer", "diagnosis",2015,2018,10)

#output_file = open("output/diagnosis.csv", "w")
#close(output_file)
#writetable("output/diagnosis.csv",df)


# ref
#https://www.nlm.nih.gov/bsd/mms/medlineelements.html#ab
