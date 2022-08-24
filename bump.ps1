try {
  Import-Module PsIni
} catch {
  Install-Module -Scope CurrentUser PsIni
  Import-Module PsIni
}
$repoName = "brrd/abricotine"
$releasesUri = "https://api.github.com/repos/$repoName/releases/latest"
$fulltag = (Invoke-WebRequest $releasesUri | ConvertFrom-Json).tag_name
$tag = $fulltag.Substring(1)
Write-Host $fulltag
Write-Host $tag
if ($tag2 -match "alpha")
{
  Write-Host "Found alpha."
  echo "SHOULD_COMMIT=no" | Out-File -FilePath $Env:GITHUB_ENV -Encoding utf8 -Append
}
elseif ($tag2 -match "beta")
{
  Write-Host "Found beta."
  echo "SHOULD_COMMIT=no" | Out-File -FilePath $Env:GITHUB_ENV -Encoding utf8 -Append
}
elseif ($tag2 -match "RC")
{
  Write-Host "Found Release Candidate."
  echo "SHOULD_COMMIT=no" | Out-File -FilePath $Env:GITHUB_ENV -Encoding utf8 -Append
}
else{
    echo "UPSTREAM_TAG=$fulltag" | Out-File -FilePath $Env:GITHUB_ENV -Encoding utf8 -Append

    $appinfo = Get-IniContent ".\AbricotinePortable\App\AppInfo\appinfo.ini"
    if ($appinfo["Version"]["DisplayVersion"] -ne $tag){
        $appinfo["Version"]["PackageVersion"]=-join($tag,".0")
        $appinfo["Version"]["DisplayVersion"]=$tag
        $appinfo | Out-IniFile -Force -Encoding ASCII -Pretty -FilePath ".\AbricotinePortable\App\AppInfo\appinfo.ini"

        $installer = Get-IniContent ".\AbricotinePortable\App\AppInfo\installer.ini"
        $installer["DownloadFiles"]["DownloadURL"]=-join("https://github.com/brrd/abricotine/releases/download/",$fulltag,"/Abricotine-Setup-",$tag,".exe")
        $installer["DownloadFiles"]["DownloadFilename"]=-join("/Abricotine-Setup-",$tag,".exe")
        $installer | Out-IniFile -Force -Encoding ASCII -Pretty -FilePath ".\AbricotinePortable\App\AppInfo\installer.ini"
        Write-Host "Bumped to "+$fulltag
        echo "SHOULD_COMMIT=yes" | Out-File -FilePath $Env:GITHUB_ENV -Encoding utf8 -Append
    }
    else{
      Write-Host "No changes."
      echo "SHOULD_COMMIT=no" | Out-File -FilePath $Env:GITHUB_ENV -Encoding utf8 -Append
    } 
}
