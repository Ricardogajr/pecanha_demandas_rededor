#INCLUDE 'PROTHEUS.CH'
#INCLUDE  'TOPCONN.CH'
#Include "TOTVS.ch" //Thais Paiva - 09/12/2020

/*/{Protheus.doc} F1200709
Processa medições.
@author 	Paulo Krüger
@since 		17/08/2017
@version 	P12.7
@Project    MAN0000007423046
@Return		lRet
/*/

User Function F1200709(aAllCab,aItsGCT,aId,cContrat,cRevisa, cNewfil )

Local cFuncao	:=	''
Local aRet		:=	{}
Local aErro		:=	{}
Local cFlagGCT	:=	''
Local cNumMed	:=	'' 
Local cOriMed	:=	''
Local dDataMed	:=	CTOD('  /  /  ')
Local cHoramed	:=	''
Local cPedCom	:=	''
Local cStatMed	:=	''
Local cObs 		:=	''
Local nPosObs	:=	0
Local cRecnSC7	:=  0
Local cFilOld 	:= ""
Local lGCTOk	:= .T.

// --------------------------------------------------------
// [ Chamado 7023201 - inicio - 1/3 ]
// --------------------------------------------------------
local lAltCN9   := .F.
local nRecCN9   := 0
local cQry      := ''
// --------------------------------------------------------
// [ Chamado 7023201 - fim    - 1/3 ]
// --------------------------------------------------------

Default cContrat:=	''
Default cRevisa	:=	''

Private lMsHelpAuto := .T.
Private lMsErroAuto := .F.
	
If ISINCALLSTACK('U_F1200600')
	cOrigMed := 'S'
Else
	cOrigMed := 'M'
EndIf
	 
CN9->(DbSetOrder(01))
If CN9->(DbSeek(aAllCab[01][01][02] + aAllCab[01][02][02]))

	cFilOld := cFilAnt
	cFilAnt := cNewfil

	Begin Transaction
		CND->(DbSetOrder(04))
		If	CND->(DbSeek(cNewfil + aAllCab[01][10][02]) )
			aAllCab[01][10][02] := GetSxENum('CND','CND_NUMMED')
			ConfirmSX8()
		EndIf

// --------------------------------------------------------
//      [ Chamado 7023201 - inicio - 2/3 ]
// --------------------------------------------------------
// -----[ Verificação padrão, replicada aqui  ]-------
// -----[ com a filial correta,               ]-------
//------[ pois a customização altera a filial ]-------
// ---------------------------------------------------
// -----[ Verifica revisão atual do contrato  ]-------
// -----[ se a situação é revisão '09'        ]-------
// ---------------------------------------------------
        CN9->( dbsetorder( 1 )) // CN9_FILIAL + CN9_NUMERO          + CN9_REVISA
        CN9->( dbseek(    aAllCab[01][01][02] + aAllCab[01][02][02] + 'ZZZ' , .T. ))
        CN9->( dbskip( -1 ))
        if ( CN9->CN9_FILIAL == aAllCab[01][01][02] .AND. ; // filial do contrato
             CN9->CN9_NUMERO == aAllCab[01][02][02] .AND. ; // numero do contrato
             CN9->CN9_SITUAC == '09'                      )
            Help( ' ' , 1 , 'CNTA120_02' ) // 'Apenas contratos em vigência podem ser medidos'
			lGCTOk   := .F.                // Erro na medicao
			cFlagGCT := '3'
			disarmtransaction()
			break
        endif
// -----[ contorna a validação padrão, ]--------------
// -----[ feita na filial errada       ]--------------
        CN9->( dbsetorder( 1 )) // CN9_FILIAL + CN9_NUMERO          + CN9_REVISA
        CN9->( dbseek(       xFilial( 'CN9' ) + aAllCab[01][02][02] + 'ZZZ' , .T. ))
        CN9->( dbskip( -1 ))
        if CN9->CN9_SITUAC == '09'
            reclock( 'CN9' , .T. )
                CN9->CN9_FILIAL := xfilial( 'CN9' )
                CN9->CN9_NUMERO := aAllCab[01][02][02]
                CN9->CN9_REVISA := 'ZZY'
                CN9->CN9_SITUAC := 'XX'
                nRecCN9         := CN9->( recno() )
                lAltCN9         := .T.
            msunlock()
        endif
// --------------------------------------------------------
//      [ Chamado 7023201 - fim    - 2/3 ]
// --------------------------------------------------------

		DbSelectArea('CN1')

		//Executa Medições
		MSExecAuto({|v,x,y,z| CNTA120(v,x,y,z)},aAllCab[01], aItsGCT, 3, .F.)
		If	lMsErroAuto
			lGCTOk := .F. //Erro na medicao
//			cObs 	:= MostraErro("\tmperro.txt")
            if cOrigMed == 'S'
                cObs := MostraErro( 'tmperro.txt' )
            elseif cOrigMed == 'M'
                mostraerro()
            endif
			cFlagGCT := '3'
			DisarmTransaction()
			Break
		EndIf
			
		//Encerra Medições
		//9304877 - Thais Paiva
		_nPosNM := Ascan(aAllCab[01],{|x| x[1] == 'CND_NUMMED'})
		If _nPosNM > 0
			If Empty(Alltrim(aAllCab[01][_nPosNM][2]))
				AAdd(aAllCab[01], {'CND_NUMMED', CND->CND_NUMMED, NIL})
			EndIf
		ElseIf _nPosNM == 0
			AAdd(aAllCab[01], {'CND_NUMMED', CND->CND_NUMMED, NIL})
		EndIf
		//9304877 - Thais Paiva

		cFuncao	:= FunName()
		SetFunName('CNTA120')
		MSExecAuto({|v,x,y,z| CNTA120(v,x,y,z)},aAllCab[01], aItsGCT, 6, .F.)
		SetFunName(cFuncao)
		
		If lMsErroAuto
			lGCTOk := .F. //Erro na medicao
			cObs 	:= MostraErro("\tmperro.txt")
			cFlagGCT:=	'3'
			DisarmTransaction()
			Break
		EndIf
		
		cFlagGCT	:=	'1'
		cNummed		:=	CND->CND_NUMMED
		cOriMed		:=	If(IsInCallStack('U_F1200600'),'S','M') // Schedule ou Manual
		dDataMed	:=	dDataBase
		cHoramed	:=	Time()
		cPedCom		:=	SC7->C7_NUM
		If Empty(aErro)
			cStatMed := 'Utilizado pelo GCT'
			//Atualiza o Campo C7_XDESFIN na inclusão do pedido vindo de medição
    	   	//U_F1600701(CNE->CNE_FILIAL, SC7->C7_NUM)
		Else
			cStatMed := 'Medição não Realizada'
		EndIf
		
// --------------------------------------------------------
//      [ Chamado 7023201 - início - 3/3 ]
// --------------------------------------------------------
// -----[ Desfaz o contorno da validação padrão ]-----
        if ( lAltCN9 .AND. ;
             nRecCN9 <> 0  )
            CN9->( dbgoto( nRecCN9 ))
            reclock( 'CN9' , .F. )
                CN9->( dbdelete() )
             msunlock()
// ------------------------------------
            cQry := "DELETE " + retsqlname( 'CN9' )
            cQry += "WHERE D_E_L_E_T_ = '*' "
            cQry += "AND CN9_FILIAL = '" + xfilial( 'CN9' )    + "' "
            cQry += "AND CN9_NUMERO = '" + aAllCab[01][02][02] + "' "
            cQry += "AND CN9_REVISA = 'ZZY' "
            cQry += "AND CN9_SITUAC = 'XX'  "
            tcsqlexec( cQry )
// ------------------------------------
        endif
// --------------------------------------------------------
//      [ Chamado 7023201 - fim    - 3/3 ]
// --------------------------------------------------------

	End Transaction

	cFilAnt := cFilOld
	
	if lGCTOk //Se processou medicao no GCT corretamente
	If cFlagGCT == '1'
		cRecnSC7 := SC7->(Recno())
	EndIf
	
	//Atualiza informações nas Solicitações de Compras
	U_F1200710(	aId				,	;
				cObs			,	;
				cFlagGCT		,	;
				cStatMed		,	;
				cNummed			,	;
				cOriMed			,	;
				dDataMed		,	;
				cHoramed		,	;
				cContrat		,	;
				cRevisa			,	;
				cPedCom)

			//Processa todo o PE do final da SC7
			//U_GCTINTEGR(3, SC7->C7_NUM, 1, SC7->(Recno())) Thais Paiva - 10355882
			U_GCTINTEGR(3, cPedCom, 1, SC7->(Recno()))
						
	If cFlagGCT == '1'
		DbSelectArea("CN9")
		CN9->(DbSetOrder(1))
		CN9->(DbSeek(aAllcab[1][AScan(aallcab[1], {|x| AllTrim(x[1]) == "CND_FILCTR"})][2]+aAllcab[1][AScan(aallcab[1], {|x| AllTrim(x[1]) == "CND_CONTRA"})][2]+aAllcab[1][AScan(aallcab[1], {|x| AllTrim(x[1]) == "CND_REVISA"})][2]))
		//Envia email com o Pedido de Compra gerado
		U_F1200501(cRecnSC7)  
	EndIf 
	EndIf
	
EndIf

Return(.T.)
