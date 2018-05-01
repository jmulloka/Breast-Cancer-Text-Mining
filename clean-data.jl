

using TextAnalysis

#function to clean article
function cleaninText(rawText)
  sd = StringDocument(rawText) # convert to SD
  #remove cases
  remove_case!(sd)
  # remove punctuations
  remove_punctuation!(sd)
  # remove numbers
  remove_numbers!(sd)
  # remove preposition
  remove_prepositions!(sd)
  # remove prepos
  remove_pronouns!(sd)
  # remove
  remove_stop_words!(sd)
  # remove white space
  #remove_whitespace!(sd)
  # remove non letters
  remove_nonletters!(sd)
  # remove custom stop words
  remove_words!(sd, ["et","al", "journal", "https", "org","pmid", "fig", "doi",
                      "nin", "na", "nand", "nof", "pone", "nn", "nthe", "ns",
                      "nplos", "based", "using"])

  return(sd)
end
