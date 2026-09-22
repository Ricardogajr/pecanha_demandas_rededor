//Bibliotecas
#Include "TOTVS.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} MSIMPCSV1
Função para importar arquivo CSV (TODAS AS TABELAS)
@author Lucas Miranda - Miranda Solution
@since 29/05/2024
@version 1.0
@type function
/*/

User Function MSIMPCSV1()
	Local aArea     := GetArea()
	Private cArqOri := ""

	//Mostra o Prompt para selecionar arquivos
	cArqOri := tFileDialog( "CSV files (*.csv) ", 'Seleção de Arquivos', , , .F., )

	//Se tiver o arquivo de origem
	If ! Empty(cArqOri)

		//Somente se existir o arquivo e for com a extensão CSV
		If File(cArqOri) .And. Upper(SubStr(cArqOri, RAt('.', cArqOri) + 1, 3)) == 'CSV'
			Processa({|| fImporta() }, "Importando...")
		Else
			MsgStop("Arquivo e/ou extensão inválida!", "Atenção")
		EndIf
	EndIf

	RestArea(aArea)
Return

/*-------------------------------------------------------------------------------*
 | Func:  fImporta                                                               |
 | Desc:  Função que importa os dados                                            |
 *-------------------------------------------------------------------------------*/
  
Static Function fImporta()
    Local aArea      := GetArea()
    Local cArqLog    := "MSIMPCSV1_" + cTabela + dToS(Date()) + "_" + StrTran(Time(), ':', '-') + ".log"
    Local nTotLinhas := 0
    Local cLinAtu    := ""
    Local nLinhaAtu  := 0
    Local aLinha     := {}
    Local oArquivo
    Local aLinhas
    Local cCodForn   := ""
    Local cLojForn   := ""
    Local cObserv    := ""
    Local cRazaoSoc  := ""
    Local aPergs   := {}
    Local nTipo    := 1
    Local nVinc    := 1

    Private cDirLog    := GetTempPath() + "MSIMPCSV1\"
    Private cLog       := ""


    aAdd(aPergs, {2, "Tipo Importação",               nTipo, {"1=Com validação SX3",              "2=Classificação em Documento de Entrada"},     122, ".T.", .F.})
 
    If ParamBox(aPergs, "Informe os parâmetros")
        Alert(cValToChar(MV_PAR01))
        Alert(cValToChar(MV_PAR02))
    EndIf
    //Se a pasta de log não existir, cria ela
    If ! ExistDir(cDirLog)
        MakeDir(cDirLog)
    EndIf
  
    //Definindo o arquivo a ser lido
    oArquivo := FWFileReader():New(cArqOri)
      
    //Se o arquivo pode ser aberto
    If (oArquivo:Open())
  
        //Se não for fim do arquivo
        If ! (oArquivo:EoF())
  
            //Definindo o tamanho da régua
            aLinhas := oArquivo:GetAllLines()
            nTotLinhas := Len(aLinhas)
            ProcRegua(nTotLinhas)
              
            //Método GoTop não funciona (dependendo da versão da LIB), deve fechar e abrir novamente o arquivo
            oArquivo:Close()
            oArquivo := FWFileReader():New(cArqOri)
            oArquivo:Open()
  
            //Enquanto tiver linhas
            While (oArquivo:HasLine())
  
                //Incrementa na tela a mensagem
                nLinhaAtu++
                IncProc("Analisando linha " + cValToChar(nLinhaAtu) + " de " + cValToChar(nTotLinhas) + "...")
                  
                //Pegando a linha atual e transformando em array
                cLinAtu := oArquivo:GetLine()
                aLinha  := StrTokArr(cLinAtu, ";")
                  
                //Se não for o cabeçalho (encontrar o texto "Código" na linha atual)
                If ! "código" $ Lower(cLinAtu)
  
                    //Zera as variaveis
                    cCodForn   := aLinha[nPosCodigo]
                    cLojForn   := aLinha[nPosLojFor]
                    cRazaoSoc  := aLinha[nPosRazSoc]
                    cObserv    := aLinha[nPosObserv]
  
                    DbSelectArea('SA2')
                    SA2->(DbSetOrder(1)) // Filial + Código + Loja
  
                    //Se conseguir posicionar no fornecedor
                    If SA2->(DbSeek(FWxFilial('SA2') + cCodForn + cLojForn))
                        cLog += "+ Lin" + cValToChar(nLinhaAtu) + ", fornecedor [" + cCodForn + cLojForn + " - " + Upper(SA2->A2_NREDUZ) + "] " +;
                            "a observação foi alterada, antes: [" + Alltrim(SA2->A2_X_OBS) + "], agora: [" + Alltrim(cObserv) + "];" + CRLF
  
                        //Realiza a alteração do fornecedor
                        RecLock('SA2', .F.)
                            SA2->A2_X_OBS  := cObserv
                        SA2->(MsUnlock())
  
                    Else
                        cLog += "- Lin" + cValToChar(nLinhaAtu) + ", fornecedor e loja [" + cCodForn + cLojForn + "] não encontrados no Protheus;" + CRLF
                    EndIf
                      
                Else
                    cLog += "- Lin" + cValToChar(nLinhaAtu) + ", linha não processada - cabeçalho;" + CRLF
                EndIf
                  
            EndDo
  
            //Se tiver log, mostra ele
            If ! Empty(cLog)
                cLog := "Processamento finalizado, abaixo as mensagens de log: " + CRLF + cLog
                MemoWrite(cDirLog + cArqLog, cLog)
                ShellExecute("OPEN", cArqLog, "", cDirLog, 1)
            EndIf
  
        Else
            MsgStop("Arquivo não tem conteúdo!", "Atenção")
        EndIf
  
        //Fecha o arquivo
        oArquivo:Close()
    Else
        MsgStop("Arquivo não pode ser aberto!", "Atenção")
    EndIf
  
    RestArea(aArea)
Return
