#Include 'Protheus.ch'

User Function MA103ATF()
Local aCab      := ParamIXB[1]
Local aItens    := ParamIXB[2]
Local nItem
Local cStatus       := SuperGetMV("FS_STATATF",.F., "1")
Local nPercMax      := SuperGetMV("FS_PMAXATF",.F., 80) //Parametro para valor máximo do ativo em percentual

Local nPosStat      := aScan(aCab, {|x| AllTrim(x[1]) = "N1_STATUS"})
Local nPosGrp       := aScan(aCab, {|x| AllTrim(x[1]) = "N1_GRUPO"})
Local nPosDescr       := aScan(aCab, {|x| AllTrim(x[1]) = "N1_DESCRIC"})

Local nPosChapa      := aScan(aCab, {|x| AllTrim(x[1]) = "N1_CHAPA"})
Local nPosdClass      := aScan(aCab, {|x| AllTrim(x[1]) = "N1_DTCLASS"})

Local nPosCtb       := aScan(aItens[1], {|x| AllTrim(x[1]) = "N3_CCONTAB"})
Local nPosCusBem    := aScan(aItens[1], {|x| AllTrim(x[1]) = "N3_CUSTBEM"})
Local nPosCCusto    := aScan(aItens[1], {|x| AllTrim(x[1]) = "N3_CCUSTO"})
Local nPosSubCon    := aScan(aItens[1], {|x| AllTrim(x[1]) = "N3_SUBCCON"})
Local nPosTpSal     := aScan(aItens[1], {|x| AllTrim(x[1]) = "N3_TPSALDO"})
Local nPosTpDepr    := aScan(aItens[1], {|x| AllTrim(x[1]) = "N3_TPDEPR"})
Local nPosDepTx1    := aScan(aItens[1], {|x| AllTrim(x[1]) = "N3_TXDEPR1"})
Local nPosDepTx2    := aScan(aItens[1], {|x| AllTrim(x[1]) = "N3_TXDEPR2"})
Local nPosDepTx3    := aScan(aItens[1], {|x| AllTrim(x[1]) = "N3_TXDEPR3"})
Local nPosDepTx4    := aScan(aItens[1], {|x| AllTrim(x[1]) = "N3_TXDEPR4"})
Local nPosDepTx5    := aScan(aItens[1], {|x| AllTrim(x[1]) = "N3_TXDEPR5"})

Local nPosVmxDep    := aScan(aItens[1], {|x| AllTrim(x[1]) = "N3_VMXDEPR"})
Local nPosClvlCon   := aScan(aItens[1], {|x| AllTrim(x[1]) = "N3_CLVLCON"}) 
Local nPosAquis     := aScan(aItens[1], {|x| AllTrim(x[1]) = "N3_AQUISIC"})
Local nPosTipo      := aScan(aItens[1], {|x| AllTrim(x[1]) = "N3_TIPO"})
Local nPosHistor    := aScan(aItens[1], {|x| AllTrim(x[1]) = "N3_HISTOR"})
Local nPosVorig     := aScan(aItens[1], {|x| AllTrim(x[1]) = "N3_VORIG1"})

Local nTamHist       := TamSx3("N3_HISTOR")[1]

//cDescric       := aScan(aCab, {|x| AllTrim(x[1]) = "N1_DESCRIC"})
Local cDescric       := aCab[nPosDescr][2]
Local lDebug := .F. 

dbSelectArea("SNG")
SNG->(DbSetOrder(1))
If !lDebug 
    dbSelectArea("ZNG")
    ZNG->(DbSetOrder(2))
    If !ZNG->(dbSeek(xFilial("ZNG") + SD1->D1_GRUPO))
        Return({aCab,aItens})
    EndIf 
    SNG->(dbSeek(xFilial("SNG") + ZNG->ZNG_GRUPOA))
Else 
    SNG->(dbSeek(xFilial("SNG") + "1004"))
EndIf 

If nPosGrp = 0 
   aAdd(aCab,{"N1_GRUPO", SNG->NG_GRUPO }) 
Else 
    If Empty(aCab[nPosGrp][2]) 
       aCab[nPosGrp][2]  := SNG->NG_GRUPO
    EndIf 
EndIf 

If nPosStat = 0 
   aAdd(aCab,{"N1_STATUS", '1' }) 
Else 
    aCab[nPosStat][2]  := '1'
EndIf 

If nPosChapa = 0 
   aAdd(aCab,{"N1_CHAPA",  StrZero(Randomize(1, 9999),4)+ALLTRIM(SD1->D1_DOC)}) 
Else 
    aCab[nPosChapa][2]  := StrZero(Randomize(1, 9999),4)+ALLTRIM(SD1->D1_DOC)
EndIf 

If nPosdClass = 0 
   aAdd(aCab,{"N1_DTCLASS", SD1->D1_DTDIGIT }) 
Else 
    aCab[nPosdClass][2]  := SD1->D1_DTDIGIT
EndIf 


If nPosCtb = 0 
   aAdd(aItens[1],{"N3_CCONTAB", If(!Empty(SNG->NG_CCONTAB)	,SNG->NG_CCONTAB	,'1') }) 
Else
    If Empty(aItens[1][nPosCtb][2]) 
        aItens[1][nPosCtb][2] := If(!Empty(SNG->NG_CCONTAB)	,SNG->NG_CCONTAB	,'1')
    EndIf 
EndIf 

If nPosCusBem = 0 
   aAdd(aItens,{"N3_CUSTBEM", If(!Empty(SNG->NG_CUSTBEM)	,SNG->NG_CUSTBEM	,'1') }) 
Else 
    If Empty(aItens[1][nPosCusBem][2]) 
        aItens[1][nPosCusBem][2] := If(!Empty(SNG->NG_CUSTBEM)	,SNG->NG_CUSTBEM,'')
    EndIf 
EndIf 

If nPosCCusto = 0 
   aAdd(aItens[1],{"N3_CCUSTO", If(!Empty(SNG->NG_CCUSTO)	,SNG->NG_CCUSTO	,'1') }) 
Else 
    If Empty(aItens[1][nPosCCusto][2]) 
        aItens[1][nPosCCusto][2] := If(!Empty(SNG->NG_CCUSTO) ,SNG->NG_CCUSTO,'')
    EndIf 
EndIf 

If nPosSubCon = 0 
   aAdd(aItens[1],{"N3_SUBCCON", If(!Empty(SNG->NG_SUBCCON)	,SNG->NG_SUBCCON	,'1') }) 
Else 
    If Empty(aItens[1][nPosSubCon][2]) 
        aItens[1][nPosSubCon][2] := If(!Empty(SNG->NG_SUBCCON) ,SNG->NG_SUBCCON,'')
    EndIf 
EndIf 

If nPosTpSal = 0 
   aAdd(aItens[1],{"N3_TPSALDO", If(!Empty(SNG->NG_TPSALDO)	,SNG->NG_TPSALDO	,'1') }) 
Else 
    If Empty(aItens[1][nPosTpSal][2]) 
        aItens[1][nPosTpSal][2] := If(!Empty(SNG->NG_TPSALDO) ,SNG->NG_TPSALDO,'1')
    EndIf 
EndIf 

If nPosTpDepr = 0 
   aAdd(aItens[1],{"N3_TPDEPR", If(!Empty(SNG->NG_TPDEPR)	,SNG->NG_TPDEPR	,'1') }) 
Else 
    If Empty(aItens[1][nPosTpDepr][2]) 
        aItens[1][nPosTpDepr][2] := If(!Empty(SNG->NG_TPDEPR) ,SNG->NG_TPDEPR,'1')
    EndIf 
EndIf 

If SNG->NG_TPDEPR == "7"
    nValOrig := aItens[1][nPosVorig][2] 
    nValorMax := (nValOrig*nPercMax)/100
    nValorMax := Round(nValorMax,2)
    If nPosVmxDep = 0
        aAdd(aItens[1],{"N3_VMXDEPR", nValorMax }) 
    Else
        If Empty(aItens[1][nPosTpDepr][2]) 
            aItens[1][nPosVmxDep][2] := nValorMax
        EndIf 
    EndIf
EndIf 
    
If nPosDepTx1 = 0 
   aAdd(aItens[1],{"N3_TXDEPR1", If(!Empty(SNG->NG_TXDEPR1)	,SNG->NG_TXDEPR1	,0) }) 
Else 
    If Empty(aItens[1][nPosDepTx1][2]) 
        aItens[1][nPosDepTx1][2] := If(!Empty(SNG->NG_TXDEPR1) ,SNG->NG_TXDEPR1,0)
    EndIf 
EndIf 

If nPosDepTx2 = 0 
   aAdd(aItens[1],{"N3_TXDEPR2", If(!Empty(SNG->NG_TXDEPR2)	,SNG->NG_TXDEPR2	,0) }) 
Else 
    If Empty(aItens[1][nPosDepTx1][2]) 
        aItens[1][nPosDepTx1][2] := If(!Empty(SNG->NG_TXDEPR2) ,SNG->NG_TXDEPR2,0)
    EndIf 
EndIf 

If nPosDepTx3 = 0 
   aAdd(aItens[1],{"N3_TXDEPR3", If(!Empty(SNG->NG_TXDEPR3)	,SNG->NG_TXDEPR3	,0) }) 
Else 
    If Empty(aItens[1][nPosDepTx3][2]) 
        aItens[1][nPosDepTx3][2] := If(!Empty(SNG->NG_TXDEPR3) ,SNG->NG_TXDEPR3,0)
    EndIf 
EndIf 

If nPosDepTx4 = 0 
   aAdd(aItens[1],{"N3_TXDEPR4", If(!Empty(SNG->NG_TXDEPR4)	,SNG->NG_TXDEPR4	,0) }) 
Else 
    If Empty(aItens[1][nPosDepTx4][2]) 
        aItens[1][nPosDepTx4][2] := If(!Empty(SNG->NG_TXDEPR4) ,SNG->NG_TXDEPR4,0)
    EndIf 
EndIf 

If nPosDepTx5 = 0 
   aAdd(aItens[1],{"N3_TXDEPR5", If(!Empty(SNG->NG_TXDEPR5)	,SNG->NG_TXDEPR5	,0) }) 
Else 
    If Empty(aItens[1][nPosDepTx5][2]) 
        aItens[1][nPosDepTx5][2] := If(!Empty(SNG->NG_TXDEPR5) ,SNG->NG_TXDEPR5,0)
    EndIf 
EndIf 



If nPosHistor = 0 
   aAdd(aItens[1],{"N3_HISTOR", If(!Empty(cDescric)	,SubStr(cDescric,1,nTamHist) ,'CLASSIFICAO AUTOMATICA DE ATIVO') }) 
Else 
    If Empty(aItens[1][nPosHistor][2]) 
        aItens[1][nPosHistor][2] := If(!Empty(cDescric) ,SubStr(cDescric,1,nTamHist),'CLASSIFICAO AUTOMATICA DE ATIVO')
    EndIf 
EndIf 

Return({aCab,aItens})
