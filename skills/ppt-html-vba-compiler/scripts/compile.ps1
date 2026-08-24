[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$HtmlPath,

    [Parameter(Mandatory = $true)]
    [string]$OutputPath,

    [Parameter(Mandatory = $true)]
    [string]$CompilerHost,

    [string]$ReportPath
)

$ErrorActionPreference = 'Stop'

$html = (Resolve-Path -LiteralPath $HtmlPath).Path
$hostFile = (Resolve-Path -LiteralPath $CompilerHost).Path
$output = [System.IO.Path]::GetFullPath($OutputPath)
if (-not $ReportPath) {
    $ReportPath = [System.IO.Path]::ChangeExtension($output, '.compile-report.json')
}
$report = [System.IO.Path]::GetFullPath($ReportPath)

if ([System.IO.Path]::GetExtension($output).ToLowerInvariant() -ne '.pptx') {
    throw 'OutputPath must end with .pptx'
}
if ($hostFile -notmatch '\.(pptm|ppam)$') {
    throw 'CompilerHost must be an approved .pptm or .ppam file'
}

$powerPoint = $null
$hostPresentation = $null
try {
    $powerPoint = New-Object -ComObject PowerPoint.Application
    $powerPoint.Visible = -1
    $hostPresentation = $powerPoint.Presentations.Open($hostFile, 0, 0, 0)
    $macro = "$($hostPresentation.Name)!CompilePptHtmlFile"
    $powerPoint.Run($macro, $html, $output, $report)
    if (-not (Test-Path -LiteralPath $output)) {
        throw "Compiler did not create output: $output"
    }
    if (-not (Test-Path -LiteralPath $report)) {
        throw "Compiler did not create report: $report"
    }
    Write-Output "Created $output"
    Write-Output "Created $report"
}
finally {
    if ($hostPresentation) { $hostPresentation.Close() }
    if ($powerPoint) { $powerPoint.Quit() }
    if ($hostPresentation) { [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($hostPresentation) }
    if ($powerPoint) { [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($powerPoint) }
}
