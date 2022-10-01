param(
  [Parameter()]
  [switch]$dryrun,
  [string]$Title = 'Other Transcode Video Helper 0.1'
)

$encoderOption = $null

Clear-Host
Write-Host "================ $Title ================`n" -ForegroundColor blue
Write-Host "1. Press '1' to encode as x265 with Nvidia optimisations. [Default]"
Write-Host "2. Press '2' to encode as x265."
Write-Host "3. Press '3' to encode as x264.`n"
Write-Host "Press Ctrl+C to quit at any time."

$encoderChoice = Read-Host "`nEnter Choice"

switch ($encoderChoice) {
  '2'{
    $encoderOption = '--hevc'
    Write-Host "`nx265`n"
  }
  '3'{
    Write-Host "`nx264`n"
  }
  'q'{exit}
  Default {
    $encoderOption = '--hevc --nvenc-recommended'
    Write-Host "`nx265 Nvida Optimised`n"-ForegroundColor green
  }
}

Write-Host "Select a video file...`n"

Add-Type -AssemblyName System.Windows.Forms

$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ Title = "Select a video file..."; }

$null = $FileBrowser.ShowDialog()

$videoPath = $FileBrowser.FileName

if (!$videoPath) {
  Write-Host "`nNo file selected"
  exit
}

other-transcode $videoPath --scan

$mainAudio = Read-Host -Prompt "`nSelect a different main audio track [Default is 1]"

$audioTracks = Read-Host -Prompt "`nAdd extra audio tracks [Seperate by spaces]"

$subtitleTracks = Read-Host -Prompt "`nSelect subtitles. Forced subtitles will automatically be added [Seperate by spaces]"

$targetBitrate = Read-Host -Prompt "`nCustom target bitrate [Default is 12000 for HD or 25000 for 4K]"

Write-Host "`n"

$splitAudio = $null

$splitSubs = $null

$forcedSubs = "--add-subtitle auto "

if (!$targetBitrate) {
  $targetBitrate = 25000
}

if ($audioTracks) {
  $splitAudio = $audioTracks.Split(" ") | ForEach-Object {
    if ($_ -ne 1) {
      "--add-audio $_ "
    }
  }
}

if ($subtitleTracks) {
  $splitSubs = $subtitleTracks.Split(" ") | ForEach-Object {
    "--add-subtitle $_ "
  }
}

if ($mainAudio) {
  $mainAudio = "--main-audio $mainAudio "
}

$dryRunCommand = $null

if($dryrun.IsPresent) {
  $dryRunCommand = "--dry-run "
}

$finalCommand = "other-transcode $dryRunCommand$encoderOption --target $targetBitrate --eac3 --copy-track-names $mainAudio$splitAudio$forcedSubs$splitSubs`"$videoPath`""

Write-Host "$finalCommand`n"
Invoke-Expression $finalCommand