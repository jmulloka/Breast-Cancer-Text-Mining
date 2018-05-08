using Taro
using DataFrames
using Requests
using TextAnalysis
using Languages
#

# initialize JVM
try
  # fix compatibility issue
  if is_apple()
      # dont initialize coz apple initializes jvm by default
  else
      Taro.init() # init once
  end

catch
  # something is not right
end

#function to clean article
function preCleaning(pdfText)
  sd = StringDocument(pdfText) # convert to SD
  remove_corrupt_utf8!(sd) # remove currupt utf8
  remove_html_tags!(sd) # remove html
  prepare!(sd, strip_punctuation) # remove punctuation
  #prepare!(sd,strip_punctuation | strip_numbers | strip_case | strip_whitespace)
  return(sd)
end

# function to fetch the entire full articles from https://www.ncbi.nlm.nih.gov/pmc
function fetchFullArticleFromPmc(dataFrame,pubYear=2018)
  pmcids = dataFrame[:pmcid]
  tempDir = mktempdir() # create temp directory
  nrows =nrow(dataFrame)
#  tracker = Progress(nrows, 1)
  # define the new columns
  dataFrame[:pmcUrl] = ""
  dataFrame[:fullText] = ""

  for row in eachrow(dataFrame)
    try
      pmcid = row[:pmcid]
      pmcUrl = "https://www.ncbi.nlm.nih.gov/pmc/articles/$pmcid/pdf";
      println("downloading: $pmcid")
      pdfTempPath = Requests.save(Requests.get(pmcUrl), joinpath(tempDir,"$pmcid.pdf"))
      pdfMeta, pdfText = Taro.extract(pdfTempPath)

      # append row
      row[:pmcUrl] = pmcUrl
      sd = preCleaning(pdfText) # clean article
      pubYear =string(pubYear)
      timestamp!(sd, pubYear) # add pub year

      row[:fullText] =  TextAnalysis.text(sd)
    catch err
      # catch errors
      warn(err)
    end
      #next!(tracker)
  end
  return(dataFrame)
end
