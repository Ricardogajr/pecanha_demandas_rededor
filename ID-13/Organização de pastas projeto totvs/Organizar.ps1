# Organizador de pastas - Projeto Totvs/Protheus Rededor (Contabilidade - ID-13)
# PowerShell script - lida com Unicode nativamente

$ErrorActionPreference = 'Continue'
Set-Location -LiteralPath $PSScriptRoot

Write-Host ""
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host " Organizador de pastas - Projeto Totvs/Protheus Rededor" -ForegroundColor Cyan
Write-Host " Demanda ID-13 - Contabilidade" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""

# --- 1/3 Criar estrutura de pastas ---
Write-Host "[1/3] Criando estrutura de pastas..." -ForegroundColor Yellow
$pastas = @(
    '01-Documentos\01-Especificacao-Processo (MIT041)',
    '01-Documentos\02-Atas-Reuniao',
    '01-Documentos\03-Homologacao',
    '02-Fontes\ADVPL',
    '03-Parametrizacoes (MIT043)',
    '04-Gestao-Projeto\Cronograma',
    '04-Gestao-Projeto\Status-Reports',
    '04-Gestao-Projeto\Riscos'
)
foreach ($p in $pastas) {
    New-Item -ItemType Directory -Force -Path $p | Out-Null
    Write-Host "   OK  $p"
}

# --- 2/3 Mover arquivos ---
Write-Host ""
Write-Host "[2/3] Movendo arquivos..." -ForegroundColor Yellow

$mapa = @(
    @{ de = 'Especificação de Processo-transferencia de lançamentos contabeis entre filias.docx'; para = '01-Documentos\01-Especificacao-Processo (MIT041)' },
    @{ de = 'MIT041_Transferencia_Lancamentos_Contabeis.docx';                                     para = '01-Documentos\01-Especificacao-Processo (MIT041)' },
    @{ de = 'MIT041_Transferencia_Lancamentos_Contabeis_v2_2.docx';                                para = '01-Documentos\01-Especificacao-Processo (MIT041)' },
    @{ de = 'Cópia de Diagrama dos processos - MIT041 (1).docx';                                   para = '01-Documentos\01-Especificacao-Processo (MIT041)' },
    @{ de = 'Protheus - MIT043 .xlsx';                                                              para = '03-Parametrizacoes (MIT043)' },
    @{ de = 'Protheus_-_MIT043_P54.xlsx';                                                           para = '03-Parametrizacoes (MIT043)' },
    @{ de = 'FMIGRACT2.prw';                                                                        para = '02-Fontes\ADVPL' }
)

foreach ($item in $mapa) {
    if (Test-Path -LiteralPath $item.de) {
        Move-Item -LiteralPath $item.de -Destination $item.para -Force
        Write-Host ("   OK  {0,-70} -> {1}" -f $item.de, $item.para)
    } else {
        Write-Host ("   !!  Nao encontrado: {0}" -f $item.de) -ForegroundColor DarkYellow
    }
}

# --- 3/3 Limpeza de arquivos de teste ---
Write-Host ""
Write-Host "[3/3] Limpando arquivos temporarios..." -ForegroundColor Yellow
if (Test-Path -LiteralPath '_teste_escrita.txt') { Remove-Item -LiteralPath '_teste_escrita.txt' -Force; Write-Host "   OK  _teste_escrita.txt" }
if (Test-Path -LiteralPath '_teste_pasta')       { Remove-Item -LiteralPath '_teste_pasta' -Recurse -Force; Write-Host "   OK  _teste_pasta\" }

Write-Host ""
Write-Host "========================================================" -ForegroundColor Green
Write-Host " Concluido! Estrutura final:" -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Green
Get-ChildItem -Recurse -Directory | Select-Object -ExpandProperty FullName | ForEach-Object { $_.Replace($PSScriptRoot, '.') }
Write-Host ""
Read-Host "Pressione ENTER para fechar"
