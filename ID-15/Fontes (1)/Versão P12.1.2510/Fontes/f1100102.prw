#INCLUDE 'Protheus.ch'

/*{Protheus.doc} F1100102
Função responsável por gravar a tabela auxiliar de Afastamentos lançados de forma retroativa.
Inicialmente será utilizado pelos fonte F1100101 (PE_MDTA68540) e F1100103 (PE_GP240VAL)
@author		Ademar Fernandes
@since		26/07/2017
@project	MAN0000007423045_EF_003 
*/
User Function F1100102(nOpcao,aGravar)
	Local lRet := .T.
	Local aArea := GetArea()
	
	Default aGravar := {}
	
	dbSelectArea("PAG")
	dbSetOrder(1)	//-PAG_ TPMAN + PAG_DTMAN + PAG_HRMAN + PAG_NUSER
	//dbSetOrder(2)	//-PAG_FILIAL+PAG_MAT+PAG_CC+PAG_DTMAN+PAG_HRMAN+PAG_NUSER
	/*
	cMyChave := TNY->(TNY_FILIAL+DTOS(TNY_DTINIC)+DTOS(TNY_DTFIM)+TNY_TIPAFA+TNY_CODAFA)
	If SR8->(R8_FILIAL+DTOS(R8_DATAINI)+DTOS(R8_DATAFIM)+R8_TIPO+R8_TIPOAFA) == cMyChave
	*/
	Sleep(1000) // Retirar o Sleep após retirar a chave única da tabela.
	RecLock("PAG",.T.)
	PAG->PAG_TPMAN		:= Iif(nOpcao=3, "I", Iif(nOpcao=4, "A", "E"))
	PAG->PAG_DTMAN		:= Date()
	PAG->PAG_HRMAN		:= Time()
	PAG->PAG_NUSER		:= __cUserID
	If Len(aGravar) = 0
		PAG->PAG_FILIAL	:= SR8->R8_FILIAL
		PAG->PAG_MAT		:= SR8->R8_MAT
		PAG->PAG_CC		:= SRA->RA_CC
		PAG->PAG_DESCCC	:= POSICIONE("CTT",1,xFilial("CTT")+SRA->RA_CC,"CTT_DESC01")
		PAG->PAG_NOME	:= SRA->RA_NOME
		PAG->PAG_ADMISS	:= SRA->RA_ADMISSA
		PAG->PAG_SITFOL	:= SRA->RA_SITFOLH
		PAG->PAG_CATFUN	:= SRA->RA_CATFUNC
		PAG->PAG_TPAFAS	:= SR8->R8_TIPO
		
		PAG->PAG_CDAFAS	:= SR8->R8_TIPOAFA	//-(*) Campo novo
		PAG->PAG_TPDESC	:= POSICIONE("RCM",1,xFilial("RCM")+SR8->R8_TIPOAFA,"RCM_DESCRI")
		PAG->PAG_SEQAFA	:= SR8->R8_SEQ
		PAG->PAG_DTAFAS	:= SR8->R8_DATAINI
		PAG->PAG_DTRETO	:= SR8->R8_DATAFIM
		
	Else
		PAG->PAG_FILIAL	:= aGravar[01,01]	//-SR8->R8_FILIAL
		PAG->PAG_MAT	:= aGravar[01,02]	//-SR8->R8_MAT
		PAG->PAG_CC		:= aGravar[01,03]	//-SR8->R8_CC
		PAG->PAG_NOME	:= POSICIONE("SRA",1,aGravar[01,01]+aGravar[01,02],"RA_NOME")
		PAG->PAG_DESCCC	:= POSICIONE("CTT",1,xFilial("CTT")+aGravar[01,03],"CTT_DESC01")
		PAG->PAG_ADMISS	:= aGravar[01,04]	//-SRA->RA_ADMISSA
		PAG->PAG_SITFOL	:= aGravar[01,05]	//-SRA->RA_SITFOLH
		PAG->PAG_CATFUN	:= aGravar[01,06]	//-SRA->RA_CATFUNC
		PAG->PAG_TPAFAS	:= aGravar[01,07]	//-SR8->R8_TIPO
		
		PAG->PAG_CDAFAS	:= aGravar[01,08]	//-SR8->R8_TIPOAFA	//-(*) Campo novo
		PAG->PAG_TPDESC	:= POSICIONE("RCM",1,xFilial("RCM")+aGravar[01,08],"RCM_DESCRI")
		PAG->PAG_SEQAFA	:= aGravar[01,09]	//-SR8->R8_SEQ
		PAG->PAG_DTAFAS	:= aGravar[01,10]	//-SR8->R8_DATAINI
		PAG->PAG_DTRETO	:= aGravar[01,11]	//-SR8->R8_DATAFIM
		
	EndIf
	
	PAG->(MsUnlock())
	RestArea(aArea)
Return(lRet)
/*
{ STR0003,	"M685INC"   , 0 , 3},;	 //"Incluir"
{ STR0004,	"M685INC"   , 0 , 4},;	 //"Alterar"
{ STR0005,	"M685INC"   , 0 , 5, 3},;//"Excluir"
*/
