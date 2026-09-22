#Include 'Protheus.ch'

/*
{Protheus.doc}  TEWBTYC1()
Cadastro para relacionamento de Fornecedor x Natureza
@Author  Ramon Teodoro e Silva	
@Since   13/05/2016       
@Version P12.7
*/
User Function TEWBTYC1(cAlias, nReg)

Local lRet     := .T.
Local aArea    := GetArea()
Local aPosObj  := {}
Local aObjects := {}
Local aSize    := MsAdvSize(.F.)
Local oDlgPri
Local oGet
Local oGet2
Local cSeek    := ""
Local aCols    := {}
Local aHeader  := {}
Local nOpcA    := 0
Local aCposAlt := {}

Public aColsPZA  := IIF( cCodFor == M->A2_COD, If(Type("aColsPZA") != "A",{},aColsPZA), {})
Public aHeadPZA  := IIF( cCodFor == M->A2_COD, If(Type("aHeadPZA") != "A",{},aHeadPZA), {})

Private oDlPZA
Private nOpc    := IIF( INCLUI .OR. ALTERA, GD_INSERT+GD_DELETE+GD_UPDATE, 2)

DEFAULT aPCols   := {}

DbSelectArea( "SA2" )
MsGoto( nReg )
cCodFor      := M->A2_COD
cCodLoja   	 := M->A2_LOJA
cNomeFor     := M->A2_NOME

DbSelectArea("PZA")
cSeek  := xFilial( "PZA" ) + cCodFor + cCodLoja
U_MntEst("PZA",cSeek)

If nOpc <> 2
	aCposAlt := {"PZA_CODNAT"}
EndIf

AAdd( aObjects, { 100,  44, .T., .F. } )
AAdd( aObjects, { 100, 100, .T., .T. } )

aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 2 }
aPosObj := MsObjSize( aInfo, aObjects )

DEFINE MSDIALOG oDlgPri TITLE "Naturezas" FROM aSize[7],00 TO aSize[6],aSize[5] OF oMainWnd PIXEL

@ 019,006 SAY "Código" SIZE 040,009 OF oDlgPri PIXEL //"Codigo"
@ 032,005 GET oGet VAR cCodFor SIZE 030,009 OF oDlgPri PIXEL WHEN .F.

@ 019,056 SAY "Loja" SIZE 040,009 OF oDlgPri PIXEL //"Loja"
@ 032,055 GET oGet2 VAR cCodLoja SIZE 010,009 OF oDlgPri PIXEL WHEN .F.

@ 019,076 SAY "Nome" SIZE 040,009 OF oDlgPri PIXEL //"Nome"
@ 032,075 GET oGet2 VAR cNomeFor SIZE 220,009 OF oDlgPri PIXEL WHEN .F.

oDlPZA := MsNewGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,"U_FtNatLOK()",,,aCposAlt,,9999,,,,oDlgPri,aHeadPZA,aColsPZA) 
	
ACTIVATE MSDIALOG oDlgPri ON INIT EnchoiceBar(oDlgPri, {|| nOpcA:=1,If(.T., oDlgPri:End(),nOpcA:=0) }, {|| nOpcA:=0,oDlgPri:End() },,{})
	
If ( nOpcA == 1 )
	M->A2_NATUREZ := oDlPZA:aCols[1][1] 
	aColsPZA := oDlPZA:aCols
EndIf
		
RestArea( aArea )

Return(lRet)


/*
{Protheus.doc}  MntGet()
Montagem aHeadPZA e aColsPZA
@Author  Ramon Teodoro e Silva	
@Since   13/05/2016       
@Version P12.7
*/

User Function MntEst(cAlias,cSeek)

Local lRet := .T.
Local nx
Local aColsPZAN := {}
Local nUsado    := 0
Local _aCmpPZA	:= {} //Thais Paiva - Compatibilização P27

_aCmpPZA := FWSX3Util():GetAllFields( "PZA" , .T. ) //Thais Paiva - Compatibilização P27

If Altera .OR. (!Altera .and. !Inclui)
 
	If Empty(aHeadPZA)
		
		aHeadPZA := {}
		DbSelectArea("PZA")
		DbGoTop()
		
		//Início - Thais Paiva - Compatibilização P27
		//DbSelectArea("SX3")
		//SX3->(DbSetOrder(1))
		//SX3->(DbSeek("PZA"))
		
		//While SX3->(!Eof()) .And. (SX3->X3_ARQUIVO == "PZA")
		For _nZa := 1 to Len(_aCmpPZA)
			
			//If X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL
			If X3USO(GetSx3Cache(_aCmpPZA[_nZa], 'X3_USADO')) .And. cNivel >= GetSx3Cache(_aCmpPZA[_nZa], 'X3_NIVEL')
				//If !(Alltrim(SX3->X3_CAMPO) $ "PZA_CODFOR|PZA_DESFOR|PZA_LOJA")	
				If !(Alltrim(_aCmpPZA[_nZa]) $ "PZA_CODFOR|PZA_DESFOR|PZA_LOJA")	
					nUsado++
					//If Alltrim(SX3->X3_CAMPO) $ "PZA_CODNAT"
					If Alltrim(_aCmpPZA[_nZa]) $ "PZA_CODNAT"
						//aAdd(aHeadPZA, {ALLTRIM(SX3->X3_TITULO), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL,"U_InfoNat()", SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3, SX3->X3_CONTEXT})
						aAdd(aHeadPZA, {ALLTRIM(GetSx3Cache(_aCmpPZA[_nZa], 'X3_TITULO')), GetSx3Cache(_aCmpPZA[_nZa], 'X3_CAMPO'), ;
										GetSx3Cache(_aCmpPZA[_nZa], 'X3_PICTURE'), GetSx3Cache(_aCmpPZA[_nZa], 'X3_TAMANHO'), ;
										GetSx3Cache(_aCmpPZA[_nZa], 'X3_DECIMAL'),"U_InfoNat()", GetSx3Cache(_aCmpPZA[_nZa], 'X3_USADO'), ;
										GetSx3Cache(_aCmpPZA[_nZa], 'X3_TIPO'), GetSx3Cache(_aCmpPZA[_nZa], 'X3_F3'), ;
										GetSx3Cache(_aCmpPZA[_nZa], 'X3_CONTEXT')})
					Else
						//aAdd(aHeadPZA, {ALLTRIM(SX3->X3_TITULO), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL,"ALLWAYSTRUE()", SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3, SX3->X3_CONTEXT})
						aAdd(aHeadPZA, {ALLTRIM(GetSx3Cache(_aCmpPZA[_nZa], 'X3_TITULO')), GetSx3Cache(_aCmpPZA[_nZa], 'X3_CAMPO'), ;
										GetSx3Cache(_aCmpPZA[_nZa], 'X3_PICTURE'), GetSx3Cache(_aCmpPZA[_nZa], 'X3_TAMANHO'), ;
										GetSx3Cache(_aCmpPZA[_nZa], 'X3_DECIMAL'),"ALLWAYSTRUE()", GetSx3Cache(_aCmpPZA[_nZa], 'X3_USADO'), ;
										GetSx3Cache(_aCmpPZA[_nZa], 'X3_TIPO'), GetSx3Cache(_aCmpPZA[_nZa], 'X3_F3'), ;
										GetSx3Cache(_aCmpPZA[_nZa], 'X3_CONTEXT')})
					EndIf
				EndIf
			EndIf
		
			//SX3->(DbSkip())
		
		//EndDo
		Next _nZa
		//Fim - Thais Paiva - Compatibilização P27

	EndIf
	
	DbSelectArea("PZA")
	If PZA->(DbSeek(cSeek))
		While !EOF() .And. cSeek == PZA->(PZA_FILIAL+PZA_CODFOR+PZA_LOJA)
			If aScan(aColsPZA,{|x|x[1]+x[2]+x[3]=PZA->(PZA_CODNAT+PZA_DESNAT+PZA_TIPNAT)}) = 0
		    	AADD(aColsPZA,{PZA->PZA_CODNAT,;
		    		           PZA->PZA_DESNAT,;
		    		           PZA->PZA_TIPNAT,;
		    		           PZA->PZA_CALCIR,;
		    		           PZA->PZA_CALCIS,;
		    		           PZA->PZA_CALCIN,;
		    		           PZA->PZA_CALCCS,;
		    		           PZA->PZA_CALCCO,;
		    		           PZA->PZA_CALCPI,;
		    		           PZA->PZA_DEDPIS,;
		    		           PZA->PZA_DEDCOF,;
		    		           PZA->PZA_CONNAT,;
		    		           .F.})
			EndIf
			PZA->(DbSkip())
		End
	EndIf
	
	If Len(aColsPZA) == 0
	
		aColsPZA := {Array(nUsado+1)}
		aColsPZA[1,nUsado+1] := .F.
		
		For nX := 1 to nUsado
			aColsPZA[1,nX] := CriaVar(aHeadPZA[nX,2])
		Next
		
		If !Empty(M->A2_NATUREZ)
			U_InfoNat(M->A2_NATUREZ,.t.)
		EndIf
		
    
    EndIf
		
ElseIf Inclui
	If Empty(aHeadPZA)
		aHeadPZA := {}
		
		//DbSelectArea("SX3")
		//SX3->(dbSetOrder(1))
		//SX3->(dbSeek("PZA"))
		
		//While SX3->(!Eof()) .And. (SX3->X3_ARQUIVO == "PZA")
		For _nZa := 1 to Len(_aCmpPZA)
			
			//If X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL
			If X3USO(GetSx3Cache(_aCmpPZA[_nZa], 'X3_USADO')) .And. cNivel >= GetSx3Cache(_aCmpPZA[_nZa], 'X3_NIVEL')
				//If !(Alltrim(SX3->X3_CAMPO) $ "PZA_CODFOR|PZA_DESFOR|PZA_LOJA")	
				If !(Alltrim(_aCmpPZA[_nZa]) $ "PZA_CODFOR|PZA_DESFOR|PZA_LOJA")	
					nUsado++
					//If Alltrim(SX3->X3_CAMPO) $ "PZA_CODNAT"
					If Alltrim(_aCmpPZA[_nZa]) $ "PZA_CODNAT"
						//aAdd(aHeadPZA, {ALLTRIM(SX3->X3_TITULO), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL,"U_InfoNat()", SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3, SX3->X3_CONTEXT})
						aAdd(aHeadPZA, {ALLTRIM(GetSx3Cache(_aCmpPZA[_nZa], 'X3_TITULO')), GetSx3Cache(_aCmpPZA[_nZa], 'X3_CAMPO'), ;
										GetSx3Cache(_aCmpPZA[_nZa], 'X3_PICTURE'), GetSx3Cache(_aCmpPZA[_nZa], 'X3_TAMANHO'), ;
										GetSx3Cache(_aCmpPZA[_nZa], 'X3_DECIMAL'),"U_InfoNat()", GetSx3Cache(_aCmpPZA[_nZa], 'X3_USADO'), ;
										GetSx3Cache(_aCmpPZA[_nZa], 'X3_TIPO'), GetSx3Cache(_aCmpPZA[_nZa], 'X3_F3'), ;
										GetSx3Cache(_aCmpPZA[_nZa], 'X3_CONTEXT')})
					Else
						//aAdd(aHeadPZA, {ALLTRIM(SX3->X3_TITULO), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL,"ALLWAYSTRUE()", SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3, SX3->X3_CONTEXT})
						aAdd(aHeadPZA, {ALLTRIM(GetSx3Cache(_aCmpPZA[_nZa], 'X3_TITULO')), GetSx3Cache(_aCmpPZA[_nZa], 'X3_CAMPO'), ;
										GetSx3Cache(_aCmpPZA[_nZa], 'X3_PICTURE'), GetSx3Cache(_aCmpPZA[_nZa], 'X3_TAMANHO'), ;
										GetSx3Cache(_aCmpPZA[_nZa], 'X3_DECIMAL'),"ALLWAYSTRUE()", GetSx3Cache(_aCmpPZA[_nZa], 'X3_USADO'), ;
										GetSx3Cache(_aCmpPZA[_nZa], 'X3_TIPO'), GetSx3Cache(_aCmpPZA[_nZa], 'X3_F3'), ;
										GetSx3Cache(_aCmpPZA[_nZa], 'X3_CONTEXT')})
					EndIf
				EndIf
			EndIf
		
			//SX3->(DbSkip())
		
		//End
		Next _nZa
	//Fim - Thais Paiva - Compatibilização P27
		
		aColsPZA := {Array(nUsado+1)}
		aColsPZA[1,nUsado+1] := .F.
		
		For nX := 1 to nUsado
			aColsPZA[1,nX] := CriaVar(aHeadPZA[nX,2])
		Next
		
		If !Empty(M->A2_NATUREZ)
			U_InfoNat(M->A2_NATUREZ, .t.)
		EndIf
		
		DbSelectArea("PZA")
		PZA->(DbSeek(cSeek))
		While !EOF() .And. cSeek == PZA->(PZA_FILIAL+PZA_CODFOR+PZA_LOJA)
			AADD(aColsPZA,{PZA_CODNAT,PZA_DESNAT,PZA_TIPNAT,PZA_CALCIR,PZA_CALCIS,PZA_CALCIN,PZA_CALCCS,PZA_CALCCO,PZA_CALCPI,PZA_DEDPIS,PZA_DEDCOF,PZA_CONNAT,.F.})
			PZA->(DbSkip())
		End
		//aPCols := {.T.}
	Else
		DbSelectArea("PZA")
		PZA->(DbSeek(cSeek))
		While !EOF() .And. cSeek == PZA->(PZA_FILIAL+PZA_CODFOR+PZA_LOJA)
			AADD(aColsPZA,{PZA_CODNAT,PZA_DESNAT,PZA_TIPNAT,PZA_CALCIR,PZA_CALCIS,PZA_CALCIN,PZA_CALCCS,PZA_CALCCO,PZA_CALCPI,PZA_DEDPIS,PZA_DEDCOF,PZA_CONNAT,.F.})
			PZA->(DbSkip())
		End
	EndIf
EndIf
//aSort(aColsPZA,,,{|x,y| x[1]+x[2]+x[3] < y[1]+Y[2]+y[3]})

Return lRet


/*
{Protheus.doc}  InfoNat()
Carrega infomações da Natureza para o aCols
@Author  Ramon Teodoro e Silva	
@Since   13/05/2016       
@Version P12.7
*/

User Function InfoNat(cNat, lTemNat)

Local lRet    := .T.
Local aArea   := GetArea()

Local nPosCod := aScan(aHeadPZA,{|x| AllTrim(x[2])== "PZA_CODNAT"})
Local nPosDes := aScan(aHeadPZA,{|x| AllTrim(x[2])== "PZA_DESNAT"})
Local nPosTp  := aScan(aHeadPZA,{|x| AllTrim(x[2])== "PZA_TIPNAT"})
Local nPosCIr := aScan(aHeadPZA,{|x| AllTrim(x[2])== "PZA_CALCIR"})
Local nPosCIs := aScan(aHeadPZA,{|x| AllTrim(x[2])== "PZA_CALCIS"})
Local nPosCIn := aScan(aHeadPZA,{|x| AllTrim(x[2])== "PZA_CALCIN"})
Local nPosCCs := aScan(aHeadPZA,{|x| AllTrim(x[2])== "PZA_CALCCS"})
Local nPosCCo := aScan(aHeadPZA,{|x| AllTrim(x[2])== "PZA_CALCCO"})
Local nPosCPi := aScan(aHeadPZA,{|x| AllTrim(x[2])== "PZA_CALCPI"})
Local nPosDeP := aScan(aHeadPZA,{|x| AllTrim(x[2])== "PZA_DEDPIS"})
Local nPosDCo := aScan(aHeadPZA,{|x| AllTrim(x[2])== "PZA_DEDCOF"})
Local nPosCon := aScan(aHeadPZA,{|x| AllTrim(x[2])== "PZA_CONNAT"})

DEFAULT cNat    := M->PZA_CODNAT
DEFAULT lTemNat := .F.

DbSelectArea("SED")
SED->(DbSetOrder(1))

If SED->(DbSeek(xFilial("SED")+cNat))

	If lTemNat
	
		aColsPZA[1][nPosCod] := cNat
		aColsPZA[1][nPosDes] := SED->ED_DESCRIC
		aColsPZA[1][nPosTp]  := SED->ED_TIPO
		aColsPZA[1][nPosCIr] := SED->ED_CALCIRF
		aColsPZA[1][nPosCIs] := SED->ED_CALCISS
		aColsPZA[1][nPosCIn] := SED->ED_CALCINS
		aColsPZA[1][nPosCCs] := SED->ED_CALCCSL
		aColsPZA[1][nPosCCo] := SED->ED_CALCCOF
		aColsPZA[1][nPosCPi] := SED->ED_CALCPIS
		aColsPZA[1][nPosDeP] := SED->ED_DEDPIS
		aColsPZA[1][nPosDCo] := SED->ED_DEDCOF
		aColsPZA[1][nPosCon] := SED->ED_COND
		
	Else
	
		aCols[n][nPosDes] := SED->ED_DESCRIC
		aCols[n][nPosTp]  := SED->ED_TIPO
		aCols[n][nPosCIr] := SED->ED_CALCIRF
		aCols[n][nPosCIs] := SED->ED_CALCISS
		aCols[n][nPosCIn] := SED->ED_CALCINS
		aCols[n][nPosCCs] := SED->ED_CALCCSL
		aCols[n][nPosCCo] := SED->ED_CALCCOF
		aCols[n][nPosCPi] := SED->ED_CALCPIS
		aCols[n][nPosDeP] := SED->ED_DEDPIS
		aCols[n][nPosDCo] := SED->ED_DEDCOF
		aCols[n][nPosCon] := SED->ED_COND
		
	EndIf	

EndIf

RestArea(aArea)

Return lRet

/*
{Protheus.doc}  FtNatLOk()
Valida a linha do cadastro
@Author  Ramon Teodoro e Silva	
@Since   13/05/2016       
@Version P12.7
*/

User Function FtNatLOk

Local lRet    := .T.
Local nPosNat := GDFieldPos( "PZA_CODNAT" )
Local nC      := 0

If !GDDeleted()

	For nC := 1 to Len(aCols)
		If Empty(Alltrim(aCols[nC][nPosNat]))
			lRet := .F.
		EndIf
	Next nC
	
EndIf

Return lRet






