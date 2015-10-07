$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Unzip-StudioFiles" {
	$source = "\\somesource\with_folder"
	$dest = "\\somedest\another_folder"
	$destnonexistent = "Dest does not exist, please check now exiting: " + $dest
	$sourcenonexistent = "Source does not exist, please check now exiting: " + $source

    Function Does-FolderExist { param ($Path) }
	Function Log-Info { param ($Message) }
	Function Log-Debug { param ($Message) }
	Function Log-Error { param ($Message) }
	Function Get-Zips { param ($Path)}
	Function Is-ZipGood { param ($Path)}
	Function Is-FilenameCorrect { param ($Path) }
	Function Unzip-SingleFile { param ($Source, $Dest) }
	Function Delete-SingleFile { param ($Path) }
	
    It "prints usage on 0 or 1 parameters" {
		$usage = "Usage: unzip-studiofiles \\janus\studio_work \\janus\studio_work"
		
		Unzip-StudioFiles | Should Be $usage
		Unzip-StudioFiles "paramone" | Should Be $usage
    }

    It "fails on nonexistent source folder" {
		Mock Does-FolderExist –ParameterFilter { $Path –eq $source } -MockWith { $false }
		Mock Log-Error -ParameterFilter { $Message -eq $sourcenonexistent }
		
		Unzip-StudioFiles $source $dest # | Should Be $sourcenonexistent
		
		Assert-MockCalled Log-Error –ParameterFilter { $Message -eq $sourcenonexistent } -Times 1
		Assert-MockCalled Does-FolderExist –ParameterFilter { $Path -eq $source } -Times 1
    }

    It "fails on nonexistent dest folder" {
		Mock Does-FolderExist –ParameterFilter { $Path –eq $source } -MockWith { $true }
		Mock Does-FolderExist –ParameterFilter { $Path –eq $dest } -MockWith { $false }
		Mock Log-Error -ParameterFilter { $Message -eq $destnonexistent }
		
		Unzip-StudioFiles $source $dest #| Should Be $destnonexistent
		
		Assert-MockCalled Log-Error –ParameterFilter { $Message -eq $destnonexistent } -Times 1
		Assert-MockCalled Does-FolderExist –ParameterFilter { $Path -eq $source } -Times 1
		Assert-MockCalled Does-FolderExist –ParameterFilter { $Path -eq $dest } -Times 1
    }

    It "no zips found exits" {
		$nothingtodo = "No zips found, nothing to do."
		Mock Does-FolderExist –ParameterFilter { $Path –eq $source } -MockWith { $true }
		Mock Does-FolderExist –ParameterFilter { $Path –eq $dest } -MockWith { $true }
		Mock Get-Zips -ParameterFilter { $Path -eq $source } -MockWith { @() }
		Mock Log-Info -ParameterFilter { $Message -eq $nothingtodo }
		
		Unzip-StudioFiles $source $dest
		
		Assert-MockCalled Does-FolderExist –ParameterFilter { $Path -eq $source } -Times 1
		Assert-MockCalled Does-FolderExist –ParameterFilter { $Path -eq $dest } -Times 1
		Assert-MockCalled Get-Zips –ParameterFilter { $Path -eq $source } -Times 1
		Assert-MockCalled Log-Info -ParameterFilter { $Message -eq $nothingtodo } -Times 1
    }

    It "one zip returned tests corrupt" {
		$onezippath = "\\machine\folder\onecorrupt.zip"
		$corruptzipmessage = "Corrupt zip detected please check: " + $onezippath
		
		Mock Does-FolderExist –ParameterFilter { $Path –eq $source } -MockWith { $true }
		Mock Does-FolderExist –ParameterFilter { $Path –eq $dest } -MockWith { $true }
		Mock Get-Zips -ParameterFilter { $Path -eq $source } -MockWith { @($onezippath) }
		Mock Is-ZipGood -ParameterFilter { $Path -eq $onezippath } -MockWith { $false }
		Mock Log-Error -ParameterFilter { $Message -eq $corruptzipmessage }
		
		Unzip-StudioFiles $source $dest
		
		Assert-MockCalled Does-FolderExist –ParameterFilter { $Path -eq $source } -Times 1
		Assert-MockCalled Does-FolderExist –ParameterFilter { $Path -eq $dest } -Times 1
		Assert-MockCalled Get-Zips –ParameterFilter { $Path -eq $source } -Times 1
		Assert-MockCalled Is-ZipGood -ParameterFilter { $Path -eq $onezippath } -Times 1
		Assert-MockCalled Log-Error -ParameterFilter { $Message -eq $corruptzipmessage } -Times 1
    }

    It "one zip incorrect filename" {
		$onezippath = "\\machine\folder\onecorrupt.zip"
		$badzipfilenamemessage = "Expect filename like State__jobid.zip please check: " + $onezippath
		
		Mock Does-FolderExist –ParameterFilter { $Path –eq $source } -MockWith { $true }
		Mock Does-FolderExist –ParameterFilter { $Path –eq $dest } -MockWith { $true }
		Mock Get-Zips -ParameterFilter { $Path -eq $source } -MockWith { @($onezippath) }
		Mock Is-ZipGood -ParameterFilter { $Path -eq $onezippath } -MockWith { $true }
		Mock Is-FilenameCorrect -ParameterFilter { $Path -eq $onezippath } -MockWith { $false }
		Mock Log-Error -ParameterFilter { $Message -eq $badzipfilenamemessage }
		
		Unzip-StudioFiles $source $dest
		
		Assert-MockCalled Does-FolderExist –ParameterFilter { $Path -eq $source } -Times 1
		Assert-MockCalled Does-FolderExist –ParameterFilter { $Path -eq $dest } -Times 1
		Assert-MockCalled Get-Zips –ParameterFilter { $Path -eq $source } -Times 1
		Assert-MockCalled Is-ZipGood -ParameterFilter { $Path -eq $onezippath } -Times 1
		Assert-MockCalled Is-FilenameCorrect -ParameterFilter { $Path -eq $onezippath } -Times 1
		Assert-MockCalled Log-Error -ParameterFilter { $Message -eq $badzipfilenamemessage } -Times 1
    }

    It "unzips and deletes" {
		$onezippath = "\\machine\folder\onecorrupt.zip"
		$onefiledonemessage = "Unzipped and deleted file: " + $onezippath
		
		Mock Does-FolderExist –ParameterFilter { $Path –eq $source } -MockWith { $true }
		Mock Does-FolderExist –ParameterFilter { $Path –eq $dest } -MockWith { $true }
		Mock Get-Zips -ParameterFilter { $Path -eq $source } -MockWith { @($onezippath) }
		Mock Is-ZipGood -ParameterFilter { $Path -eq $onezippath } -MockWith { $true }
		Mock Is-FilenameCorrect -ParameterFilter { $Path -eq $onezippath } -MockWith { $true }
		Mock Unzip-SingleFile -ParameterFilter { $Source -eq $onezippath, $Dest -eq $dest }
		Mock Delete-SingleFile -ParameterFilter { $Source -eq $onezippath }
		Mock Log-Info -ParameterFilter { $Message -eq $onefiledonemessage }
		
		Unzip-StudioFiles $source $dest
		
		Assert-MockCalled Does-FolderExist –ParameterFilter { $Path -eq $source } -Times 1
		Assert-MockCalled Does-FolderExist –ParameterFilter { $Path -eq $dest } -Times 1
		Assert-MockCalled Get-Zips –ParameterFilter { $Path -eq $source } -Times 1
		Assert-MockCalled Is-ZipGood -ParameterFilter { $Path -eq $onezippath } -Times 1
		Assert-MockCalled Is-FilenameCorrect -ParameterFilter { $Path -eq $onezippath } -Times 1
		Assert-MockCalled Unzip-SingleFile -ParameterFilter { $Source -eq $onezippath, $Dest -eq $dest } -Times 1
		Assert-MockCalled Delete-SingleFile -ParameterFilter { $Source -eq $onezippath } -Times 1
		Assert-MockCalled Log-Info -ParameterFilter { $Message -eq $onefiledonemessage } -Times 1
    }
}
