Clear-Host

$Path = "C:\Windows\System32\drivers\etc\hosts"
$LocalHost = "127.0.0.1"
$Dominios = @("youtube","tiktok","instagram","facebook","twitter","netflix","epicgames","steam","steampowered","spotify","softonic","uptodown","poki","minijuegos","1001juegos","friv","malavida","skypc","spotipremiumapk","tunefab","spotifypremium","gamesfull")
$Subdominios = @("www","m","touch","music","gaming","tv","api","connect","mobile ","store","en","open")
$Extension = @("com","es","co","mx","be","org","ar")

foreach ($Subdominio in $Subdominios) {
    foreach ($Dominio in $Dominios) {
        foreach ($Ext in $Extension) {
            $Full = "$Subdominio.$Dominio.$Ext"
            $Ipset = "$LocalHost   $Full"
            if (-not (Get-Content $Path 2>$null | Select-String -Pattern $Ipset)) {
                Add-Content -Path $Path -Value $Ipset -ErrorAction SilentlyContinue
            } 
        }
    }
}
Write-Host "Se ha completado con exito los bloqueos" -ForegroundColor Green
Read-Host -Prompt "Presione Enter para continuar"
