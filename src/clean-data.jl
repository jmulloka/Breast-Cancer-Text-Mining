

using TextAnalysis

#function to clean article
function cleanText(rawText)
    sd = StringDocument(rawText) # convert to SD
  try
    #remove cases
    prepare!(sd, strip_case)
    # remove punctuations
    prepare!(sd, strip_punctuation)
    # remove numbers
    prepare!(sd, strip_numbers )
    # remove preposition
    prepare!(sd, strip_prepositions)
    # remove prepos
    prepare!(sd, strip_pronouns)
    # remove stop words
    prepare!(sd, strip_stopwords)
    # remove articles
    prepare!(sd, strip_articles)
    # remove white space
    #  prepare!(sd, strip_whitespace)
    # remove corrupt
    remove_corrupt_utf8!(sd)
    # remove non letters
    # remove_nonletters!(sd)
    # remove custom stop words
     remove_words!(sd, ["et","al", "journal", "https", "org","pmid", "fig", "doi",
                        "nin", "na", "nand", "nof", "pone", "nn", "nthe", "ns",
                        "pmc", "nih", "author", "pa", "manuscript", "nanuscript",
                        "nu", "nscript", "nauthor", "nuthor", "nan", "page", "nmed",
                        "available","nint", "nm", #unit
                        "nam", "pubmed",
                        "nplos", "based", "using", "uthor", "script", "uthor"])


  catch err
      # supress error
        warn(err)
  end
  sx = TextAnalysis.text(sd)
  remove_nonletters!(sd) # this brings error
  return(sd, sx)
end
