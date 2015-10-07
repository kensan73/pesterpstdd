$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Unzip-StudioFiles" {
    Function Does-FolderExist { param ($Path) }
	Function Log-Info { param ($Message) }
	Function Log-Debug { param ($Message) }
	Function Log-Error { param ($Message) }

    It "prints usage on 0 or 1 parameters" {
		$usage = "Usage: unzip-studiofiles \\janus\studio_work \\janus\studio_work"
		
		Unzip-StudioFiles | Should Be $usage
		Unzip-StudioFiles "paramone" | Should Be $usage
    }

    It "fails on nonexistent source folder" {
		$source = "\\somesource\with_folder"
		$dest = "\\somedest\another_folder"
		$sourcenonexistent = "Source does not exist, please check now exiting: " + $source
		Mock Does-FolderExist –ParameterFilter { $Path –eq $source } -MockWith { $false }
		Mock Log-Error -ParameterFilter { $Message -eq $sourcenonexistent }
		
		Unzip-StudioFiles $source $dest # | Should Be $sourcenonexistent
		
		Assert-MockCalled Log-Error –ParameterFilter { $Message -eq $sourcenonexistent } -Times 1
		Assert-MockCalled Does-FolderExist –ParameterFilter { $Path -eq $source } -Times 1
    }

    It "fails on nonexistent dest folder" {
		$source = "\\somesource\with_folder"
		$dest = "\\somedest\another_folder"
		$destnonexistent = "Dest does not exist, please check now exiting: " + $dest
		Mock Does-FolderExist –ParameterFilter { $Path –eq $source } -MockWith { $true }
		Mock Does-FolderExist –ParameterFilter { $Path –eq $dest } -MockWith { $false }
		Mock Log-Error -ParameterFilter { $Message -eq $destnonexistent }
		
		Unzip-StudioFiles $source $dest #| Should Be $destnonexistent
		
		Assert-MockCalled Log-Error –ParameterFilter { $Message -eq $destnonexistent } -Times 1
		Assert-MockCalled Does-FolderExist –ParameterFilter { $Path -eq $source } -Times 1
		Assert-MockCalled Does-FolderExist –ParameterFilter { $Path -eq $dest } -Times 1
    }

    It "no zips found exits" {
		$source = "\\somesource\with_folder"
		$dest = "\\somedest\another_folder"
		Mock Does-FolderExist –ParameterFilter { $Path –eq $source } -MockWith { $true }
		Mock Does-FolderExist –ParameterFilter { $Path –eq $dest } -MockWith { $true }
		
		Unzip-StudioFiles $source $dest
		
		Assert-MockCalled Does-FolderExist –ParameterFilter { $Path -eq $source } -Times 1
		Assert-MockCalled Does-FolderExist –ParameterFilter { $Path -eq $dest } -Times 1
    }
}
