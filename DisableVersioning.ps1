#Load SharePoint CSOM Assemblies
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
  
Function Disable-SPOVersioning()
{
    param
    (
        [Parameter(Mandatory=$true)] [string] $SiteURL,
        [Parameter(Mandatory=$true)] [string] $ListName
    )
    Try {
        #Get Credentials to connect
 #       $Credentials= Get-Credential
   
        #Setup the context
        $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
        $Ctx.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Credentials.Username, $Credentials.Password)
           
        #Get the List
        $List = $Ctx.Web.Lists.GetByTitle($ListName)

write-host $List.EnableVersioning
          
        #sharepoint online powershell disable versioning
        $List.EnableVersioning = $False
        $List.Update()
#	read-host
        $Ctx.ExecuteQuery()
        Write-host -f Green "Versioning has been turned OFF at $ListName"
    }
    Catch {
        write-host -f Red "Error:" $_.Exception.Message
    }
}
  
#Set Parameters
$SiteURL="https://frenchexchangefaq.sharepoint.com/sites/ALPHORM"
$ListName="Documents"
  
#Call the function
Disable-SPOVersioning -SiteURL $SiteURL -ListName $ListName


#Read more: https://www.sharepointdiary.com/2018/08/sharepoint-online-powershell-to-disable-versioning.html#ixzz6U3TA4ebR