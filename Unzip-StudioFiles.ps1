function Unzip-StudioFiles {
	if($args.Count -lt 2){
		"Usage: unzip-studiofiles \\janus\studio_work \\janus\studio_work"
		return
	}
	
	$source = $args[0]
	$dest = $args[1]
	if((Does-FolderExist -Path $source) -eq $false){
		$message = "Source does not exist, please check now exiting: " + $source
		Log-Error $message
		return
	}
	if((Does-FolderExist -Path $dest) -eq $false){
		$message = "Dest does not exist, please check now exiting: " + $dest
		Log-Error $message
		return
	}
}
