
################################################################################

using Requests

# dictionary for keeping track of years
year_dict = Dict()

search_terms = "\"breast cancer\"[ad] and \"diagnosis\"[mh]"

# Retrieve number of results - from ESearch results
# define base search query for eutils
base_search_query = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi"

# run esearch to get pmids
search_result = readstring(post(base_search_query; data = Dict("db" => "pubmed", "term" => "$search_terms", "retmax" => 1000)))
#print(search_result)

# retrieve the pmids into a Set
pmid_set = Set()
for result_line in split(search_result, "\n")
  # get list of pmids
  pmid = match(r"<Id>(\d+)<\/Id>", result_line)
  if pmid != nothing
    push!(pmid_set,pmid[1])
  end
end

# concatenate pmids into a single comma separated string
id_string = join(collect(pmid_set), ",")

# define base fetch query for eutils
base_fetch_query = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi"

# retrieve metadata for pmid Set
fetch_result = readstring(post(base_fetch_query; data = Dict("db" => "pubmed",
"id" => id_string, "rettype" => "medline", "retmode" => "text")))
#print(fetch_result)

# initialize variables
pmid_full = date_created_full = date_completed_full = mesh_date_full =
converted_date_completed = converted_date_created = ""
empty_flag = 0

# read through each line
for fetch_line in split(fetch_result, "\n")

    # get pmid
    pmid = match(r"PMID- ([0-9]+)", fetch_line)
    if pmid != nothing
  		pmid_full = pmid[1]
            println("$pmid_full:")
    end

  # get Title
  title = match(r"TI  - ([\w\W \r\n]+)", fetch_line)
  if title != nothing
      ti=  title[1]
      println("$ti")
  end




end
