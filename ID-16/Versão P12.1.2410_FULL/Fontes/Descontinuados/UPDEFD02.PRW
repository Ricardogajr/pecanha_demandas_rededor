




























function U_UPDEFD02(CEMPAMB,CFILAMB)
local ASAY := {}
local ABUTTON := {}
local AMARCADAS := {}
local CTITULO := "ATUALIZAÇÃO DE DICIONÁRIOS E TABELAS"
local CDESC1 := "Esta rotina tem como função fazer  a atualização  dos dicionários do Sistema ( SX?/SIX )"
local CDESC2 := "Este processo deve ser executado em modo EXCLUSIVO, ou seja não podem haver outros"
local CDESC3 := "usuários  ou  jobs utilizando  o sistema.  É EXTREMAMENTE recomendavél  que  se  faça"
local CDESC4 := "um BACKUP  dos DICIONÁRIOS  e da  BASE DE DADOS antes desta atualização, para"
local CDESC5 := "que caso ocorram eventuais falhas, esse backup possa ser restaurado."
local CDESC6 := ""
local CDESC7 := ""
local CMSG := ""
local LOK :=  .F. 
local LAUTO := (CEMPAMB<>NIL) .or. (CFILAMB<>NIL)

private OMAINWND := NIL
private OPROCESS := NIL


TCINTERNAL(5,"*OFF")


__CINTERNET := NIL
__LPYME :=  .F. 

SET(11,"ON")


AADD(ASAY,CDESC1)
AADD(ASAY,CDESC2)
AADD(ASAY,CDESC3)
AADD(ASAY,CDESC4)
AADD(ASAY,CDESC5)




AADD(ABUTTON,{1, .T. ,{||LOK :=  .T. ,FECHABATCH()}})
AADD(ABUTTON,{2, .T. ,{||LOK :=  .F. ,FECHABATCH()}})

if LAUTO
    LOK :=  .T. 
else 
    FORMBATCH(CTITULO,ASAY,ABUTTON)
endif

if LOK

    ; if (GETVERSAO( .F. )<"12") .or. (FINDFUNCTION("MPDicInDB") .and. .not. (MPDICINDB()))


        CMSG := "Este update NÃO PODE ser executado neste Ambiente."+CHR(13)+CHR(10)+CHR(13)+CHR(10)+"Os arquivos de dicionários se encontram em formato ISAM"+" ("+GETDBEXTENSION()+") "+"Os arquivos de dicionários se encontram em formato ISAM"+" "+"para atualizar apenas ambientes com dicionários no Banco de Dados."

        ; if LAUTO
            AUTOGRLOG("--------------------------------------------------------------------------------------------------------------------------------")
            AUTOGRLOG("                                                                                                                                ")
            AUTOGRLOG("LOG DA ATUALIZAÇÃO DOS DICIONÁRIOS")
            AUTOGRLOG("                                                                                                                                ")
            AUTOGRLOG("--------------------------------------------------------------------------------------------------------------------------------")
            AUTOGRLOG("                                                                                                                                ")
            AUTOGRLOG(CMSG)
            CONOUT(DTOC(DATE())+"|"+TIME()+CMSG)
        else 
            iif(FINDFUNCTION("APMsgInfo"),APMSGINFO(CMSG,),MSGINFO(CMSG,))
        endif

        return NIL
    endif

    ; if LAUTO
        AMARCADAS := {{CEMPAMB,CFILAMB,""}}
    else 
        AMARCADAS := ESCEMPRESA()
    endif

    ; if .not. (EMPTY(AMARCADAS))
        ; if (LAUTO) .or. (iif(FINDFUNCTION("APMsgNoYes"),APMSGNOYES("Confirma a atualização dos dicionários ?",CTITULO),(CMSGNOYES := "MsgNoYes", &CMSGNOYES.("Confirma a atualização dos dicionários ?",CTITULO))))
            OPROCESS := MSNEWPROCESS():NEW({ | LEND |LOK := FSTPROC(@LEND,AMARCADAS,LAUTO)},"Atualizando","Aguarde, atualizando ...", .F. )
            OPROCESS:ACTIVATE()

            ; if LAUTO
                ; if LOK
                    iif(FINDFUNCTION("APMsgStop"),APMSGSTOP("Atualização realizada.","UPDEFD02"),MSGSTOP("Atualização realizada.","UPDEFD02"))
                else 
                    iif(FINDFUNCTION("APMsgStop"),APMSGSTOP("Atualização não realizada.","UPDEFD02"),MSGSTOP("Atualização não realizada.","UPDEFD02"))
                endif
                DBCLOSEALL()
            else 
                ; if LOK
                    FINAL("Atualização realizada.")
                else 
                    FINAL("Atualização não realizada.")
                endif
            endif
        else 

            FINAL("Atualização não realizada.")
        endif
    else 


        FINAL("Atualização não realizada.")
    endif
endif



return NIL













static function FSTPROC(LEND,AMARCADAS,LAUTO)
local AINFO := {}
local ARECNOSM0 := {}
local CAUX := ""
local CFILE := ""
local CFILELOG := ""
local CMASK := "Arquivos Texto"+"(*.TXT)|*.txt|"
local CTCBUILD := "TCGetBuild"
local CTEXTO := ""
local CTOPBUILD := ""
local LOPEN :=  .F. 
local LRET :=  .T. 
local NI := 0
local NPOS := 0
local NRECNO := 0
local NX := 0
local ODLG := NIL
local OFONT := NIL
local OMEMO := NIL

private AARQUPD := {}

if LOPEN := MYOPENSM0( .T. )

    dbselectarea("SM0")
    DBGOTOP()

    ;while .not. ((SM0)->(EOF())); 


        ; if ASCAN(ARECNOSM0,{ |X|X[2]==SM0->M0_CODIGO})==0 .and. ASCAN(AMARCADAS,{ |X|X[1]==SM0->M0_CODIGO})>0
            AADD(ARECNOSM0,{RECNO(),SM0->M0_CODIGO})
        endif
        (SM0)->(DBSKIP()); end


    (SM0)->(DBCLOSEAREA())

    ; if LOPEN

        for NI := 1 to ( len(ARECNOSM0)) step 1

            ; if .not. (LOPEN := MYOPENSM0( .F. ))
                iif(FINDFUNCTION("APMsgStop"),APMSGSTOP("Atualização da empresa "+ARECNOSM0[NI][2]+" não efetuada.",),MSGSTOP("Atualização da empresa "+ARECNOSM0[NI][2]+" não efetuada.",))
                exit 
            endif

            (SM0)->(DBGOTO(ARECNOSM0[NI][1]))

            RPCSETENV(SM0->M0_CODIGO,SM0->M0_CODFIL)

            LMSFINALAUTO :=  .F. 
            LMSHELPAUTO :=  .F. 

            AUTOGRLOG("--------------------------------------------------------------------------------------------------------------------------------")
            AUTOGRLOG("                                                                                                                                ")
            AUTOGRLOG("LOG DA ATUALIZAÇÃO DOS DICIONÁRIOS")
            AUTOGRLOG("                                                                                                                                ")
            AUTOGRLOG("--------------------------------------------------------------------------------------------------------------------------------")
            AUTOGRLOG(" ")
            AUTOGRLOG(" Dados Ambiente")
            AUTOGRLOG(" --------------------")
            AUTOGRLOG(" Empresa / Filial...: "+CEMPANT+"/"+CFILANT)
            AUTOGRLOG(" Nome Empresa.......: "+CAPITAL( alltrim(GETADVFVAL("SM0","M0_NOMECOM",CEMPANT+CFILANT,1,""))))
            AUTOGRLOG(" Nome Filial........: "+CAPITAL( alltrim(GETADVFVAL("SM0","M0_FILIAL",CEMPANT+CFILANT,1,""))))
            AUTOGRLOG(" DataBase...........: "+DTOC(DDATABASE))
            AUTOGRLOG(" Data / Hora Ínicio.: "+DTOC(DATE())+" / "+TIME())
            AUTOGRLOG(" Environment........: "+GETENVSERVER())
            AUTOGRLOG(" StartPath..........: "+GETSRVPROFSTRING("StartPath",""))
            AUTOGRLOG(" RootPath...........: "+GETSRVPROFSTRING("RootPath",""))
            AUTOGRLOG(" Versão.............: "+GETVERSAO( .T. ))
            AUTOGRLOG(" Usuário TOTVS .....: "+__CUSERID+" "+CUSERNAME)
            AUTOGRLOG(" Computer Name......: "+GETCOMPUTERNAME())

            AINFO := GETUSERINFOARRAY()
            ; if (NPOS := ASCAN(AINFO,{ |X,Y|X[3]==THREADID()}))>0
                AUTOGRLOG(" ")
                AUTOGRLOG(" Dados Thread")
                AUTOGRLOG(" --------------------")
                AUTOGRLOG(" Usuário da Rede....: "+AINFO[NPOS][1])
                AUTOGRLOG(" Estação............: "+AINFO[NPOS][2])
                AUTOGRLOG(" Programa Inicial...: "+AINFO[NPOS][5])
                AUTOGRLOG(" Environment........: "+AINFO[NPOS][6])
                AUTOGRLOG(" Conexão............: "+ alltrim(STRTRAN(STRTRAN(AINFO[NPOS][7],CHR(13),""),CHR(10),"")))
            endif
            AUTOGRLOG("--------------------------------------------------------------------------------------------------------------------------------")
            AUTOGRLOG(" ")

            ; if .not. (LAUTO)
                AUTOGRLOG("--------------------------------------------------------------------------------------------------------------------------------")
                AUTOGRLOG("Empresa : "+SM0->M0_CODIGO+"/"+SM0->M0_NOME+CHR(13)+CHR(10))
            endif

            OPROCESS:SETREGUA1(8)




            FSATUSX3()

            OPROCESS:INCREGUA1("Dicionário de dados"+" - "+SM0->M0_CODIGO+" "+SM0->M0_NOME+" ...")
            OPROCESS:INCREGUA2("Atualizando campos/índices")


            __SETX31MODE( .F. )

            ; if FINDFUNCTION(CTCBUILD)
                CTOPBUILD := &CTCBUILD.()
            endif

            for NX := 1 to ( len(AARQUPD)) step 1

                ; if CTOPBUILD>="20090811" .and. TCINTERNAL(89)=="CLOB_SUPPORTED"

                    ; if ((AARQUPD[NX]>="NQ " .and. AARQUPD[NX]<="NZZ") .or. (AARQUPD[NX]>="O0 " .and. AARQUPD[NX]<="NZZ")) .and. .not. ((AARQUPD[NX]) $ ("NQD,NQF,NQP,NQT"))
                        TCINTERNAL(25,"CLOB")
                    endif
                endif

                ; if SELECT(AARQUPD[NX])>0
                    dbselectarea(AARQUPD[NX])
                    DBCLOSEAREA()
                endif

                X31UPDTABLE(AARQUPD[NX])

                ; if __GETX31ERROR()
                    ALERT(__GETX31TRACE())
                    iif(FINDFUNCTION("APMsgStop"),APMSGSTOP("Ocorreu um erro desconhecido durante a atualização da tabela : "+AARQUPD[NX]+". Verifique a integridade do dicionário e da tabela.","ATENÇÃO"),MSGSTOP("Ocorreu um erro desconhecido durante a atualização da tabela : "+AARQUPD[NX]+". Verifique a integridade do dicionário e da tabela.","ATENÇÃO"))
                    AUTOGRLOG("Ocorreu um erro desconhecido durante a atualização da estrutura da tabela : "+AARQUPD[NX])
                endif

                ; if CTOPBUILD>="20090811" .and. TCINTERNAL(89)=="CLOB_SUPPORTED"
                    TCINTERNAL(25,"OFF")
                endif
            next





            OPROCESS:INCREGUA1("Helps de Campo"+" - "+SM0->M0_CODIGO+" "+SM0->M0_NOME+" ...")
            FSATUHLP()

            AUTOGRLOG("--------------------------------------------------------------------------------------------------------------------------------")
            AUTOGRLOG(" Data / Hora Final.: "+DTOC(DATE())+" / "+TIME())
            AUTOGRLOG("--------------------------------------------------------------------------------------------------------------------------------")

            RPCCLEARENV()
        next


        ; if .not. (LAUTO)

            CTEXTO := LELOG()

            OFONT := TFONT():NEW("Mono AS",5,12, .F. ,,,,,,,,,,,,)

            ODLG := MSDIALOG():NEW(3,0,340,417,"Atualização concluida.",,, .F. ,,,,,, .T. ,,, .F. )

            OMEMO := TMULTIGET():NEW(5,5,{ | U |iif(PCOUNT()==0,CTEXTO,CTEXTO := U)},ODLG,200,145,, .F. ,,,, .T. ,, .F. ,, .F. , .F. , .F. ,,, .F. ,,)
            OMEMO:BRCLICKED := {||ALLWAYSTRUE()}
            OMEMO:OFONT := OFONT

            PIXEL := SBUTTON():NEW(153,175,1,{||ODLG:END()},ODLG, .T. ,,)

            PIXEL := SBUTTON():NEW(153,145,13,{||CFILE := CGETFILE(CMASK,""), iif(CFILE=="", .T. ,MEMOWRITE(CFILE,CTEXTO))},ODLG, .T. ,,)

            ODLG:ACTIVATE(ODLG:BLCLICKED,ODLG:BMOVED,ODLG:BPAINTED, .T. ,,,,ODLG:BRCLICKED,)
        endif
    endif
else 




    LRET :=  .F. 
endif


return LRET













static function FSATUSX3()
local AESTRUT := {}
local ASX3 := {}
local CALIAS := ""
local CALIASATU := ""
local CMSG := ""
local CSEQATU := ""
local CX3CAMPO := ""
local CX3DADO := ""
local LTODOSNAO :=  .F. 
local LTODOSSIM :=  .F. 
local NI := 0
local NJ := 0
local NOPCA := 0
local NPOSARQ := 0
local NPOSCPO := 0
local NPOSORD := 0
local NPOSSXG := 0
local NPOSTAM := 0
local NPOSVLD := 0
local NSEQATU := 0
local NTAMSEEK :=  len(SX3->X3_CAMPO)

AUTOGRLOG("Ínicio da Atualização"+" SX3"+CHR(13)+CHR(10))







AESTRUT := {{"X3_ARQUIVO",0},{"X3_ORDEM",0},{"X3_CAMPO",0},{"X3_TIPO",0},{"X3_TAMANHO",0},{"X3_DECIMAL",0},{"X3_TITULO",0},{"X3_TITSPA",0},{"X3_TITENG",0},{"X3_DESCRIC",0},{"X3_DESCSPA",0},{"X3_DESCENG",0},{"X3_PICTURE",0},{"X3_VALID",0},{"X3_USADO",0},{"X3_RELACAO",0},{"X3_F3",0},{"X3_NIVEL",0},{"X3_RESERV",0},{"X3_CHECK",0},{"X3_TRIGGER",0},{"X3_PROPRI",0},{"X3_BROWSE",0},{"X3_VISUAL",0},{"X3_CONTEXT",0},{"X3_OBRIGAT",0},{"X3_VLDUSER",0},{"X3_CBOX",0},{"X3_CBOXSPA",0},{"X3_CBOXENG",0},{"X3_PICTVAR",0},{"X3_WHEN",0},{"X3_INIBRW",0},{"X3_GRPSXG",0},{"X3_FOLDER",0},{"X3_CONDSQL",0},{"X3_CHKSQL",0},{"X3_IDXSRV",0},{"X3_ORTOGRA",0},{"X3_TELA",0},{"X3_POSLGT",0},{"X3_IDXFLD",0},{"X3_AGRUP",0},{"X3_MODAL",0},{"X3_PYME",0}}

AEVAL(AESTRUT,{ |X|X[2] := (SX3)->(FIELDPOS(X[1]))})























































AADD(ASX3,{{"SB1", .T. },{"GQ", .T. },{"B1_XNATREC", .T. },{"C", .T. },{5, .T. },{0, .T. },{"Natureza Rec", .T. },{"Natureza Rec", .T. },{"Natureza Rec", .T. },{"Natureza Receita tb REINF", .T. },{"Natureza Receita tb REINF", .T. },{"Natureza Receita tb REINF", .T. },{"@!", .T. },{"", .T. },{"x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x", .T. },{"", .T. },{"FKX", .T. },{0, .T. },{"xxxxxx x", .T. },{"", .T. },{"", .T. },{"U", .T. },{"N", .T. },{"A", .T. },{"R", .T. },{"", .T. },{"", .T. },{"", .T. },{"", .T. },{"", .T. },{"", .T. },{"", .T. },{"", .T. },{"", .T. },{"", .T. },{"", .T. },{"", .T. },{"", .T. },{"N", .T. },{"", .T. },{"", .T. },{"N", .T. },{"", .T. },{"", .T. },{"", .T. }})

















































AADD(ASX3,{{"SD1", .T. },{"GQ", .T. },{"D1_XNATREC", .T. },{"C", .T. },{5, .T. },{0, .T. },{"Natureza Rec", .T. },{"Natureza Rec", .T. },{"Natureza Rec", .T. },{"Natureza Rec", .T. },{"Natureza Rec", .T. },{"Natureza Rec", .T. },{"", .T. },{"", .T. },{"x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x", .T. },{"", .T. },{"FKX", .T. },{0, .T. },{"xxxxxx x", .T. },{"", .T. },{"", .T. },{"U", .T. },{"S", .T. },{"A", .T. },{"R", .T. },{"", .T. },{"", .T. },{"", .T. },{"", .T. },{"", .T. },{"", .T. },{"", .T. },{"", .T. },{"", .T. },{"", .T. },{"", .T. },{"", .T. },{"", .T. },{"N", .T. },{"", .T. },{"", .T. },{"N", .T. },{"", .T. },{"", .T. },{"", .T. }})





NPOSARQ := ASCAN(AESTRUT,{ |X| alltrim(X[1])=="X3_ARQUIVO"})
NPOSORD := ASCAN(AESTRUT,{ |X| alltrim(X[1])=="X3_ORDEM"})
NPOSCPO := ASCAN(AESTRUT,{ |X| alltrim(X[1])=="X3_CAMPO"})
NPOSTAM := ASCAN(AESTRUT,{ |X| alltrim(X[1])=="X3_TAMANHO"})
NPOSSXG := ASCAN(AESTRUT,{ |X| alltrim(X[1])=="X3_GRPSXG"})
NPOSVLD := ASCAN(AESTRUT,{ |X| alltrim(X[1])=="X3_VALID"})

ASORT(ASX3,,,{ |X,Y|X[NPOSARQ][1]+X[NPOSORD][1]+X[NPOSCPO][1]<Y[NPOSARQ][1]+Y[NPOSORD][1]+Y[NPOSCPO][1]})

OPROCESS:SETREGUA2( len(ASX3))

dbselectarea("SX3")
DBSETORDER(2)
CALIASATU := ""

for NI := 1 to ( len(ASX3)) step 1




    ; if .not. (EMPTY(ASX3[NI][NPOSSXG][1]))
        (SXG)->(DBSETORDER(1))
        ; if (SXG)->(MSSEEK(ASX3[NI][NPOSSXG][1]))
            ; if ASX3[NI][NPOSTAM][1]<>SXG->XG_SIZE
                ASX3[NI][NPOSTAM][1] := SXG->XG_SIZE


                AUTOGRLOG("O tamanho do campo "+ASX3[NI][NPOSCPO][1]+" NÃO atualizado e foi mantido em ["+ alltrim(STR(SXG->XG_SIZE))+"]"+CHR(13)+CHR(10)+" por pertencer ao grupo de campos ["+SXG->XG_GRUPO+"]"+CHR(13)+CHR(10))
            endif
        endif
    endif

    (SX3)->(DBSETORDER(2))

    ; if .not. ((ASX3[NI][NPOSARQ][1]) $ (CALIAS))
        CALIAS += ASX3[NI][NPOSARQ][1]+"/"
        AADD(AARQUPD,ASX3[NI][NPOSARQ][1])
    endif

    ; if .not. ((SX3)->(DBSEEK(PADR(ASX3[NI][NPOSCPO][1],NTAMSEEK))))




        ; if ASX3[NI][NPOSARQ][1]<>CALIASATU
            CSEQATU := "00"
            CALIASATU := ASX3[NI][NPOSARQ][1]

            DBSETORDER(1)
            (SX3)->(DBSEEK(CALIASATU+"ZZ", .T. ))
            DBSKIP(- (1))

            ; if SX3->X3_ARQUIVO==CALIASATU
                CSEQATU := SX3->X3_ORDEM
            endif

            NSEQATU :=  val(RETASC(CSEQATU,3, .F. ))
        endif

        NSEQATU++
        CSEQATU := RETASC(STR(NSEQATU),2, .T. )

        RECLOCK("SX3", .T. )
        for NJ := 1 to ( len(ASX3[NI])) step 1
            ; if NJ==NPOSORD
                (SX3)->(FIELDPUT(FIELDPOS(AESTRUT[NJ][1]),CSEQATU))

            elseif AESTRUT[NJ][2]>0
                (SX3)->(FIELDPUT(FIELDPOS(AESTRUT[NJ][1]),ASX3[NI][NJ][1]))
            endif
        next


        DBCOMMIT()
        MSUNLOCK()

        AUTOGRLOG("Criado campo "+ASX3[NI][NPOSCPO][1])
    else 





        ; if .not. (EMPTY(SX3->X3_GRPSXG)) .and. SX3->X3_GRPSXG<>ASX3[NI][NPOSSXG][1]
            (SXG)->(DBSETORDER(1))
            ; if (SXG)->(MSSEEK(SX3->X3_GRPSXG))
                ; if ASX3[NI][NPOSTAM][1]<>SXG->XG_SIZE
                    ASX3[NI][NPOSTAM][1] := SXG->XG_SIZE


                    AUTOGRLOG("O tamanho do campo "+ASX3[NI][NPOSCPO][1]+" NÃO atualizado e foi mantido em ["+ alltrim(STR(SXG->XG_SIZE))+"]"+CHR(13)+CHR(10)+"   por pertencer ao grupo de campos ["+SX3->X3_GRPSXG+"]"+CHR(13)+CHR(10))
                endif
            endif
        endif




        for NJ := 1 to ( len(ASX3[NI])) step 1




            ; if ASX3[NI][NJ][2]
                CX3CAMPO :=  alltrim(AESTRUT[NJ][1])
                CX3DADO := (SX3)->(FIELDGET(AESTRUT[NJ][2]))




                ; if AESTRUT[NJ][2]>0 .and. PADR(STRTRAN(ALLTOCHAR(CX3DADO)," ",""),250)<>PADR(STRTRAN(ALLTOCHAR(ASX3[NI][NJ][1])," ",""),250) .and. .not. (CX3CAMPO=="X3_ORDEM")






                    CMSG := "O campo "+ASX3[NI][NPOSCPO][1]+" está com o "+CX3CAMPO+" com o conteúdo"+CHR(13)+CHR(10)+"["+ rtrim(ALLTOCHAR(CX3DADO))+"]"+CHR(13)+CHR(10)+"que será substituído pelo NOVO conteúdo"+CHR(13)+CHR(10)+"["+ rtrim(ALLTOCHAR(ASX3[NI][NJ][1]))+"]"+CHR(13)+CHR(10)+"Deseja substituir ? "

                    ; if LTODOSSIM
                        NOPCA := 1
                    elseif LTODOSNAO
                        NOPCA := 2
                    else 
                        NOPCA := AVISO("ATUALIZAÇÃO DE DICIONÁRIOS E TABELAS",CMSG,{"Sim","Não","Sim p/Todos","Não p/Todos"},3,"Diferença de conteúdo - SX3")
                        LTODOSSIM := NOPCA==3
                        LTODOSNAO := NOPCA==4

                        ; if LTODOSSIM
                            NOPCA := 1
                            LTODOSSIM := iif(FINDFUNCTION("APMsgNoYes"),APMSGNOYES("Foi selecionada a opção de REALIZAR TODAS alterações no SX3 e NÃO MOSTRAR mais a tela de aviso."+CHR(13)+CHR(10)+"Confirma a ação [Sim p/Todos] ?",),(CMSGNOYES := "MsgNoYes", &CMSGNOYES.("Foi selecionada a opção de REALIZAR TODAS alterações no SX3 e NÃO MOSTRAR mais a tela de aviso."+CHR(13)+CHR(10)+"Confirma a ação [Sim p/Todos] ?",)))
                        endif

                        ; if LTODOSNAO
                            NOPCA := 2
                            LTODOSNAO := iif(FINDFUNCTION("APMsgNoYes"),APMSGNOYES("Foi selecionada a opção de NÃO REALIZAR nenhuma alteração no SX3 que esteja diferente da base e NÃO MOSTRAR mais a tela de aviso."+CHR(13)+CHR(10)+"Confirma esta ação [Não p/Todos]?",),(CMSGNOYES := "MsgNoYes", &CMSGNOYES.("Foi selecionada a opção de NÃO REALIZAR nenhuma alteração no SX3 que esteja diferente da base e NÃO MOSTRAR mais a tela de aviso."+CHR(13)+CHR(10)+"Confirma esta ação [Não p/Todos]?",)))
                        endif
                    endif


                    ; if NOPCA==1


                        AUTOGRLOG("Alterado campo "+ASX3[NI][NPOSCPO][1]+CHR(13)+CHR(10)+"   "+PADR(CX3CAMPO,10)+" de ["+ALLTOCHAR(CX3DADO)+"]"+CHR(13)+CHR(10)+"            para ["+ALLTOCHAR(ASX3[NI][NJ][1])+"]"+CHR(13)+CHR(10))

                        RECLOCK("SX3", .F. )
                        FIELDPUT(FIELDPOS(AESTRUT[NJ][1]),ASX3[NI][NJ][1])
                        MSUNLOCK()
                    endif
                endif
            endif
        next
    endif





    OPROCESS:INCREGUA2("Atualizando Campos de Tabelas (SX3) ...")
next


AUTOGRLOG(CHR(13)+CHR(10)+"Final da Atualização"+" SX3"+CHR(13)+CHR(10)+"--------------------------------------------------------------------------------------------------------------------------------"+CHR(13)+CHR(10))

return NIL













static function FSATUHLP()
local AHLPPOR := {}
local AHLPENG := {}
local AHLPSPA := {}

AUTOGRLOG("Ínicio da Atualização"+" "+"Helps de Campos"+CHR(13)+CHR(10))


OPROCESS:INCREGUA2("Atualizando Helps de Campos ...")




AHLPPOR := {}
AADD(AHLPPOR,"Natureza Receita tb REINF")

AHLPENG := {}
AADD(AHLPENG,"Natureza Receita tb REINF")

AHLPSPA := {}
AADD(AHLPSPA,"Natureza Receita tb REINF")

PUTSX1HELP("PB1_XNATREC",AHLPPOR,AHLPENG,AHLPSPA, .T. ,, .T. )
AUTOGRLOG("Atualizado o Help do campo "+"B1_XNATREC")




AHLPPOR := {}
AADD(AHLPPOR,"Natureza Rec")

AHLPENG := {}
AADD(AHLPENG,"Natureza Rec")

AHLPSPA := {}
AADD(AHLPSPA,"Natureza Rec")

PUTSX1HELP("PD1_XNATREC",AHLPPOR,AHLPENG,AHLPSPA, .T. ,, .T. )
AUTOGRLOG("Atualizado o Help do campo "+"D1_XNATREC")

AUTOGRLOG(CHR(13)+CHR(10)+"Final da Atualização"+" "+"Helps de Campos"+CHR(13)+CHR(10)+"--------------------------------------------------------------------------------------------------------------------------------"+CHR(13)+CHR(10))

return {}














static function ESCEMPRESA()













local ARET := {}
local ASALVAMB := GETAREA()
local ASALVSM0 := {}
local AVETOR := {}
local CMASCEMP := "??"
local CVAR := ""
local LCHK :=  .F. 
local LOK :=  .F. 
local LTEVEMARC :=  .F. 
local ONO := LOADBITMAP(GETRESOURCES(),"LBNO")
local OOK := LOADBITMAP(GETRESOURCES(),"LBOK")
local ODLG,OCHKMAR,OLBX,OMASCEMP,OSAY
local OBUTDMAR,OBUTINV,OBUTMARC,OBUTOK,OBUTCANC

local AMARCADAS := {}


if .not. (MYOPENSM0( .F. ))
    return ARET
endif


dbselectarea("SM0")
ASALVSM0 := (SM0)->(GETAREA())
DBSETORDER(1)
DBGOTOP()

while .not. ((SM0)->(EOF())); 
    
    ; if ASCAN(AVETOR,{|X|X[2]==SM0->M0_CODIGO})==0
        AADD(AVETOR,{ASCAN(AMARCADAS,{|X|X[1]==SM0->M0_CODIGO .and. X[2]==SM0->M0_CODFIL})>0,SM0->M0_CODIGO,SM0->M0_CODFIL,SM0->M0_NOME,SM0->M0_FILIAL})
    endif
    
    DBSKIP(); end


RESTAREA(ASALVSM0)

ODLG := MSDIALOG():NEW(0,0,280,395,"",,, .F. ,,,,,, .T. ,,, .F. )

ODLG:CTOOLTIP := "Tela para Múltiplas Seleções de Empresas/Filiais"

ODLG:CTITLE := "Selecione a(s) Empresa(s) para Atualização"

OLBX:=VAR:=CVAR:=TWBROWSE():NEW(10,10,178,95,,{" "," ","Empresa"},,ODLG,,,,,,,,,,,, .F. ,, .T. ,, .F. ,,,)
OLBX:SETARRAY(AVETOR)


OLBX:BLINE := {||{iif(AVETOR[OLBX:NAT][1],OOK,ONO),AVETOR[OLBX:NAT][2],AVETOR[OLBX:NAT][4]}}
OLBX:BLDBLCLICK := {||AVETOR[OLBX:NAT][1] := .not. (AVETOR[OLBX:NAT][1]),VERTODOS(AVETOR,@LCHK,OCHKMAR),OCHKMAR:REFRESH(),OLBX:REFRESH()}
OLBX:CTOOLTIP := ODLG:CTITLE
OLBX:LHSCROLL :=  .F. 


OCHKMAR := TCHECKBOX():NEW(112,10,"Todos",{ | U |iif(PCOUNT()==0,LCHK,LCHK := U)},ODLG,40,7,,{||MARCATODOS(LCHK,@AVETOR,OLBX)},,,,, .F. , .T. ,"Marca / Desmarca"+CHR(13)+CHR(10)+"Todos", .F. ,)


OSAY := TSAY():NEW(113,51,{||"Empresa"},ODLG,,, .F. , .F. , .F. , .T. ,,,40,8, .F. , .F. , .F. , .F. , .F. , .F. )

OMASCEMP := TGET():NEW(112,80,{ | U |iif(PCOUNT()==0,CMASCEMP,CMASCEMP := U)},ODLG,5,5,"@!",{||CMASCEMP := STRTRAN(CMASCEMP," ","?"), OMASCEMP:REFRESH(),  .T. },,,, .F. ,, .T. ,"Máscara Empresa ( ?? )", .F. ,, .F. , .F. ,, .F. , .F. ,,"cMascEmp",,,,)
OSAY:CTOOLTIP := OMASCEMP:CTOOLTIP


OBUTINV := TBUTTON():NEW(128,10,"&Inverter",ODLG,{||INVSELECAO(@AVETOR,OLBX), VERTODOS(AVETOR,@LCHK,OCHKMAR)},32,12,,, .F. , .T. , .F. ,"Inverter Seleção", .F. ,,, .F. )
OBUTINV:SETCSS("QPushButton { color: #024670; "+"    border-image: url(rpo:fwstd_btn_nml.png) 3 3 3 3 stretch; "+"    border-top-width: 3px; "+"    border-left-width: 3px; "+"    border-right-width: 3px; "+"    border-bottom-width: 3px }"+"QPushButton:pressed {	color: #FFFFFF; "+"    border-image: url(rpo:fwstd_btn_prd.png) 3 3 3 3 stretch; "+"    border-top-width: 3px; "+"    border-left-width: 3px; "+"    border-right-width: 3px; "+"    border-bottom-width: 3px }")

OBUTMARC := TBUTTON():NEW(128,50,"&Marcar",ODLG,{||MARCAMAS(OLBX,AVETOR,CMASCEMP, .T. ), VERTODOS(AVETOR,@LCHK,OCHKMAR)},32,12,,, .F. , .T. , .F. ,"Marcar usando"+CHR(13)+CHR(10)+"máscara ( ?? )", .F. ,,, .F. )
OBUTMARC:SETCSS("QPushButton { color: #024670; "+"    border-image: url(rpo:fwstd_btn_nml.png) 3 3 3 3 stretch; "+"    border-top-width: 3px; "+"    border-left-width: 3px; "+"    border-right-width: 3px; "+"    border-bottom-width: 3px }"+"QPushButton:pressed {	color: #FFFFFF; "+"    border-image: url(rpo:fwstd_btn_prd.png) 3 3 3 3 stretch; "+"    border-top-width: 3px; "+"    border-left-width: 3px; "+"    border-right-width: 3px; "+"    border-bottom-width: 3px }")

OBUTDMAR := TBUTTON():NEW(128,80,"&Desmarcar",ODLG,{||MARCAMAS(OLBX,AVETOR,CMASCEMP, .F. ), VERTODOS(AVETOR,@LCHK,OCHKMAR)},32,12,,, .F. , .T. , .F. ,"Desmarcar usando"+CHR(13)+CHR(10)+"máscara ( ?? )", .F. ,,, .F. )
OBUTDMAR:SETCSS("QPushButton { color: #024670; "+"    border-image: url(rpo:fwstd_btn_nml.png) 3 3 3 3 stretch; "+"    border-top-width: 3px; "+"    border-left-width: 3px; "+"    border-right-width: 3px; "+"    border-bottom-width: 3px }"+"QPushButton:pressed {	color: #FFFFFF; "+"    border-image: url(rpo:fwstd_btn_prd.png) 3 3 3 3 stretch; "+"    border-top-width: 3px; "+"    border-left-width: 3px; "+"    border-right-width: 3px; "+"    border-bottom-width: 3px }")

OBUTOK := TBUTTON():NEW(112,157,"Processar",ODLG,{||RETSELECAO(@ARET,AVETOR), iif( len(ARET)>0,ODLG:END(),MSGSTOP("Ao menos um grupo deve ser selecionado","UPDEFD02"))},32,12,,, .F. , .T. , .F. ,"Confirma a seleção e efetua"+CHR(13)+CHR(10)+"o processamento", .F. ,,, .F. )
OBUTOK:SETCSS("QPushButton { color: #024670; "+"    border-image: url(rpo:fwstd_btn_nml.png) 3 3 3 3 stretch; "+"    border-top-width: 3px; "+"    border-left-width: 3px; "+"    border-right-width: 3px; "+"    border-bottom-width: 3px }"+"QPushButton:pressed {	color: #FFFFFF; "+"    border-image: url(rpo:fwstd_btn_prd.png) 3 3 3 3 stretch; "+"    border-top-width: 3px; "+"    border-left-width: 3px; "+"    border-right-width: 3px; "+"    border-bottom-width: 3px }")

OBUTCANC := TBUTTON():NEW(128,157,"Cancelar",ODLG,{||iif(LTEVEMARC,ARET := AMARCADAS, .T. ), ODLG:END()},32,12,,, .F. , .T. , .F. ,"Cancela o processamento"+CHR(13)+CHR(10)+"e abandona a aplicação", .F. ,,, .F. )
OBUTCANC:SETCSS("QPushButton { color: #024670; "+"    border-image: url(rpo:fwstd_btn_nml.png) 3 3 3 3 stretch; "+"    border-top-width: 3px; "+"    border-left-width: 3px; "+"    border-right-width: 3px; "+"    border-bottom-width: 3px }"+"QPushButton:pressed {	color: #FFFFFF; "+"    border-image: url(rpo:fwstd_btn_prd.png) 3 3 3 3 stretch; "+"    border-top-width: 3px; "+"    border-left-width: 3px; "+"    border-right-width: 3px; "+"    border-bottom-width: 3px }")

ODLG:ACTIVATE(ODLG:BLCLICKED,ODLG:BMOVED,ODLG:BPAINTED, .T. ,,,,ODLG:BRCLICKED,)

RESTAREA(ASALVAMB)
dbselectarea("SM0")
DBCLOSEAREA()

return ARET















static function MARCATODOS(LMARCA,AVETOR,OLBX)
local NI := 0

for NI := 1 to ( len(AVETOR)) step 1
    AVETOR[NI][1] := LMARCA
next

OLBX:REFRESH()

return NIL














static function INVSELECAO(AVETOR,OLBX)
local NI := 0

for NI := 1 to ( len(AVETOR)) step 1
    AVETOR[NI][1] := .not. (AVETOR[NI][1])
next

OLBX:REFRESH()

return NIL














static function RETSELECAO(ARET,AVETOR)
local NI := 0

ARET := {}
for NI := 1 to ( len(AVETOR)) step 1
    ; if AVETOR[NI][1]
        AADD(ARET,{AVETOR[NI][2],AVETOR[NI][3],AVETOR[NI][2]+AVETOR[NI][3]})
    endif
next

return NIL
















static function MARCAMAS(OLBX,AVETOR,CMASCEMP,LMARDES)
local CPOS1 :=  substr(CMASCEMP,1,1)
local CPOS2 :=  substr(CMASCEMP,2,1)
local NPOS := OLBX:NAT
local NZ := 0

for NZ := 1 to ( len(AVETOR)) step 1
    ; if (CPOS1=="?") .or. ( substr(AVETOR[NZ][2],1,1)==CPOS1)
        ; if (CPOS2=="?") .or. ( substr(AVETOR[NZ][2],2,1)==CPOS2)
            AVETOR[NZ][1] := LMARDES
        endif
    endif
next

OLBX:NAT := NPOS
OLBX:REFRESH()

return NIL















static function VERTODOS(AVETOR,LCHK,OCHKMAR)
local LTTRUE :=  .T. 
local NI := 0

for NI := 1 to ( len(AVETOR)) step 1
    LTTRUE := iif(.not. (AVETOR[NI][1]), .F. ,LTTRUE)
next

LCHK := iif(LTTRUE, .T. , .F. )
OCHKMAR:REFRESH()

return NIL













static function MYOPENSM0(LSHARED)
local LOPEN :=  .F. 
local NLOOP := 0

if FINDFUNCTION("OpenSM0Excl")
    for NLOOP := 1 to (20) step 1
        ; if OPENSM0EXCL(, .F. )
            LOPEN :=  .T. 
            exit 
        endif
        SLEEP(500)
    next
else 
    for NLOOP := 1 to (20) step 1
        DBUSEAREA( .T. ,,"SIGAMAT.EMP","SM0",LSHARED, .F. )

        ; if .not. (EMPTY(SELECT("SM0")))
            LOPEN :=  .T. 
            DBSETINDEX("SIGAMAT.IND")
            exit 
        endif
        SLEEP(500)
    next
endif

if .not. (LOPEN)

    iif(FINDFUNCTION("APMsgStop"),APMSGSTOP("Não foi possível a abertura da tabela "+iif(LSHARED,"de empresas (SM0).","de empresas (SM0) de forma exclusiva."),"ATENÇÃO"),MSGSTOP("Não foi possível a abertura da tabela "+iif(LSHARED,"de empresas (SM0).","de empresas (SM0) de forma exclusiva."),"ATENÇÃO"))
endif

return LOPEN













static function LELOG()
local CRET := ""
local CFILE := NOMEAUTOLOG()
local CAUX := ""

FT_FUSE(CFILE)
FT_FGOTOP()

while .not. (FT_FEOF()); 
    
    CAUX := FT_FREADLN()
    
    ; if  len(CRET)+ len(CAUX)<1048000
        CRET += CAUX+CHR(13)+CHR(10)
    else 
        CRET += CHR(13)+CHR(10)
        CRET += "================================================================================================================================"+CHR(13)+CHR(10)
        CRET += "Tamanho de exibição maxima do LOG alcançado."+CHR(13)+CHR(10)
        CRET += "LOG Completo no arquivo "+CFILE+CHR(13)+CHR(10)
        CRET += "================================================================================================================================"+CHR(13)+CHR(10)
        exit 
    endif
    
    FT_FSKIP(); end


FT_FUSE()

return CRET
