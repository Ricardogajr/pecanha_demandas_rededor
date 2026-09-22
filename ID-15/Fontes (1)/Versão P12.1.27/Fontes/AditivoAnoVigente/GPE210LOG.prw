#Include "Protheus.ch"
#Include "rwmake.ch"

User Function GPE210LOG()

Local nSalFunc   as Numeric
Local nTeto      as Numeric
Local nTotCopart as Numeric

Local nFaixa1    as Numeric
Local nTeto1     as Numeric
Local nPerc1     as Numeric

Local nFaixa2    as Numeric
Local nTeto2     as Numeric
Local nPerc2     as Numeric

Local nFaixa3    as Numeric
Local nTeto3     as Numeric
Local nPerc3     as Numeric

Local nFaixa4    as Numeric
Local nTeto4     as Numeric
Local nPerc4     as Numeric

Local cFaixa     as Character
Local cConteudo  as Character

Local aArea      as array
Local aVerbas    as array
Local aCopart    as array
Local cMatricula as Character
Local aFilParam  as Character
Local aFilLib    as Character
Local nPosFil    as Character
Local cFilLib    as Character
Local cFilQry    as Character
Local cQry       as Character
Local nY         as Numeric
Local nX         as Numeric
Local cIniAnoMes as Character
Local cFimAnoMes as Character
Local cAnoMes    as Character
Local lValidade  as Logical
Local aDadLog    as Array
Local cDadTxt    as Character

aFilParam := STRTOKARR (SUPERGETMV("DOR_FILLIB", .T., "01BU0001,01BU0003"),',')

aFilLib := {}
cFilLib := ""
cFilQry := ""

aArea := GetArea()

nPosFil := aScan(aCampos,{ |x| Upper(Alltrim(x[1])) == "RGB_FILIAL"})

for nY:=1 to Len(aReg)
    if aScan(aFilParam,{ |x| Upper(Alltrim(x)) == Upper(aReg[nY,nPosFil])}) > 0
        if aScan(aFilLib,{ |x| Upper(Alltrim(x)) == Upper(aReg[nY,nPosFil])}) = 0
            aadd(aFilLib, aReg[nY,nPosFil])
        endif
    endif
next nY

if cAliasArq == "RGB" .and. (Len(aFilLib) > 0)

    cFaixa      := ""
    aVerbas     := {}
    aCopart     := {}
    aDadLog     := {}
    cDadTxt     := ""
    nX          := 1
    nTeto       := 0
    nTotCopart  := 0

    cQry:= "SELECT RGB_FILIAL, RGB_MAT, RGB_PD, RGB_VALOR, RGB_PERIOD, RGB_SEMANA, RGB_SEQ FROM " + RetSqlName("RGB") + " "
    cQry+= " WHERE D_E_L_E_T_ <> '*'"
    if Len(aFilLib) > 1
        for nY:=1 to Len(aFilLib)
            cFilQry += "'"+aFilLib[nY]+"', "
        next nY
        cFilQry := SubStr(cFilQry, 1, (Len(cFilQry)-2))
        cQry+= "   AND RGB_FILIAL IN ("+cFilQry+") "
    else
        cQry+= "   AND RGB_FILIAL = '"+aFilLib[1]+"'"
    endif
    cQry+= " ORDER BY RGB_FILIAL, RGB_MAT, RGB_PD DESC"

    if SELECT("TDP")
        TDP->( DbCloseArea() )
    endif

    dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQry),"TDP",.T.,.T.)

    TDP->( dbGoTop() )
    cMatricula := TDP->RGB_MAT
    cFilLib := ""
    lValidade := .T.

    aTitTeste := STRTOKARR(cTitImpres, ' ')
    cTitImpres := SPACE(04)+aTitTeste[1]+SPACE(08)+aTitTeste[2]+SPACE(04)+aTitTeste[3]+SPACE(02)+aTitTeste[4]+SPACE(01)+aTitTeste[5]+SPACE(13)+aTitTeste[6]+SPACE(01)+aTitTeste[7]+SPACE(05)+aTitTeste[8]+SPACE(11)+aTitTeste[9]+SPACE(11)+"Coparticipação"
    aLog[2][1] := cTitImpres

    while TDP->( !EOF() )
        if TDP->RGB_FILIAL <> cFilLib
            lValidade := .T.
            cFilLib := TDP->RGB_FILIAL
            dbSelectArea("RCC")
            RCC->( dbSetOrder(1) )          // RCC_FILIAL+RCC_CODIGO+RCC_FIL+RCC_CHAVE+RCC_SEQUEN
            RCC->( dbGoTop() )
            IF RCC->( dbSeek(FwxFilial("RCC")+"U052"+TDP->RGB_FILIAL) )
                while RCC->( !EOF() .and. RCC_FIL=TDP->RGB_FILIAL)
                    cConteudo := alltrim(RCC->RCC_CONTEU)

                    cVerba := Substr( cConteudo, 136,3 )
                    aadd(aVerbas, cVerba)

                    if cVerba = '627' .OR. cVerba = '628'
                        cIniAnoMes := Substr( cConteudo, 1,6 ) // 202201
                        cFimAnoMes := Substr( cConteudo, 7,6 ) // 202312
                        // Verificar validade da tabela
                        cAnoMes := strzero(year(dDataBase),4)+strzero(month(dDataBase),2)
		                if cAnoMes >= cIniAnoMes .and. cAnoMes <= cFimAnoMes
                            nFaixa1 := val(SubStr(cConteudo,13,12))
                            nTeto1  := val(SubStr(cConteudo,25,12))
                            nPerc1  := val(SubStr(cConteudo,37,6))

                            nFaixa2 := val(SubStr(cConteudo,43,12))
                            nTeto2  := val(SubStr(cConteudo,55,12))
                            nPerc2  := val(SubStr(cConteudo,67,6))

                            nFaixa3 := val(SubStr(cConteudo,73,12))
                            nTeto3  := val(SubStr(cConteudo,85,12))
                            nPerc3  := val(SubStr(cConteudo,97,6))

                            nFaixa4 := val(SubStr(cConteudo,103,12))
                            nTeto4  := val(SubStr(cConteudo,115,12))
                            nPerc4  := val(SubStr(cConteudo,127,6))
                        else
                            lValidade := .F.
                        endif
                    endif
                    RCC->( dbSkip() )
                enddo
            endif
        endif
      
        if TDP->RGB_MAT = cMatricula
            if lValidade
                if nTotCopart <= nTeto
                    if aScan( aVerbas, ALLTRIM(TDP->RGB_PD) )
                        nSalFunc := GetAdvFVal("SRA", "RA_SALARIO", TDP->RGB_FILIAL+TDP->RGB_MAT,1, "")
                        if nSalFunc <= nFaixa1 //1949.19
                            // FAIXA - A
                            // DE - R$ 0,00 à R$ 1.949,19 - Caluclar 55% do valor da coparticipação
                            nCopart  := (TDP->RGB_VALOR*nPerc1)/100
                            cFaixa   := "A"
                            nTeto := nTeto1
                        //elseif nSalFunc > 1949.19 .and. nSalFunc <= 2834.10
                        elseif nSalFunc > nFaixa1 .and. nSalFunc <= nFaixa2
                            // FAIXA - B
                            // DE - R$ 1.949,20 à R$ 2.834,10 - Caluclar 70% do valor da coparticipação
                            nCopart  := (TDP->RGB_VALOR*nPerc2)/100
                            cFaixa   := "B"
                            nTeto := nTeto2
                        //elseif nSalFunc > 2834.10 .and. nSalFunc <= 3925.72
                        elseif nSalFunc > nFaixa2 .and. nSalFunc <= nFaixa3
                            // FAIXA - C
                            // DE - R$ 2.834,11 à R$ 3.925,72 - Caluclar 85% do valor da coparticipação
                            nCopart  := (TDP->RGB_VALOR*nPerc3)/100
                            cFaixa   := "C"
                            nTeto := nTeto3
                        else
                            // FAIXA - D
                            // A partir de R$ 3.925,73 - Caluclar 100% do valor da coparticipação
                            nCopart  := (TDP->RGB_VALOR*nPerc4)/100
                            cFaixa   := "D"
                            nTeto := nTeto4
                        endif

                        if nCopart > nTeto
                            if nTotCopart > 0
                                nCopart := nTeto-nTotCopart
                                nTotCopart := nTotCopart + nCopart
                            else
                                nCopart := nTeto
                                nTotCopart := nTeto
                                nTotCopart := nTotCopart + nCopart
                            endif
                        else
                            if nTotCopart = 0 
                                nTotCopart := nTotCopart + nCopart
                            else
                                if (nTotCopart+nCopart) < nTeto
                                    nTotCopart := nTotCopart + nCopart
                                else
                                    nCopart := nTeto-nTotCopart
                                    nTotCopart := nTotCopart + nCopart
                                endif
                            endif
                        endif
                        aadd(aCopart, {TDP->RGB_FILIAL, TDP->RGB_MAT, TDP->RGB_PD, TDP->RGB_PERIOD, TDP->RGB_SEMANA, TDP->RGB_SEQ, NoRound(nCopart, 2), ''})
                        
                        for nY:=2 to Len(aLog[2])
                            aDadLog := STRTOKARR(aLog[2][nY], ' ')
                            if Len(aDadLog) > 5
                                if TDP->RGB_FILIAL+TDP->RGB_MAT+TDP->RGB_PD == aDadLog[3]+aDadLog[4]+substr(aDadLog[5],1,3)
                                    cDadTxt := aDadLog[1]+SPACE(01)+aDadLog[2]+SPACE(03)+aDadLog[3]+SPACE(04)+aDadLog[4]+SPACE(04)+aDadLog[5]+SPACE(01)+aDadLog[6]+SPACE(01)+aDadLog[7]+SPACE(01)+aDadLog[8]+SPACE(04)+aDadLog[9]+SPACE(20)+PADL(aDadLog[10], 12)+SPACE(07)+PADL(alltrim(REPLACE(str(NoRound(nCopart)),'.',',')), 12)
                                    aLog[2][nY] := cDadTxt
                                    exit
                                endif
                            endif
                        next nY
                    endif
                else
                    if aScan( aVerbas, ALLTRIM(TDP->RGB_PD) )
                        aadd(aCopart, {TDP->RGB_FILIAL, TDP->RGB_MAT, TDP->RGB_PD, TDP->RGB_PERIOD, TDP->RGB_SEMANA, TDP->RGB_SEQ, 0, ''})
                        for nY:=2 to Len(aLog[2])
                            aDadLog := STRTOKARR(aLog[2][nY], ' ')
                            if Len(aDadLog) > 5
                                if TDP->RGB_FILIAL+TDP->RGB_MAT+TDP->RGB_PD == aDadLog[3]+aDadLog[4]+substr(aDadLog[5],1,3)
                                    cDadTxt := aDadLog[1]+SPACE(01)+aDadLog[2]+SPACE(03)+aDadLog[3]+SPACE(04)+aDadLog[4]+SPACE(04)+aDadLog[5]+SPACE(01)+aDadLog[6]+SPACE(01)+aDadLog[7]+SPACE(01)+aDadLog[8]+SPACE(04)+aDadLog[9]+SPACE(20)+PADL(aDadLog[10], 12)+SPACE(15)+"0,00"
                                    aLog[2][nY] := cDadTxt
                                    exit
                                endif
                            endif
                        next nY
                    endif
                endif
                TDP->( dbSkip() )
            else
                aadd(aCopart, {TDP->RGB_FILIAL, TDP->RGB_MAT, TDP->RGB_PD, TDP->RGB_PERIOD, TDP->RGB_SEMANA, TDP->RGB_SEQ, 0, 'D'})
                for nY:=2 to Len(aLog[2])
                    aDadLog := STRTOKARR(aLog[2][nY], ' ')
                    if Len(aDadLog) > 5
                        if TDP->RGB_FILIAL+TDP->RGB_MAT+TDP->RGB_PD == aDadLog[3]+aDadLog[4]+substr(aDadLog[5],1,3)
                            if Len(aDadLog) > 10
                                cDadTxt := aDadLog[1]+SPACE(01)+aDadLog[2]+SPACE(03)+aDadLog[3]+SPACE(04)+aDadLog[4]+SPACE(04)+aDadLog[5]+SPACE(01)+aDadLog[6]+SPACE(01)+aDadLog[7]+SPACE(01)+aDadLog[8]+SPACE(04)+aDadLog[9]+SPACE(3)+aDadLog[10]+SPACE(3)+PADR(aDadLog[11], 12)+SPACE(4)+"0,00 - Não calculou a coparticipação pois a Data esta fora do período de validade na tabela U052"
                            else
                                cDadTxt := aDadLog[1]+SPACE(01)+aDadLog[2]+SPACE(03)+aDadLog[3]+SPACE(04)+aDadLog[4]+SPACE(04)+aDadLog[5]+SPACE(01)+aDadLog[6]+SPACE(01)+aDadLog[7]+SPACE(01)+aDadLog[8]+SPACE(04)+aDadLog[9]+SPACE(20)+PADL(aDadLog[10], 12)+SPACE(4)+"0,00 - Não calculou a coparticipação pois a Data esta fora do período de validade na tabela U052"
                            endif
                            aLog[2][nY] := cDadTxt
                            exit
                        endif
                    endif
                next nY
                TDP->( dbSkip() )
            endif
        else
            cMatricula := TDP->RGB_MAT
            nTotCopart := 0
            nTeto := 0
        endif
    enddo

    for nX := 1 to len(aCopart)
        dbSelectArea("RGB")
        RGB->( dbSetOrder(1) )          // RGB_FILIAL+RGB_MAT+RGB_PD+RGB_PERIOD+RGB_SEMANA+RGB_SEQ+RGB_CONVOC
        RGB->( dbGoTop() )
        if RGB->( dbSeek( aCopart[nX][1]+aCopart[nX][2]+aCopart[nX][3]+aCopart[nX][4]+aCopart[nX][5]+aCopart[nX][6] ) )
            if aCopart[nX][7] > 0
                RGB->( RecLock("RGB", .F.) )
                    RGB->( RGB_VALOR ) := aCopart[nX][7]
                RGB->( MsUnlock() )
            else
                if aCopart[nX][8] == 'D'
                    RGB->( RecLock("RGB", .F.) )
                        RGB->( RGB_VALOR ) := aCopart[nX][7]
                    RGB->( MsUnlock() )
                else
                    RGB->( dbRLock()  )
                    RGB->( dbDelete() )
                    RGB->( dbcommit() )
                    RGB->( dbrUnLock() )
                endif
            endif
        endif
    next nX
endif

RestArea(aArea)

Return aLog
