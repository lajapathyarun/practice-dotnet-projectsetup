$RepoPath = "C:\ProjectRepositories\"

New-Item -Path $RepoPath -Type Directory -Force

$ApplicationName = "IdentityAccessManager1"

$ProjectConfig = (Get-Content -Path ".\setup-config.json" -Raw).Replace('$AppName', $ApplicationName) | ConvertFrom-Json

#Create Application
CreateDirectory -path "$RepoPath$ApplicationName"

#Create Solution
$SolutionPath = "$RepoPath$ApplicationName"
dotnet new create solution --output $SolutionPath  --name $ApplicationName  --force

# Projects
foreach ($project in $ProjectConfig.Projects) {
    $ProjectPath = Join-Path $SolutionPath $project.Name
    
    dotnet new create $project.Template --output $ProjectPath --name $project.Name --force

    # Package References
    foreach ($package in $project.Packages) {
        dotnet add $ProjectPath package $package.Name --version $package.Version --source $package.Source    
    }

    # Project References
    foreach ($reference in $project.References) {
        $ProjectReferencePath = Join-Path $SolutionPath $reference.Name
        
        dotnet add  $ProjectPath reference $ProjectReferencePath
    }

    # Solution-Project References
    dotnet sln $SolutionPath add $ProjectPath 
}

