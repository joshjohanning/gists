echo -n "NuGet feed name?"
read nugetfeed
echo -n "NuGet feed source?"
read nugetsource
echo -n "Enter PAT"
read pat
# adding to ~/.config/NuGet/NuGet.config
nuget sources add -Name $nugetfeed -Source $nugetsource -username "az" -password $pat 
results=$(find . -name "*.nupkg")
resultsArray=($results)

for pkg in "${resultsArray[@]}"
do
    echo $pkg
    nuget push -Source $nugetfeed -ApiKey az $pkg
done