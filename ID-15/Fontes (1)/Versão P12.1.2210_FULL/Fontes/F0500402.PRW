static LTRANSF :=  .F. , LOUTROS :=  .F. , LTURNO :=  .F. , ATPSSOL := {NIL,NIL,NIL,NIL,NIL}, CFILNOVA := CFILANT
















function U_F0500402(OMODEL)

local CFILSOL := OMODEL:GETMODEL("RH3MASTER"):GETVALUE("RH3_FILIAL")
local CNUMSOL := OMODEL:GETMODEL("RH3MASTER"):GETVALUE("RH3_CODIGO")
local DDTASOL := OMODEL:GETMODEL("RH3MASTER"):GETVALUE("RH3_DTSOLI")
local CMATFUN := OMODEL:GETMODEL("RH3MASTER"):GETVALUE("RH3_MAT")
local CVISAOA := OMODEL:GETMODEL("RH3MASTER"):GETVALUE("RH3_VISAO")
local ACPOS := {}
local CTIPOATU := ""
local LVLDT :=  .T. 
local CBLQSLTF := ""
local LEXETRANS :=  .F. 
private DM1DT
private LINTTAF := SUPERGETMV("MV_RHTAF",, .F. )== .T.  .and.  val(SUPERGETMV("MV_FASESOC",," "))>=1
private LTPDESL := LINTTAF .and. X3USADO("RE_DESL")

private OGAUGE2
private CCONDEPT :=  .F. 
private CCONPROC :=  .F. 
private CCONPOSTO :=  .F. 
private LGPEA180FLT :=  .F. 



if CFILNOVA<>CFILANT
    CFILNOVA := CFILANT
endif


DM1DT := PEGAM1DT(CFILSOL,CNUMSOL)
dbselectarea("RH4")
(RH4)->(DBSETORDER(1))
if (RH4)->(DBSEEK(CFILSOL+CNUMSOL))

    ;while CFILSOL+CNUMSOL==(RH4)->(RH4_FILIAL+RH4_CODIGO); 

        ; if ("TMP_TIPO") $ (RH4->RH4_CAMPO) .and. CTIPOATU<>RH4->RH4_VALNOV

            ; if .not. (EMPTY(CTIPOATU))
                ACUSOLI( alltrim(CTIPOATU),@ACPOS)
            endif

            CTIPOATU := RH4->RH4_VALNOV
        endif


        ; if ("RA_") $ (RH4->RH4_CAMPO)
            AADD(ACPOS,{RH4->RH4_CAMPO,RH4->RH4_VALNOV})
        endif

        (RH4)->(DBSKIP()); end


    ACUSOLI( alltrim(CTIPOATU),@ACPOS)



    ; if LVLDT := VLDTRANSF(ATPSSOL[1]) .and. VALPOSTO(CFILSOL,CNUMSOL)

        LEXETRANS := LTRANSF .and. (LVLDT := iif(FINDFUNCTION("APMsgNoYes"),APMSGNOYES("Confirma a Transferência?"+CHR(13)+CHR(10)+CHR(13)+CHR(10)+"ATENÇÃO: Após a confirmação NÃO SERÁ POSSÍVEL DESFAZER ESSA OPERAÇÃO!",),(CMSGNOYES := "MsgNoYes", &CMSGNOYES.("Confirma a Transferência?"+CHR(13)+CHR(10)+CHR(13)+CHR(10)+"ATENÇÃO: Após a confirmação NÃO SERÁ POSSÍVEL DESFAZER ESSA OPERAÇÃO!",)))); 

            BEGINTRAN()

            ; if LEXETRANS
                FWMSGRUN(,{||LVLDT := ATTRANSF(OMODEL,ATPSSOL[1],CFILSOL,CMATFUN,DDTASOL)},"Processando...","Atualizando para a transferência. Aguarde!")
            endif

            ; if LVLDT .and. LOUTROS

                ; if ATPSSOL[2]<>NIL .and.  len(ATPSSOL[2])>0

                    LSOTUR := VERSOTUR(CFILSOL,CNUMSOL)
                    FWMSGRUN(,{||LVLDT := ATTURHOR(ATPSSOL[2],CFILSOL,CMATFUN,DDTASOL,ATPSSOL[5],DM1DT,LSOTUR,LEXETRANS)},"Processando...","Atualizando Carga Horária/Turno de trabalho. Aguarde!")
                endif

                ; if LVLDT .and. ATPSSOL[3]<>NIL .and.  len(ATPSSOL[3])>0
                    FWMSGRUN(,{||LVLDT := ATCARGO(ATPSSOL[3],CFILSOL,CMATFUN,DDTASOL,DM1DT)},"Processando...","Atualizando Cargo. Aguarde!")
                endif

                ; if LVLDT .and. ATPSSOL[4]<>NIL .and.  len(ATPSSOL[4])>0 .and. LTRANSF .and.  alltrim(GETMV("FS_BLQSLTF"))=="S"
                    LVLDT :=  .F. 
                endif

                ; if LVLDT .and. ATPSSOL[4]<>NIL .and.  len(ATPSSOL[4])>0
                    FWMSGRUN(,{||LVLDT := ATSALARI(ATPSSOL[4],CFILSOL,CMATFUN,DDTASOL,DM1DT,CTIPOATU)},"Processando...","Atualizando Salário. Aguarde!")
                endif

                ; if LEXETRANS



                    RECLOCK("SRE", .F. )
                    RE_DATA := DM1DT
                    MSUNLOCK()
                endif
            endif







            ; if LVLDT
                dbselectarea("RH3")
                (RH3)->(DBSETORDER(1))
                ; if (RH3)->(DBSEEK(CFILSOL+CNUMSOL))
                    RECLOCK("RH3", .F. )
                    RH3->RH3_STATUS := "2"
                    RH3->RH3_DTATEN := DDATABASE
                    RH3->RH3_XDTAPV := DATE()

                    (RH3)->(MSUNLOCK())
                endif
            endif

            ENDTRAN()
    endif
endif



if LVLDT


    U_F0500407(CFILSOL,CMATFUN,CNUMSOL,CVISAOA)




    AVISO("SUCESSO - EFETIVAÇÃO","A solicitação foi efetuada com sucesso. ",{"OK"},1)
else 


    AVISO("NÃO EFETIVADA - EFETIVAÇÃO","A solicitação não foi efetuada. ",{"OK"},1)
endif


LTRANSF :=  .F. 
LOUTROS :=  .F. 
ATPSSOL := {NIL,NIL,NIL,NIL,NIL}
CFILNOVA := CFILANT

return LVLDT










static function ACUSOLI(CTIPOATU,ACPOS)


if CTIPOATU=="5"
    
    ATPSSOL[1] := ACPOS
    ACPOS := {}
    LTRANSF :=  .T. 

elseif (CTIPOATU) $ ("4")
    
    ATPSSOL[2] := ACPOS
    ACPOS := {}
    LOUTROS :=  .T. 
    LTURNO :=  .T. 

elseif (CTIPOATU) $ ("3")
    
    ATPSSOL[5] := ACPOS
    ACPOS := {}
    LOUTROS :=  .T. 
    LTURNO :=  .T. 

elseif CTIPOATU=="2"
    
    ATPSSOL[3] := ACPOS
    ACPOS := {}
    LOUTROS :=  .T. 

elseif CTIPOATU=="1"
    
    ATPSSOL[4] := ACPOS
    ACPOS := {}
    LOUTROS :=  .T. 
endif

return 












static function VLDTAPROV(LVLDT,DDTASOL)

local LCONTIN :=  .F. 
local CDIASOL := DAY(DDTASOL)
local CMESSOL := MONTH(DDTASOL)
local CDIAATU := DAY(DDATABASE)
local CMESATU := MONTH(DDATABASE)
local DDTTUR := CTOD("16/"+ strzero(MONTH(DDATABASE),2)+"/"+STR(YEAR(DDATABASE)))
local DDATAATU := MSDATE()
local DMESBASE
































































static function ATSALARI(ACPOS,CFILFUN,CMATFUN,DDTASOL,DM1SAL,CTIPOATU)

local AAREASRA := (SRA)->(GETAREA())
local NSALANT := 0
local LATUSAL :=  .T. 
local NPERTOL := 0
local CTABNOV := ""
local CTABNIV := ""
local CTABFXA := ""
local AFAIXA := {}
local NX := 0
local NSALTRAN := 0


if CFILNOVA<>CFILANT
    CFILFUN := CFILNOVA
endif



(SRA)->(DBSETORDER(1))
if (SRA)->(DBSEEK(CFILFUN+CMATFUN))

    NSALANT := SRA->RA_SALARIO

    (RCA)->(DBSETORDER(1))
    ; if (RCA)->(DBSEEK(FWXFILIAL("RCA")+"M_PERCTOL"))
        NPERTOL :=  val(RCA->RCA_CONTEU)
    endif

    NSALTRAN :=  val(STRTRAN(STRTRAN( alltrim(ACPOS[1][2]),".",""),",","."))

    (SQ3)->(DBSETORDER(1))
    ; if (SQ3)->(DBSEEK(FWXFILIAL("SQ3")+SRA->RA_CODFUNC))
        AFAIXA := BSCFXSAL(SRA->RA_CODFUNC,CFILFUN,,,SRA->RA_HRSMES)
        ; if  len(AFAIXA)>=3
            ; if NSALTRAN<=AFAIXA[1][3]+(AFAIXA[1][3]) * ((NPERTOL) / (100))
                CTABFXA := "01"
            elseif NSALTRAN>AFAIXA[1][3]+(AFAIXA[1][3]) * ((NPERTOL) / (100)) .and. NSALTRAN<=AFAIXA[2][3]+(AFAIXA[2][3]) * ((NPERTOL) / (100))
                CTABFXA := "02"
            else 
                CTABFXA := "03"
            endif
            CTABNOV := SQ3->Q3_TABELA
            CTABNIV := SQ3->Q3_TABNIVE
        else 
            CTABNOV := SQ3->Q3_TABELA
            CTABNIV := SQ3->Q3_TABNIVE
            CTABFXA := SRA->RA_TABFAIX
        endif
    else 
        CTABNOV := SRA->RA_TABELA
        CTABNIV := SRA->RA_TABNIVE
        CTABFXA := SRA->RA_TABFAIX
    endif

    (SRA)->(RECLOCK("SRA", .F. ))
    SRA->RA_SALARIO :=  val(STRTRAN(STRTRAN( alltrim(ACPOS[1][2]),".",""),",","."))
    SRA->RA_ANTEAUM :=  val(STRTRAN(STRTRAN( alltrim(ACPOS[1][2]),".",""),",","."))
    SRA->RA_TABELA := CTABNOV
    SRA->RA_TABNIVE := CTABNIV
    SRA->RA_TABFAIX := CTABFXA

    (SRA)->(MSUNLOCK())

    ; if SRA->RA_SALARIO==NSALANT
        HELP("",1,"Help","Atualização Salarial(AtSalari_01)","Não foi possível efetuar a atualização salarial. Efetue manualmente!",3,0)
    else 

        GRVSR3R7(ACPOS,CFILFUN,CMATFUN,DDTASOL,DM1SAL)
    endif
endif


RESTAREA(AAREASRA)

return LATUSAL










static function ATCARGO(ACPOS,CFILFUN,CMATFUN,DDTASOL,DM1CAR)

local AAREASRA := (SRA)->(GETAREA())
local AAREATN0 := (TN0)->(GETAREA())
local LALTCARG :=  .F. 
local DDTATU := iif(DDTASOL<>NIL,DDTASOL,MSDATE())
local CANOMES1 := ""
local CCODFUNC :=  alltrim(ACPOS[1][2])
local NPERTOL := 0
local CTABNOV := ""
local CTABNIV := ""
local CTABFXA := ""
local AFAIXA := {}
local NX := 0
local NSALTRAN := 0

if DAY(DDTATU)<=20
    CANOMES1 := SOMAMESANO(DDTATU)
else 
    CANOMES1 := SOMAMESANO(DDTATU)
    CANOMES1 := SOMAMESANO(CANOMES1)
endif

DDTATU := STOD( alltrim(CANOMES1)+"01")


if CFILNOVA<>CFILANT
    CFILFUN := CFILNOVA
endif

dbselectarea("SRA")
(SRA)->(DBSETORDER(1))
if (SRA)->(DBSEEK(CFILFUN+CMATFUN))
    
    (RCA)->(DBSETORDER(1))
    ; if (RCA)->(DBSEEK(FWXFILIAL("RCA")+"M_PERCTOL"))
        NPERTOL :=  val(RCA->RCA_CONTEU)
    endif
    
    NSALTRAN := SRA->RA_SALARIO
    
    (SQ3)->(DBSETORDER(1))
    ; if (SQ3)->(DBSEEK(FWXFILIAL("SQ3")+CCODFUNC))
        AFAIXA := BSCFXSAL(CCODFUNC,CFILFUN,,,SRA->RA_HRSMES)
        ; if  len(AFAIXA)>=3
            ; if NSALTRAN<=AFAIXA[1][3]+(AFAIXA[1][3]) * ((NPERTOL) / (100))
                CTABFXA := "01"
            elseif NSALTRAN>AFAIXA[1][3]+(AFAIXA[1][3]) * ((NPERTOL) / (100)) .and. NSALTRAN<=AFAIXA[2][3]+(AFAIXA[2][3]) * ((NPERTOL) / (100))
                CTABFXA := "02"
            else 
                CTABFXA := "03"
            endif
            CTABNOV := SQ3->Q3_TABELA
            CTABNIV := SQ3->Q3_TABNIVE
        else 
            CTABNOV := SQ3->Q3_TABELA
            CTABNIV := SQ3->Q3_TABNIVE
            CTABFXA := SRA->RA_TABFAIX
        endif
    else 
        CTABNOV := SRA->RA_TABELA
        CTABNIV := SRA->RA_TABNIVE
        CTABFXA := SRA->RA_TABFAIX
    endif
    DDTOPER := DATE()
    CHROPER := TIME()
    (SRA)->(RECLOCK("SRA", .F. ))
    SRA->RA_CARGO :=  alltrim(ACPOS[1][2])
    SRA->RA_CODFUNC :=  alltrim(ACPOS[1][2])
    SRA->RA_TABELA := CTABNOV
    SRA->RA_TABNIVE := CTABNIV
    SRA->RA_TABFAIX := CTABFXA
    (TN0)->(DBSETORDER(5))
    ; if ((TN0)->(DBSEEK(SRA->RA_FILIAL+SRA->RA_CC+SRA->RA_CODFUNC))) .or. ((TN0)->(DBSEEK(SRA->RA_FILIAL+"*          "+SRA->RA_CODFUNC)))
        MDT180INT(SRA->RA_MAT,TN0->TN0_NUMRIS, .F. ,4,SRA->RA_FILIAL)
    else 
        MDT180INT(SRA->RA_MAT,"", .T. ,4,SRA->RA_FILIAL)
    endif
    
    ; if SRA->RA_HRSMES>0
        ; if .not. (SRA->RA_HRSMES==SRA->RA_PERICUL) .and. SRA->RA_ADCPERI=="2"
            SRA->RA_PERICUL := SRA->RA_HRSMES
        endif
        ; if .not. (SRA->RA_HRSMES==SRA->RA_INSMAX) .and. SRA->RA_ADCINS=="2"
            SRA->RA_INSMAX := SRA->RA_HRSMES
        endif
    endif
    (SRA)->(MSUNLOCK())
    
    
    ; if LALTCARG :=  alltrim(ACPOS[1][2])==SRA->RA_CARGO .and.  alltrim(ACPOS[1][2])==SRA->RA_CODFUNC
        
        
        ; if ATPSSOL[4]==NIL
            
            
            GRVSR3R7(ACPOS,CFILFUN,CMATFUN,DDTASOL,DM1CAR)
            
            
            
            GRVSR9B(CFILFUN,CMATFUN,DDTATU,"RA_CARGO", alltrim(ACPOS[1][2]),DDTOPER,CHROPER,DM1CAR)
        endif
        
        
        LALTCARG :=  .T. 
    endif
else 
    HELP("",1,"Help","INSUCESSO - Cargo(AtCargo_01)","Não foi localizado o funcionário "+CMATFUN+" na filial de destino "+CFILFUN+". Os campos cargo/função não foram atualizados!",3,0)
    LALTCARG :=  .F. 
endif

RESTAREA(AAREASRA)
RESTAREA(AAREATN0)
return LALTCARG








static function GRVSR3R7(ACPOS,CFILFUN,CMATFUN,DDTASOL,DGRR3R7)

local CSEQ := ""
local DDTATU := iif(DDTASOL<>NIL,DDTASOL,MSDATE())
local CANOMES1 := ""
local DDTOPER
local CHROPER








if DAY(DDTATU)<=20
    CANOMES1 := SOMAMESANO(DDTATU)
else 
    CANOMES1 := SOMAMESANO(DDTATU)
    CANOMES1 := SOMAMESANO(CANOMES1)
endif

DDTATU := STOD( alltrim(CANOMES1)+"01")

dbselectarea("SR3")
(SR3)->(DBSETORDER(1))
if (SR3)->(DBSEEK(CFILFUN+CMATFUN+DTOS(DDTATU)+ alltrim(ACPOS[2][2])))

    ;while CFILFUN+CMATFUN+DTOS(DDTATU)+ alltrim(ACPOS[2][2])==(SR3)->(R3_FILIAL+R3_MAT+DTOS(R3_DATA)+R3_TIPO); 

        CSEQ := SR3->R3_SEQ

        (SR3)->(DBSKIP()); end
endif



DDTOPER := DATE()
CHROPER := TIME()

(SR3)->(RECLOCK("SR3", .T. ))
SR3->R3_FILIAL := CFILFUN
SR3->R3_MAT := CMATFUN
SR3->R3_DATA := DGRR3R7
SR3->R3_SEQ :=  strzero( val(CSEQ)+1,1)
SR3->R3_PD := "000"
SR3->R3_DESCPD := "SALARIO BASE"
SR3->R3_VALOR := SRA->RA_SALARIO
SR3->R3_TIPO :=  alltrim(ACPOS[2][2])
SR3->R3_ANTEAUM := SRA->RA_SALARIO

SR3->R3_TABELA := SRA->RA_TABELA
SR3->R3_TABFAIX := SRA->RA_TABFAIX
SR3->R3_TABNIVE := SRA->RA_TABNIVE
SR3->R3_XDTOPER := DDTOPER
SR3->R3_XHROPER := CHROPER
SR3->R3_XINTINC := " "
SR3->R3_XIDINC := "                                "

(SR3)->(MSUNLOCK())

if (ISINCALLSTACK("AtSalari")) ; ; endif












dbselectarea("SR7")
(SR7)->(DBSETORDER(1))
if (SR7)->(DBSEEK(CFILFUN+CMATFUN+DTOS(DDTATU)+ alltrim(ACPOS[2][2])))

    ;while CFILFUN+CMATFUN+DTOS(DDTATU)+ alltrim(ACPOS[2][2])==(SR7)->(R7_FILIAL+R7_MAT+DTOS(R7_DATA)+R7_TIPO); 

        CSEQ := SR7->R7_SEQ

        (SR7)->(DBSKIP()); end
endif



dbselectarea("SR7")
if (SR7)->(RECLOCK("SR7", .T. ))
    SR7->R7_FILIAL := CFILFUN
    SR7->R7_MAT := CMATFUN
    SR7->R7_DATA := DGRR3R7
    SR7->R7_TIPO :=  alltrim(ACPOS[2][2])
    SR7->R7_FUNCAO := SRA->RA_CODFUNC
    SR7->R7_DESCFUN := POSICIONE("SRJ",1,XFILIAL("SRJ")+SRA->RA_CODFUNC,"RJ_DESC")
    SR7->R7_TIPOPGT := SRA->RA_TIPOPGT
    SR7->R7_CATFUNC := SRA->RA_CATFUNC
    SR7->R7_USUARIO :=  alltrim(CUSERNAME)+"|"+ alltrim(LOGUSERNAME())
    ; if (SR7)->(TYPE("R7_CARGO"))<>"U"
        SR7->R7_CARGO := SRA->RA_CARGO
    endif
    ; if (SR7)->(TYPE("R7_DESCCAR"))<>"U"
        SR7->R7_DESCCAR := POSICIONE("SQ3",1,XFILIAL("SQ3")+SRA->RA_CARGO,"Q3_DESCSUM")
    endif
    SR7->R7_SEQ :=  strzero( val(CSEQ)+1,1)

    SR7->R7_XDTOPER := DDTOPER
    SR7->R7_XHROPER := CHROPER
    SR7->R7_XINTINC := " "
    SR7->R7_XIDINC := "                                "

    (SR7)->(MSUNLOCK())
endif










return 









static function ATTURHOR(ACPOS,CFILFUN,CMATFUN,DDTASOL,ACPCARG,DM1TH,LTUROK,LONTRF)

local AAREASRA := (SRA)->(GETAREA())
local AAREASPF := {}
local CTURNANT := ""
local CTSEQANT := ""
local CREGRANT := ""
local ICPOSRA := 0
local ICPOCG := 0
local LATUTURN :=  .T. 
local NPOSCPO := 0
local DDTATU := iif(DDTASOL<>NIL,DDTASOL,MSDATE())
local CANOMES1 := ""
local CDESCTUR := ""
local NPOSHR := 0
local NPOSTRN := 0
local DDTOPER
local CHROPER
local DDTTUR

local LINCLUISPF :=  .F. 

ACPOS := iif(ACPOS==NIL,{},ACPOS)
CFILFUN := iif(CFILFUN==NIL,"",CFILFUN)
CMATFUN := iif(CMATFUN==NIL,"",CMATFUN)
DDTASOL := iif(DDTASOL==NIL,CTOD("//"),DDTASOL)
ACPCARG := iif(ACPCARG==NIL,{},ACPCARG)









if YEAR(DDTATU)<YEAR(DDATABASE)
    ; if MONTH(DDTATU)<MONTH(DDATABASE)+12
        DDTTUR := DAYSUM(FIRSTDATE(DDATABASE),15)
    elseif MONTH(DDTATU)==MONTH(DDATABASE)
        ; if DAY(DDTATU)<=15
            DDTTUR := DAYSUM(FIRSTDATE(DDATABASE),15)
        else 
            DDTTUR := DAYSUM(FIRSTDATE(MONTHSUM(DDATABASE,1)),15)
        endif
    endif
else 

    ; if MONTH(DDTATU)<MONTH(DDATABASE)
        DDTTUR := DAYSUM(FIRSTDATE(DDATABASE),15)
    elseif MONTH(DDTATU)==MONTH(DDATABASE)
        ; if DAY(DDTATU)<=15
            DDTTUR := DAYSUM(FIRSTDATE(DDATABASE),15)
        else 
            DDTTUR := DAYSUM(FIRSTDATE(MONTHSUM(DDATABASE,1)),15)
        endif
    endif
endif





















if LONTRF

    ; if CFILNOVA<>CFILANT
        CFILFUN := CFILNOVA
    endif
endif


dbselectarea("SRA")
(SRA)->(DBSETORDER(1))
if (SRA)->(DBSEEK(CFILFUN+CMATFUN))

    CTURNANT := SRA->RA_TNOTRAB
    CTSEQANT := SRA->RA_SEQTURN
    CREGRANT := SRA->RA_REGRA

    (SRA)->(RECLOCK("SRA", .F. ))

    for ICPOSRA := 1 to ( len(ACPOS)) step 1

        ; if POSICIONE("SX3",2, alltrim(ACPOS[ICPOSRA][1]),"X3_TIPO")=="N"
            &(ACPOS[ICPOSRA][1]) := GETDTOVAL(ACPOS[ICPOSRA][2])
        else 
            &(ACPOS[ICPOSRA][1]) := ACPOS[ICPOSRA][2]
        endif
    next


    for ICPOCG := 1 to ( len(ACPCARG)) step 1
        ; if POSICIONE("SX3",2, alltrim(ACPCARG[ICPOCG][1]),"X3_TIPO")=="N"
            &(ACPCARG[ICPOCG][1]) := GETDTOVAL(ACPCARG[ICPOCG][2])

            ; if  alltrim(SRA->RA_ADCPERI)=="2"
                SRA->RA_PERICUL :=  val( alltrim(ACPCARG[1][2]))
            elseif  alltrim(SRA->RA_ADCPERI)=="1"
                SRA->RA_PERICUL := 0
            endif
        else 

            &(ACPCARG[ICPOCG][1]) := ACPCARG[ICPOCG][2]

            ; if  alltrim(SRA->RA_ADCPERI)=="2"
                SRA->RA_PERICUL :=  alltrim(ACPCARG[1][2])
            elseif  alltrim(SRA->RA_ADCPERI)=="1"
                SRA->RA_PERICUL := 0
            endif
        endif
    next


    (SRA)->(MSUNLOCK())


    ; if LTUROK
        DTURCH := DDTTUR
    else 
        DTURCH := DM1TH
    endif


    AAREASPF := (SPF)->(GETAREA())

    dbselectarea("SPF")
    (SPF)->(DBSETORDER(1))

    LINCLUISPF := .not. ((SPF)->(DBSEEK(CFILFUN+CMATFUN+DTOS(DTURCH))))

    ; if (SPF)->(RECLOCK("SPF",LINCLUISPF))
        DDTOPER := DATE()
        CHROPER := TIME()
        SPF->PF_FILIAL := CFILFUN
        SPF->PF_MAT := CMATFUN
        SPF->PF_DATA := DTURCH
        SPF->PF_TURNODE := CTURNANT
        SPF->PF_SEQUEDE := CTSEQANT
        SPF->PF_REGRADE := CREGRANT
        SPF->PF_TURNOPA := iif((NPOSCPO := ASCAN(ACPOS,{|X,Y| alltrim(X[1])=="RA_TNOTRAB"}))>0, alltrim(ACPOS[NPOSCPO][2]),CTURNANT)
        SPF->PF_SEQUEPA := iif((NPOSCPO := ASCAN(ACPOS,{|X,Y| alltrim(X[1])=="RA_SEQTURN"}))>0, alltrim(ACPOS[NPOSCPO][2]),CTSEQANT)
        SPF->PF_REGRAPA := iif((NPOSCPO := ASCAN(ACPOS,{|X,Y| alltrim(X[1])=="RA_REGRA"}))>0, alltrim(ACPOS[NPOSCPO][2]),CREGRANT)
        SPF->PF_XDTOPER := DDTOPER
        SPF->PF_XHROPER := CHROPER
        SPF->PF_XINTINC := " "
        SPF->PF_XIDINC := "                                "

        (SPF)->(MSUNLOCK())
    endif










    RESTAREA(AAREASPF)

    NPOSTRN := ASCAN(ACPOS,{|X,Y| alltrim(X[1])=="RA_TNOTRAB"})
    ; if NPOSTRN>0
        CDESCTUR := POSICIONE("SR6",1,XFILIAL("SR6")+ alltrim(ACPOS[NPOSTRN][2]),"R6_DESC")
        GRVSR9B(CFILFUN,CMATFUN,DDTTUR,"RA_TNOTRAB",CDESCTUR,DDTOPER,CHROPER,DTURCH)
    endif

    NPOSHR := ASCAN(ACPCARG,{|X,Y| alltrim(X[1])=="RA_HRSMES"})
    ; if NPOSHR>0
        GRVSR9B(CFILFUN,CMATFUN,DDTATU,"RA_HRSMES", alltrim(ACPCARG[NPOSHR][2]),DDTOPER,CHROPER,DTURCH)
    endif
endif


RESTAREA(AAREASRA)

return LATUTURN














static function GRVSR9B(CFILFUN,CMATFUN,DDTREAL,CCPOALT,CCNTALT,DDTOPSR9,CHROPER,DM1SR9)

local AAREAATU := (SR9)->(GETAREA())
DDTOPSR9 := iif(DDTOPSR9==NIL,CTOD("  /  /    "),DDTOPSR9)
CHROPER := iif(CHROPER==NIL," ",CHROPER)


dbselectarea("SR9")
if (SR9)->(RECLOCK("SR9", .T. ))
    SR9->R9_FILIAL := CFILFUN
    SR9->R9_MAT := CMATFUN
    SR9->R9_DATA := DM1SR9
    SR9->R9_CAMPO := CCPOALT
    SR9->R9_DESC := CCNTALT
    SR9->R9_XDTOPER := DDTOPSR9
    SR9->R9_XHROPER := CHROPER
    SR9->R9_XINTINC := " "
    SR9->R9_XIDINC := "                                "
    (SR9)->(MSUNLOCK())
endif









RESTAREA(AAREAATU)

return 









static function VLDTRANSF(ACPOS)

local LRET :=  .T. 
local NSCAN := 0
local NTAMFIL :=  len(CFILANT)
local CMSGERRO := ""
local AAREAATU := {}

if LTRANSF

    NSCAN := ASCAN(ACPOS,{|X| alltrim(X[1])=="RA_FILIAL"})
    ; if NSCAN>0

        CFILP := PADR(ACPOS[NSCAN][2],NTAMFIL)
        CFILNOVA := CFILP


        ; if .not. (EMPTY( alltrim(XFILIAL("SQB"))))
            NSCAN := ASCAN(ACPOS,{|X| alltrim(X[1])=="RA_DEPTO"})
            ; if NSCAN>0
                CDEPTOP :=  alltrim(ACPOS[NSCAN][2])

                AAREAATU := (SQB)->(GETAREA())


                dbselectarea("SQB")
                (SQB)->(DBSETORDER(1))
                ; if .not. ((SQB)->(DBSEEK(CFILP+CDEPTOP)))
                    CMSGERRO += "Depto: "+ alltrim(CDEPTOP)+" nâo existe na filial de destino: "+CFILP+"."+CHR(13)+CHR(10)
                endif

                RESTAREA(AAREAATU)
            endif
        endif


        ; if .not. (EMPTY( alltrim(XFILIAL("CTT"))))
            NSCAN := ASCAN(ACPOS,{|X| alltrim(X[1])=="RA_CC"})
            ; if NSCAN>0
                CCCP := ACPOS[NSCAN][2]


                AAREAATU := (CTT)->(GETAREA())

                dbselectarea("CTT")
                (CTT)->(DBSETORDER(1))
                ; if .not. ((CTT)->(DBSEEK(CFILP+CCCP)))
                    CMSGERRO += "C. Custo: "+ alltrim(CCCP)+" nâo existe na filial de destino: "+CFILP+"."+CHR(13)+CHR(10)
                endif

                RESTAREA(AAREAATU)
            endif
        endif


        ; if .not. (EMPTY( alltrim(XFILIAL("RCJ"))))
            NSCAN := ASCAN(ACPOS,{|X| alltrim(X[1])=="RA_PROCES"})
            ; if NSCAN>0
                CPROCP := ACPOS[NSCAN][2]


                AAREAATU := (RCJ)->(GETAREA())

                dbselectarea("RCJ")
                (RCJ)->(DBSETORDER(1))
                ; if .not. ((RCJ)->(DBSEEK(CFILP+CPROCP)))
                    CMSGERRO += "Processo: "+ alltrim(CPROCP)+" nâo existe na filial de destino: "+CFILP+"."+CHR(13)+CHR(10)
                endif

                RESTAREA(AAREAATU)
            endif
        endif



        ; if .not. (EMPTY( alltrim(XFILIAL("SRJ"))))
            NSCAN := ASCAN(ACPOS,{|X| alltrim(X[1])=="RA_CODFUNC"})
            ; if NSCAN>0
                CFUNCP := ACPOS[NSCAN][2]

                AAREAATU := (SRJ)->(GETAREA())

                dbselectarea("SRJ")
                (SRJ)->(DBSETORDER(1))
                ; if .not. ((SRJ)->(DBSEEK(CFILP+CFUNCP)))
                    CMSGERRO += "Função: "+ alltrim(CFUNCP)+" nâo existe na filial de destino: "+CFILP+"."+CHR(13)+CHR(10)
                endif

                RESTAREA(AAREAATU)
            endif
        endif





        ; if .not. (EMPTY(CMSGERRO))
            AVISO("Atenção",CMSGERRO,{"ok"},2)
            LRET :=  .F. 
        endif
    endif
endif

return LRET










static function ATTRANSF(OMODEL,ACPOS,CFILFUN,CMATFUN,DDTASOL)

local LRET :=  .F. 
local DDTATU := MSDATE()
local DDTAREF
private LLOTE :=  .F. 
















DDTAREF := FIRSTDATE(DDTATU)

dbselectarea("SRA")
(SRA)->(DBSETORDER(1))
if (SRA)->(DBSEEK(CFILFUN+CMATFUN))
    LRET := TCFA040ATENDE(OMODEL,"2",DM1DT)
else 
    LRET :=  .F. 
endif

return LRET











static function TCFA040ATENDE(OMODEL,CSTATUS,DDTATU)

local OMODRH3 := OMODEL:GETMODEL("RH3MASTER")
local LRET :=  .F. 
local NI := 0
local DM1TRF
local CSRAFILORI := ""
local CSRAPOSORI := ""
local CREFILDES := ""
local CREPOSDES := ""
local CSRAMATF := ""
private CCADASTRO := ""
private CTIPSOLICPORTAL := ""
private CFILFUN := ""
private CMATFUN := ""
private DFERDTINI := CTOD("")
private DFERDTFIM := CTOD("")
private NFERDURACAO := 0
private CCODSOLIC := OMODRH3:GETVALUE("RH3_CODIGO")
private ACPOSPORTAL := {}
private BPARAMPORTAL := {|| .T. }
private LUSESPJ := iif(CPAISLOC=="BRA", .T. ,SUPERGETMV("MV_USESPJ",NIL,"0")=="1")
private CRH3COD := ""


private ACPOSRA := {}
private LMSERROAUTO :=  .F. 
private LMSHELPAUTO :=  .T. 
private LAUTOERRNOFILE :=  .T. 


private LINCSRA :=  .T. 
private LINITDESC
private LHABABA :=  .F. 
private CORGCFG := SUPERGETMV("MV_ORGCFG",NIL,"0")
private CGSPUBL := SUPERGETMV("MV_GSPUBL",,"1")
private CCONTRMAT := SUPERGETMV("MV_MATRICU",NIL,"0")
private LCTRAUTOMAT :=  .F. 

if CGSPUBL=="2" .and. GETMV("MV_VDFLOGO",,"0")<>"0"
    CGSPUBL := "3"
endif


private CCODTRASFPORTAL := OMODRH3:GETVALUE("RH3_CODIGO")


private CITEMCLVL := SUPERGETMV("MV_ITMCLVL", .F. ,"2")
private LITEMCLVL := (SUPERGETMV("MV_ITMCLVL", .F. ,"2")) $ ("13")
private ALOGTRANSF := {}
private ATRANSFCOLS := {}
private ATRANSF1COLS := {}

private ANEWINDEXSRA := {}
private BNEWFILTROBRW := {||NIL}
private CMARKTRANSF := GETMARK()
private CRAOKTRANSSPC := SPACE(TAMSX3("RA_OKTRANS")[1])
private LABORTPRINT :=  .F. 

private LGERADEM :=  .T. 
private DDATATRA := DDTATU
private LROBO :=  .F. 
private DDATATAF := DDTATU

CCADASTRO := OEMTOANSI("TransferË†ncias")
CTIPSOLICPORTAL := "4"

dbselectarea("SRA")
(SRA)->(DBSETORDER(RETORDER("SRA","RA_FILIAL + RA_MAT")))

if (SRA)->(DBSEEK(RH3->RH3_FILIAL+RH3->RH3_MAT))

    CSRAFILORI := SRA->RA_FILIAL
    CSRAPOSORI := SRA->RA_POSTO
    CSRAMATF := SRA->RA_MAT; 

        BEGINTRAN()

        RECLOCK("SRA", .F. )
        SRA->RA_OKTRANS := CMARKTRANSF
        (SRA)->(MSUNLOCK())

        ENDTRAN()

    (RH4)->(DBSEEK((RH3)->(RH3_FILIAL+RH3_CODIGO)))


    M->RE_EMPP := CEMPANT
    M->RE_FILIALP := ""
    M->RE_MATP := ""
    M->RE_DEPTOP := ""
    M->RE_PROCESP := ""
    M->RE_CCP := ""
    M->RA_DESCCC := ""
    M->RE_POSTOP := ""
    M->RE_DATA := DDTATU

    ;while .not. ((RH4)->(EOF())) .and. (RH4)->(RH4_FILIAL+RH4_CODIGO)==(RH3)->(RH3_FILIAL+RH3_CODIGO); 
        ; if  alltrim(RH4->RH4_CAMPO)=="RE_EMPP"
            M->RE_EMPP := LEFT(RH4->RH4_VALNOV, len(SRE->RE_EMPP))
        elseif ( alltrim(RH4->RH4_CAMPO)=="RE_FILIALP") .or. ( alltrim(RH4->RH4_CAMPO)=="RA_FILIAL")
            M->RE_FILIALP := LEFT(RH4->RH4_VALNOV, len(SRA->RA_FILIAL))
        elseif ( alltrim(RH4->RH4_CAMPO)=="RE_MATP") .or. ( alltrim(RH4->RH4_CAMPO)=="RA_MAT")
            M->RE_MATP := LEFT(RH4->RH4_VALNOV, len(SRE->RE_MATP))
        elseif ( alltrim(RH4->RH4_CAMPO)=="RE_DEPTOP") .or. ( alltrim(RH4->RH4_CAMPO)=="RA_DEPTO")
            M->RE_DEPTOP := LEFT(RH4->RH4_VALNOV, len(SRE->RE_DEPTOP))
        elseif ( alltrim(RH4->RH4_CAMPO)=="RE_CCP") .or. ( alltrim(RH4->RH4_CAMPO)=="RA_CC")
            M->RE_CCP := LEFT(RH4->RH4_VALNOV, len(SRE->RE_CCP))
            M->RA_DESCCC := FDESC("CTT",LEFT(RH4->RH4_VALNOV, len(SRA->RA_CC)),"CTT_DESC01",,)
        elseif ( alltrim(RH4->RH4_CAMPO)=="RE_PROCESP") .or. ( alltrim(RH4->RH4_CAMPO)=="RA_PROCES")
            M->RE_PROCESP := LEFT(RH4->RH4_VALNOV, len(SRE->RE_PROCESP))
        elseif ( alltrim(RH4->RH4_CAMPO)=="RE_POSTOP") .or. ( alltrim(RH4->RH4_CAMPO)=="RA_POSTO")
            M->RE_POSTOP := LEFT(RH4->RH4_VALNOV, len(SRE->RE_POSTOP))
        elseif ( alltrim(RH4->RH4_CAMPO)=="RE_ITEMP") .or. ( alltrim(RH4->RH4_CAMPO)=="RA_ITEM")
            M->RE_ITEMP := LEFT(RH4->RH4_VALNOV, len(SRE->RE_ITEMP))
        elseif ( alltrim(RH4->RH4_CAMPO)=="RE_CLVLP") .or. ( alltrim(RH4->RH4_CAMPO)=="RA_CLVL")
            M->RE_CLVLP := LEFT(RH4->RH4_VALNOV, len(SRE->RE_CLVLP))
        endif
        (RH4)->(DBSKIP()); end


    OBRWAUX := GETMBROWSE()
    OFILAUX := OBRWAUX:FWFILTER()
    CSRAFILTER := OFILAUX:GETEXPRSQL()


    ABKPFILTER := OBRWAUX:OFWFILTER:AFILTER
    OBRWAUX:OFWFILTER:AFILTER := {}

    SETFUNNAME("GPEA180")
    LRET := GPEA180MAT("RH3",(RH3)->(RECNO()),2)==1
    SETFUNNAME("F050030S")

    OBRWAUX:OFWFILTER:AFILTER := ABKPFILTER
endif



CREFILDES := M->RE_FILIALP
CREPOSDES := M->RE_POSTOP




U_AMSTRFPOST(CSRAMATF,CSRAFILORI,CSRAPOSORI,CREFILDES,CREPOSDES)


return LRET









static function VALPOSTO(CFILSOL,CCODSOL)

local CDEPTO := ""
local CFILAT := ""
local CCCAT := ""
local CCODCARG := ""
local CQRY := ""
local NQTDEPOST := 0
local NPOSCPO := 0
local CTABATU := ""
local LVALPOSTO :=  .T. 
local AAREASRA := (SRA)->(GETAREA())
local LLIBPST := SUPERGETMV("FS_BLQSOL",, .F. )




if ATPSSOL[1]<>NIL


    ; if (NPOSCPO := ASCAN(ATPSSOL[1],{|X| alltrim(X[1])=="RA_FILIAL"}))>0
        CFILAT :=  alltrim(ATPSSOL[1][1][NPOSCPO+1])
    endif


    ; if (NPOSCPO := ASCAN(ATPSSOL[1],{|X| alltrim(X[1])=="RA_CC"}))>0
        CCCAT :=  alltrim(ATPSSOL[1][NPOSCPO][2])
    endif


    ; if (NPOSCPO := ASCAN(ATPSSOL[1],{|X| alltrim(X[1])=="RA_DEPTO"}))>0
        CDEPTO :=  alltrim(ATPSSOL[1][NPOSCPO][2])
    endif
endif



if ATPSSOL[3]<>NIL

    ; if (NPOSCPO := ASCAN(ATPSSOL[3],{|X| alltrim(X[1])=="RA_CODFUNC"}))>0
        CCODCARG :=  alltrim(ATPSSOL[3][NPOSCPO][2])
    endif
endif















































































RESTAREA(AAREASRA)

return LVALPOSTO








static function BSCFXSAL(CCODVG,CFILP,CFLSOLSQS,CCDSOLSQS,CHRMES)

local CQUERY := ""
local CALIRB6 := "INFRB6"
local AAUX := {}

CFLSOLSQS := iif(CFLSOLSQS==NIL,"",CFLSOLSQS)
CCDSOLSQS := iif(CCDSOLSQS==NIL,"",CCDSOLSQS)
CHRMES := iif(CHRMES==NIL,0,CHRMES)

CFILRB6 := U_F0600402(CFILP,"RB6")
CFILSQ3 := U_F0600402(CFILP,"SQ3")





CQUERY := "SELECT RB6.RB6_VALOR,RB6.RB6_FAIXA,RB6.RB6_NIVEL FROM "+RETSQLNAME("RBR")+" RBR "
CQUERY += "INNER JOIN "+RETSQLNAME("RB6")+" RB6 "
CQUERY += "ON RB6.RB6_FILIAL = '"+CFILRB6+"' AND "
CQUERY += "RB6.RB6_TABELA     IN (SELECT Q3_TABELA FROM "+RETSQLNAME("SQ3")+" "
CQUERY += "				WHERE  Q3_FILIAL = '"+CFILSQ3+"' AND Q3_CARGO = '"+CCODVG+"' AND D_E_L_E_T_ = ' ') "
CQUERY += "AND RB6.RB6_NIVEL  IN (SELECT Q3_TABNIVE FROM "+RETSQLNAME("SQ3")+" "
CQUERY += "				WHERE  Q3_FILIAL = '"+CFILSQ3+"' AND Q3_CARGO = '"+CCODVG+"' AND D_E_L_E_T_ = ' ') "
CQUERY += "AND RB6.RB6_DTREF = RBR.RBR_DTREF "
CQUERY += "AND RB6.D_E_L_E_T_ = ' '  "
CQUERY += "WHERE RBR.RBR_FILIAL = '"+CFILRB6+"' "
CQUERY += "AND RBR.RBR_TABELA IN (SELECT Q3_TABELA FROM "+RETSQLNAME("SQ3")+" WHERE  Q3_FILIAL = '"+CFILSQ3+"' AND Q3_CARGO = '"+CCODVG+"' AND D_E_L_E_T_ = ' ') "
CQUERY += "AND RBR.RBR_APLIC = '1' "
CQUERY += "AND RBR.D_E_L_E_T_ = ' ' "
CQUERY += "ORDER BY RB6.RB6_NIVEL, RB6.RB6_FAIXA "



CQUERY := CHANGEQUERY(CQUERY)
DBUSEAREA( .T. ,"TOPCONN",TCGENQRY(CQUERY),CALIRB6)

dbselectarea(CALIRB6)
while .not. ((CALIRB6)->(EOF())); 
    AADD(AAUX,{CALIRB6->RB6_NIVEL,CALIRB6->RB6_FAIXA,((CALIRB6->RB6_VALOR) * (CHRMES)) / (220)})
    (CALIRB6)->(DBSKIP()); end

(CALIRB6)->(DBCLOSEAREA())

return AAUX







static function PEGAM1DT(CFILM1,CSOLM1)

local DDTAPROV
local CALI := ""

local DDTATRA



CALI := " SELECT MAX(PA5_XDATA) AS PA5_XDATA "
CALI += " FROM "+RETSQLNAME("PA5")+" PA5 "
CALI += " WHERE PA5.D_E_L_E_T_ = ' ' "

CALI += " AND UPPER(TRIM(PA5.PA5_XSTAT)) = 'APROVADO SOLICITAÇÃO' "
CALI += " AND PA5_XNRSOL = '"+CSOLM1+"' "
CALI += " AND PA5_FILIAL = '"+CFILM1+"' "


if SELECT("PA5DT")>0
    (PA5DT)->(DBCLOSEAREA())
endif

CALI := CHANGEQUERY(CALI)
DBUSEAREA( .T. ,"TOPCONN",TCGENQRY(CALI),"PA5DT")



NTEMXDT := 0
while (PA5DT)->(.not. (EOF())); 
    NTEMXDT += 1
    DM1PA5DT := PA5DT->PA5_XDATA
    (PA5DT)->(DBSKIP()); end



if (NTEMXDT==0) .or. (EMPTY(DM1PA5DT))
    DDTAPROV := DDATABASE
else 
    DDTAPROV := STOD(DM1PA5DT)
endif

DDTATRA := FIRSTDATE(MONTHSUM(DDTAPROV,1))

return DDTATRA








static function VERSOTUR(CFILTUR,CSOLTUR)


local CALITUR := ""
local LSOTUR :=  .F. 

CALITUR := " SELECT * "
CALITUR += " FROM "+RETSQLNAME("RH4")+" RH4 "
CALITUR += " WHERE RH4.D_E_L_E_T_ = ' ' "
CALITUR += " AND RH4_CODIGO = '"+CSOLTUR+"' "
CALITUR += " AND RH4_FILIAL = '"+CFILTUR+"' "

if SELECT("RH4TUR")>0
    (RH4TUR)->(DBCLOSEAREA())
endif

CALITUR := CHANGEQUERY(CALITUR)
DBUSEAREA( .T. ,"TOPCONN",TCGENQRY(CALITUR),"RH4TUR")



NTEMTUR := 0
NTEMOUT := 0
while (RH4TUR)->(.not. (EOF())); 
    ; if  alltrim(RH4TUR->RH4_CAMPO)=="TMP_TIPO" .and.  alltrim(RH4TUR->RH4_VALNOV)=="4"
        NTEMTUR += 1
    elseif  alltrim(RH4TUR->RH4_CAMPO)=="TMP_TIPO" .and.  alltrim(RH4TUR->RH4_VALNOV)<>"4"
        NTEMOUT += 1
    endif
    (RH4TUR)->(DBSKIP()); end


if NTEMTUR==1 .and. NTEMOUT==0
    LSOTUR :=  .T. 
elseif NTEMTUR==1 .and. NTEMOUT>0
    LSOTUR :=  .F. 
endif
return LSOTUR
