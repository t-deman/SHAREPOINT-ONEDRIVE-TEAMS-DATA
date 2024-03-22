#Load SharePoint CSOM Assemblies
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
$global:c=0
$global:t=0
  
#Function to get all files of a folder
Function Get-AllFilesFromFolder([Microsoft.SharePoint.Client.Folder]$Folder)
{
    #Get All Files of the Folder
    $Ctx =  $Folder.Context
    try{ $Ctx.load($Folder.files)
      $Ctx.ExecuteQuery()}
    catch{
      Write-host -f red $Folder.Name }

 
    Write-host -f blue $Folder.Name 
    #Get all files in Folder
    ForEach ($File in $Folder.files)
    {
        #Get the File Name or do something
          #Get all versions of the file
          $Versions = $File.Versions
        try {
          $Ctx.Load($Versions)
          $Ctx.ExecuteQuery() }
        catch{
          Write-host -f red "Version Error"
          }

#Read more: https://www.sharepointdiary.com/2016/02/sharepoint-online-delete-version-history-using-powershell.html#ixzz6U3dFmd6A
        $v=$Versions.Count
        $n=$File.Name
        $global:c+=1
        Write-host -f Green "Vus=$global:c $n $v"
        if ($v -gt 0) {
#Delete all versions of the file
          try{
            $Versions.DeleteAll()
            $Ctx.ExecuteQuery()
            }
          catch{  Write-host -f red "Remove Version Error" }
          $global:t+=1
          Write-host -f Yellow "Mod=$global:t All versions Deleted for: $n"
        }
    }
    Start-Sleep -Milliseconds 1000     
    #Recursively Call the function to get files of all folders
    try{
      $Ctx.load($Folder.Folders)
      $Ctx.ExecuteQuery()}
    catch{  Write-host -f red "Folder load Error"}
  
    #Exclude "Forms" system folder and iterate through each folder
    ForEach($SubFolder in $Folder.Folders | Where {$_.Name -ne "Forms"})
    {
        Get-AllFilesFromFolder -Folder $SubFolder
    }
}
  
#powershell list all documents in sharepoint online library
Function Get-SPODocumentLibraryFiles()
{
    param
    (
        [Parameter(Mandatory=$true)] [string] $SiteURL,
        [Parameter(Mandatory=$true)] [string] $LibraryName,
        [Parameter(Mandatory=$true)] [System.Management.Automation.PSCredential] $Credentials
    )
    Try {
      
        #Setup the context
        $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
        $Ctx.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Credentials.UserName,$Credentials.Password)
  
        #Get the Library and Its Root Folder
        $Library=$Ctx.web.Lists.GetByTitle($LibraryName)
        $Ctx.Load($Library)
        $Ctx.Load($Library.RootFolder)



        $Ctx.ExecuteQuery()
  
        #Call the function to get Files of the Root Folder
        Get-AllFilesFromFolder -Folder $Library.RootFolder
#        Get-AllFilesFromFolder -Folder $targetFolder
     }
    Catch {
        write-host -f Red "Error:" $_.Exception.Message
    }
}
#Config Parameters
$SiteURL= "https://frenchexchangefaq-my.sharepoint.com/personal/tdeman_faqexchange_info"
$LibraryName="Documents"
 
#Get Credentials to connect
#$Credentials = Get-Credential
  
#Call the function to Get All Files from a document library
Get-SPODocumentLibraryFiles -SiteURL $SiteURL -LibraryName $LibraryName -Credential $Credentials
#Get-AllFilesFromFolder
write-host "$global:t $global:c"
#Read more: https://www.sharepointdiary.com/2018/08/sharepoint-online-powershell-to-get-all-files-in-document-library.html#ixzz6U3aXeGe1