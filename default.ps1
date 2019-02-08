###############################################################
##                                                           ##
##                 Base "Psake" Build Script                 ##
##                            For                            ##
##                   Global Resale GRID 3.0                  ##
##                                                           ##
###############################################################

Properties {
    $rootPath = (Get-Item -Path ".\").FullName
    $roundhouse = "$rootPath\tools\roundhouse\rh.exe"
    $build_artifacts_dir = "$rootPath\BuildArtifacts"
    $build_artifacts_api_dir = "$build_artifacts_dir\PublishAPI"
    $build_artifacts_web_dir = "$build_artifacts_dir\PublishWeb"
    $code_dir = "$rootPath\src"
    $test_dir = "$code_dir\TestProjects"
    $api_dir = "$code_dir\GlobalResale.GRID3.Api"
    $web_dir = "$code_dir\GlobalResale.GRID3.Web"
}

Task DEFAULT -depends RestoreDatabase, CleanSolution, BuildSolution, TestSolution
Task DEF -depends RestoreDatabase, CleanSolution, BuildSolution, TestSolution
Task DEV -depends UpdateDatabase, CleanSolution, BuildSolution, TestSolution
Task RDB -depends RestoreDatabase
Task UDB -depends UpdateDatabase
Task PUBAPI -depends PublishApi ##TeamCity
Task PUBWEB -depends PublishWeb ##TeamCity
Task HELP -depends GetHelpMenu

Task RestoreDatabase {
    Write-Host "Restoring Databases" -ForegroundColor Green
    # Exec { & $roundhouse }
}

Task UpdateDatabase {
    Write-Host "Updating Databases" -ForegroundColor Green
    # Exec { & $roundhouse }
}

Task CleanSolution {
    Write-Host "Creating BuildArtifacts directory" -ForegroundColor Green
    if (Test-Path $build_artifacts_dir) {
        Remove-Item $build_artifacts_dir -rec -force | out-null
    }

    mkdir $build_artifacts_dir | out-null

    Write-Host "Cleaning GlobalResale.GRID3.sln" -ForegroundColor Green
    Exec { dotnet clean "$code_dir\GlobalResale.GRID3.sln" -c Debug }
}

Task BuildSolution {
    Write-Host "Building GlobalResale.GRID3.sln" -ForegroundColor Green
    Exec { dotnet build "$code_dir\GlobalResale.GRID3.sln" -c Debug -o $build_artifacts_dir }
}

Task TestSolution {
    Write-Host "Testing GlobalResale.GRID3.sln" -ForegroundColor Green
    Exec { dotnet test "$code_dir\GlobalResale.GRID3.sln" -c Debug -o "$build_artifacts_api_dir" }
}

Task PublishApi {
    if (Test-Path $build_artifacts_api_dir) {
        Remove-Item $build_artifacts_api_dir -rec -force | out-null
    }

    mkdir "$build_artifacts_api_dir" | out-null
    Write-Host "Publishing GlobalResale.GRID3.Api.csproj" -ForegroundColor Green
    Exec { dotnet publish $api_dir -c Release -o "$build_artifacts_api_dir" }
}

Task PublishWeb {
    if (Test-Path $build_artifacts_web_dir) {
        Remove-Item $build_artifacts_web_dir -rec -force | out-null
    }

    mkdir "$build_artifacts_web_dir" | out-null
    Write-Host "Publishing GlobalResale.GRID3.Web.csproj" -ForegroundColor Green
    Exec { dotnet publish $web_dir -c Release -o "$build_artifacts_web_dir" }
}

Task GetHelpMenu {
    Write-Host "#######################################################################################" -ForegroundColor Green
    Write-Host "##                                                                                   ##" -ForegroundColor Green
    Write-Host "##                                      Help Menu                                    ##" -ForegroundColor Green
    Write-Host "##                                                                                   ##" -ForegroundColor Green
    Write-Host "##          DEF    - Drop and Restore databases, rebuild solution and test           ##" -ForegroundColor Green
    Write-Host "##          DEV    - Update database, rebuild solution and test                      ##" -ForegroundColor Green
    Write-Host "##          RDB    - Drop and Restore databases                                      ##" -ForegroundColor Green
    Write-Host "##          UDB    - Update database                                                 ##" -ForegroundColor Green
    Write-Host "##          PUBAPI - Publish API project                                             ##" -ForegroundColor Green
    Write-Host "##          PUBWEB - Publish Web Project                                             ##" -ForegroundColor Green
    Write-Host "##                                                                                   ##" -ForegroundColor Green
    Write-Host "#######################################################################################" -ForegroundColor Green
}