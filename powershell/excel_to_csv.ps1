<#
	The sample scripts are not supported under any Microsoft standard support 
	program or service. The sample scripts are provided AS IS without warranty  
	of any kind. Microsoft further disclaims all implied warranties including,  
	without limitation, any implied warranties of merchantability or of fitness for 
	a particular purpose. The entire risk arising out of the use or performance of  
	the sample scripts and documentation remains with you. In no event shall 
	Microsoft, its authors, or anyone Else involved in the creation, production, or 
	delivery of the scripts be liable for any damages whatsoever (including, 
	without limitation, damages for loss of business profits, business interruption, 
	loss of business information, or other pecuniary loss) arising out of the use 
	of or inability to use the sample scripts or documentation, even If Microsoft 
	has been advised of the possibility of such damages 
#>

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
$FolderPath = "D:\var\projects\OCOS\var\excelchange"

Convert-CsvInBatch -Folder $FolderPath
