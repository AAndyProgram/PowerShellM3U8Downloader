$plsUrl = Read-Host -Prompt 'Enter m3u8 URL'
$outFileName = Read-Host -Prompt 'Enter the name of the output file'
$plsUrl = $plsUrl.Trim()
$outFileName = $outFileName.Trim()
if($plsUrl.Trim().Length -cgt 0 -and $outFileName.Length -cgt 0){
    $resp = Invoke-RestMethod -Uri $plsUrl -Method Get
    $arr = $resp.Split("`n", ([System.StringSplitOptions]::RemoveEmptyEntries)).Where({$_.StartsWith("segment")})
    $optUrl = $plsUrl.Remove($plsUrl.IndexOf("/index-f"),$plsUrl.Length - $plsUrl.IndexOf("/index-f")) + "/"
    $arrUrls = $arr.ForEach({$optUrl + $_})
    $destDir = "d:\Downloads\"
    $cacheDir = "d:\Downloads\cache\"
    if(Test-Path -Path $cacheDir){}else{New-Item -Path "d:\Downloads\" -Name "cache" -ItemType "directory"}
    $arrNames = $arr.ForEach({$cacheDir + $_})
    for($i=0;$i -le $arrUrls.Count-1; $i++){Invoke-WebRequest $arrUrls[$i] -OutFile $arrNames[$i]}
    $ff_files
    $arr.ForEach({$ff_files = $ff_files + $_ + "|"})
    $ff_files.Remove($ff_files.Length-1,1)
    cd $cacheDir

    $arrNames.ForEach({echo "file '$_'" >> files.txt})
    $rawStr = Get-Content -Raw files.txt
    $utf8Enc = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllLines("d:\Downloads\cache\files.txt", $rawStr, $utf8Enc)

    $ff_command = "D:\Programs\BAT\ffmpeg.exe -f concat -safe 0 -i files.txt -c copy ""d:\Downloads\" + $outFileName + ".mp4"""
    Invoke-Expression -Command $ff_command
    Remove-Item "d:\Downloads\cache\*.*"
    Read-Host -Prompt 'Downloaded'
}