#S.Kusen Feb 6 2015
#
#This powershell script shows a way to loop through a list of instances pulled from a database table and execute an SSIS package against those instances.
#The example uses a file path to a .dtsx file. Search dtexec in BOL for example on how to execute from packages stored within MSDB.
#
#For this example to work, you'll need to do the following updates to the script:
#1. set the $dbaadminserver value to the name of your SQL Server where the DEMO_DBAInventory exists.
#2. Verify the path to dtexec.  The $scriptcommand is set to C:\Program Files\Microsoft SQL Server\110\DTS\Binn\dtexec by default.  Your path may be different.
#

Add-PSSnapin SqlServerProviderSnapin110 -ErrorAction SilentlyContinue -WarningAction SilentlyContinue #SQL 2008 / 2008 R2
Add-PSSnapin SqlServerCmdletSnapin110 -ErrorAction SilentlyContinue -WarningAction SilentlyContinue #SQL 2008 / 2008 R2

#####  Set the $dbaadminserver to where you have placed the DEMO_DBAInventory database
$dbaadminserver = "PACDCSQLDEVD01"
$dbainventorydb = "DEMO_DBAInventory"
$sqlcommand_pull_instance_list = "SELECT [instance_name] FROM [dbo].[instances]"

$instances = Invoke-Sqlcmd -DisableVariables -QueryTimeout 900 -ServerInstance $dbaadminserver  -Database $dbainventorydb -Query $sqlcommand_pull_instance_list

#uncomment the next like to see the list of instances that was pulled back by the query
$instances

#loop through each instance and execute the SSIS package
foreach ($instance in $instances) {

	#the path to the dtexec command may be different on your server.  Powershell is not very friendly to folder names with spaces, so the insertion
	#of char(34) puts in quotes to help resolve the path
	#this line will create the command to pass the instance name from the instance loaded in the loop to the package variable instance_name
	$scriptcommand = " & D:\$([Char]34)Program Files$([Char]34)\$([Char]34)Microsoft SQL Server$([Char]34)\110\DTS\Binn\dtexec /FILE $([Char]34)C:\temp\Method2.dtsx$([Char]34) /SET $([Char]34)\Package.Variables[instance_name].Value;$($instance.instance_name)$([Char]34)"
	
	try
	{
		#initiate the powershell job for the loaded instance, should continue through to start jobs for all instances
		Start-Job -ScriptBlock { param($p_command); Invoke-Expression $p_command } -ArgumentList $scriptcommand
	}
	catch { [system.exception] "Failed to Pull from $instance" | Out-File "C:\temp\method2_catch_errors.txt" -Width 200 -Append}
	finally {write-host "Finally $instance"}
	
	#$instance.instancename
} #foreach ($instance in $instances) 

#this will give each job 3 minutes to execute.  If it runs beyond 3 minutes, it is presumed hung and will allow powershell to quit the job and
#prevent memory "leaks".
#Also, when you schedule this as a SQL Agent job, you may want to know that the data collection is complete before proceeding to the next step in your
#job.
get-job | wait-job -Timeout 180;
