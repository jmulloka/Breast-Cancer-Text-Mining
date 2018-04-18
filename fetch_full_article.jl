using Taro
using DataFrames
using Requests
using ProgressMeter
Taro.init() # init once

function fetchFullArticleFromPmc(dataFrame ::DataFrames) ::DataFrames
  pmcids = dataFrame[:pmcid]
  tempDir = mktempdir() # create temp directory
  nrows =nrow(dataFrame)
  tracker = Progress(nrows, 1)
  # define the new columns
  dataFrame[:pmcUrl] = fill!(Array(Any, size(df,1)), NA)
  dataFrame[:fullText] = fill!(Array(Any, size(df,1)), NA)

  for row in eachrow(dataFrame)
      pmcid = row[:pmcid]
      pmcUrl = "https://www.ncbi.nlm.nih.gov/pmc/articles/$pmcid/pdf";
      pdfTempPath = save(get(pmcUrl), joinpath(tempDir,"$pmcid.pdf"))
      pdfMeta, pdfText = Taro.extract(pdfTempPath)

      # append row
      row[:pmcUrl] = pmcUrl
      row[:fullText] = pdfText

      next!(tracker)
  end
  # return dataFrame
  return(dataFrame)
end

# How to use
# df = fetchBreastCancerArticles("breast cancer", "diagnosis",2015,2018,10)
# df2 = fetchFullArticleFromPmc(df)
