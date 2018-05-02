
# add all packages used here
packages = [
     "IJulia",
     "Gadfly",
     "DataFrames",
     "RCall",
     "TextAnalysis",
     "Query",
     "Vega",
     "Taro",
     "ProgressMeter",
     "Languages",
     "Requests",
     "Plotly",
 ]
# this function installs all required packages
function initApp()
    println("checking for packages...")
    # fetch all installed packages
    installedPkgs = Pkg.installed()
    # loop through each required packages and install of missing
    for pkg in packages
        if !haskey(installedPkgs, pkg)
                println("$pkg is missing in your system...")
                println("Installing $pkg...")
                Pkg.add(pkg)
        end
    end
    println(":) All Packages installed!")
end

# initilize app
initApp()
