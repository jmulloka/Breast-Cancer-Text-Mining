using Taro
using DataFrames
using Requests
using ProgressMeter
using TextAnalysis
using Languages

# initialize packages and JVM
try
  Taro.init() # init once
catch
  # something is not right
end

#function to clean article
function preCleaning(pdfText)
  sd = StringDocument(pdfText) # convert to SD
  remove_corrupt_utf8!(sd) # remove currupt utf8
  remove_html_tags!(sd) # remove html
  remove_punctuation!(sd) # remove punctuation
  #prepare!(sd,strip_punctuation | strip_numbers | strip_case | strip_whitespace)
  return(sd)
end

# function to fetch the entire full articles from https://www.ncbi.nlm.nih.gov/pmc
function fetchFullArticleFromPmc(dataFrame, filename="diagnosis_full_article")
  pmcids = dataFrame[:pmcid]
  tempDir = mktempdir() # create temp directory
  nrows =nrow(dataFrame)
  tracker = Progress(nrows, 1)
  # define the new columns
  dataFrame[:pmcUrl] = ""
  dataFrame[:fullText] = ""

  for row in eachrow(dataFrame)
    try
      pmcid = row[:pmcid]
      pmcUrl = "https://www.ncbi.nlm.nih.gov/pmc/articles/$pmcid/pdf";
      println("downloading: $pmcid")
      pdfTempPath = save(get(pmcUrl), joinpath(tempDir,"$pmcid.pdf"))
      pdfMeta, pdfText = Taro.extract(pdfTempPath)

      # append row
      row[:pmcUrl] = pmcUrl
      sd = preCleaning(pdfText) # clean article

      row[:fullText] =  text(sd)
    catch err
      # catch errors
      warn(err)
    end
      next!(tracker)
  end
  # save it as excel
  output_file = open("output/$filename.csv", "w")
  close(output_file)
  writetable("output/$filename.csv",dataFrame)
  # return dataFrame
  return(dataFrame)
end



# How to use
# df = fetchBreastCancerArticles("breast cancer", "diagnosis",2015,2018,10)
# df2 = fetchFullArticleFromPmc(df)
