
















function U_F0703308(OCABEC,NOPERAC,NTPMETD)

local ACABEC := {}
local ACONV := {}
local AEXCNF := {}
local AEXCTIT := {}
local AIMP := {}
local AITENS := {}
local ALINHA := {}
local ALOG := {}
local ATITULO := {}
local BBLOCK := ERRORBLOCK({|E|CHKERR(E)})
local CFILDOC := ""
local CRET := "ERRO|"
local CXID := U_GETINTEGID()
local CXIDOLD := ""
local LRET :=  .T. 
local NTAMDOC := TAMSX3("F2_DOC")[1]
local NTAMCLI := TAMSX3("F2_CLIENTE")[1]
local NTAMLOJA := TAMSX3("F2_LOJA")[1]
local NTAMSER := TAMSX3("F2_SERIE")[1]
local NX := 0
local NY := 0
local NZ := 0
local CINDKEY := ""
local NTAMTGDV := TAMSX3("F2_XDEVFRO")[1]
local CQUERY := ""
local CALIAS1 := GETNEXTALIAS()

private CERRORL := ""
private LAUTOERRNOFILE :=  .T. 
private LMSERROAUTO :=  .F. 
private CUSERNAME := "INTNFD"
private AREGSD2 := {}
private AREGSE1 := {}
private NREGLOG := 0
private AREGSE2 := {}

CFILDOC :=  alltrim(OCABEC:CFILREG)



NREGLOG := U_MSINTNFS("I",{OCABEC},0,{},2)

if (EMPTY(CFILDOC)) .or. (.not. (EXISTCPO("SM0",CEMPANT+CFILDOC)))
    LRET :=  .F. 
    CRET += "PARAMETRO OBRIGATORIO INVALIDO: CFILREG"+CHR(13)+CHR(10)
else 
    CFILANT := CFILDOC
endif

if NTPMETD==1
    ; if LRET .and. EMPTY(OCABEC:CDOC)
        LRET :=  .F. 
        CRET += "PARAMETRO OBRIGATORIO INVALIDO: CDOC"+CHR(13)+CHR(10)
    endif
else 
    ; if LRET .and. EMPTY(OCABEC:CTAGDEV)
        LRET :=  .F. 
        CRET += "PARAMETRO OBRIGATORIO INVALIDO: cTAGDEV"+CHR(13)+CHR(10)
    endif
endif

if NTPMETD==1
    ; if LRET .and. EMPTY(OCABEC:CSERIE)
        LRET :=  .F. 
        CRET += "PARAMETRO OBRIGATORIO INVALIDO: CSERIE"+CHR(13)+CHR(10)
    endif
endif

if LRET .and. EMPTY(OCABEC:CFORNECE)
    LRET :=  .F. 
    CRET += "PARAMETRO OBRIGATORIO INVALIDO: CFORNECE"+CHR(13)+CHR(10)
endif

if LRET .and. EMPTY(OCABEC:CLOJA)
    LRET :=  .F. 
    CRET += "PARAMETRO OBRIGATORIO INVALIDO: CLOJA"+CHR(13)+CHR(10)
endif

if NOPERAC==3 .and. .not. (EMPTY(OCABEC:CDTDIGIT))
    ; if EMPTY(CTOD(OCABEC:CDTDIGIT))
        LRET :=  .F. 
        CRET += "PARAMETRO OBRIGATORIO INVALIDO: CDTDIGIT"+CHR(13)+CHR(10)
    else 
        DDATABASE := CTOD(OCABEC:CDTDIGIT)
    endif
endif


if NTPMETD==2 .and. LRET
    CQUERY := "SELECT SF2.F2_FILIAL, SF2.F2_DOC, SF2.F2_SERIE, SF2.F2_CLIENTE, SF2.F2_LOJA "
    CQUERY += " FROM "+RETSQLNAME("SF2")+" SF2 "
    CQUERY += " WHERE SF2.D_E_L_E_T_ = ' ' "
    CQUERY += " AND SF2.F2_FILIAL  = '"+XFILIAL("SF2")+"'"
    CQUERY += " AND SF2.F2_XDEVFRO = '"+ alltrim(OCABEC:CTAGDEV)+"'"
    CQUERY += " AND SF2.F2_CLIENTE = '"+ alltrim(OCABEC:CFORNECE)+"'"
    CQUERY += " AND SF2.F2_LOJA = '"+ alltrim(OCABEC:CLOJA)+"'"

    CQUERY := CHANGEQUERY(CQUERY)
    DBUSEAREA( .T. ,"TOPCONN",TCGENQRY(CQUERY),CALIAS1, .T. , .T. )

    ; if (CALIAS1)->(.not. (EOF()))
        OCABEC:CDOC := CALIAS1->F2_DOC
        OCABEC:CSERIE := CALIAS1->F2_SERIE
    endif
endif

CINDKEY := XFILIAL("SF2")+"|"+PADR(OCABEC:CDOC,NTAMDOC)+"|"+PADR(OCABEC:CSERIE,NTAMSER)+"|"+PADR(OCABEC:CFORNECE,NTAMCLI)+"|"+PADR(OCABEC:CLOJA,NTAMLOJA)


if LRET


    (SF2)->(DBSETORDER(1))
    ; if (SF2)->(DBSEEK(XFILIAL("SF2")+PADR(OCABEC:CDOC,NTAMDOC)+PADR(OCABEC:CSERIE,NTAMSER)+PADR(OCABEC:CFORNECE,NTAMCLI)+PADR(OCABEC:CLOJA,NTAMLOJA)))
        ; if .not. (EMPTY(SF2->F2_XDEVFRO))
                //BEGINTRAN()
                Begin Transaction
                CONOUT("Inicio: "+TIME())
                (SD2)->(DBSETORDER(3))
                ; if (SD2)->(DBSEEK(XFILIAL("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))

                    CNUMPED := SD2->D2_PEDIDO
                    CFILORI := SD2->D2_FILIAL

                    ; if MACANDELF2("SF2",(SF2)->(RECNO()),@AREGSD2,@AREGSE1,@AREGSE2)
                        CONOUT("VALIDA EXCLUS�O DA NOTA - MaCanDelF2 OK")



                        LMSERROAUTO :=  .F. 
                        (SF2)->(MADELNFS(AREGSD2,AREGSE1,AREGSE2, .F. , .F. , .T. , .T. ))
                    else 
                        CRET := 'ERRO|EXCLUSAO DO T�TULO. Fun��o padr�o MaCanDelF2."'
                        ALOG := GETAUTOGRLOG()
                        for NY := 1 to ( len(ALOG)) step 1
                            CRET += ALOG[NY]+CHR(13)+CHR(10)
                        next
                        LMSERROAUTO :=  .T. 
                        DISARMTRANSACTION()
                        break 
                    endif

                    ; if (SF2)->(DBSEEK(XFILIAL("SF2")+PADR(OCABEC:CDOC,NTAMDOC)+PADR(OCABEC:CSERIE,NTAMSER)+PADR(OCABEC:CFORNECE,NTAMCLI)+PADR(OCABEC:CLOJA,NTAMLOJA)))
                        CRET := 'ERRO|EXCLUSAO DO T�TULO. Fun��o padr�o MaDelNFS."'
                        ALOG := GETAUTOGRLOG()
                        for NY := 1 to ( len(ALOG)) step 1
                            CRET += ALOG[NY]+CHR(13)+CHR(10)
                        next
                        LMSERROAUTO :=  .T. 
                        DISARMTRANSACTION()
                        break 
                    endif

                    ; if .not. (LMSERROAUTO)
                        ACABEC := {}
                        AITENS := {}
                        CONOUT("Exclus�o da Nota Fiscal feita com sucesso! [SF2/SD2] "+OCABEC:CDOC)

                        (SC5)->(DBSETORDER(1))
                        ; if (SC5)->(DBSEEK(CFILORI+CNUMPED))
                            AADD(ACABEC,{"C5_NUM",SC5->C5_NUM,NIL})
                            AADD(ACABEC,{"C5_TIPO",SC5->C5_TIPO,NIL})
                            AADD(ACABEC,{"C5_CLIENTE",SC5->C5_CLIENTE,NIL})
                            AADD(ACABEC,{"C5_LOJACLI",SC5->C5_LOJACLI,NIL})
                            AADD(ACABEC,{"C5_CONDPAG",SC5->C5_CONDPAG,NIL})

                            (SC6)->(DBSETORDER(1))
                            ; if (SC6)->(DBSEEK(XFILIAL("SC6")+SC5->C5_NUM))
                                AADD(ALINHA,{"C6_ITEM",SC6->C6_ITEM,NIL})
                                AADD(ALINHA,{"C6_PRODUTO",SC6->C6_PRODUTO,NIL})
                                AADD(ALINHA,{"C6_QTDVEN",SC6->C6_QTDVEN,NIL})
                                AADD(ALINHA,{"C6_PRCVEN",SC6->C6_PRCVEN,NIL})
                                AADD(ALINHA,{"C6_PRUNIT",SC6->C6_PRUNIT,NIL})
                                AADD(ALINHA,{"C6_VALOR",SC6->C6_VALOR,NIL})
                                AADD(ALINHA,{"C6_TES",SC6->C6_TES,NIL})
                                AADD(AITENS,ALINHA)

                                MSEXECAUTO({ |X,Y,Z|MATA410(X,Y,Z)},ACABEC,AITENS,4)

                                ; if LMSERROAUTO
                                    LRET :=  .F. 
                                    CRET := "ERRO|EXCLUSAO PEDIDO FRONT: "+ alltrim(SC5->C5_XNUM)+" / "+"PEDIDO PROTHEUS: "+ alltrim(SC5->C5_NUM)+". OBS: "+CHR(13)+CHR(10)
                                    ALOG := GETAUTOGRLOG()
                                    for NY := 1 to ( len(ALOG)) step 1
                                        CRET += ALOG[NY]+CHR(13)+CHR(10)
                                    next
                                    DISARMTRANSACTION()
                                    break 
                                else 
                                    LRET :=  .T. 
                                    CRET := "OK|EXCLUSAO PEDIDO FRONT: "+ alltrim(SC5->C5_XNUM)+" / "+"PEDIDO PROTHEUS: "+ alltrim(SC5->C5_NUM)+". OBS: "+CHR(13)+CHR(10)
                                endif
                            else 
                                CRET := "ERRO|EXCLUSAO PEDIDO FRONT: "+ alltrim(SC5->C5_XNUM)+" / "+"PEDIDO PROTHEUS: "+ alltrim(SC5->C5_NUM)+". OBS: "+CHR(13)+CHR(10)
                                CRET += "Itens do pedido n�o foram localizados."+CHR(13)+CHR(10)
                                DISARMTRANSACTION()
                                break 
                            endif
                        endif
                    else 
                        CONOUT("Erro| Exclus�o n�o foi bem sucedida! "+OCABEC:CDOC)
                        LRET :=  .F. 
                        DISARMTRANSACTION()
                        break 
                    endif
                    CONOUT("Fim  : "+TIME())
                    CONOUT("--------------------------------------------------------------------------------")
                else 
                    CONOUT("Erro| Itens n�o foram localizados (SD2)! "+OCABEC:CDOC)
                    DISARMTRANSACTION()
                    break 
                endif
                End Transaction
                //ENDTRAN()
        else 
            CRET += " Nota n�o originada pela integra��o (Campo F2_XDEVFRO em branco)! "+CHR(13)+CHR(10)
            LRET :=  .F. 
        endif
    else 
        CRET += " Cabe�alho n�o foi localizado (SF2)! "+CHR(13)+CHR(10)
        LRET :=  .F. 
    endif

    ERRORBLOCK(BBLOCK)

    ; if LMSERROAUTO .and. LRET
        CRET += "INCONSISTENCIA DE ROTINA AUTOMATICA | "+CHR(13)+CHR(10)
        ALOG := GETAUTOGRLOG()
        for NY := 1 to ( len(ALOG)) step 1
            CRET += ALOG[NY]+CHR(13)+CHR(10)
        next
    endif

    ; if .not. (EMPTY(CERRORL))
        LRET :=  .F. 
        CRET += "ERRO DE PROGRAMACAO | "+CHR(13)+CHR(10)+CERRORL
    endif

    ; if .not. (LMSERROAUTO) .and. LRET
        CRET := "OK"
        U_MSINTNFS("A",{},NREGLOG,{CRET,1},2)
    else 
        U_MSINTNFS("A",{},NREGLOG,{CRET,2},2)
    endif
endif

DDATABASE := DATE()

return CRET











static function CHKERR(OERROARQ)

local NI := 0

if OERROARQ:GENCODE>0
    CERRORL := "("+ alltrim(STR(OERROARQ:GENCODE))+") : "+ alltrim(OERROARQ:DESCRIPTION)+CHR(13)+CHR(10)
endif

NI := 2

while .not. (EMPTY(PROCNAME(NI)))
    CERRORL +=  rtrim(PROCNAME(NI))+"("+ alltrim(STR(PROCLINE(NI)))+") "+CHR(13)+CHR(10)
    NI++; end

if INTRANSACT()
    CERRORL += "Transacao aberta desarmada"
    DISARMTRANSACTION()
endif
U_MSINTNFS("A",{},NREGLOG,{CERRORL,2},2)
CRETERR := "ERRO| "+CERRORL

return 
