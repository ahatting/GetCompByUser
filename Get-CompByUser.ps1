#region Change these
$date=Get-Date -format M.d.yyyy

#inputfile: SamAccountName as header with values below, 1 per line, no comma's needed.
#Fetch the current directory
$currentdir = (Get-Location).path
#import the inputlist
$users= import-csv "$currentdir\inputlist.csv"
#Define outputfile 
[string]$ExportFile="$currentdir\PS-Get-CompByUser($date).csv"

#write output file headers
Out-File -InputObject "SamAccountName;Computername" -FilePath $Exportfile

#Re-used function (http://www.jbmurphy.com/2012/01/17/powershell-query-to-find-a-users-computer-name-in-sccm/comment-page-1/#comment-324799)
FUNCTION Get-CompByUser {
Param([parameter(Mandatory = $true)]$SamAccountName,
	#Change SCCM site
	$SiteName="001",
	#change SCCM server
	$SCCMServer="SCCMServer.domain.local")
	$SCCMNameSpace="root\sms\site_$SiteName"
	Get-WmiObject -namespace $SCCMNameSpace -computer $SCCMServer -query "select Name from sms_r_system where LastLogonUserName='$SamAccountName'"
}

#endregion


#region  ------------------------MAIN---------------------------------

#For each user do the lookup in SCCM and write to file (+show a progress bar during execution)
foreach($user in $users){
	$pos++
	$count=$users.Count
	$username=$user.samaccountname
	write-progress -id 1 -activity "Fetching computer for user $($user.SamAccountName)" -status "% Complete" -percentcomplete ($pos/$count*100)
	$computer = Get-CompByUser -SamAccountName $user.SamAccountName
	$computername = $computer.name
	Out-File -InputObject "$UserName;$computername" -FilePath $Exportfile -Append
} 
write-progress -activity "Fetching computer for user $($user.SamAccountName)" -status "% Complete:" -percentcomplete -1 -Completed


#endregion
