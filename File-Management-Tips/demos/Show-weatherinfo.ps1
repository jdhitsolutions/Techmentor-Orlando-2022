#display weather in the lower right corner of the session
# https://github.com/chubin/wttr.in

Param([string]$Zipcode = "32801")

$left = $host.ui.RawUI.WindowSize.width - 23
$pos = [system.management.automation.host.coordinates]::new($left, 1)
#save current
$here = $host.ui.RawUI.CursorPosition
$host.ui.RawUI.CursorPosition = $pos
$uri = 'http://wttr.in/{0}?u&format=2' -f $Zipcode
Invoke-RestMethod -Uri $uri
$host.UI.RawUI.CursorPosition = $here