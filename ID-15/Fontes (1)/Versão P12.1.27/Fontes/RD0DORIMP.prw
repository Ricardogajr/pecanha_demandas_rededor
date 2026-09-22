#Include "totvs.ch"
#Include "Protheus.ch"
#INCLUDE "TopConn.Ch"
//#INCLUDE "FONT.CH"    


/*
Funcao: RD0DORIMP - Rotina para Relacionamento dos Funcionários nas tabelas RDZ e RD0
Autor : Mauricio Siqueira
Data..: 14/09/18
Versão: Protheus12
Menu..: SIGAGPE\MISCELANEA\ESPECIFICOS\RELACIONA SRA X RD0
Função: RD0DOR01() - Cria Perguntas
Função: RD0DOR02() - Valida Parametros
Função: RD0DOR03() - Processa Arquivo de Trabalho
*/

User Function RD0DORIMP()

Local aArea     := GetArea()
Local aSays		:= {}
Local aButtons	:= {}	
Local nOpca 	:= 0

Private cPerg    := "RD0DORIMP "

// Cria Perguntas
RD0DOR01()

Pergunte(cPerg,.F.)
			
cCadastro := OemToAnsi("Gerar Relacionamento entre Funcionários x Participantes")
	
AADD(aSays,OemToAnsi("Este programa realiza o relacionamento entre o Cadastro") )
AADD(aSays,OemToAnsi("de Funcionários x Cadastro de Participantes.")) 
	
AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T.)  } } )
AADD(aButtons, { 1,.T.,{|o| nOpca := 1,If(RD0DOR02(MV_PAR01),FechaBatch(),nOpca:=0) }} )
AADD(aButtons, { 2,.T.,{|o| FechaBatch() }} )
		
FormBatch(cCadastro,aSays,aButtons)

If nOpca == 1                      
   Processa({|lEnd| RD0DOR03(),"Relacionando", "Gerando Relacionamento..."})
EndIf

RestArea(aArea)

Return



/*
Função:	RD0DOR02 - Confirmação de Processamento
Param.: Nenhum
Return:	lRet, Se tudo ok, continua...
*/
Static Function RD0DOR02()

Local lRet := .F.

If MsgYesNo("Confirma a configuração dos parâmetros?", "Atenção !")
	lRet := .T.
EndIf

Return lRet
   

/*
Função 	RD0DOR03 - Processa Rotina Principal
Return	lRet, habilitado para continuar ou não
*/
Static Function RD0DOR03()

Local aArea     := GetArea()
Local cQuery    := ""
Local cId_RD0   := ""

Local nCont_Func := 0
Local nCont_RD0  := 0
Local nCont_RDZ  := 0
Local nTot_Func  := 0

dbSelectArea("RD0")
dbSetOrder(6)	// RD0_FILIAL+RD0_CIC+RD0_CODIGO

// Filtra funcionários "ativos" da filial especificada em MV_PAR01
cQuery := "SELECT RA_FILIAL, RA_MAT, RA_NOME, RA_SITFOLH, RA_SEXO, RA_NASC, RA_CIC, RA_ADMISSA, RA_ENDEREC, RA_COMPLEM, RA_CEP, RA_BAIRRO, RA_MUNICIP, RA_ESTADO, RA_TELEFON, RA_CC, RA_PIS, RA_EMAIL , RA_XPORTAL FROM " + RETSQLNAME("SRA") + " "
cQuery += "WHERE D_E_L_E_T_ = ' ' "                   
cQuery += "AND RA_SITFOLH <> 'D' "
cQuery += "AND RA_FILIAL = '" + MV_PAR01 + "' "
cQuery += "ORDER BY RA_CIC " 

TcQuery cQuery New Alias "TSRA"  

TcSetField( "TSRA", "RA_NASC", "D", 8, 0 )
TcSetField( "TSRA", "RA_ADMISSA", "D", 8, 0 )

ProcRegua(RECCOUNT())

Count TO nTot_Func

TSRA->( dbGoTop() )

While TSRA->(!EOF())

    nCont_Func ++

	IncProc("Funcionário: "+AllTrim(Str(nCont_Func))+"/"+AllTrim(Str(nTot_Func)))

	// Verifica se o Funcionário já possui cadastro de participante
    dbSelectArea("RD0")
	If !RD0->(DbSeek(Space(08)+TSRA->RA_CIC))
       // Busca próximo código de participante, disponível
	   cId_RD0  := GetSXENum( "RD0", "RD0_CODIGO" )
	
	   RecLock("RD0",.T.)
	   RD0->RD0_CODIGO := cId_RD0
	   RD0->RD0_NOME   := TSRA->RA_NOME
	   RD0->RD0_TIPO   := "1"
	   RD0->RD0_SEXO   := TSRA->RA_SEXO
	   RD0->RD0_DTNASC := TSRA->RA_NASC
	   RD0->RD0_CIC    := TSRA->RA_CIC
	   RD0->RD0_DTADMI := TSRA->RA_ADMISSA
	   RD0->RD0_END    := TSRA->RA_ENDEREC
	   RD0->RD0_CMPEND := TSRA->RA_COMPLEM
	   RD0->RD0_CEP    := TSRA->RA_CEP
	   RD0->RD0_BAIRRO := TSRA->RA_BAIRRO
	   RD0->RD0_MUN    := TSRA->RA_MUNICIP
	   RD0->RD0_UF     := TSRA->RA_ESTADO
	   RD0->RD0_FONE   := TSRA->RA_TELEFON
	   RD0->RD0_CC     := TSRA->RA_CC
	   RD0->RD0_EMAIL  := TSRA->RA_EMAIL
	   RD0->RD0_USER   := SPACE(03)
	   RD0->RD0_MSBLQL := "2"
//	   RD0->RD0_SENHA  := "111111"  // Alterado em 10/07/19 para o projeto RIOMAR Left(TSRA->RA_CIC, 6) // Solicitado por Hiago em 10/05/2019 - Projeto Samer "111111"
//	   RD0->RD0_SENHA  := Left(TSRA->RA_CIC, 6)	// Alterado em 19/12/19 para o projeto RICHET, solicitado por Hiago em 13/12/2019 // Projeto São Lucas "111111"
	   RD0->RD0_SENHA  := Embaralha(SubStr(TSRA->RA_CIC, 1, 6), 0)	// Alterado em 06/01/20 para o projeto RICHET, solicitado por Hiago em 13/12/2019
	   RD0->RD0_PORTAL := TSRA->RA_XPORTAL
	   RD0->RD0_LOGIN  := TSRA->RA_CIC
	   RD0->RD0_EMPATU := "01"
	   RD0->RD0_FILATU := TSRA->RA_FILIAL
	   RD0->RD0_PERMAD := "2"
	   RD0->RD0_PIS    := TSRA->RA_PIS
	   MsUnlock()
	   
 	   ConfirmSx8()
 	   
 	   nCont_RD0 ++

	Else
	   cId_RD0  := RD0_CODIGO

	EndIf
	   
	// Verifica se existe o relacionamento Pessoas x Entidades
    dbSelectArea("RDZ")
	If !RDZ->(DbSeek(Space(08)+"01"+MV_PAR01+"SRA"+(MV_PAR01+TSRA->RA_MAT+SPACE(21))+cId_RD0))
	   RecLock("RDZ",.T.)
	   RDZ->RDZ_EMPENT := "01"
	   RDZ->RDZ_FILENT := MV_PAR01
	   RDZ->RDZ_ENTIDA := "SRA"
	   RDZ->RDZ_CODENT := MV_PAR01+TSRA->RA_MAT
	   RDZ->RDZ_CODRD0 := cId_RD0
	   RDZ->RDZ_ENTIND := "01"
	   MsUnlock()
	   
 	   nCont_RDZ ++
    EndIf

//    cRD0_SENHA  := Embaralha(SubStr(TSRA->RA_CIC, 1, 6), 0)

	dbSelectArea("TSRA")
	DbSkip()
		

EndDo			

MSGINFO(AllTrim(Str(nCont_Func))+", funcionários processados.","Término")

If nCont_RD0 > 0
   MSGINFO(AllTrim(Str(nCont_RD0))+", registros inseridos na RD0.","Término")
Else
   MSGINFO("Nenhum registro inserido na RD0.","Término")
EndIf

If nCont_RDZ > 0
   MSGINFO(AllTrim(Str(nCont_RDZ))+", registros inseridos na RDZ.","Término")
Else
   MSGINFO("Nenhum registro inserido na RDZ.","Término")
EndIf

TSRA->(DbCloseArea())

dbSelectArea("SRA")

RestArea(aArea)

Return

 
/*
Função: RD0DOR01 - Cria Perguntas
Return	
*/
Static Function RD0DOR01

Local _sAlias := Alias()
Local aRegs   := {}

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

// Grupo/Ordem/Pergunta///Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01///Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
Aadd(aRegs,{cPerg , "01" , "Gerar p/Filial            ?" ,"","", "mv_ch1" , "C" , 8 ,0 ,0 , "G" , "naovazio" , "mv_par01" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "","","","","","","","","","","XM0" ,"","033",".RHFILDE."})
For i:=1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			EndIf
		Next
		MsUnlock()
	EndIf
Next

dbSelectArea(_sAlias)

Return
