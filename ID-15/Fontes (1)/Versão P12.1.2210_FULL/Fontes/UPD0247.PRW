#include "totvs.ch"
#include "protheus.ch"
#include "topconn.ch"

/////////////////////////////////////////////////////////
// CLONAR APROVADOR E APROVADOR X GRUPO DE APROVADORES //
/////////////////////////////////////////////////////////

***********************
User Function UPD0247()
***********************
Local cLinha 	   := ""
Local lRet		   := .T.
Local lPrim 	   := .F.

Local cText 	   := OemToAnsi("Selecione o Arquivo de Importação:")
Private aParmBox1  := {} // Perguntas do Parambox
Private aRetBox1   := {} // Retorno do Parambox
Private aPeriodo   := {}
Private aAno       := {}
Private cNovoAprovador := SPACE(TAMSX3("AK_USER")[1])
Private cAntiAprovador := SPACE(TAMSX3("AK_USER")[1])
Private cNovoNome := SPACE(TAMSX3("AK_NOME")[1])
Private cAntiNome := SPACE(TAMSX3("AK_NOME")[1])
Private cCriaPZX  := " "  
Private aUserAll := FWSFALLUSERS()

Private pNovoAprovador := SPACE(TAMSX3("AK_USER")[1])
Private pAntiAprovador := SPACE(TAMSX3("AK_USER")[1])

Private nLidos     := 0
Private nProce     := 0

AAdd( aParmBox1, {1," Novo Aprovador   ",pNovoAprovador,"@","u_valSAL1(1)","USR","",0,.F.})
AAdd( aParmBox1, {1," Antigo Aprovador ",pAntiAprovador,"@","u_valSAL1(2)","USR","",0,.F.})
AAdd( aParmBox1, {2,"Cria Aprov X Centro Custo (PZX) ","Sim",{"Sim", "Nao" },60,"",.F.})	

If( ParamBox(aParmBox1, "Parametros para Clonar Aprovador", @aRetBox1,,,.T.,,,,,,) )
    If( Len(aRetBox1)==Len(aParmBox1) )
        cNovoAprovador := aRetBox1[1]
		cAntiAprovador := aRetBox1[2] 
		cCriaPZX       := aRetBox1[3] 
	    cNovoNome := UsrFullName(cNovoAprovador)
	    cAntiNome := UsrFullName(cAntiAprovador)
    Else
        Return .F.
    EndIf
Else
    Return .F.
EndIf        

MsAguarde({|lEnd| fClonarSAK(@lEnd)},"Aguarde...","Clonando Aprovador",.T.)
MsgStop( "Fim da Rotina", "UPD0247" )

Return


********************************
Static Function fClonarSAK(lEnd)
********************************
Local cQry := " "
Local aDados1 := {}
Local aDados2 := {}
Local aDados3 := {}
Local ix, nx
//////////////////////////////////////
// buscando SAK do Aprovador antigo //
//////////////////////////////////////
//////////////////////
// array aAprov     //
//////////////////////
// [1]   AK_FILIAL  //
// [2]   AK_COD     //
// [3]   AK_USER    //
// [4]   AK_NOME    //
// [5]   AK_LIMMIN  //
// [6]   AK_LIMMAX  //
// [7]   AK_APROSUP //
// [8]   AK_MOEDA   //
// [9]   AK_LIMITE  //
// [10]  AK_TIPO    //
// [11]  AK_LIMPED  //
// [12]  AK_XMIGLT  //
// [13]  AK_LOGIN   //
//////////////////////
cMsg := "Selecionando dados do Antigo Aprovador"
///ptinternal(1,cMsg) 
MsProcTxt(cMsg)	
ProcessMessage()                           
aAprov := {}                      
cQry1 := "SELECT * FROM SAK010 WHERE D_E_L_E_T_<>'*' and ak_user='"+cAntiAprovador+"' order by 1,2"
cQry1 := changequery(cQry1) 
TCQUERY cQry1 ALIAS "cTMPx" NEW
While !cTMPx->(EOF())  
   aadd(aAprov,{CTMPx->AK_FILIAL,;
                CTMPx->AK_COD,;
                CTMPx->AK_USER,;
                CTMPx->AK_NOME,;
                CTMPx->AK_LIMMIN,; 
                CTMPx->AK_LIMMAX,; 
                CTMPx->AK_APROSUP,;
                CTMPx->AK_MOEDA,;  
                CTMPx->AK_LIMITE,; 
                CTMPx->AK_TIPO,;   
                CTMPx->AK_LIMPED,; 
                CTMPx->AK_XMIGLT,;
                CTMPx->AK_LOGIN}) 
   ctmpx->(dbskip())
End
ctmpx->(dbclosearea())                  
//////////////////////////////////////////////////////////////////////

/////////////////////////
// array aGrupos       //
/////////////////////////
// [1]  AL_FILIAL      //
// [2]  AL_COD         //
// [3]  AL_DESC        //       
// [4]	AL_ITEM        //
// [5]	AL_APROV       //
// [6]  AL_USER        //
// [7]  AL_NIVEL       //
// [8]  AL_LIBAPR      //
// [9]  AL_AUTOLIM     //
// [10]  AL_TPLIBER    //
// [11]  AL_DOCAE      //
// [12]  AL_DOCCO      // 
// [13]  AL_DOCCP      // 
// [14]  AL_DOCMD      // 
// [15]  AL_DOCNF      // 
// [16]  AL_DOCPC      // 
// [17]  AL_DOCSA      // 
// [18]  AL_DOCSC      // 
// [19]  AL_DOCST      // 
// [20]  AL_DOCIP      // 
// [21]  AL_DOCCT      // 
// [22]  AL_DOCGA      // 
// [23]  AL_XMIGLT     // 
// [24]  AL_PERFIL     // 
// [25]  AL_APROSUP    // 
// [26]  AL_USERSUP    // 
// [27]  AL_AGRCNNG    // 
// [28]  AL_XNOME      //
/////////////////////////

agrupos := {}
CQRY1 := "SELECT * FROM SAL010 WHERE  AL_USER='"+CANTIAPROVADOR+"' AND D_E_L_E_T_<>'*' ORDER BY 1,2,4"
cQry1 := changequery(cQry1) 
TCQUERY cQry1 ALIAS "cTMPx" NEW
While !cTMPx->(EOF())  
     aadd(agrupos,{ctmpx->(AL_FILIAL),;            
  	               ctmpx->(AL_COD),;               
                   cTMPx->(AL_DESC),;              
				   ctmpx->(AL_ITEM),;
				   ctmpx->(AL_APROV),;
   		           ctmpx->(AL_USER),;
                   ctmpx->(AL_NIVEL),;
                   ctmpx->(AL_LIBAPR),;
                   ctmpx->(AL_AUTOLIM),;
                   ctmpx->(AL_TPLIBER),;
                   ctmpx->(AL_DOCAE),;    
                   ctmpx->(AL_DOCCO),;       
                   ctmpx->(AL_DOCCP),;       
                   ctmpx->(AL_DOCMD),;       
                   ctmpx->(AL_DOCNF),;       
                   ctmpx->(AL_DOCPC),;       
                   ctmpx->(AL_DOCSA),;       
                   ctmpx->(AL_DOCSC),;       
                   ctmpx->(AL_DOCST),;       
                   ctmpx->(AL_DOCIP),;       
                   ctmpx->(AL_DOCCT),;       
                   ctmpx->(AL_DOCGA),;       
                   ctmpx->(AL_XMIGLT),;      
                   ctmpx->(AL_PERFIL),;      
                   ctmpx->(AL_APROSUP),;     
                   ctmpx->(AL_USERSUP),;     
                   ctmpx->(AL_AGRCNNG),;     
                   ctmpx->(AL_XNOME)})
     ctmpx->(dbskip())
End
ctmpx->(dbclosearea())                  
          
////////////////////////
// CLONANDO DADOS SAK //
////////////////////////
nreg:=0
For ix := 1 to Len(aAprov)
    nreg++
    cMsg := "Gravando Dados na SAK do Novo Aprovador"+str(nreg,9,0)
    ///ptinternal(1,cMsg) 
    MsProcTxt(cMsg)	
    ProcessMessage()
    xAprov := ProxAprov(aAprov[ix][1])
    cMsg := "Gravando Dados na SAK do Novo Aprovador"+str(nreg,9,0)
    ///ptinternal(1,cMsg) 
    MsProcTxt(cMsg)	
    ProcessMessage()
    if xAprov <> "000000"
	   DBSELECTAREA("SAK")
  	   DBSETORDER(1)
       IF !DBSEEK(aAprov[ix][1]+XAprov)
          RecLock("SAK",.T.)
		  SAK->(AK_FILIAL)  := aAprov[ix][1]
          SAK->(AK_COD)     := xAprov
          SAK->(AK_USER)    := cNovoAprovador
          SAK->(AK_NOME)    := cNovoNome
          SAK->(AK_LIMMIN)  := aAprov[ix][5]
          SAK->(AK_LIMMAX)  := aAprov[ix][6]
          SAK->(AK_APROSUP) := aAprov[ix][7]
          SAK->(AK_MOEDA)   := aAprov[ix][8]
          SAK->(AK_LIMITE)  := aAprov[ix][9]
          SAK->(AK_TIPO)    := aAprov[ix][10] 
          SAK->(AK_LIMPED)  := aAprov[ix][11] 
          SAK->(AK_XMIGLT)  := "UPD0247 " + dtos(date()) + " " + time()
          SAK->(AK_LOGIN)   := buskacpf(cNovoAprovador) 
          SAK->(MSUNLOCK()) 
          aadd(aDados1,{aAprov[ix][1],aAprov[ix][2],xAprov})
       ENDIF
    ENDIF
Next      
              
aAprov:={}

////////////////////////
// CLONANDO DADOS SAL //
////////////////////////
nreg:=0
cMsg := "Gravando Dados na SAL do Novo Aprovador "+str(nreg,9,0)
////ptinternal(1,cMsg) 
MsProcTxt(cMsg)	
ProcessMessage()
For ix := 1 To Len(aGrupos)
	  nreg++
      cMsg := "Gravando Dados na SAL do Novo Aprovador "+str(nreg,9,0)
      ////ptinternal(1,cMsg) 
      MsProcTxt(cMsg)	
      ProcessMessage()
      c1 := agrupos[ix][1]        
      c2 := agrupos[ix][2]           
	  cite1 := ProxItem(agrupos[ix][1],agrupos[ix][2])
	  IF ExistSAL(agrupos[ix][1],agrupos[ix][2],cite1)
 	     xAprov = "000000"
         for nx := 1 to Len(aDados1)
             if alltrim(adados1[nx][1]) == alltrim(agrupos[ix][1]) .AND.;
                alltrim(adados1[nx][2]) == alltrim(agrupos[ix][5]) .AND.;
                xAprov = "000000"
                xAprov := adados1[nx][3]
             endif
         next             
         IF xAprov <> "000000"
		    AADD(ADADOS3,{agrupos[ix][1],agrupos[ix][2],agrupos[ix][5],xAprov,CNOVONOME})
            RecLock("SAL",.T.)
            SAL->AL_FILIAL      := agrupos[ix][1]        
            SAL->AL_COD         := agrupos[ix][2]           
            SAL->AL_DESC        := agrupos[ix][3]           
            SAL->AL_ITEM        := cite1		             
            SAL->AL_APROV       := XAPROV		             
            SAL->AL_USER        := cNovoAprovador           
            SAL->AL_NIVEL       := agrupos[ix][7]           
            SAL->AL_LIBAPR      := agrupos[ix][8]           
            SAL->AL_AUTOLIM     := agrupos[ix][9]           
            SAL->AL_TPLIBER     := agrupos[ix][10]           
            SAL->AL_DOCAE       := fcvtipo(agrupos[ix][11],SAL->AL_DOCAE)        
            SAL->AL_DOCCO       := fcvtipo(agrupos[ix][12],SAL->AL_DOCCO)           
            SAL->AL_DOCCP       := fcvtipo(agrupos[ix][13],SAL->AL_DOCCP)           
            SAL->AL_DOCMD       := fcvtipo(agrupos[ix][14],SAL->AL_DOCMD)            
            SAL->AL_DOCNF       := fcvtipo(agrupos[ix][15],SAL->AL_DOCNF)           
            SAL->AL_DOCPC       := fcvtipo(agrupos[ix][16],SAL->AL_DOCPC)           
            SAL->AL_DOCSA       := fcvtipo(agrupos[ix][17],SAL->AL_DOCSA)           
            SAL->AL_DOCSC       := fcvtipo(agrupos[ix][18],SAL->AL_DOCSC)           
            SAL->AL_DOCST       := fcvtipo(agrupos[ix][19],SAL->AL_DOCST)           
            SAL->AL_DOCIP       := fcvtipo(agrupos[ix][20],SAL->AL_DOCIP)           
            SAL->AL_DOCCT       := fcvtipo(agrupos[ix][21],SAL->AL_DOCCT)           
            SAL->AL_DOCGA       := fcvtipo(agrupos[ix][22],SAL->AL_DOCGA)           
            SAL->AL_XMIGLT      := "UPD0247 " + dtos(date()) + " " + time()
            SAL->AL_PERFIL      := agrupos[ix][24]           
            SAL->AL_APROSUP     := agrupos[ix][25]           
            SAL->AL_USERSUP     := agrupos[ix][26]           
            SAL->AL_AGRCNNG     := fcvtipo(agrupos[ix][27],SAL->AL_AGRCNNG) 
            SAL->AL_XNOME       := cNovoNome               
            SAL->(MSUNLOCK())
         ENDIF
      ENDIF
Next

////////////////////////
// CLONANDO DADOS PZX //
////////////////////////
If cCriaPZX = "Sim"
nreg:=0
FOR NX := 1 TO LEN(ADADOS3)

    CFIL1 := ADADOS3[NX][1]
	CCOD1 := ADADOS3[NX][2]
    CCODA := ADADOS3[NX][3]
	CCODN := ADADOS3[NX][4]
	CNOME := ADADOS3[NX][5]

	cQry := "SELECT *"
    cQry += CRLF+"  FROM "+RetSqlName("PZX")
    cQry += CRLF+" WHERE PZX_FILIAL = '"+CFIL1+"' "
    cQry += CRLF+"   AND PZX_CODAPR = '"+CCODA+"' "
    cQry += CRLF+"   AND (D_E_L_E_T_  <> '*')"   
    cQry := changequery(cQry) 
    TCQUERY cQry ALIAS "cTMPx" NEW
    While !cTMPx->(EOF())
      DBSELECTAREA("PZX")
      DBSETORDER(1)
      IF !DBSEEK(cTMPx->PZX_FILIAL+CCODN+cTMPx->PZX_CCUSTO)
	     nreg++
	     cMsg := "Gravando Dados na PZX do Novo Aprovador "+str(nreg,9,0)
         ////ptinternal(1,cMsg) 
         MsProcTxt(cMsg)	
         ProcessMessage()
         RecLock("PZX",.T.)
         PZX->PZX_FILIAL  := cTMPx->PZX_FILIAL
         PZX->PZX_CODAPR  := CCODN
         PZX->PZX_NOMAPR  := CNOME
         PZX->PZX_CCUSTO  := cTMPx->PZX_CCUSTO
         PZX->PZX_DESCCC  := cTMPx->PZX_DESCCC
         PZX->PZX_XMIGLT  := "UPD0247 " + dtos(date()) + " " + time()
         PZX->(MSUNLOCK())
      ENDIF	
      DBSELECTAREA("cTMPx")
	  cTMPx->(DBSKIP())
	ENDDO
    cTMPx->(DbCloseArea()) 
NEXT
Endif

Return                           

************************************                                                                         
static function fcvtipo(cOrig,cDest)
************************************
Local  rRet := ""                   

if Valtype(cOrig) = "C" .and. Valtype(cDest) = "C"
   rRet := cOrig
endif
if Valtype(cOrig) = "N" .and. Valtype(cDest) = "N"
   rRet := cOrig
endif
if Valtype(cOrig) = "D" .and. Valtype(cDest) = "D"
   rRet := cOrig
endif                                            
if Valtype(cOrig) = "M" .and. Valtype(cDest) = "M"
   rRet := cOrig
endif                                            

if Valtype(cOrig) = "C" .and. Valtype(cDest) = "N"
   rRet := Val(cOrig)
endif                

if Valtype(cOrig) = "C" .and. Valtype(cDest) = "D"
   If AT("/", cOrig) > 0
      rRet := IIf(EMPTY(cOrig),CTOD("  /  /    "),CTOD(cOrig))
   Else
      rRet := IIf(EMPTY(cOrig),CTOD("  /  /    "),STOD(cOrig))
   EndIf
endif                

if Valtype(cOrig) = "C" .and. Valtype(cDest) = "L"
   If cOrig = "t" .or. cOrig = "T"
      rRet := .T.
   else
      rRet := .F.
   endif
endif                

if Valtype(cOrig) = "C" .and. Valtype(cDest) = "M"
   rRet := MSMM(cOrig)
endif                 

if Valtype(cOrig) = "N" .and. Valtype(cDest) = "C"
   rRet := cValToChar(cOrig) 
endif                 

if Valtype(cOrig) = "D" .and. Valtype(cDest) = "C"
   rRet := dtos(cOrig)
endif                

Return rRet

User Function ValSAL1(nTeste)
Local lRet := .T.

if nTeste = 1 .And. Len(Alltrim(MV_PAR01)) > 0
   cQry := "SELECT count(*) as QtdLin FROM SAK010 WHERE D_E_L_E_T_<>'*' AND AK_USER='"+MV_PAR01+"' "
   cQry := changequery(cQry) 
   TCQUERY cQry ALIAS "cTMP" NEW
   If cTMP->QtdLin > 0
      Aviso('Aviso Rotina',"Usuario ja existe como Aprovador", {'OK'}, 1)
      lRet := .F.
   Endif                                
   cTMP->(DbCloseArea()) 
   If lRet
      cQry := "SELECT count(*) as QtdLin FROM SAL010 WHERE D_E_L_E_T_<>'*' AND AL_USER='"+MV_PAR01+"' "
      cQry := changequery(cQry) 
      TCQUERY cQry ALIAS "cTMP" NEW
      If cTMP->QtdLin > 0
         Aviso('Aviso Rotina',"Usuario ja existe no Grupo de Aprovadores", {'OK'}, 1)
         lRet := .F.
      Endif
      cTMP->(DbCloseArea()) 
   Endif                                
Endif

if nTeste = 2.And. Len(Alltrim(MV_PAR02)) > 0
   cQry := "SELECT count(*) as QtdLin FROM SAK010 WHERE D_E_L_E_T_<>'*' AND AK_USER='"+MV_PAR02+"' "
   cQry := changequery(cQry) 
   TCQUERY cQry ALIAS "cTMP" NEW
   If cTMP->QtdLin = 0
      Aviso('Aviso Rotina',"Usuario nao esta registrado como Aprovador", {'OK'}, 1)
      lRet := .F.
   Endif
   cTMP->(DbCloseArea()) 
   If lRet
      cQry := "SELECT count(*) as QtdLin FROM SAL010 WHERE D_E_L_E_T_<>'*' AND AL_USER='"+MV_PAR02+"' "
      cQry := changequery(cQry) 
      TCQUERY cQry ALIAS "cTMP" NEW
      If cTMP->QtdLin = 0
         Aviso('Aviso Rotina',"Usuario nao esta no Grupo de Aprovadores", {'OK'}, 1)
         lRet := .F.
      Endif
      cTMP->(DbCloseArea()) 
   Endif
Endif

Return lRet

********************************
Static Function ProxAprov(cFil1)
********************************
Local _aArea := FwGetArea()
Local cQry1 := ""
Local cQry2 := ""
Local cAlias1 := GetNextAlias()
Local cAlias2 := GetNextAlias()
Local cCodAux1 := ""
Local cCodAux2 := ""

cQry1 := "SELECT  A.AK_FILIAL , (MAX (A.AK_COD)) AS NOVOCOD"
cQry1 += " FROM "+retsqlname("SAK")+" A "
cQry1 += " WHERE A.AK_FILIAL = '"+cFil1+"' "
cQry1 += " and a.D_E_L_E_T_<>'*'"
cQry1 += " GROUP BY A.AK_FILIAL"
cQry1 := changequery(cQry1) 
TCQUERY cQry1 ALIAS cAlias1 NEW

cCodAux1 := soma1((cAlias1)->(NOVOCOD))

cQry2 := "SELECT  A.AK_FILIAL , (MAX (A.AK_COD)) AS NOVOCOD"
cQry2 += " FROM "+retsqlname("SAK")+" A "
cQry2 += " WHERE A.AK_FILIAL = '"+cFil1+"' "
cQry2 += "AND SUBSTR(A.AK_COD,1,1) <> '9'"
cQry2 += " and a.D_E_L_E_T_<>'*'"
cQry2 += " GROUP BY A.AK_FILIAL"
cQry2 := changequery(cQry1) 
TCQUERY cQry1 ALIAS cAlias2 NEW

cCodAux2 := soma1((cAlias2)->(NOVOCOD))

If cCodAux2 < cCodAux1
	CCod1 := cCodAux2
	While DBSEEK(cFil1+CCod1,.F.)
		CCod1 := soma1(CCod1)
	EndDo
Else
	CCod1 := cCodAux1
	While DBSEEK(cFil1+CCod1,.F.)
		CCod1 := soma1(CCod1)
	EndDo
EndIf

(cAlias1)->(dbclosearea())
(cAlias2)->(dbclosearea())

FwRestArea(_aArea)

Return CCod1

Static Function ProxItem(cfil1,ccod1)
    Local lRet := " "
    cQry1 := "SELECT  AL_FILIAL,AL_COD, MAX(AL_ITEM) AS NOVOIT"
    cQry1 += " FROM "+RETSQLNAME("SAL")
    cQry1 += " WHERE AL_FILIAL = '"+cfil1+"' "
    cQry1 += "   AND AL_COD    = '"+ccod1+"' "
    cQry1 += "   AND D_E_L_E_T_<>'*'"
    cQry1 += " GROUP BY AL_FILIAL, AL_COD  "
    cQry1 += " ORDER BY AL_FILIAL, AL_COD, MAX (AL_ITEM)"
    cQry1 := changequery(cQry1) 
    TCQUERY cQry1 ALIAS "cTMPx" NEW
    lRet := soma1(ctmpx->(NOVOIT))
    ctmpx->(dbclosearea())                            
Return lRet

Static Function ExistSAL(cFil1,cCod1,cIte1)
Local lRet := .T.
    cQry1 := "SELECT  count(*) as Qtdreg"
    cQry1 += " FROM "+RETSQLNAME("SAL")
    cQry1 += " WHERE AL_FILIAL = '"+cFil1+"' "
    cQry1 += "   AND AL_COD    = '"+cCod1+"' "
    cQry1 += "   AND AL_ITEM   = '"+cIte1+"' "
    cQry1 += "   AND D_E_L_E_T_<>'*'"
    cQry1 := changequery(cQry1) 
    TCQUERY cQry1 ALIAS "cTMPx" NEW
    if ctmpx->(Qtdreg) > 0
       lRet := .F.
    Endif
    ctmpx->(dbclosearea())                            
Return lRet

Static Function buskacpf(cNovoAprovador) 
Local CPFusr := ""
Local nx:=0
For nx := 1 To Len(aUserAll)
    If aUserAll[nx][2] = cNovoAprovador
       CPFusr := aUserAll[nx][3]
    Endif
Next
Return CPFusr
