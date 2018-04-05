using Requests
using Base.Dates

search_terms = "\"breast cancer\"[ad] and \"diagnosis\"[mh]"

base_search_query = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi"


search_result = readstring(post(base_search_query; data = Dict("db" => "pubmed", "term" => "$search_terms", "retmax" => 1000)))

# retrieve the pmids into a Set
pmid_set = Set()
for result_line in split(search_result, "\n")
  # get list of pmids
  pmid = match(r"<Id>(\d+)<\/Id>", result_line)
  if pmid != nothing
    push!(pmid_set,pmid[1])
  end
end


id_string = join(collect(pmid_set), ",")

base_fetch_query = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi"

fetch_result = readstring(post(base_fetch_query; data = Dict("db" => "pubmed", "id" => id_string, "rettype" => "medline", "retmode" => "text")))


pmid_full = converted_date_created_full = converted_date_completed_full = ""
empty_flag = 0
TI = TI_full = ""

for fetch_line in split(fetch_result, "\n")

	# check if empty line; skip first empty line,
	# otherwise, print pmid, date created, and mesh date
	if isempty(fetch_line)
		if empty_flag == 0
			empty_flag = 1
			end
	end

# get pmid
TI = match(r"TI  - ([\w\W \n]+)", fetch_line)
if TI != nothing
    TI_full = TI[1]
end

end
println(TI_full)
