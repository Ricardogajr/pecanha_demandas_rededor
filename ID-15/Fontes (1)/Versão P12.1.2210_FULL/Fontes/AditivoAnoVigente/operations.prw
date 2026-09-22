
class REST_OPERATIONSdata CRESPONSE
    data DESCRIPTION__
    data DESCRIPTION_FORMAT
    data DESCRIPTION_INFO_POST
    data DESCRIPTION_POST
    data DESCRIPTION_SECURITY
    data DESCRIPTION_SSL
    data DESCRIPTION_SYNTAX_POST
    method POST(_QUERYPARAM,WSNOSEND)
end class










































method POST(_QUERYPARAM,WSNOSEND) class REST_OPERATIONS

local LRETURN :=  .T. 
local LCHECKAUTH := SUPERGETMV("MK_CHKAUTH",, .F. )
local OOBJJSON := NIL
local CFATPREFIXO := SUPERGETMV("MK_PREFIXO",,"NEG")
local CTIPOFAT := SUPERGETMV("MK_TIPOFAT",,"FT ")
local CCONDPAG := SUPERGETMV("MK_CONDPAG",,"001")
local DVENCORI := CTOD("")
local CHISTORI := ""
local CPORTORI := ""
local CBCOORI := ""
local CAGEORI := ""
local CDVAGORI := ""
local CCTAORI := ""
local CDVCTORI := ""
local CAGEPAG := ""
local CDVAGPAG := ""
local CCTAPAG := ""
local CDVCTPAG := ""
local CFORMORI := ""
local CFORMPG := ""
local CNUMFATURA := ""
local CBODY := ""
local CERRO := ""
local CMESSAGE := ""
local CRESPONSE := ""


local ATITULOS := {}
local AFATURA := {}
local NHTTPCODE := 400

local NREGSE2 := 0
local NI := 0

local NTAM := 0
local NTAXA := 0
local NACRESC := 0
local NDECRESC := 0
local NACRORI := 0
local NDECRORI := 0
local NVLJURORI := 0
local NVLMULORI := 0
local NVLDESORI := 0
local NBSIRFORI := 0
local NBSINSORI := 0
local NBSISSORI := 0
local NBSPISORI := 0
local NBSCOFORI := 0
local NBSCSLORI := 0
local NVLIRFORI := 0
local NVLINSORI := 0
local NVLISSORI := 0
local NVLPISORI := 0
local NVLCOFORI := 0
local NVLCSLORI := 0
local NVALBRU := 0
local NVALLIQ := 0
local NVALPCC := 0
local NRECNOSA2 := 0
local NTAMEMP :=  len(SM0->M0_CODIGO)
local NTAMFIL :=  len(FWXFILIAL("SE2"))
local CCNPJ := SUPERGETMV("MK_CNPJ",,"")
local LFATCUSTOM := SUPERGETMV("MK_FATCUST",, .F. )
local LLIBPAG := SUPERGETMV("MV_CTLIPAG",, .F. )
local CLOGDIR := SUPERGETMV("MK_LOGDIR",,"\log\")
local CLOGARQ := "operations"
local CCONFIRMQUERY := ""
local CCONFIRMALIAS := ""
local NCONFIRMCOUNT := 0

private LMSERROAUTO :=  .F. 
private LMSHELPAUTO :=  .T. 

private LCXPROP :=  .F. 
private LFATEXISTS :=  .F. 


CONOUT(OEMTOANSI(FWTIMESTAMP(2)+" * * * | operations Inicio"))
FWLOGMSG("INFO",,"MONKEY","operations","001","001","Inicio do Processo",0,0,{})

::SETCONTENTTYPE("application/JSON;charset=UTF-8")

if LCHECKAUTH
    CUSER := U_MNKRETUSR(::GETHEADER("Authorization"))
else 
    CONOUT(OEMTOANSI(FWTIMESTAMP(2)+" * * * | operations Executando sem autenticacao"))
    FWLOGMSG("WARN",,"MONKEY","operations","002","400","Inicio do Processo",0,0,{})
endif


(SE4)->(dbselectarea("SE4"))
(SE4)->(DBSETORDER(1))
if .not. ((SE4)->(DBSEEK(FWXFILIAL("SE4")+CCONDPAG)))
    LRETURN :=  .F. 
    NHTTPCODE := 412
    CMESSAGE := "Condicao de pagamento nao cadastrada"
endif

if LRETURN
    
    ; if LCHECKAUTH .and. EMPTY(CUSER)
        
        LRETURN :=  .F. 
        NHTTPCODE := 401
        CMESSAGE := "Usuario nao autenticado"
    else 
        
        
        CBODY := DECODEUTF8( alltrim(::GETCONTENT()))
        MEMOWRITE(CLOGDIR+CLOGARQ+"_request.json",CBODY)
        
        ; if FWJSONDESERIALIZE(CBODY,@OOBJJSON)
            
            CONOUT(OEMTOANSI(FWTIMESTAMP(2)+" * * * | operations FWJSONDeserialize"))
            
            LRETURN :=  .T. 
            
            for NI := 1 to ( len(OOBJJSON:OPERATIONS)) step 1
                
                CONOUT(OEMTOANSI(FWTIMESTAMP(2)+" * * * | operations Registro: "+CVALTOCHAR(NI)+"/"+CVALTOCHAR( len(OOBJJSON:OPERATIONS))))
                CONOUT(OEMTOANSI(FWTIMESTAMP(2)+" * * * | operations externalId: "+OOBJJSON:OPERATIONS[NI]:EXTERNALID))
                
                NACRESC := 0
                NACRORI := 0
                NDECRESC := 0
                NDECRORI := 0
                
                CEMPANT :=  substr(OOBJJSON:OPERATIONS[NI]:EXTERNALID,1,NTAMEMP)
                CFILANT :=  substr(OOBJJSON:OPERATIONS[NI]:EXTERNALID,NTAMEMP+1,NTAMFIL)
                NREGSE2 :=  val( substr(OOBJJSON:OPERATIONS[NI]:EXTERNALID,NTAMEMP+NTAMFIL+1, len( alltrim(OOBJJSON:OPERATIONS[NI]:EXTERNALID))-NTAMEMP+NTAMFIL))
                
                ; if EMPTY(CCNPJ)
                    CCNPJ := SM0->M0_CGC
                endif
                
                (SE2)->(dbselectarea("SE2"))
                
                
                
                
                
                (SE2)->(DBGOTO(NREGSE2))
                
                CONOUT(OEMTOANSI(FWTIMESTAMP(2)+" * * * | operations Chave: "+SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA))
                
                
                
                
                ; do case ; case  alltrim( upper(OOBJJSON:OPERATIONS[NI]:EVENTTYPE))=="SOLD"
                
                CONOUT(OEMTOANSI(FWTIMESTAMP(2)+" * * * | operations SOLD "))
                
                ; if (SE2)->(FIELDPOS("E2_XAGEPOR"))>0
                    CAGEPAG := SE2->E2_XAGEPOR
                endif
                ; if (SE2)->(FIELDPOS("E2_XDVAPOR"))>0
                    CDVAGPAG := SE2->E2_XDVAPOR
                endif
                ; if (SE2)->(FIELDPOS("E2_XCONPOR"))>0
                    CCTAPAG := SE2->E2_XCONPOR
                endif
                ; if (SE2)->(FIELDPOS("E2_XDVCPOR"))>0
                    CDVCTPAG := SE2->E2_XDVCPOR
                endif
                
                NBSIRFORI := SE2->E2_BASEIRF
                NBSINSORI := SE2->E2_BASEINS
                NBSISSORI := SE2->E2_BASEISS
                NBSPISORI := SE2->E2_BASEPIS
                NBSCOFORI := SE2->E2_BASECOF
                NBSCSLORI := SE2->E2_BASECSL
                NVLIRFORI := SE2->E2_IRRF
                NVLINSORI := SE2->E2_INSS
                NVLISSORI := SE2->E2_ISS
                NVLPISORI := SE2->E2_PIS
                NVLCOFORI := SE2->E2_COFINS
                NVLCSLORI := SE2->E2_CSLL
                NACRORI := SE2->E2_SDACRES
                NDECRORI := SE2->E2_SDDECRE
                NVLJURORI := SE2->E2_JUROS
                NVLMULORI := SE2->E2_MULTA
                NVLDESORI := SE2->E2_DESCONT
                
                NVALBRU := SE2->E2_VALOR
                
                ; if .not. (EMPTY(SE2->E2_PARCIR))
                    NVALBRU := NVALBRU+SE2->E2_IRRF
                endif
                
                ; if .not. (EMPTY(SE2->E2_PARCINS))
                    NVALBRU := NVALBRU+SE2->E2_INSS
                endif
                
                ; if .not. (EMPTY(SE2->E2_PARCISS))
                    NVALBRU := NVALBRU+SE2->E2_ISS
                endif
                
                ; if .not. (EMPTY(SE2->E2_PARCPIS))
                    NVALBRU := NVALBRU+SE2->E2_PIS
                endif
                
                ; if .not. (EMPTY(SE2->E2_PARCCOF))
                    NVALBRU := NVALBRU+SE2->E2_COFINS
                endif
                
                ; if .not. (EMPTY(SE2->E2_PARCSLL))
                    NVALBRU := NVALBRU+SE2->E2_CSLL
                endif
                
                
                
                NVALLIQ := SE2->E2_VALOR+SE2->E2_ACRESC+SE2->E2_MULTA+SE2->E2_JUROS-iif( alltrim(GETMV("MV_MRETISS"))=="1",SE2->E2_COFINS+SE2->E2_PIS+SE2->E2_CSLL+SE2->E2_DESCONT+SE2->E2_DECRESC,SE2->E2_ISS+SE2->E2_COFINS+SE2->E2_PIS+SE2->E2_CSLL+SE2->E2_DESCONT+SE2->E2_DECRESC)
                CONOUT(OEMTOANSI(FWTIMESTAMP(2)+" * * * | operations Valor Liquido: "+CVALTOCHAR(NVALLIQ)))
                
                NVALPCC := SE2->E2_COFINS+SE2->E2_PIS+SE2->E2_CSLL
                CONOUT(OEMTOANSI(FWTIMESTAMP(2)+" * * * | operations Valor PCC: "+CVALTOCHAR(NVALPCC)))
                
                ; if (SE2)->(FIELDPOS("E2_XPORTAD"))>0
                    CPORTORI := SE2->E2_XPORTAD
                endif
                
                
                ; if (OOBJJSON:OPERATIONS[NI]:BUYERGOVERNMENTID) $ (CCNPJ)
                    
                    CONOUT(OEMTOANSI(FWTIMESTAMP(2)+" * * * | operations Caixa Proprio "))
                    LCXPROP :=  .T. 
                    NTAXA := OOBJJSON:OPERATIONS[NI]:PAYMENTVALUE-OOBJJSON:OPERATIONS[NI]:SELLERRECEIVEMENTVALUE
                    CONOUT(OEMTOANSI(FWTIMESTAMP(2)+" * * * | operations Taxa: "+CVALTOCHAR(NTAXA)))
                    CHISTORI := SE2->E2_HIST
                    CBCOORI := SE2->E2_FORBCO
                    CAGEORI := SE2->E2_FORAGE
                    CDVAGORI := SE2->E2_FAGEDV
                    CCTAORI := SE2->E2_FORCTA
                    CDVCTORI := SE2->E2_FCTADV
                    CFORMORI := SE2->E2_FORMPAG
                    
                    
                    NDECRORI := 0
                    NDECRESC := NDECRORI+NTAXA
                    
                    NVALLIQ := NVALLIQ-NTAXA
                    CONOUT(OEMTOANSI(FWTIMESTAMP(2)+" * * * | operations Valor Liquido - Taxa: "+CVALTOCHAR(NVALLIQ)))
                    
                    (SA2)->(dbselectarea("SA2"))
                    (SA2)->(DBSETORDER(1))
                    ; if (SA2)->(DBSEEK(FWXFILIAL("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA))
                        LRETURN :=  .T. 
                        CMESSAGE := "Fornecedor localizado -> Codigo: "+SA2->A2_COD+" - Loja: "+SA2->A2_LOJA
                        CONOUT(OEMTOANSI(FWTIMESTAMP(2)+" * * * | operations Fornecedor localizado -> Codigo: "+SA2->A2_COD+" - Loja: "+SA2->A2_LOJA))
                    else 
                        LRETURN :=  .F. 
                        NHTTPCODE := 500
                        CMESSAGE := "Fornecedor nao localizado -> CNPJ: "+ alltrim(OOBJJSON:OPERATIONS[NI]:BUYERGOVERNMENTID)
                        CONOUT(OEMTOANSI(FWTIMESTAMP(2)+" * * * | operations Fornecedor nao localizado -> (SE2: Codigo: "+SE2->E2_FORNECE+" - Loja: "+SE2->E2_LOJA+") CNPJ: "+ alltrim(OOBJJSON:OPERATIONS[NI]:BUYERGOVERNMENTID)))
                    endif
                else 
                    
                    CONOUT(OEMTOANSI(FWTIMESTAMP(2)+" * * * | operations Caixa Terceiro Buyer "))
                    LCXPROP :=  .F. 
                    CHISTORI := SE2->E2_HIST
                    DVENCORI := SE2->E2_VENCTO
                    NDECRORI := 0
                    NDECRESC := 0
                    
                    (SA2)->(dbselectarea("SA2"))
                    (SA2)->(DBSETORDER(3))
                    ; if (SA2)->(DBSEEK(FWXFILIAL("SA2")+ alltrim(OOBJJSON:OPERATIONS[NI]:BUYERGOVERNMENTID)))
                        LRETURN :=  .T. 
                        CMESSAGE := "Fornecedor localizado -> Codigo: "+SA2->A2_COD+" - Loja: "+SA2->A2_LOJA
                        CONOUT(OEMTOANSI(FWTIMESTAMP(2)+" * * * | operations Fornecedor localizado -> Codigo: "+SA2->A2_COD+" - Loja: "+SA2->A2_LOJA))
                    else 
                        LRETURN :=  .F. 
                        NHTTPCODE := 500
                        CMESSAGE := "Fornecedor nao localizado -> CNPJ: "+ alltrim(OOBJJSON:OPERATIONS[NI]:BUYERGOVERNMENTID)
                        CONOUT(OEMTOANSI(FWTIMESTAMP(2)+" * * * | operations Fornecedor nao localizado -> CNPJ: "+ alltrim(OOBJJSON:OPERATIONS[NI]:BUYERGOVERNMENTID)))
                    endif
                endif
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                ; if LRETURN
                    
                    ; if SE2->E2_SALDO==0
                        
                        LRETURN :=  .T. 
                        NHTTPCODE := 201
                        CMESSAGE := "Titulo ja baixado anteriormente"
                        CONOUT(OEMTOANSI(FWTIMESTAMP(2)+" * * * | operations Titulo ja baixado anteriormente"))
                        FWLOGMSG("INFO",,"MONKEY","operations","003","101","Titulo ja baixado anteriormente",0,0,{})
                    else 
                        
                        
                        
                        CONOUT(OEMTOANSI(FWTIMESTAMP(2)+" * * * | operations Gravacao SEA"))
                        (SEA)->(dbselectarea("SEA"))
                        (SEA)->(DBSETORDER(1))
                        ; if (SEA)->(DBSEEK(FWXFILIAL("SEA")+SE2->E2_NUMBOR+"P"+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA))
                            ; if RECLOCK("SEA", .F. )
                                (SEA)->(DBDELETE())
                                (SE2)->(MSUNLOCK())
                            else 
                                CONOUT(OEMTOANSI(FWTIMESTAMP(2)+" * * * | operations Nao foi possivel reservar registro - SEA"))
                                FWLOGMSG("ERROR",,"MONKEY","operations","004","501","Nao foi possivel reservar registro - SEA",0,0,{})
                            endif
                        endif
                        
                        CONOUT(OEMTOANSI(FWTIMESTAMP(2)+" * * * | operations Gravacao SE2"))
                        ; if RECLOCK("SE2", .F. )
                            SE2->E2_PORTADO := CPORTORI
                            SE2->E2_NUMBOR := SPACE(TAMSX3("E2_NUMBOR")[1])
                            SE2->E2_DTBORDE := CTOD("")
                            SE2->E2_XMNKSTA := "2"
                            (SE2)->(MSUNLOCK())
                        else 
                            CONOUT(OEMTOANSI(FWTIMESTAMP(2)+" * * * | operations Nao foi possivel reservar registro - SE2"))
                            FWLOGMSG("ERROR",,"MONKEY","operations","005","501","Nao foi possivel reservar registro - SE2",0,0,{})
                        endif
                        
                        
                        NRECNOSA2 := (SA2)->(RECNO())
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        AADD(ATITULOS,{SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO, .F. })
                        
                        NTAM := TAMSX3("E2_NUM")[1]
                        CNUMFATURA := SOMA1(GETMV("MV_NUMFATP"))
                        CNUMFATURA := PADR(CNUMFATURA,NTAM)
                        
                        
                        
                        
                        GETMV("MV_NUMFATP")
                        RECLOCK("SX6", .F. )
                        SX6->X6_CONTEUD := CNUMFATURA
                        (SX6)->(MSUNLOCK())
                        
                        CONOUT(OEMTOANSI(FWTIMESTAMP(2)+" * * * | operations Numero da Fatura: "+CNUMFATURA))
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        AFATURA := {CFATPREFIXO,CTIPOFAT,CNUMFATURA,SE2->E2_NATUREZ,SE2->E2_EMISSAO,SE2->E2_EMISSAO,SE2->E2_FORNECE,SE2->E2_LOJA,SA2->A2_COD,SA2->A2_LOJA,CCONDPAG,SE2->E2_MOEDA,ATITULOS,NDECRESC,NACRESC}
                        
                        LMSERROAUTO :=  .F. 
                        
                        (SA2)->(DBSETORDER(1))
                        (SE2)->(DBSETORDER(1))
                        (SEA)->(DBSETORDER(1))
                        
                        
                        PERGUNTE("AFI290", .F. )
                        __BKMV01 := MV_PAR01
                        __BKMV02 := MV_PAR02
                        
                        
                        MV_PAR01 := 2
                        MV_PAR02 := 2
                        
                        ; if LFATCUSTOM
                            CONOUT(OEMTOANSI(FWTIMESTAMP(2)+" * * * | operations (U) FINA290 Inicio"))
                            MSEXECAUTO({|X,Y|U_MY290FI(X,Y)},3,AFATURA, .T. )
                            CONOUT(OEMTOANSI(FWTIMESTAMP(2)+" * * * | operations (U) FINA290 Fim"))
                        else 
                            CONOUT(OEMTOANSI(FWTIMESTAMP(2)+" * * * | operations FINA290 Inicio"))
                            MSEXECAUTO({|X,Y|FINA290(X,Y)},3,AFATURA,)
                            CONOUT(OEMTOANSI(FWTIMESTAMP(2)+" * * * | operations FINA290 Fim"))
                        endif
                        
                        ; if LMSERROAUTO
                            
                            CONOUT(OEMTOANSI(FWTIMESTAMP(2)+" * * * | Erro na rotina de geracao de fatura"))
                            CERRO := ARRAYTOSTR(GETAUTOGRLOG())
                            CONOUT(OEMTOANSI(FWTIMESTAMP(2)+" * * * | operations Erro FINA290 "+CERRO))
                            FWLOGMSG("ERROR",,"MONKEY","operations","006","502","Erro na rotina de geracao de fatura",0,0,{})
                        endif
                        
                        
                        AAREASE2 := (SE2)->(GETAREA())
                        (SE2)->(dbselectarea("SE2"))
                        (SE2)->(DBSETORDER(1))
                        ; if (SE2)->(MSSEEK(FWXFILIAL("SE2")+CFATPREFIXO+CNUMFATURA))
                            LFATEXISTS :=  .T. 
                        else 
                            LFATEXISTS :=  .F. 
                        endif
                        RESTAREA(AAREASE2)
                        
                        ; if .not. (LFATEXISTS)
                            
                            LRETURN :=  .F. 
                            NHTTPCODE := 500
                            CMESSAGE := "Processamento nao gerou fatura"
                        else 
                            
                            
                            
                            CONOUT(OEMTOANSI(FWTIMESTAMP(2)+" * * * | operations FINA290 OK"))
                            LRETURN :=  .T. 
                            
                            CONOUT(OEMTOANSI(FWTIMESTAMP(2)+" * * * | operations Fornecedor: "+SE2->E2_FORBCO))
                            
                            
                            CONOUT(OEMTOANSI(FWTIMESTAMP(2)+" * * * | verificacao final fatura"))
                            CONOUT(OEMTOANSI(FWTIMESTAMP(2)+" * * * | E2_PREFIXO = "+CFATPREFIXO))
                            CONOUT(OEMTOANSI(FWTIMESTAMP(2)+" * * * | E2_TIPO    = "+CTIPOFAT))
                            CONOUT(OEMTOANSI(FWTIMESTAMP(2)+" * * * | E2_NUM     = "+CNUMFATURA))
                            CONOUT(OEMTOANSI(FWTIMESTAMP(2)+" * * * | E2_FILIAL  = "+FWXFILIAL("SE2")))
                            
                            CCONFIRMQUERY += "SELECT se2_fat.R_E_C_N_O_ e2fat_recno "+CHR(13)+CHR(10)
                            CCONFIRMQUERY += "  FROM "+RETSQLNAME("SE2")+"  se2_fat "+CHR(13)+CHR(10)
                            CCONFIRMQUERY += "      ,"+RETSQLNAME("SE2")+"  se2 "+CHR(13)+CHR(10)
                            CCONFIRMQUERY += " WHERE se2.e2_filial        = se2_fat.e2_filial "+CHR(13)+CHR(10)
                            CCONFIRMQUERY += "   AND se2.e2_fatura        = se2_fat.e2_num "+CHR(13)+CHR(10)
                            CCONFIRMQUERY += "   AND se2.e2_fatpref       = se2_fat.e2_prefixo "+CHR(13)+CHR(10)
                            CCONFIRMQUERY += "   AND se2.e2_dtfatur       = se2_fat.e2_emissao "+CHR(13)+CHR(10)
                            CCONFIRMQUERY += "   AND se2_fat.e2_prefixo   = '"+CFATPREFIXO+"' "+CHR(13)+CHR(10)
                            CCONFIRMQUERY += "   AND se2_fat.e2_tipo      = '"+CTIPOFAT+"' "+CHR(13)+CHR(10)
                            CCONFIRMQUERY += "   AND se2_fat.e2_num   	  = '"+CNUMFATURA+"' "+CHR(13)+CHR(10)
                            CCONFIRMQUERY += "   AND se2_fat.e2_filial    = '"+FWXFILIAL("SE2")+"' "+CHR(13)+CHR(10)
                            
                            CCONFIRMALIAS := GETNEXTALIAS()
                            
                            DBUSEAREA( .T. ,"TOPCONN",TCGENQRY(CCONFIRMQUERY),CCONFIRMALIAS, .F. , .T. )
                            
                            NCONFIRMCOUNT := 0; DBEVAL(NCONFIRMCOUNT := NCONFIRMCOUNT+1} .F. )
                            
                            CONOUT(OEMTOANSI(FWTIMESTAMP(2)+" * * * | verificacao final fatura, qtd = "+CVALTOCHAR(NCONFIRMCOUNT)))
                            
                            ; if NCONFIRMCOUNT>0
                                
                                
                                (SA2)->(dbselectarea("SA2"))
                                (SA2)->(DBSETORDER(1))
                                (SA2)->(DBGOTO(NRECNOSA2))
                                
                                (SE2)->(dbselectarea("SE2"))
                                (SE2)->(DBSETORDER(1))
                                (SE2)->(DBSEEK(FWXFILIAL("SE2")+CFATPREFIXO+CNUMFATURA))
                                
                                ;while .not. ((SE2)->(EOF())) .and. SE2->E2_FILIAL==FWXFILIAL("SE2") .and. SE2->E2_PREFIXO==CFATPREFIXO .and. SE2->E2_NUM==CNUMFATURA; 
                                    
                                    ; if RECLOCK("SE2", .F. )
                                        CONOUT(OEMTOANSI(FWTIMESTAMP(2)+" * * * | operations Gravacao de campos especificos - SE2"))
                                        ; if LLIBPAG
                                            SE2->E2_DATALIB := DDATABASE
                                        endif
                                        ; if LCXPROP
                                            CONOUT(OEMTOANSI(FWTIMESTAMP(2)+" * * * | operations Caixa Proprio"))
                                            SE2->E2_FORBCO := CBCOORI
                                            SE2->E2_FORAGE := CAGEORI
                                            SE2->E2_FAGEDV := CDVAGORI
                                            SE2->E2_FORCTA := CCTAORI
                                            SE2->E2_FCTADV := CDVCTORI
                                        else 
                                            CONOUT(OEMTOANSI(FWTIMESTAMP(2)+" * * * | operations Caixa Terceiro"))
                                            SE2->E2_VENCTO := DVENCORI
                                            SE2->E2_VENCREA := DATAVALIDA(DVENCORI, .T. )
                                            SE2->E2_FORBCO := SA2->A2_BANCO
                                            SE2->E2_FORAGE := SA2->A2_AGENCIA
                                            SE2->E2_FAGEDV := SA2->A2_DVAGE
                                            SE2->E2_FORCTA := SA2->A2_NUMCON
                                            SE2->E2_FCTADV := SA2->A2_DVCTA
                                        endif
                                        ; if (SE2)->(FIELDPOS("E2_XRISCOS"))>0
                                            SE2->E2_XRISCOS := "S"
                                        endif
                                        ; if (SE2)->(FIELDPOS("E2_XANALIS"))>0
                                            SE2->E2_XANALIS := "S"
                                        endif
                                        ; if (SE2)->(FIELDPOS("E2_XAGEPOR"))>0
                                            SE2->E2_XAGEPOR := CAGEPAG
                                        endif
                                        ; if (SE2)->(FIELDPOS("E2_XDVAPOR"))>0
                                            SE2->E2_XDVAPOR := CDVAGPAG
                                        endif
                                        ; if (SE2)->(FIELDPOS("E2_XCONPOR"))>0
                                            SE2->E2_XCONPOR := CCTAPAG
                                        endif
                                        ; if (SE2)->(FIELDPOS("E2_XDVCPOR"))>0
                                            SE2->E2_XDVCPOR := CDVCTPAG
                                        endif
                                        ; if (SE2)->(FIELDPOS("E2_XVLBRUT"))>0
                                            SE2->E2_XVLBRUT := NVALBRU
                                        endif
                                        ; if (SE2)->(FIELDPOS("E2_XVLLIQ"))>0
                                            SE2->E2_XVLLIQ := NVALLIQ
                                        endif
                                        
                                        
                                        
                                        
                                        
                                        
                                        SE2->E2_BASEIRF := NBSIRFORI
                                        SE2->E2_BASEINS := NBSINSORI
                                        SE2->E2_BASEISS := NBSISSORI
                                        SE2->E2_IRRF := NVLIRFORI
                                        SE2->E2_INSS := NVLINSORI
                                        SE2->E2_ISS := NVLISSORI
                                        
                                        
                                        SE2->E2_BASEPIS := 0
                                        SE2->E2_BASECOF := 0
                                        SE2->E2_BASECSL := 0
                                        SE2->E2_PIS := 0
                                        SE2->E2_COFINS := 0
                                        SE2->E2_CSLL := 0
                                        
                                        
                                        
                                        SE2->E2_JUROS := NVLJURORI
                                        SE2->E2_MULTA := NVLMULORI
                                        SE2->E2_DESCONT := NVLDESORI
                                        SE2->E2_HIST := CHISTORI
                                        SE2->E2_PORTADO := CPORTORI
                                        
                                        
                                        SE2->E2_VALOR := SE2->E2_VALOR-NVALPCC
                                        SE2->E2_SALDO := SE2->E2_SALDO-NVALPCC
                                        SE2->E2_VLCRUZ := SE2->E2_VLCRUZ-NVALPCC
                                        
                                        (SE2)->(MSUNLOCK())
                                    else 
                                        
                                        
                                        CONOUT(OEMTOANSI(FWTIMESTAMP(2)+" * * * | operations Nao foi possivel reservar registro - SE2 (1)"))
                                        FWLOGMSG("ERROR",,"MONKEY","operations","007","501","Nao foi possivel reservar registro - SE2 (1)",0,0,{})
                                    endif
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                    CONOUT(OEMTOANSI(FWTIMESTAMP(2)+" * * * | operations Banco Fornecedor: "+SE2->E2_FORBCO))
                                    
                                    
                                    ; if (SE2->E2_XPORTAD==SE2->E2_FORBCO) .or. (SE2->E2_PORTADO==SE2->E2_FORBCO)
                                        CFORMPG := "01"
                                    else 
                                        CFORMPG := "41"
                                    endif
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                    ; if RECLOCK("SE2", .F. )
                                        CONOUT(OEMTOANSI(FWTIMESTAMP(2)+" * * * | operations Gravacao da forma de pagamento - SE2"))
                                        SE2->E2_FORMPAG := CFORMPG
                                        (SE2)->(MSUNLOCK())
                                    else 
                                        
                                        
                                        CONOUT(OEMTOANSI(FWTIMESTAMP(2)+" * * * | operations Nao foi possivel reservar registro - SE2 (2)"))
                                        FWLOGMSG("ERROR",,"MONKEY","operations","007","501","Nao foi possivel reservar registro - SE2 (2)",0,0,{})
                                    endif
                                    
                                    
                                    (SE2)->(DBSKIP()); end
                                
                                
                                
                                LRETURN :=  .T. 
                                NHTTPCODE := 201
                                CMESSAGE := "Operacoes realizadas com sucesso"
                            else 
                                
                                
                                LRETURN :=  .F. 
                                NHTTPCODE := 400
                                CMESSAGE := "Verificacao final de criacao de fatura nao encontrou registros"
                            endif
                        endif
                        
                        
                        
                        
                        MV_PAR01 := __BKMV01
                        MV_PAR02 := __BKMV02
                    endif
                endif
                
                
                
                
                ; case  alltrim( upper(OOBJJSON:OPERATIONS[NI]:EVENTTYPE))=="DELETED"
                
                CONOUT(OEMTOANSI(FWTIMESTAMP(2)+" * * * | operations DELETED "))
                
                ; if (SE2->E2_XMNKSTA) $ ("1|5")
                    
                    
                    (SEA)->(dbselectarea("SEA"))
                    (SEA)->(DBSETORDER(1))
                    ; if (SEA)->(DBSEEK(FWXFILIAL("SEA")+SE2->E2_NUMBOR+"P"+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA))
                        ; if RECLOCK("SEA", .F. )
                            (SEA)->(DBDELETE())
                            (SEA)->(MSUNLOCK())
                        else 
                            LRETURN :=  .F. 
                            NHTTPCODE := 423
                            CMESSAGE := "DELETED - Nao foi possivel reservar registro - SEA"
                            CONOUT(OEMTOANSI(FWTIMESTAMP(2)+" * * * | operations DELETED - Nao foi possivel reservar registro - SEA"))
                            FWLOGMSG("ERROR",,"MONKEY","operations","008","501","DELETED - Nao foi possivel reservar registro - SEA",0,0,{})
                        endif
                    endif
                    
                    ; if RECLOCK("SE2", .F. )
                        ; if (SE2)->(FIELDPOS("E2_XPORTAD"))>0
                            SE2->E2_PORTADO := SE2->E2_XPORTAD
                        else 
                            SE2->E2_PORTADO := SPACE(TAMSX3("E2_PORTADO")[1])
                        endif
                        SE2->E2_NUMBOR := SPACE(TAMSX3("E2_NUMBOR")[1])
                        SE2->E2_DTBORDE := CTOD("")
                        
                        ; if SE2->E2_XMNKSTA=="1"
                            SE2->E2_XMNKSTA := SPACE(TAMSX3("E2_XMNKSTA")[1])
                            SE2->E2_XMNKLOT := SPACE(TAMSX3("E2_XMNKLOT")[1])
                        endif
                        (SE2)->(MSUNLOCK())
                    else 
                        LRETURN :=  .F. 
                        NHTTPCODE := 423
                        CMESSAGE := "DELETED - Nao foi possivel reservar registro - SE2"
                        CONOUT(OEMTOANSI(FWTIMESTAMP(2)+" * * * | operations DELETED - Nao foi possivel reservar registro - SE2"))
                        FWLOGMSG("ERROR",,"MONKEY","operations","009","501","DELETED - Nao foi possivel reservar registro - SE2",0,0,{})
                    endif
                else 
                    
                    
                    LRETURN :=  .F. 
                    NHTTPCODE := 425
                    CMESSAGE := "DELETED - Nao foi recebida a confirmacao deste registro"
                    CONOUT(OEMTOANSI(FWTIMESTAMP(2)+" * * * | operations DELETED - Nao foi recebida a confirmacao deste registro"))
                    FWLOGMSG("ERROR",,"MONKEY","operations","011","502","DELETED - Nao foi recebida a confirmacao deste registro",0,0,{})
                endif
                
                
                ; case  alltrim( upper(OOBJJSON:OPERATIONS[NI]:EVENTTYPE))=="DUPLICATED"
                
                CONOUT(OEMTOANSI(FWTIMESTAMP(2)+" * * * | operations DUPLICATED "))
                
                
                ; case  alltrim( upper(OOBJJSON:OPERATIONS[NI]:EVENTTYPE))=="REFUSED"
                
                CONOUT(OEMTOANSI(FWTIMESTAMP(2)+" * * * | operations REFUSED "))
                otherwise
                
                
                
                
                
                
                LRETURN :=  .F. 
                NHTTPCODE := 500
                CMESSAGE := "Operacao invalida: "+ alltrim( upper(OOBJJSON:OPERATIONS[NI]:EVENTTYPE))
                FWLOGMSG("ERROR",,"MONKEY","operations","011","502","Operacao invalida",0,0,{})
                endcase
            next
            
            
            
            CRESPONSE := "{ "
            CRESPONSE += '"operations": '+CVALTOCHAR( len(OOBJJSON:OPERATIONS))
            CRESPONSE += "} "
        else 
            
            
            LRETURN :=  .F. 
            NHTTPCODE := 500
            CMESSAGE := "Erro na funcao FWJSONDeserialize"
            FWLOGMSG("ERROR",,"MONKEY","operations","012","500","Erro na funcao FWJSONDeserialize",0,0,{})
        endif
    endif
    
    
    
    CONOUT(OEMTOANSI(FWTIMESTAMP(2)+" * * * | operations: "+CMESSAGE))
endif


if .not. (LRETURN)
    SETRESTFAULT(NHTTPCODE,ENCODEUTF8(CMESSAGE))
    ::SETRESPONSE(CRESPONSE)
else 
    ::SETRESPONSE(CRESPONSE)
endif

MEMOWRITE(CLOGDIR+CLOGARQ+"_response.json",CRESPONSE)

CONOUT(OEMTOANSI(FWTIMESTAMP(2)+" * * * | operations Fim"))
FWLOGMSG("INFO",,"MONKEY","operations","999","999","Fim do Processo",0,0,{})

return LRETURN
