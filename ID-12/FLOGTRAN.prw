#include 'totvs.ch'

User Function LoadTransf()
  Private aFrames := {}
  Private nFrame  := 1
  Private oSayAnim

  aAdd( aFrames, '[Origem]  o-------  [Destino]' )
  aAdd( aFrames, '[Origem]  --o-----  [Destino]' )
  aAdd( aFrames, '[Origem]  ----o---  [Destino]' )
  aAdd( aFrames, '[Origem]  ------o>  [Destino]' )

  Processa( {|| U_ExecRotina() }, "Transferindo dados", "Processando registros, aguarde..." )

Return

User Function ExecRotina()
  Local nI := 0

  ProcRegua( 100 )

  For nI := 1 To 100
    // Sua lógica aqui — substitua o Sleep pelo processamento real
    Sleep( 50 )
    IncRegua()
  Next nI

Return
