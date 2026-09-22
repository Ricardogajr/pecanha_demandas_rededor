#INCLUDE "PROTHEUS.CH"
#Include "TopConn.ch"
#INCLUDE "Dbstruct.ch"

#DEFINE TP_FIL 		"01" 

#DEFINE CSSBOTAO	"QPushButton { color: #024670; "+;
"    border-image: url(rpo:fwstd_btn_nml.png) 3 3 3 3 stretch; "+;
"    border-top-width: 3px; "+;
"    border-left-width: 3px; "+;
"    border-right-width: 3px; "+;
"    border-bottom-width: 3px }"+;
"QPushButton:pressed {	color: #FFFFFF; "+;
"    border-image: url(rpo:fwstd_btn_prd.png) 3 3 3 3 stretch; "+;
"    border-top-width: 3px; "+;
"    border-left-width: 3px; "+;
"    border-right-width: 3px; "+;
"    border-bottom-width: 3px }"


#DEFINE CBX_EMPTY "Selecione a empresa modelo..."
#DEFINE CBX_EMPTY_MESSAGE 'Selecione uma empresa para que o seu dicionario'+CRLF+'seja utilizado como "modelo" durante o processamento!'

User Function AuditDic()

Local   aSay      := {}
Local   aButton   := {}
Local   aMarcadas := {}
Local   cTitulo   := "AUDITORIA DO DICIONARIO DE DADOS"
Local   lOk       := .F.

Private oMainWnd  := NIL
Private oProcess  := NIL

Private aSx2Tables := {} //Tabelas selecionadas para o processamento.
Private aTemplate  := {}
Private cEmpMod    := "" //Empresa modelo...

PtSetAcento(.T.)

/*#IFDEF TOP
    TCInternal( 5, "*OFF" ) // Desliga Refresh no Lock do Top
#ENDIF*/

__cInterNet := NIL
__lPYME     := .F.

Set Dele On

aMarcadas := EscEmpresa()

If !Empty( aMarcadas )
	If MsgNoYes( "Confirma a auditoria dos dicionarios ?", cTitulo )
		oProcess := MsNewProcess():New( { | lEnd | lOk := FSTProc( @lEnd, aMarcadas ) }, "Auditando", "Aguarde, auditando ...", .F. )
		oProcess:Activate()
		If lOk
			MsgInfo("Auditoria concluida.")
		Else
			MsgAlert("Auditoria cancelada.")
		EndIf
	Else
		MsgStop( "Auditoria nao Realizada.", "AUDITDIC" )
	EndIf
Else
	MsgStop( "Auditoria foi cancelada.", "AUDITDIC" )
EndIf

Return NIL

*****************************************************
** Verifica se a empresa/filial sera processada (.T.)
Static Function fProcEmp(cCodEmp,cCodFil)
*****************************************************
Local lRet  := .F.

Local aEmps := {{'01','01'}, {'02','01'}, {'01','02'}, {'02','02'}, {'02','03'}, {'01','03'}, {'05','01'}, {'06','01'}, {'07','01'}, {'08','01'}, {'09','01'}, {'10','01'},;
                {'11','01'}, {'13','01'}, {'14','01'}, {'16','01'}, {'12','01'}, {'12','02'}, {'17','01'}, {'18','01'}, {'19','01'}, {'20','01'}, {'21','01'}, {'22','01'},;
                {'23','01'}, {'24','01'}, {'25','01'}, {'26','01'}, {'27','01'}, {'02','04'}, {'02','05'}, {'28','01'}, {'01','04'}, {'29','01'}, {'01','05'}, {'31','01'},;
                {'31','02'}, {'31','03'}, {'31','07'}, {'31','08'}, {'31','09'}, {'31','10'}, {'31','11'}, {'31','12'}, {'31','13'}, {'32','01'}, {'33','01'}, {'34','01'},;
                {'35','01'}, {'36','01'}, {'37','01'}, {'38','01'}, {'01','06'}, {'40','01'}, {'41','01'}, {'42','01'}, {'43','01'}, {'44','01'}, {'45','01'}, {'46','01'},;
                {'46','02'}, {'46','03'}, {'46','04'}, {'46','05'}, {'46','06'}, {'47','01'}, {'48','01'}, {'48','02'}, {'48','03'}, {'49','01'}, {'40','02'}, {'40','03'},;
                {'40','04'}, {'40','05'}, {'40','06'}, {'40','07'}, {'40','08'}, {'41','02'}, {'31','14'}, {'31','15'}, {'31','16'}, {'31','17'}, {'31','18'}, {'31','19'},;
                {'31','20'}, {'31','21'}, {'50','01'}, {'55','01'}, {'56','01'}, {'57','01'}, {'58','01'}, {'59','01'}, {'60','01'}, {'60','02'}, {'60','03'}, {'61','01'},;
                {'62','01'}, {'63','01'}, {'64','01'}, {'65','01'}, {'46','07'}, {'31','22'}, {'31','23'}, {'65','02'}, {'66','01'}, {'67','01'}, {'68','01'}, {'69','01'},;
                {'40','09'}, {'69','02'}, {'70','01'}, {'71','01'}, {'31','24'}, {'31','25'}, {'72','01'}, {'73','01'}, {'74','01'}, {'39','01'}, {'40','10'}, {'40','11'},;
                {'40','12'}, {'40','13'}, {'40','14'}, {'40','15'}, {'40','16'}, {'40','17'}, {'40','18'}, {'40','19'}, {'30','01'}, {'75','01'}, {'76','01'}, {'77','01'},;
                {'78','01'}, {'78','02'}, {'78','03'}, {'78','04'}, {'80','01'}, {'81','01'}, {'82','01'}, {'82','02'}, {'82','03'}, {'83','01'}, {'84','01'}, {'84','02'},;
                {'79','01'}, {'79','02'}, {'79','03'}, {'79','04'}, {'85','01'}, {'85','02'}, {'85','03'}, {'85','04'}, {'86','01'}, {'87','01'}, {'88','01'}, {'89','01'},;
                {'13','02'}, {'40','20'}, {'90','01'}, {'31','38'}, {'31','50'}, {'01','90'}, {'13','90'}, {'14','90'}, {'31','90'}, {'13','04'}, {'13','03'}, {'13','06'},;
                {'31','04'}, {'31','05'}, {'31','06'}, {'91','01'}, {'31','26'}, {'31','27'}, {'92','01'}, {'94','01'}, {'95','01'}, {'96','01'}, {'16','02'}, {'16','03'},;
                {'16','04'}, {'16','05'}, {'16','06'}, {'16','07'}, {'16','08'}, {'16','09'}, {'16','10'}, {'03','01'}, {'03','02'}, {'04','01'}, {'04','02'}, {'97','01'},;
                {'98','01'}, {'A1','01'}, {'A2','01'}, {'A3','01'}, {'A4','01'}, {'A5','01'}, {'A6','01'}, {'A7','01'}, {'31','51'}, {'70','02'}, {'70','03'}, {'A8','01'},;
                {'A9','01'}, {'B1','01'}, {'B2','01'}, {'40','21'}, {'40','22'}, {'B3','01'}, {'B4','01'}, {'B5','01'}, {'B6','01'}, {'31','28'}, {'31','29'}, {'31','30'},;
                {'31','52'}, {'B7','01'}, {'B8','01'}, {'B9','01'}, {'C1','01'}, {'C2','01'}, {'C2','02'}, {'C2','03'}, {'C2','04'}, {'C2','05'}, {'C3','01'}, {'C4','01'},;
                {'13','05'}, {'C5','01'}, {'C5','02'}, {'C5','03'}, {'C5','04'}, {'C5','05'}, {'C5','06'}, {'C6','01'}, {'C6','02'}, {'C7','01'}, {'C7','02'}, {'C8','01'},;
                {'C9','01'}, {'D1','01'}, {'D2','01'}, {'D3','01'}, {'D4','01'}, {'31','53'}, {'10','02'}, {'D5','01'}, {'D6','01'}, {'D7','01'}, {'D8','01'}, {'D9','01'},;
                {'D9','02'}, {'D9','03'}, {'31','87'}, {'E1','01'}, {'E1','02'}, {'E2','01'}, {'E3','01'}, {'E4','01'}, {'E5','01'}, {'95','02'}, {'E6','01'}, {'E7','01'},;
                {'95','03'}, {'E8','01'}, {'E9','01'}, {'F1','01'}, {'F2','01'}, {'34','02'}, {'F3','01'}, {'40','23'}, {'28','02'}, {'F4','01'}, {'F5','01'}, {'F6','01'},;
                {'F8','01'}, {'F7','01'}, {'F9','01'}, {'99','01'}}

   lRet := ( AScan(aEmps, {|x| AllTrim(cCodEmp) == x[1] }) > 0) .And. AllTrim(cCodEmp) != cEmpMod 
   
Return lRet

******************************************
Static Function FSTProc( lEnd, aMarcadas )
******************************************
Local aInfo     := {}
Local aRecnoSM0 := {}
Local cAux      := ""
Local cFile     := ""
Local cFileLog  := ""
Local cMask     := "Arquivos Texto" + "(*.TXT)|*.txt|"
Local cTCBuild  := "TCGetBuild"
Local cTexto    := ""
Local cTopBuild := ""
Local lOpen     := .F.
Local lRet      := .T.
Local nI        := 0
Local nX        := 0
Local nY        := 0
Local oDlg      := NIL
Local oFont     := NIL
Local oMemo     := NIL
Local aTables   := {}
Local _aCmpX3 := {}
Local aModelo    := {}
Local aStruct    := {}
Local aAllStruct := {}

Private cRelTit := ""

If Empty(cEmpMod)
   MsgStop('Selecione uma empresa "modelo"!')
   Return .F.
Endif

If Empty(aSx2Tables)
   MsgStop('Nenhuma tabela foi selecionada! Verifique.')
   Return .F.
Endif

AEval(aSx2Tables,{|t| Aadd(aTables,t[2])})

//Empresa Modelo.
RpcSetType( 3 )
RpcSetEnv( cEmpMod, "01" )

cRelTit := "Dicionario modelo: Empresa "+cEmpMod+" - "+FWEmpName(cEmpMod) + CRLF

//SX2->(DbSetOrder(1))
//SX3->(DbSetOrder(1))

For nX := 1 To Len(aTables)
	_aCmpX3 := FWSX3Util():GetAllFields(aTables[nX], .T. )
    If Len(_aCmpX3) > 0 //SX3->(DbSeek(aTables[nX]))
       For nI := 1 to Len(_aCmpX3) //While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == aTables[nX]
             Aadd(aModelo,{GetSx3Cache(_aCmpX3[nI], 'X3_CAMPO'),GetSx3Cache(_aCmpX3[nI], 'X3_TITULO'),GetSx3Cache(_aCmpX3[nI], 'X3_DESCRIC'),.F.})
             //SX3->(DbSkip(1))
       Next nI //Enddo
    Endif
	_aCmpX3 := {}
Next nX

RpcClearEnv()
__cInterNet := NIL
__lPYME     := .F.

If ( lOpen := MyOpenSm0(.T.) )

	dbSelectArea( "SM0" )
	dbGoTop()

	While !SM0->( EOF() )
		// So adiciona no aRecnoSM0 se a empresa for diferente
		If aScan( aRecnoSM0, { |x| x[2] == SM0->M0_CODIGO } ) == 0 ;
		   .AND. aScan( aMarcadas, { |x| x[1] == SM0->M0_CODIGO } ) > 0
			aAdd( aRecnoSM0, { SM0->(Recno()), SM0->M0_CODIGO } )
		EndIf
		SM0->( dbSkip() )
	End

	SM0->( dbCloseArea() )

	If lOpen .And. ( Len( aRecnoSM0 ) > 0 )

        oProcess:SetRegua1( Len(aRecnoSM0) )

		For nI := 1 To Len( aRecnoSM0 )

			If !( lOpen := MyOpenSm0(.T.) )
				MsgStop( "Auditoria da empresa " + aRecnoSM0[nI][2] + " nao efetuada." )
				Exit
			EndIf

			SM0->( dbGoTo( aRecnoSM0[nI][1] ) )

			oProcess:IncRegua1(" Auditando Empresa: " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )

			RpcSetType( 3 )
			RpcSetEnv( SM0->M0_CODIGO, SM0->M0_CODFIL )
			
			SX3->(DbSetOrder(2))
			
			aStruct := aClone(aModelo)
			
			//Verifica se o campo existe no dicionário da empresa corrente.
			AEval(aStruct,{|s| s[len(s)] := SX3->(DbSeek(s[1]))} )
	    
	        //Monta os dados para o relatório.
			AEval(aStruct,{|s| if(!s[len(s)],Aadd(aAllStruct,{AllTrim(SM0->M0_CODIGO),SM0->M0_NOME,s[1],s[2],s[3]}),) }) 
			
			RpcClearEnv()
            __cInterNet := NIL
            __lPYME     := .F.
		Next nI
	EndIf
Else
	lRet := .F.
EndIf

MsAguarde({|| fReport(aAllStruct)},"Aguarde, gerando o relatorio...")

Return lRet


******************************
Static Function fReport(aRows)
******************************
   Local cFileName := U_GetTmpKit(.T.) + "AuditDic.csv"
   Local nHld      := fCreate(cFileName)
   Local aHtml     := {}
   Local cRow      := ""
   Local nX, nY, nZ:= 0
   Local aHeader   := {"COD.EMPRESA","EMPRESA","CAMPO","TITULO","DESCRICAO"}
   
   If Empty(aRows)
      MsgInfo("Nenhuma diferenca encontrada!")
      Return .F.
   Endif

   aSort( aRows,,,{ |x,y| x[1] < y[1] } )
   
   If nHld = -1
      conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
      Return .F.
   Endif
   
   FWrite(nHld, cRelTit + CRLF)
   
   For nX := 1 To Len(aRows)
       
       cRow := ""
       
       If nX == 1
          AEval(aHeader,{|h| cRow += h + ";" })
          cRow += CRLF
       Endif 

       AEval(aRows[nX],{|d| cRow += cValToChar(d) + ";" })
       
       FWrite(nHld, cRow + CRLF)
       
   Next nX
   
   FClose(nHld)
   
   If File(cFileName)
      ShellExecute("Open",cFileName,"","",3)	// 1 = Normal, 2 = Minimizado, 3 = Maximizado
   Endif
   
Return .T.
  
   

//--------------------------------------------------------------------
/*/{Protheus.doc} EscEmpresa
FunCao generica para escolha de Empresa, montada pelo SM0

@return aRet Vetor contendo as seleCoes feitas. Se nao for marcada nenhuma o vetor volta vazio

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function EscEmpresa()

//---------------------------------------------
// Parâmetro  nTipo
// 1 - Monta com Todas Empresas/Filiais
// 2 - Monta so com Empresas
// 3 - Monta so com Filiais de uma Empresa
//
// Parâmetro  aMarcadas
// Vetor com Empresas/Filiais pre marcadas
//
// Parâmetro  cEmpSel
// Empresa que sera usada para montar seleCao
//---------------------------------------------
Local aRet       := {}
Local aSalvAmb   := FWGetArea()
Local aSalvSM0   := {}
Local aVetor     := {}
Local cMascEmp   := "??"
Local cVar       := ""
Local lChk       := .F.
Local lOk        := .F.
Local lTeveMarc  := .F.
Local oNo        := LoadBitmap( GetResources(), "LBNO" )
Local oOk        := LoadBitmap( GetResources(), "LBOK" )
Local oDlg, oChkMar, oLbx, oMascEmp, oSay
Local oBtnTables, oButInv, oButOk, oButCanc
Local aCbxEmp    := {}
Local oFnt08AriN := Tfont():New("Arial",,-08,,.T.,,,,,.F.)
Local bChangeCbx := {|| fChgCbxEmp(cCbxEmp)}

Local   aMarcadas := {}

Private cCbxEmp    := ""
 
If !MyOpenSm0(.T.)
	Return aRet
EndIf

dbSelectArea( "SM0" )
aSalvSM0 := SM0->( FWGetArea() )
SM0->(dbSetOrder( 1 ))
SM0->(dbGoTop())

While !SM0->( EOF() )

     //Verifica se a empresa/filial devera ser processada.
	 If !fProcEmp(SM0->M0_CODIGO,SM0->M0_CODFIL)
        SM0->( dbSkip() )
        Loop
     Endif

	If aScan( aVetor, {|x| x[2] == SM0->M0_CODIGO} ) == 0
		aAdd(  aVetor, { aScan( aMarcadas, {|x| x[1] == SM0->M0_CODIGO .and. x[2] == SM0->M0_CODFIL} ) > 0, SM0->M0_CODIGO, SM0->M0_CODFIL, SM0->M0_NOME, SM0->M0_FILIAL } )
	EndIf

	SM0->(dbSkip())
End

FWRestArea( aSalvSM0 )

If Empty(aVetor)
   MsgStop("Nao ha empresas para o processamento!")
   return
Endif

Aadd(aCbxEmp,"Selecione a empresa modelo...")
AEval(aVetor,{|v| Aadd(aCbxEmp, v[2]+" - "+v[4])})

Define MSDialog  oDlg Title "" From 0, 0 To 320, 395 Pixel

oCbxTpEnt   := TComboBox():New(002,010,bSetGet(cCbxEmp),aCbxEmp,148,15,oDlg,,bChangeCbx,,,,.T.,/*oFnt12AriN*/,,,{||.T.},,,,,,"Empresa modelo",1,oFnt08AriN)

@ 010, 160 Button oButInv Prompt "Tabelas"  Size 28, 12 Pixel Action ( SelTables(@aSx2Tables) ) ;
Message "Selecione as tabelas a serem processadas." Of oDlg
oButInv:SetCss( CSSBOTAO )


oDlg:cToolTip := "Tela para Multiplas SeleCoes de Empresas/Filiais"
oDlg:cTitle   := "Selecione a(s) Empresa(s) para a auditoria"
@ 25, 10 Listbox  oLbx Var  cVar Fields Header " ", " ", "Empresa" Size 178, 095 Of oDlg Pixel
oLbx:SetArray(  aVetor )
oLbx:bLine := {|| {IIf( aVetor[oLbx:nAt, 1] .And. aVetor[oLbx:nAt, 2] != cEmpMod, oOk, oNo ), ;
aVetor[oLbx:nAt, 2], ;
aVetor[oLbx:nAt, 4]}}
oLbx:BlDblClick := { || aVetor[oLbx:nAt, 1] := !aVetor[oLbx:nAt, 1], VerTodos( aVetor, @lChk, oChkMar ), oChkMar:Refresh(), oLbx:Refresh()}
oLbx:cToolTip   :=  oDlg:cTitle
oLbx:lHScroll   := .F. // NoScroll

@ 126, 12 CheckBox oChkMar Var  lChk Prompt "Todos" Message "Marca / Desmarca"+ CRLF + "Todos" Size 40, 007 Pixel Of oDlg;
on Click MarcaTodos( lChk, @aVetor, oLbx )

@ 142, 10 Button oButInv    Prompt "&Inverter"  Size 32, 12 Pixel Action ( InvSelecao( @aVetor, oLbx, @lChk, oChkMar ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Inverter Selecao" Of oDlg
oButInv:SetCss( CSSBOTAO )
@ 126, 157  Button oButOk   Prompt "Processar"  Size 32, 12 Pixel Action (  RetSelecao( @aRet, aVetor ), If(fVldExec(),oDlg:End(),.F.)  ) ;
Message "Confirma a selecao e efetua" + CRLF + "o processamento" Of oDlg
oButOk:SetCss( CSSBOTAO )
@ 142, 157  Button oButCanc Prompt "Cancelar"   Size 32, 12 Pixel Action ( IIf( lTeveMarc, aRet :=  aMarcadas, .T. ), oDlg:End() ) ;
Message "Cancela o processamento" + CRLF + "e abandona a aplicacao" Of oDlg
oButCanc:SetCss( CSSBOTAO )

Activate MSDialog  oDlg Center

If Select("SM0") > 0
   dbSelectArea( "SM0" )
   dbCloseArea()
Endif

FWRestArea( aSalvAmb )

Return  aRet

**************************
Static Function fVldExec()
**************************
   If Empty(cEmpMod)
      MsgStop('Selecione uma empresa "modelo"!')
      Return .F.
   Endif
      
   If Empty(aSx2Tables)
      MsgStop('Nenhuma tabela foi selecionada! Verifique.')
      Return .F.
   Endif

Return .T.


***************************
Static Function SelTables()
***************************
   Local lRet      := .F.
   Local oDlgTbl   := Nil
   Local oListTbl  := Nil
   Local cListTbl  := 0
   Local aListTbl  := {}
   Local nListH    := 0
   Local nListW    := 0
   Local oNo       := LoadBitmap( GetResources(), "LBNO" )
   Local oOk       := LoadBitmap( GetResources(), "LBOK" )
   Local oChkTodos := Nil
   Local lChkTodos := .F.
   Local oBtnConf  := Nil
   Local bBtnConf  := {|| lRet := .T., oDlgTbl:End() }
   Local oBtnCanc  := Nil
   Local bBtnCanc  := {|| lRet := .F., oDlgTbl:End() }
   Local bSelTodos := {|| AEval(aListTbl,{|l| l[1] := lChkTodos}), oListTbl:Refresh() }
   
   If (cCbxEmp == CBX_EMPTY)
      MsgStop(CBX_EMPTY_MESSAGE)
      Return .F.
   Endif
   
   MsAguarde({|| fLoadTables(@aListTbl) },"Aguarde, carregando o dicionario...")
   
   If Empty(aListTbl)
      Return .F.
   Endif
   
   oDlgTbl :=TDialog():New(000,000,400, 400,"Selecione a(s) tabela(s)",,,,,,,,,.T.)
       oDlgTbl:nClrPane:= RGB(254,255,255)
       
       nListH := (oDlgTbl:nClientHeight / 2) - 50
       nListW := (oDlgTbl:nClientWidth / 2) - 10
       
       @ 005, 005 Listbox oListTbl Var cListTbl Fields Header " ", "Tabela", "Descricao" Size nListW,nListH Of oDlgTbl Pixel
          oListTbl:SetArray(  aListTbl )
          oListTbl:bLine      := {||{IIf( aListTbl[oListTbl:nAt, 1], oOk, oNo ), aListTbl[oListTbl:nAt, 2], aListTbl[oListTbl:nAt, 3]}}
          oListTbl:BlDblClick := { || aListTbl[oListTbl:nAt, 1] := !aListTbl[oListTbl:nAt, 1], oListTbl:Refresh()}
          oListTbl:cToolTip   := oDlgTbl:cTitle

       oChkTodos := TCheckBox():New((oListTbl:nBottom/2)+10,05,'Todos',bSetGet(lChkTodos),oDlgTbl,100,050,,bSelTodos,,,,,,.T.,,,)

       oBtnCanc := TButton():New((oListTbl:nBottom/2)+10,(oDlgTbl:nRight/2)-080,"Cancelar" ,oDlgTbl,bBtnCanc,070,15,,,,.T.)
       oBtnConf := TButton():New((oListTbl:nBottom/2)+10,(oDlgTbl:nRight/2)-155,"Confirmar",oDlgTbl,bBtnConf,070,15,,,,.T.)

   oDlgTbl:Activate(,,,.T.)
   
   If lRet
      aSx2Tables := {}
      Aeval(aListTbl,{|x| If(x[1],Aadd(aSx2Tables,x),) })
   Endif
   
Return lRet

************************************
Static Function fLoadTables(aTables)
************************************
Local cQuery := ""
Local aTables := {}
Local _cAliasX2 := GetNextAlias()


RpcSetType( 3 )
RpcSetEnv( cEmpMod, "01" )

cQuery := " SELECT X2_CHAVE AS CHAVEX2, X2_NOME AS NOMEX2"
cQuery += " FROM "+RetSQLName("SX2") + " SX2  "
cQuery += " WHERE D_E_L_E_T_= ' ' "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T., 'TOPCONN', TcGenQry(,,cQuery), _cAliasX2)

//SX2->(DbSetOrder(1))
//SX2->(DbGotop())
While (_cAliasX2)->(!Eof())
	 Aadd(aTables,{.F.,(_cAliasX2)->CHAVEX2,AllTrim((_cAliasX2)->NOMEX2)})
	 (_cAliasX2)->(DbSkip())
EndDo

If !Empty(aSx2Tables)
  AEval(aTables,{|x| k := x[2], x[1] := ( AScan(aSx2Tables,{|t| t[2] == k}) > 0 )}) 
Endif

RpcClearEnv()

__cInterNet := NIL
__lPYME     := .F.

Return .T.


***********************************
Static Function fChgCbxEmp(cCodEmp)
***********************************

   If (cCodEmp == CBX_EMPTY)
      MsgStop(CBX_EMPTY_MESSAGE)
      Return .F.
   Endif 
   
   cEmpMod := Left(cCodEmp,2)
   
Return .T.


//--------------------------------------------------------------------
/*{Protheus.doc} MarcaTodos
FunCao auxiliar para marcar/desmarcar todos os Itens do ListBox ativo

@param lMarca  Conteudo para marca .T./.F.
@param aVetor  Vetor do ListBox
@param oLbx    Objeto do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
**************************************************
Static Function MarcaTodos( lMarca, aVetor, oLbx )
**************************************************
   Local  nI := 0
   
   If (cCbxEmp == CBX_EMPTY)
      MsgStop(CBX_EMPTY_MESSAGE)
      Return .F.
   Endif 
   
   For nI := 1 To Len( aVetor )
   	aVetor[nI][1] := lMarca
   Next nI
   
   oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} InvSelecao
FunCao auxiliar para inverter a seleCao do ListBox ativo

@param aVetor  Vetor do ListBox
@param oLbx    Objeto do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function InvSelecao( aVetor, oLbx )
Local  nI := 0

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := !aVetor[nI][1]
Next nI

oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} RetSelecao
FunCao auxiliar que monta o retorno com as seleCoes

@param aRet    Array que tera o retorno das seleCoes (e alterado internamente)
@param aVetor  Vetor do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function RetSelecao( aRet, aVetor )
Local  nI    := 0

aRet := {}
For nI := 1 To Len( aVetor )
	If aVetor[nI][1]
		aAdd( aRet, { aVetor[nI][2] , aVetor[nI][3], aVetor[nI][2] +  aVetor[nI][3] } )
	EndIf
Next nI

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} MarcaMas
FunCao para marcar/desmarcar usando mascaras

@param oLbx     Objeto do ListBox
@param aVetor   Vetor do ListBox
@param cMascEmp Campo com a mascara (???)
@param lMarDes  Marca a ser atribuIda .T./.F.

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MarcaMas( oLbx, aVetor, cMascEmp, lMarDes )
Local cPos1 := SubStr( cMascEmp, 1, 1 )
Local cPos2 := SubStr( cMascEmp, 2, 1 )
Local nPos  := oLbx:nAt
Local nZ    := 0

For nZ := 1 To Len( aVetor )
	If cPos1 == "?" .or. SubStr( aVetor[nZ][2], 1, 1 ) == cPos1
		If cPos2 == "?" .or. SubStr( aVetor[nZ][2], 2, 1 ) == cPos2
			aVetor[nZ][1] := lMarDes
		EndIf
	EndIf
Next

oLbx:nAt := nPos
oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} VerTodos
FunCao auxiliar para verificar se estao todos marcados ou nao

@param aVetor   Vetor do ListBox
@param lChk     Marca do CheckBox do marca todos (referncia)
@param oChkMar  Objeto de CheckBox do marca todos

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function VerTodos( aVetor, lChk, oChkMar )
Local lTTrue := .T.
Local nI     := 0

For nI := 1 To Len( aVetor )
	lTTrue := IIf( !aVetor[nI][1], .F., lTTrue )
Next nI

lChk := IIf( lTTrue, .T., .F. )
oChkMar:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} MyOpenSM0
FunCao de processamento abertura do SM0 modo exclusivo

@author TOTVS Protheus
@since  30/11/2016
@obs    Gerado por EXPORDIC - V.5.2.1.0 EFS / Upd. V.4.20.15 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MyOpenSM0(lShared)
Local _aAllFil := FWLoadSM0( .T. , .F. )
Local lOpen := .F.
Local nLoop := 0
Local _aDados := {}
lShared := .T.

For nLoop := 1 To Len(_aAllFil) //20
	//dbUseArea( .T., , "SIGAMAT.EMP", "SM0", lShared, .F. )
	_aDados := FWSM0Util():GetSM0Data( _aAllFil[nLoop][1] , _aAllFil[nLoop][2] , {"M0_CODIGO"}) 
	If Len(_aDados) > 0 //!Empty( Select( "SM0" ) )
		lOpen := .T.
		//dbSetIndex( "SIGAMAT.IND" )
		Exit
	EndIf

	Sleep( 500 )

Next nLoop

If !lOpen
	MsgStop( "Nao foi possIvel a abertura da tabela " + ;
	IIf( lShared, "de empresas (SM0).", "de empresas (SM0) de forma exclusiva." ), "ATENCaO" )
EndIf

Return lOpen



