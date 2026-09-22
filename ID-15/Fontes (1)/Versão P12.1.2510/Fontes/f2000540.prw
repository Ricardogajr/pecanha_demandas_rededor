#INCLUDE "PROTHEUS.CH"

User function F2000540()
local OBUTTON1
local OGROUP1
local OGET1
local _CCODUSER := space(TAMSX3("AL_USER")[1])
local _CGRUPOAPV := space(TAMSX3("AL_APROV")[1])
local OGET2
local OFONT1
local OCOMBOBO1
local NCOMBOBO1 := "1"

private VISUAL :=  .F. 
private INCLUI :=  .F. 
private ALTERA :=  .F. 
private DELETA :=  .F. 
private CHTML := ""
private LTEMREG :=  .F. 

private ALISTBOX1 := {}
private OLISTBOX1
private OBROWSE

private ODLG2
private OVERDE := LOADBITMAP(GETRESOURCES(),"BR_VERDE")
private OAMARELO := LOADBITMAP(GETRESOURCES(),"BR_AMARELO")
private OVERMELHO := LOADBITMAP(GETRESOURCES(),"BR_VERMELHO")
private _CTOTREG := 0

private OOK := LOADBITMAP(GETRESOURCES(),"LBOK")
private ONO := LOADBITMAP(GETRESOURCES(),"LBNO")
private CCAB := ""

OFONT1 := TFONT():NEW("Arial",0,- (18), .F. , .T. ,,,,,,,,,,,)
ODLG2 := MSDIALOG():NEW(0,0,600,1400,"Bloqueio de usuarios ",,, .F. ,,0,16777215,,, .T. ,,, .F. )
OGROUP1 := TGROUP():NEW(7,7,292,686,,ODLG2,0,16777215, .T. ,)
OSAY1 := TSAY():NEW(25,16,{ ||"Cod.Usuario"},ODLG2,,, .F. , .F. , .F. , .T. ,0,16777215,34,7, .F. , .F. , .F. , .F. , .F. , .F. )
OGET1 := TGET():NEW(22,55,{ | U |iif(pcount()==0,_CCODUSER,_CCODUSER := U)},ODLG2,60,10,,,0,16777215,, .F. ,, .T. ,, .F. ,, .F. , .F. ,, .F. , .F. ,,"_cCodUser",,,,)
OSAY3 := TSAY():NEW(25,150,{ ||"Cod.Aprovador "},ODLG2,,, .F. , .F. , .F. , .T. ,0,16777215,44,7, .F. , .F. , .F. , .F. , .F. , .F. )
OGET2 := TGET():NEW(22,194,{ | U |iif(pcount()==0,_CGRUPOAPV,_CGRUPOAPV := U)},ODLG2,60,10,,,0,16777215,, .F. ,, .T. ,, .F. ,, .F. , .F. ,, .F. , .F. ,,"_cGrupoApv",,,,)
OSAY9 := TSAY():NEW(25,294,{ ||"Opção"},ODLG2,,, .F. , .F. , .F. , .T. ,0,16777215,34,7, .F. , .F. , .F. , .F. , .F. , .F. )
OCOMBOBO1 := TCOMBOBOX():NEW(22,320,{ | U |iif(pcount()==0,NCOMBOBO1,NCOMBOBO1 := U)},{"1=Bloquear","2=Desbloquear"},60,13,ODLG2,,,,0,16777215, .T. ,,, .F. ,, .F. ,,,,"nComboBo1")
OBUTTON2 := TBUTTON():NEW(22,480,"&Pesquisar",ODLG2,{ ||PROCESSA({|LEND|FLISTBOX1(_CCODUSER,_CGRUPOAPV)})},37,12,,, .F. , .T. , .F. ,, .F. ,,, .F. )

_CRIATCBROWSE()

OBUTTON1 := TBUTTON():NEW(265,480,"&Marcar/Desmarcar todos",ODLG2,{ ||PROCESSA({|LEND|MARKALL()})},69,12,,, .F. , .T. , .F. ,, .F. ,,, .F. )
OBUTTON1 := TBUTTON():NEW(265,591,"&Confirmar",ODLG2,{ ||PROCESSA({|LEND|UPDSAL(_CCODUSER,_CGRUPOAPV,NCOMBOBO1)}), ZERALIST(@_CCODUSER,@_CGRUPOAPV,@NCOMBOBO1)},37,12,,, .F. , .T. , .F. ,, .F. ,,, .F. )
OBUTTON1 := TBUTTON():NEW(265,631,"&Sair",ODLG2,{ ||ODLG2:END()},37,12,,, .F. , .T. , .F. ,, .F. ,,, .F. )
OSAY4 := TSAY():NEW(265,16,{ ||"Total de Registros : "+ alltrim(str(_CTOTREG))},ODLG2,,OFONT1,,,, .T. ,128,16777215,200,10)

ODLG2:ACTIVATE(ODLG2:BLCLICKED,ODLG2:BMOVED,ODLG2:BPAINTED, .T. ,,,,ODLG2:BRCLICKED,)

return 

static function _CRIATCBROWSE()

OBROWSE := TCBROWSE():NEW(45,16,658,213,,{"MARK","COD.GRUPO","ITEM","DESCRICAO","USUÁRIO","COD.APROVADOR","NOME","BLOQUEADO"},{80,30,30,40,40,40,40,20},ODLG2,,,,,{ ||},,,,,,, .F. ,, .T. ,, .F. ,,,)
ALISTBOX1 := {}
aadd(ALISTBOX1,{ .T. ,"","","","","","",""})

OBROWSE:BLINE := { ||{iif(ALISTBOX1[OBROWSE:NAT][1],OOK,ONO),ALISTBOX1[OBROWSE:NAT][2],ALISTBOX1[OBROWSE:NAT][3],ALISTBOX1[OBROWSE:NAT][4],ALISTBOX1[OBROWSE:NAT][5],ALISTBOX1[OBROWSE:NAT][6],ALISTBOX1[OBROWSE:NAT][7],ALISTBOX1[OBROWSE:NAT][8]}}
OBROWSE:BLDBLCLICK := { ||ALISTBOX1[OBROWSE:NAT][1] := .not. (ALISTBOX1[OBROWSE:NAT][1]),OBROWSE:REFRESH()}
OBROWSE:REFRESH()

return 

static function FLISTBOX1(XCODUSR,XGRPUSR)

local _NTOTM3 := 0
local _NTOTPESO3 := 0
local _CPEDIDO := ""
local _CTRANSP := ""
local _NQUANT := 0
local _CVOLUME := 0
local _CFRETE := ""
local CQUERY := ""
local _CALIAS := GETNEXTALIAS()
local _NCONT := 1
local _CDOC := ""
local _CSERIE := ""
local _CKEY := ""
local LPVEZ :=  .T. 
local _CSTATUS := ""
local _LSTATUS :=  .T. 

_CTOTREG := 0
ALISTBOX1 := {}

if empty(XCODUSR) .and. empty(XGRPUSR)
    aadd(ALISTBOX1,{ .T. ,"","","","","","",""})
else 
    CQUERY := " SELECT SAL.AL_FILIAL, SAL.AL_COD, SAL.AL_ITEM, SAL.AL_DESC, SAL.AL_DESC, SAL.AL_APROV, SAL.AL_USER, SAL.AL_XNOME, SAL.AL_MSBLQL  "
    CQUERY += " FROM "+RETSQLNAME("SAL")+" SAL "
    CQUERY += " WHERE "
    CQUERY += " SAL.AL_FILIAL = '"+XFILIAL("SAL")+"' "
    CQUERY += " AND SAL.D_E_L_E_T_ = ' ' "
   
    if .not. (empty(XCODUSR))
        CQUERY += " AND SAL.AL_USER ='"+XCODUSR+"' "
        CQUERY += " ORDER BY SAL.AL_COD, SAL.AL_USER, SAL.AL_APROV  "
    elseif .not. (empty(XGRPUSR))
        CQUERY += " AND SAL.AL_APROV ='"+XGRPUSR+"' "
        CQUERY += " ORDER BY SAL.AL_COD, SAL.AL_APROV, SAL.AL_USER  "
    endif

    CQUERY := CHANGEQUERY(CQUERY)
    dbusearea( .T. ,"TOPCONN",TCGenQry(,,CQUERY),_CALIAS, .F. , .T. )

    if (_CALIAS)->(eof())
        aadd(ALISTBOX1,{ .T. ,"","","","","","",""})
    else 
        while (_CALIAS)->(.not. (eof())) 
            _CTOTREG++
            _CMSG := " "
            if (_CALIAS)->AL_MSBLQL=="1"
                _CSTATUS := "Sim"
                _LSTATUS :=  .F. 
            else 
                _CSTATUS := "Não"
                _LSTATUS :=  .F. 
            endif
            aadd(ALISTBOX1,{_LSTATUS,(_CALIAS)->AL_COD,(_CALIAS)->AL_ITEM,(_CALIAS)->AL_DESC,(_CALIAS)->AL_USER,(_CALIAS)->AL_APROV,(_CALIAS)->AL_XNOME,_CSTATUS})
            (_CALIAS)->(dbskip())
            ODLG2:REFRESH()
		endDo
    endif
endif

dbclosearea()

OBROWSE:SETARRAY(ALISTBOX1)
OBROWSE:BLINE := { ||{iif(ALISTBOX1[OBROWSE:NAT][1],OOK,ONO),ALISTBOX1[OBROWSE:NAT][2],ALISTBOX1[OBROWSE:NAT][3],ALISTBOX1[OBROWSE:NAT][4],ALISTBOX1[OBROWSE:NAT][5],ALISTBOX1[OBROWSE:NAT][6],ALISTBOX1[OBROWSE:NAT][7],ALISTBOX1[OBROWSE:NAT][8]}}
OBROWSE:BLDBLCLICK := { ||ALISTBOX1[OBROWSE:NAT][1] := .not. (ALISTBOX1[OBROWSE:NAT][1]),OBROWSE:REFRESH()}
OBROWSE:REFRESH()
ODLG2:REFRESH()

return 

static function UPDSAL(XUSER,XAPROV,XOPC)

local LRET :=  .T. 
local CMSG := ""
local NTOTREG :=  len(ALISTBOX1)
local NI := 0
local _NINDICE := 1
local _CCHAVE := ""
local _BLOQUE := ""
local _NCONT := 0

private CNMARQEX := ""
private OEXCEL := FWMSEXCELEX():NEW()
private CABA1 := "Solicitação"
private CTITULO1 := "Bloqueio de usuários"
private CCAMIAUX := ""
private NITEMATU := 1

if XOPC=="1"
    CMSG := "Bloquear"
    _BLOQUE := "1"
else 
    CMSG := "Desbloquear"
    _BLOQUE := "2"
endif

LTEMREG :=  .F. 

if iif(FindFunction("MsgYesNo"),MSGYESNO("Deseja realizar alteração de "+CMSG+"?(Sim/Não)","Atenção"),(CMSGYESNO := "MsgYesNo", &CMSGYESNO.("Deseja realizar alteração de "+CMSG+"?(Sim/Não)","Atenção")))
    
    if .not. (empty(XUSER))
        CCAB := "Prezados, anexo pendências relacionadas ao usuário "+XUSER+" - "+ alltrim(USRFULLNAME(XUSER))
    else 
        CCAB := "Prezados, anexo pendências relacionadas ao aprovador "+XAPROV+" - "+ alltrim(ALISTBOX1[1][7])
    endif

    GEREXCEL()

    for NI := 1 to NTOTREG step 1
        
        if ALISTBOX1[NI][1]
            _NCONT++
        
            if .not. (empty(XUSER))
                _NINDICE := 3
                _CCHAVE := XUSER
            else 
                _NINDICE := 4
                _CCHAVE := XAPROV
            endif
        
            _CCHAVE := ALISTBOX1[NI][2]+ALISTBOX1[NI][3]
            dbselectarea("SAL")
            dbsetorder(1)
        
            if dbseek(XFILIAL("SAL")+_CCHAVE)
                RECLOCK("SAL", .F. )
                SAL->AL_MSBLQL := _BLOQUE
                SAL->(MSUNLOCK())
            endif
        
            MONTAEMAIL(XFILIAL("SCR"),ALISTBOX1[NI][2],ALISTBOX1[NI][3],ALISTBOX1[NI][5],ALISTBOX1[NI][6])
        
        endif

    next

    if _NCONT>0
        
        if .not. (LTEMREG)
            OEXCEL:ADDROW(CABA1,CTITULO1,{"","","","","","","","","",""})
        endif
        
        ENVWORKFSC()

    endif

endif

return LRET

static function C(NTAM)

local NHRES := OMAINWND:NCLIENTWIDTH

if NHRES==640
    NTAM *= 0.8
elseif (NHRES==798) .or. (NHRES==800)
    NTAM *= 1
else 
    NTAM *= 1.28
endif

if ("MP8") $ (OAPP:CVERSION)
    if ( alltrim(GETTHEME())=="FLAT") .or. (SETMDICHILD())
        NTAM *= 0.9
    endif
endif

return int(NTAM)

static function ZERALIST(_CCODUSER,_CGRUPOAPV,NCOMBOBO1)

local LRET :=  .T. 

_CCODUSER := space(TAMSX3("AL_USER")[1])
_CGRUPOAPV := space(TAMSX3("AL_APROV")[1])
NCOMBOBO1 := "1"
ALISTBOX1 := {}
aadd(ALISTBOX1,{ .T. ,"","","","","","",""})

OBROWSE:SETARRAY(ALISTBOX1)
OBROWSE:BLINE := { ||{iif(ALISTBOX1[OBROWSE:NAT][1],OOK,ONO),ALISTBOX1[OBROWSE:NAT][2],ALISTBOX1[OBROWSE:NAT][3],ALISTBOX1[OBROWSE:NAT][4],ALISTBOX1[OBROWSE:NAT][5],ALISTBOX1[OBROWSE:NAT][6],ALISTBOX1[OBROWSE:NAT][7],ALISTBOX1[OBROWSE:NAT][8]}}
OBROWSE:BLDBLCLICK := { ||ALISTBOX1[OBROWSE:NAT][1] := .not. (ALISTBOX1[OBROWSE:NAT][1]),OBROWSE:REFRESH()}
OBROWSE:REFRESH()
ODLG2:REFRESH()

return LRET

static function MONTAEMAIL(CFIL,XGRUPO,XITEM,XUSR,XAPROV)

local _CQUERY := ""
local CALIAS := GETNEXTALIAS()
local AAUX := {}
local CNOMEFIL := ""

CFIL := iif(CFIL==NIL,XFILIAL("SCR"),CFIL)
CNUM := iif(CNUM==NIL,"",CNUM)

_CQUERY := " SELECT CR_FILIAL AS FILIAL, TRIM(CR_NUM) AS SOL_PAG, "+CHR(13)+CHR(10)
_CQUERY += " CR_APROV AS COD_APROV, CR_USER AS USUARIO_APROV, "+CHR(13)+CHR(10)
_CQUERY += " CR_TOTAL AS TOTAL, CR_NIVEL AS NIVEL, CR_STATUS, CR_GRUPO, "+CHR(13)+CHR(10)
_CQUERY += " CR_EMISSAO,  CR_USERLIB, CR_LIBAPRO, CR_TIPO "+CHR(13)+CHR(10)
_CQUERY += " FROM "+RETSQLNAME("SCR")+" CR "+CHR(13)+CHR(10)
_CQUERY += "     WHERE CR.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
_CQUERY += "     AND CR_STATUS IN('01','02') "+CHR(13)+CHR(10)
_CQUERY += "     AND CR_USER ='"+XUSR+"' "+CHR(13)+CHR(10)
_CQUERY += "     AND CR_APROV ='"+XAPROV+"' "+CHR(13)+CHR(10)
_CQUERY += "     AND CR_GRUPO ='"+XGRUPO+"' "+CHR(13)+CHR(10)
_CQUERY += "     ORDER BY 1, 2 "+CHR(13)+CHR(10)

dbusearea( .F. ,"TOPCONN",TCGenQry(,,_CQUERY),CALIAS, .F. , .F. )

if select(CALIAS)<=0
    return 
endif

CFILBKP := CFILANT
CUSERAPR := (CALIAS)->USUARIO_APROV
CFILAPR := (CALIAS)->FILIAL
CFILANT := CFILAPR

while .not. ((CALIAS)->(eof()))
    LTEMREG :=  .T. 
    CNOMEFIL := POSICIONE("SM0",1,CEMPANT+ alltrim((CALIAS)->FILIAL),"M0_FILIAL")
    MONTAHTML({(CALIAS)->FILIAL,CNOMEFIL,(CALIAS)->SOL_PAG,(CALIAS)->CR_TIPO,(CALIAS)->USUARIO_APROV,(CALIAS)->COD_APROV,USRFULNAME((CALIAS)->USUARIO_APROV),(CALIAS)->CR_GRUPO,transform((CALIAS)->TOTAL,"@E 999,999,999,999.99"),(CALIAS)->CR_EMISSAO})
    (CALIAS)->(dbskip())
endDo

CFILANT := CFILBKP

return 

static function USRFULNAME(cVar)
return USRFULLNAME(cVar)

static function ENVWORKFSC(CFIL)

local LAUTENTICA := GetMv("MV_RELAUTH")
local _CQUERY := ""
local CALIAS := GETNEXTALIAS()
local AAUX := {}
local NI := 0

private CERROR := ""
private _LENVIADO :=  .F. 
private LRESULT :=  .F. 
private CEMAILUSR := ""

if .not. (SUPERGETMV("MV_XMAILPC",, .T. ))
endif

RODAPEHTML()

if ( .F. ) 
    LRESULT := CALLPROC("MailSmtpOn",GetMv("MV_RELSERV"),GetMv("MV_RELACNT"),GetMv("MV_RELPSW"),,,)
else
    LRESULT := MAILSMTPON(GetMv("MV_RELSERV"),GetMv("MV_RELACNT"),GetMv("MV_RELPSW"),,,)
endif

if LAUTENTICA
    LRET := MAILAUTH(GetMv("MV_RELACNT"),GetMv("MV_RELPSW"))
else 
    LRET :=  .T. 
endif

if LRESULT .and. LRET
    CAMBIENTE := GetEnvServer()
    ALISTMAIL := SUPERGETMV("FS_MAILSAL",,"")

    if empty(ALISTMAIL)
        ALERT("Nenhum email configurado no parâmetro FS_MAILSAL! Favor verifiar.")
        return 
    else 
        ALISTMAIL := strtokarr(ALISTMAIL,";")
    endif
    
    for NI := 1 to ( len(ALISTMAIL)) step 1      
        if empty(CEMAILUSR)
            CEMAILUSR += USRRETMAIL( alltrim(ALISTMAIL[NI]))
        else 
            CEMAILUSR += ";"+USRRETMAIL( alltrim(ALISTMAIL[NI]))
        endif
    next
    
    if _CTOTREG>1
        _CSUBJECT := "Solicitações pendentes de aprovação"
    else 
        _CSUBJECT := "Solicitação pendente de aprovação"
    endif
    
    if ( .F. ) 
    	_LENVIADO := CALLPROC("MailSend",GetMv("MV_RELACNT"),{CEMAILUSR},{},{},_CSUBJECT+" - "+__CUSERID,CHTML,{CNMARQEX}, .T. ,,)
	else
		_LENVIADO := MAILSEND(GetMv("MV_RELACNT"),{CEMAILUSR},{},{},_CSUBJECT+" - "+__CUSERID,CHTML,{CNMARQEX}, .T. ,,)
	endif
    
    if .not. (_LENVIADO)
        
        if ISBLIND()
        
            if ( .F. ) 
				CERROR := CALLPROC("MailGetErr")
			else
			    CERROR := MAILGETERR()
			endif
        
            HELP(" ",1,"ATENCAO",,CERROR+" "+CEMAILTO,4,5)
        
        endif
    
    endif

    if ( .F. ) 
	    CALLPROC("MailSmtpOff")
	else
	    MAILSMTPOFF()
	endif

else     
    
    if ISBLIND()
        if ( .F. ) 
		    CERROR := CALLPROC("MailGetErr")
		else
		    CERROR := MAILGETERR()
		endif
        HELP(" ",1,"Atencao",,CERROR,4,5)
    endif
endif

CHTML := ""

return 

static function MARKALL()

local NI := 0

for NI := 1 to ( len(ALISTBOX1)) step 1
    ALISTBOX1[NI][1] := .not. (ALISTBOX1[NI][1])
next

OBROWSE:REFRESH()

return 

static function GEREXCEL()

CHTML += " <!DOCTYPE html>"
CHTML += " <html>"
CHTML += " <body>"
CHTML += " <p>"+CCAB+"</p>"

OEXCEL:ADDWORKSHEET(CABA1)
OEXCEL:ADDTABLE(CABA1,CTITULO1)

OEXCEL:ADDCOLUMN(CABA1,CTITULO1,"Filial",1,1)
OEXCEL:ADDCOLUMN(CABA1,CTITULO1,"Descr. Filial",1,1)
OEXCEL:ADDCOLUMN(CABA1,CTITULO1,"Documento",1,1)
OEXCEL:ADDCOLUMN(CABA1,CTITULO1,"Tipo",1,1)
OEXCEL:ADDCOLUMN(CABA1,CTITULO1,"Codigo Usuário",1,1)
OEXCEL:ADDCOLUMN(CABA1,CTITULO1,"Código Aprovador",1,1)
OEXCEL:ADDCOLUMN(CABA1,CTITULO1,"Nome do Aprovador",1,1)
OEXCEL:ADDCOLUMN(CABA1,CTITULO1,"Grupo",1,1)
OEXCEL:ADDCOLUMN(CABA1,CTITULO1,"Valor do documento",1,1)
OEXCEL:ADDCOLUMN(CABA1,CTITULO1,"Emissão",1,1)

return 

static function MONTAHTML(AAUX)

if  len(AAUX)>0
    OEXCEL:ADDROW(CABA1,CTITULO1,{AAUX[1], alltrim(AAUX[2]), alltrim(AAUX[3]), alltrim(AAUX[4]), alltrim(AAUX[5]), alltrim(AAUX[6]),AAUX[7],AAUX[8], alltrim(AAUX[9]), alltrim(AAUX[10])})
endif

return 

static function RODAPEHTML()

CHTML += "  </body>"
CHTML += " </table>"
CHTML += " </body>"
CHTML += " </html>"

OEXCEL:ACTIVATE()

CNMARQEX := "\system\"+"F0200501_"+dtos(DDATABASE)+"_"+strtran(time(),":","_")+".xml"
OEXCEL:GETXMLFILE(CNMARQEX)

FreeObj(OEXCEL)

return
