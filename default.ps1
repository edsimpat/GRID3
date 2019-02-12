$script:project_config = "Release"
$script:datascripts = $FALSE

properties {
    $project_name = "GlobalResale.GRID3"
	if(-not $version)
    {
        $version = "1.0.0.1"
    }
	
	$ReleaseNumber =  if ($env:BUILD_NUMBER) {$env:BUILD_NUMBER} else {$version}
	
	Write-Host "**********************************************************************"
	Write-Host "Release Number: $ReleaseNumber"
	Write-Host "**********************************************************************"
	
	$OctopusEnvironment = $env:OCTOPUS_ENVIRONMENT
	$OctopusProjectName = $env:OCTOPUS_PROJECT_NAME

    $base_dir = resolve-path .
    $publish_dir = "$base_dir\publish"
	$build_dir = "$base_dir\build"
	$package_dir = "$build_dir\latestVersion"
	$source_dir = "$base_dir\src"
	$test_dir = "$build_dir\test"
	$result_dir = "$build_dir\results"
	
    $db_server = if ($env:db_server) { $env:db_server } else { ".\SqlExpress" }
	$db_username = if ($env:db_username) { $env:db_username } else { "" }
	$db_password = if ($env:db_password) { $env:db_password } else { "" }
	
	$test_assembly_patterns_unit = @("*UnitTests.dll")
	$test_assembly_patterns_integration = @("*IntegrationTests.dll")
    $test_assembly_to_exclude = "IntegrationTests.Common.dll"
	$test_assembly_patterns_full = @("*FullSystemTests.dll")

    $grid3_db_name = if ($env:db_name) { $env:db_name } else { "GRID3" }
    $grid3_db_scripts_dir = "$source_dir\DatabaseMigration\Databases\GRID3"

	$connStr = "Server=" + $db_server + ";Database=" + $grid3_db_name + ";User Id=" + $db_username + ";Password=" + $db_password + ";"
	
    $roundhouse_dir = "$base_dir\tools\roundhouse"
    $roundhouse_output_dir = "$roundhouse_dir\output"
    $roundhouse_exe_path = "$roundhouse_dir\rh.exe"
    $roundhouse_local_backup_folder = "$base_dir\database_backups"
	
	$octopus_nuget_repo = "c:\Nugets"
	$octopus_API_URL = if ($env:octopus_API_URL) { $env:octopus_API_URL } else { "http://localhost:81/api" }
	$octopus_API_key = if ($env:octopus_API_key) { $env:octopus_API_key } else { "API-MSFWYNHBFXJXBNJJW3KB4H6W0" } 
	$octopus_Publish_URL = if ($env:octopus_API_URL) { $env:octopus_API_URL } else { "http://localhost:81/nuget/packages" }

    $all_database_info = @{
        "$grid3_db_name"="$grid3_db_scripts_dir"
    }
}

task default -depends InitialPrivateBuild
task dev -depends DeveloperBuild
task ci -depends IntegrationBuild
task uad -depends UpdateAllDatabases
task rad -depends RebuildAllDatabases
task tq -depends RunIntegrationTestsQuickly
task tt -depends RunIntegrationTestsThoroughly
task quick -depends QuickRebuild

task help {
	Write-Help-Header
	Write-Help-Section-Header "Comprehensive Building"
	Write-Help-For-Alias "(default)" "Intended for first build or when you want a fresh, clean local copy"
	Write-Help-For-Alias "dev" "Optimized for local dev; Most notably UPDATES databases instead of REBUILDING them"
	Write-Help-For-Alias "ci" "Continuous Integration build (long and thorough) with packaging"
	Write-Help-For-Alias "quick" "Compile and update the database, but skip tests"
	Write-Help-Section-Header "Database Maintence"
	Write-Help-For-Alias "uad" "Update All the Databases to the latest version (all db used for the app, that is)"
	Write-Help-For-Alias "rad" "Rebuild All the Databases to the latest version from scratch (useful while working on the schema)"
	Write-Help-Section-Header "Running Tests"
	Write-Help-For-Alias "tq" "Unit and Test Integration Quickly, aka, UPDATE databases before testing"
	Write-Help-For-Alias "tt" "Unit and Test Integration Thoroughly, aka, REBUILD databases before testing (useful while working on the schema)"
	Write-Help-Footer
	exit 0
}

task InitialPrivateBuild -depends Clean, Compile, RebuildAllDatabases, RunIntegrationTestsThoroughly, WarnSlowBuild
task DeveloperBuild -depends SetDebugBuild, Clean, Compile, UpdateAllDatabases
task IntegrationBuild -depends SetReleaseBuild, CommonAssemblyInfo, Clean, Compile, PublishApiAndWebProjects, CreateOctopusRelease
task QuickRebuild -depends SetDebugBuild, Clean, Compile, UpdateAllDatabases

task SetDebugBuild {
    $script:project_config = "Debug"
}

task SetReleaseBuild {
    $script:project_config = "Release"
}

task RebuildAllDatabases {
    $all_database_info.GetEnumerator() | ForEach-Object{ 
		Write-Host $_.Key
		deploy_database "Rebuild" $db_server $_.Key $_.Value
	}
}

task UpdateAllDatabases {
    $all_database_info.GetEnumerator() | ForEach-Object{ deploy_database "Update" $db_server $_.Key $_.Value}
}

task CommonAssemblyInfo {
    create_SharedAssemblyInfo_class "$ReleaseNumber" $project_name "$source_dir\SharedAssemblyInfo.cs"
}

task CopyAssembliesForTest -Depends Compile {
    copy_all_assemblies_for_test $test_dir
}

task RunIntegrationTestsThoroughly -Depends CopyAssembliesForTest, RebuildAllDatabases {
    update_test_config
    $test_assembly_patterns_integration | ForEach-Object{ run_tests $_ }
}

task RunIntegrationTestsQuickly -Depends CopyAssembliesForTest, UpdateAllDatabases {
    update_test_config
    $test_assembly_patterns_integration | ForEach-Object{ run_tests $_ }
}

task Compile -depends Clean, CommonAssemblyInfo { 
    exec { dotnet restore $source_dir\$project_name.sln }
    exec { dotnet build $source_dir\$project_name.sln --configuration $project_config }
}

task Clean {
	delete_directory $publish_dir
	delete_directory $build_dir
	create_directory $publish_dir
	create_directory $package_dir
    create_directory $test_dir 
	create_directory $result_dir

	Write-Host $source_dir
	Write-Host $project_name.sln
    exec { dotnet clean $source_dir\$project_name.sln --configuration $project_config }
}

task PublishApiAndWebProjects{
	Write-Host "Release Number: $ReleaseNumber"
    exec { dotnet publish $source_dir\$project_name.Web\$project_name.Web.csproj --configuration $project_config --output "$publish_dir\Web" }
    exec { dotnet publish $source_dir\$project_name.Api\$project_name.Api.csproj --configuration $project_config --output "$publish_dir\Api" }
}

task CreateOctopusRelease {
	exec { tools\octotools\octo.exe create-release --project=$OctopusProjectName --server=$octopus_API_URL --apiKey=$octopus_API_key --packageversion=$ReleaseNumber --version=$ReleaseNumber}
}

task WarnSlowBuild {
	Write-Host ""
	Write-Host "Warning: " -foregroundcolor Yellow -nonewline;
	Write-Host "The default build you just ran is primarily intended for initial "
	Write-Host "environment setup. While developing you most likely want the quicker dev"
	Write-Host "build task. For a full list of common build tasks, run: "
	Write-Host " > build.bat help"
}

# -------------------------------------------------------------------------------------------------------------
# generalized functions added by Simpat for Help Section
# -------------------------------------------------------------------------------------------------------------
function Write-Help-Header($description) {
	Write-Host ""
	Write-Host "********************************" -foregroundcolor DarkGreen -nonewline;
	Write-Host " HELP " -foregroundcolor Green  -nonewline; 
	Write-Host "********************************"  -foregroundcolor DarkGreen
	Write-Host ""
	Write-Host "This build script has the following common build " -nonewline;
	Write-Host "task " -foregroundcolor Green -nonewline;
	Write-Host "aliases set up:"
}

function Write-Help-Footer($description) {
	Write-Host ""
	Write-Host " For a complete list of build tasks, view default.ps1."
	Write-Host ""
	Write-Host "**********************************************************************" -foregroundcolor DarkGreen
}

function Write-Help-Section-Header($description) {
	Write-Host ""
	Write-Host " $description" -foregroundcolor DarkGreen
}

function Write-Help-For-Alias($alias,$description) {
	Write-Host "  > " -nonewline;
	Write-Host "$alias" -foregroundcolor Green -nonewline; 
	Write-Host " = " -nonewline; 
	Write-Host "$description"
}

# -------------------------------------------------------------------------------------------------------------
# generalized functions 
# -------------------------------------------------------------------------------------------------------------
function deploy_database($action,$server,$db_name,$scripts_dir,$env) {
    if (!$env) {
        $env = "LOCAL"
        Write-Host "RoundhousE environment variable is not specified... defaulting to 'LOCAL'"
    } else {
        Write-Host "Executing RoundhousE for environment:" $env
    }
    
	Write-Host "RoundhousE parameters:"
	Write-Host "-action:" $action
	Write-Host "-server:" $server
	Write-Host "-db_name:" $db_name
	Write-Host "-scripts_dir:" $scripts_dir
	Write-Host "-environment:" $env    
	Write-Host "-output_dir:" $roundhouse_output_dir    
	Write-Host "-build scripts target:" $build_scripts_target
    Write-Host "-Exe path:" $roundhouse_exe_path
    
	$build_scripts_target = $scripts_dir

	try {
		# Run roundhouse commands on $build_scripts_target
		if ($action -eq "Update"){
			exec { &$roundhouse_exe_path -s $server -d "$db_name"  --commandtimeout=300 -f $build_scripts_target --env $env --silent -o $roundhouse_output_dir --transaction }
		}

		if ($action -eq "Rebuild"){
            exec { &$roundhouse_exe_path -s $server -d "$db_name" --commandtimeout=300 --env $env --silent -drop -o $roundhouse_output_dir }
            exec { &$roundhouse_exe_path -s $server -d "$db_name" --commandtimeout=300 -f $build_scripts_target -env $env --silent --simple -o $roundhouse_output_dir }
		}

	} finally {
		if($script:datascripts)
		{
			# Delete $build_scripts_target directory
			Remove-Item $build_scripts_target -recurse
		}
	}
}

function run_tests([string]$pattern) {
    
    $items = Get-ChildItem -Path $test_dir $pattern
    $items | ForEach-Object{ run_xunit $_.Name }
}

function update_test_config() {
	Get-ChildItem -Path $test_dir *IntegrationTests*.dll.config | Where-Object {$_.Name -NotMatch $test_assembly_to_exclude} | foreach-object { xmlPoke $_ "/configuration/connectionStrings/add[@name='AppConnString']/@connectionString" $connStr }
}

function xmlPoke($file, $xpath, $value) {
    $filePath = $file.FullName

    [xml] $fileXml = Get-Content $filePath
    $node = $fileXml.SelectSingleNode($xpath)
    if ($node) {
        $node.Value = $value

        $fileXml.Save($filePath)
    }
}
function global:delete_file($file) {
    if($file) { remove-item $file -force -ErrorAction SilentlyContinue | out-null } 
}

function global:delete_directory($directory_name) {
  Remove-Item $directory_name -recurse -force  -ErrorAction SilentlyContinue | out-null
}

function global:create_directory($directory_name) {
  mkdir $directory_name  -ErrorAction SilentlyContinue  | out-null
}

function global:run_xunit ($test_assembly) {
	$assembly_to_test = $test_dir + "\" + $test_assembly
	$results_output = $result_dir + "\" + $test_assembly + ".xml"
    write-host "Running XUnit Tests in: " $test_assembly
    exec { dotnet vstest --tests $assembly_to_test /logger:trx $results_output }
}

function global:Copy_and_flatten ($source,$include,$dest) {
	Get-ChildItem $source -include $include -r | Copy-Item -dest $dest
}

function global:copy_all_assemblies_for_test($destination){
	$bin_dir_match_pattern = "$source_dir\**\bin\$project_config"
	create_directory $destination
	Copy_and_flatten $bin_dir_match_pattern @("*.exe","*.dll","*.config","*.pdb","*.sql","*.xlsx","*.csv") $destination

	$dictionaryDestination = "$destination\Dictionary"
	create_directory $dictionaryDestination
	Copy_and_flatten $bin_dir_match_pattern @("*.aff", "*.dic") $dictionaryDestination
}

function global:create_SharedAssemblyInfo_class($version,$applicationName,$filename) {
"using System.Reflection;

// Version information for an assembly consists of the following four values:
//
//      Year                    (Expressed as YYYY)
//      Major Release           (i.e. New Project / Namespace added to Solution or New File / Class added to Project)
//      Minor Release           (i.e. Fixes or Feature changes)
//      Build Date & Revsion    (Expressed as MMDD)
//
[assembly: AssemblyCompany(""GRID 3.0"")]
[assembly: AssemblyCopyright(""Copyright Global Resale 2019"")]
[assembly: AssemblyTrademark("""")]
[assembly: AssemblyCulture("""")]
[assembly: AssemblyVersion(""$version"")]
[assembly: AssemblyFileVersion(""$version"")]" | out-file $filename -encoding "utf8"
}
