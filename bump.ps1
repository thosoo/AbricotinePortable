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
$appinfo = Get-IniContent ".\AbricotinePortable\App\AppInfo\appinfo.ini"
$appinfo["Version"]["PackageVersion"]=-join($tag,".0")
$appinfo["Version"]["DisplayVersion"]=$tag
$appinfo | Out-IniFile -Force -Encoding ASCII -Pretty -FilePath ".\AbricotinePortable\App\AppInfo\appinfo.ini"

$installer = Get-IniContent ".\AbricotinePortable\App\AppInfo\installer.ini"
$installer["DownloadFiles"]["DownloadURL"]=-join("https://github.com/brrd/abricotine/releases/download/",$tag,"/Abricotine-Setup-",$tag,".exe")
$installer["DownloadFiles"]["DownloadFilename"]=-join("/Abricotine-Setup-",$tag,".exe")
$installer | Out-IniFile -Force -Encoding ASCII -Pretty -FilePath ".\AbricotinePortable\App\AppInfo\installer.ini"
