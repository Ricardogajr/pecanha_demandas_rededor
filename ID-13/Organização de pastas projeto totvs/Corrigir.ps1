# Move quaisquer .docx que ainda estejam na raiz para a pasta de Especificacao
Set-Location -LiteralPath $PSScriptRoot

$destino = '01-Documentos\01-Especificacao-Processo (MIT041)'

Write-Host ""
Write-Host "Movendo arquivos .docx remanescentes da raiz..." -ForegroundColor Yellow

$arquivos = Get-ChildItem -LiteralPath $PSScriptRoot -File -Filter '*.docx'
if ($arquivos.Count -eq 0) {
    Write-Host "Nenhum .docx remanescente na raiz. Nada a fazer." -ForegroundColor Green
} else {
    foreach ($f in $arquivos) {
        Move-Item -LiteralPath $f.FullName -Destination $destino -Force
        Write-Host ("   OK  {0}" -f $f.Name) -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "Estrutura final da pasta 01-Documentos\01-Especificacao-Processo (MIT041):" -ForegroundColor Cyan
Get-ChildItem -LiteralPath $destino -File | Select-Object -ExpandProperty Name

Write-Host ""
Read-Host "Pressione ENTER para fechar"
