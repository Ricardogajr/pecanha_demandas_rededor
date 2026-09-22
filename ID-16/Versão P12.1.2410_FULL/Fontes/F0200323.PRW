#Include 'Protheus.ch'

/*/{Protheus.doc} F0200323
Monta tela de acesso ao pergunte de alteração dos parâmetros de e-mail
@type function
@author henrique.toyada
@since 14/12/2016
@version 1.0
@return nil
@example
(examples)
@see (links_or_references)
/*/
User Function F0200323()
	Local aArrSay := {}
	Local aArrBut := {}
	Local cArqTxt := ''
	Local cPerg   := 'FSW0200323'
	Local nOpca   := 0
	
	Pergunte(cPerg,.F.)
	
	If EMPTY(MV_PAR01) .AND. EMPTY(MV_PAR02)
		MV_PAR01 := SUPERGETMV("FS_RHDED" ,.T. ,'' ,cFilAnt)
		MV_PAR02 := SUPERGETMV("FS_DIREXE",.T. ,'' ,cFilAnt)
	EndIf
	
	AAdd(aArrSay, 'Esta rotina tem por objetivo alterar os, ')
	AAdd(aArrSay, 'parametros de envio de e-mail.')
	
	AAdd(aArrBut, {5, .T., {|| lExeFun := .T., Pergunte(cPerg,.T. )}})
	AAdd(aArrBut, {1, .T., {|| nOpca := 1,FechaBatch() }} )
	AAdd(aArrBut, {2, .T., {|| nOpca := 0,FechaBatch() }} )
	
	FormBatch('Alteração paramêtros', aArrSay, aArrBut)
	
	If nOpca == 1
		Processa( { || AtuSx6(MV_PAR01,MV_PAR02) })
	EndIf
	
Return nil

/*/{Protheus.doc} AtuSx6
Altera parâmetros
@type function
@author henrique.toyada
@since 14/12/2016
@version 1.0
@param cPAR01, character, FS_RHDED  - E-mail do Departamento do RH Dedicado
@param cPAR02, character, FS_DIREXE - E-mail do Departamento do Diretor Executivo
@return nil
@example
(examples)
@see (links_or_references)
/*/
Static Function AtuSx6(cPAR01, cPAR02)
  	
  	Local lRet := .T.
  	
	//DbSelectArea('SX6') 
	If SX6->( DbSeek( cFilAnt + 'FS_RHDED' ) )
		PutMv ("FS_RHDED", cPAR01)
	Else
		lRet := .F.
	EndIf
	If SX6->( DbSeek( cFilAnt + 'FS_DIREXE' ) )
		PutMv ("FS_DIREXE", cPAR02)
	Else
		lRet := .F.
	EndIf
	
	If lRet
		MsgAlert("Modificação efetuada!")
	Else
		MsgAlert("Modificação não efetuada!")
	EndIf

Return nil