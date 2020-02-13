
$ErrorActionPreference = 'Stop'

Function Convert-CsvInBatch
{
	[CmdletBinding()]
	Param
	(
		[Parameter(Mandatory=$true)][String]$Folder
	)
	$ExcelFiles = Get-ChildItem -Path $Folder -Filter *.xlsx -Recurse

	$excelApp = New-Object -ComObject Excel.Application
	$excelApp.DisplayAlerts = $false

	$ExcelFiles | ForEach-Object {
		$workbook = $excelApp.Workbooks.Open($_.FullName)
		$csvFilePath = $_.FullName -replace "\.xlsx$", ".csv"
		$workbook.SaveAs($csvFilePath, [Microsoft.Office.Interop.Excel.XlFileFormat]::xlCSV)
		$workbook.Close()
	}

	# Release Excel Com Object resource
	$excelApp.Workbooks.Close()
	$excelApp.Visible = $true
	Start-Sleep 5
	$excelApp.Quit()
	[System.Runtime.Interopservices.Marshal]::ReleaseComObject($excelApp) | Out-Null
}

#
# 0. Prepare the folder path which contains all excel files
$FolderPath = "C:/Office365"

Convert-CsvInBatch -Folder $FolderPath


## Authentification Office 365 par PAPAMICA
$UserAdmin = "admin@e2c95.fr"         ## Adresse email de connexion
$Credentials = "vffysbdynxxzbbtn"     ## Mot de passe application du compte
Connect-MsolService -Credential $Credentials
$MsoExchangeURL = "https://ps.outlook.com/PowerShell-LiveID?PSVersion=5.0.10586.122"
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $MsoExchangeURL -Credential $Credentials -Authentication Basic -AllowRedirection

## Importer les paramètres de la session Office 365 Microsoft Online
Import-PSSession $Session

## Récupérer le contenu du fichier CSV
$CSV = Import-Csv -Path "C:\ajout-utilisateur.csv" -Delimiter ";" -Encoding Default

foreach($User in $CSV){
    $UserName = $User.PRENOM
    $UserSurname = $User.NOM
    $UserDisplayName = $User.PRENOM + " " + $User.NOM
    $UserPassword = $User.PASSWORD

    # Licence à attribuer à l'utilisateur
    $UserLicense = "e2c95:STANDARDWOFFPACK_STUDENT"

    # UPN sous la forme prenom.nom@ndd
    $UserPrincipalName = ($UserName).ToLower() + "." + ($UserSurname).ToLower() + "@e2c77.org"  ## Nom de domaine de la société

try{
    # Créer l'utilisateur
    New-MsolUser    -DisplayName $UserDisplayName -FirstName $UserName -LastName $UserSurname `
                    -UserPrincipalName $UserPrincipalName `
                    -StrongPasswordRequired $false -PasswordNeverExpires $true -Password $UserPassword `
                    -LicenseAssignment $UserLicense -UsageLocation "FR"

    Write-Host "Utilisateur $UserDisplayName créé avec succès !" -ForegroundColor Green

}catch{

    Write-Host "ATTENTION ! Impossible de créer l'utilisateur $UserDisplayName" -ForegroundColor Red

}

}