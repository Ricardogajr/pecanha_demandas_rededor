#include "totvs.ch"
#include "protheus.ch"
#include "topconn.ch"

/////////////////////////////////////////////////////
// CLONAR COMPRADOR E COMPRADOR X GRUPO DE COMPRAS //
/////////////////////////////////////////////////////

***********************
User Function UPD0246()
***********************
Local cLinha 	   := ""
Local lRet		   := .T.
Local lPrim 	   := .F.

Local cText 	   := OemToAnsi("Selecione o Arquivo de Importação:")
Private aParmBox1  := {} // Perguntas do Parambox
Private aRetBox1   := {} // Retorno do Parambox
Private aDadosSY1  := {}
Private aDadosSAJ  := {}
Private aPeriodo   := {}
Private aAno       := {}
Private cNovoComprador := SPACE(TAMSX3("Y1_USER")[1])
Private cAntiComprador := SPACE(TAMSX3("Y1_USER")[1])
Private cNovoNome := SPACE(TAMSX3("Y1_USER")[1])
Private cAntiNome := SPACE(TAMSX3("Y1_USER")[1])

Private pNovoComprador := SPACE(TAMSX3("Y1_USER")[1])
Private pAntiComprador := SPACE(TAMSX3("Y1_USER")[1])

Private nLidos     := 0
Private nProce     := 0

AAdd( aParmBox1, {1," Novo Comprador   ",pNovoComprador,"@","u_ValSAJ1(1,pNovoComprador)","USR","",0,.F.})
AAdd( aParmBox1, {1," Antigo Comprador ",pAntiComprador,"@","u_ValSAJ1(2,pAntiComprador)","USR","",0,.F.})
	
If( ParamBox(aParmBox1, "Parametros para Clonar Comprador", @aRetBox1,,,.T.,,,,,,) )
    If( Len(aRetBox1)==Len(aParmBox1) )
        cNovoComprador := aRetBox1[1]
		cAntiComprador := aRetBox1[2]  
	    cNovoNome := UsrFullName(cNovoComprador)
	    cAntiNome := UsrFullName(cAntiComprador)
    Else
        Return .F.
    EndIf
Else
    Return .F.
EndIf        

MsAguarde({|lEnd| fClonarSY1(@lEnd)},"Aguarde...","Clonando Comprador",.T.)
MsgStop( "Fim da Rotina", "UPD0246" )

Return


********************************
Static Function fClonarSY1(lEnd)
********************************
Local cQry := " "
Local aDados1 := {}
Local aDados2 := {}
Local nx
// buscando sy1 do comprador antigo //
cMsg := "Selecionando dados do Antigo Comprador"
///ptinternal(1,cMsg) 
MsProcTxt(cMsg)	
ProcessMessage()                           

cQry1 := "SELECT  A.Y1_FILIAL , (MAX (A.Y1_COD)) AS NOVOCOD"
cQry1 += "  FROM "+retsqlname("SY1")+" A "
cQry1 += " WHERE A.Y1_FILIAL IN (select B.Y1_FILIAL from sy1010 B where B.y1_user='"+cAntiComprador+"' and b.D_E_L_E_T_<>'*' ) "
cQry1 += "   and a.D_E_L_E_T_<>'*'"
cQry1 += " GROUP BY A.Y1_FILIAL"
cQry1 := changequery(cQry1) 
TCQUERY cQry1 ALIAS "cTMPx" NEW
While !cTMPx->(EOF())  
     CFIL1 := ctmpx->(y1_filial)
     CCOD1 := soma1(ctmpx->(NOVOCOD))
     aadd(aDados1,{CFIL1,CCOD1})
     ctmpx->(dbskip())
End
ctmpx->(dbclosearea())                            

//////////////////////////////////////////////////////////////////////

cQry1 := "SELECT  AJ_FILIAL,AJ_GRCOM, MAX (AJ_ITEM) AS NOVOIT"
cQry1 += "  FROM SAJ010"
cQry1 += " WHERE AJ_FILIAL IN (SELECT B.AJ_FILIAL FROM SAJ010 B WHERE B.D_E_L_E_T_<>'*' AND B.AJ_USER='"+CANTICOMPRADOR+"') "
//cQry1 += "   AND AJ_GRCOM  IN (SELECT C.AJ_GRCOM  FROM SAJ010 C WHERE B.D_E_L_E_T_<>'*' AND C.AJ_USER='"+CANTICOMPRADOR+"') "
cQry1 += " GROUP BY AJ_FILIAL, AJ_GRCOM "
cQry1 += " order by AJ_FILIAL, AJ_GRCOM, MAX (AJ_ITEM) "
cQry1 := changequery(cQry1) 
TCQUERY cQry1 ALIAS "cTMPx" NEW
While !cTMPx->(EOF())  
     CFIL1 := ctmpx->(AJ_FILIAL)
     CGRC1 := ctmpx->(AJ_GRCOM)
     CITE1 := soma1(ctmpx->(NOVOIT))
     aadd(aDados2,{CFIL1,CGRC1,CITE1})
     ctmpx->(dbskip())
End
ctmpx->(dbclosearea())                            

////////////////////////
// CLONANDO DADOS SY1 //
////////////////////////

cQry := "SELECT *"
cQry += CRLF+"  FROM "+RetSqlName("SY1")
cQry += CRLF+" WHERE Y1_USER = '"+cAntiComprador+"'"
cQry += CRLF+"   AND (D_E_L_E_T_  <> '*')"   
cQry := changequery(cQry) 
TCQUERY cQry ALIAS "cTMP" NEW
nreg:=0
While !cTMP->(EOF())
       nreg++
	   cMsg := "Gravando Dados na SY1 do Novo Comprador "+str(nreg,9,0)
       /////ptinternal(1,cMsg) 
       MsProcTxt(cMsg)	
       ProcessMessage()
	   //xCod1 = "000"
       //for nx := 1 to Len(aDados1)
        //  if alltrim(adados1[nx][1])==alltrim(CTMP->(Y1_FILIAL))
         //    xCod1 := adados1[nx][2]
          //endif
       //next
	   //if xCod1 <> "000"
         //Correção do contador da SY1 Lucas Miranda 24/09/2020
         cFilAnt := CTMP->(Y1_FILIAL)
         xCOD1 := SY1->(GetSX8Num("SY1","Y1_COD"))
		 
		While SY1->(DbSeek(CTMP->Y1_FILIAL+XCOD1)) //Thais Paiva - 18310491
			ConfirmSX8() //Thais Paiva - 18310491
			XCOD1 := GetSX8Num("SY1", "Y1_COD") //Thais Paiva - 18310491
		EndDo //Thais Paiva - 18310491
		
         //Fim
	      DBSELECTAREA("SY1")
  	      DBSETORDER(1)
          IF !DBSEEK(CTMP->Y1_FILIAL+XCOD1)
             RecLock("SY1",.T.)
	          SY1->(Y1_FILIAL)   := CTMP->(Y1_FILIAL)
		       SY1->(Y1_COD)      := xCOD1
             SY1->(Y1_NOME)     := cNovoNome
             SY1->(Y1_USER)     := cNovoComprador
             SY1->(Y1_TEL)      := CTMP->(Y1_TEL)
             SY1->(Y1_FAX)      := CTMP->(Y1_FAX)      
             SY1->(Y1_EMAIL)    := UsrRetMail(cNovoComprador)    
             SY1->(Y1_GRAPROV)  := CTMP->(Y1_GRAPROV)  
             SY1->(Y1_PEDIDO)   := CTMP->(Y1_PEDIDO)   
             SY1->(Y1_GRUPCOM)  := CTMP->(Y1_GRUPCOM)  
             SY1->(Y1_GRAPRCP)  := CTMP->(Y1_GRAPRCP)  
             SY1->(Y1_ACCID)    := CTMP->(Y1_ACCID)    
             SY1->(Y1_XMIGLT)   := "UPD0246 " + dtos(date())+ " " + time()
	          SY1->(dbCommit())
             SY1->(MSUNLOCK())
             ConfirmSX8() ////Correção do contador da SY1 Lucas Miranda 24/09/2020
	      ENDIF
      //ENDIF
	   
       DBSELECTAREA("cTMP")
	   cTMP->(Dbskip())

End                    

cTMP->(DbCloseArea()) 

////////////////////////
// CLONANDO DADOS SAJ //
////////////////////////

cQry := "SELECT * "
cQry += "  FROM "+RETSQLNAME("SAJ")
cQry += " WHERE AJ_USER ='"+cAntiComprador+"' "
//cQry += "WHERE AJ_FILIAL IN (select B.AJ_FILIAL  from SAJ010 B where B.AJ_user='"+cAntiComprador+"') "
//cQry += "  AND AJ_GRCOM  IN (select C.AJ_GRCOM   from SAJ010 C where C.AJ_user='"+cAntiComprador+"') "
cQry += "  AND D_E_L_E_T_  <> '*'"   
cQry := changequery(cQry) 
TCQUERY cQry ALIAS "cTMP" NEW
nreg:=0
While !cTMP->(EOF())

       nreg++
	   cMsg := "Gravando Dados na SAJ do Novo Comprador "+str(nreg,9,0)
       ////ptinternal(1,cMsg) 
       MsProcTxt(cMsg)	
       ProcessMessage()
	   xCod1 = "00"
       for nx := 1 to Len(aDados2)
          if alltrim(adados2[nx][1])==alltrim(CTMP->(AJ_FILIAL)) .AND.;
             alltrim(adados2[nx][2])==alltrim(CTMP->(AJ_GRCOM))
             xCod1 := adados2[nx][3]
          endif
       next
	   if xCod1 <> "00"
	      DBSELECTAREA("SAJ")
  	      DBSETORDER(1)
          IF !DBSEEK(CTMP->AJ_FILIAL+CTMP->AJ_GRCOM+XCOD1)
             RecLock("SAJ",.T.)
             SAJ->AJ_FILIAL   := CTMP->(AJ_FILIAL)
             SAJ->AJ_GRCOM    := CTMP->(AJ_GRCOM)
             SAJ->AJ_ITEM     := xCod1
             SAJ->AJ_USER     := cNovoComprador
             SAJ->AJ_US2NAME  := SUBSTR(cNovoNome,1,TAMSX3("AJ_US2NAME")[1])
             SAJ->AJ_COTACAO  := CTMP->(AJ_COTACAO)
             SAJ->AJ_XMIGLT   := "UPD0246 " + dtos(date())+ " " + time()  
             SAJ->AJ_XDESCRI  := CTMP->(AJ_XDESCRI)
	     SAJ->AJ_DESC     := CTMP->(AJ_DESC)
	         SAJ->(dbCommit())
             SAJ->(MSUNLOCK())
	      ENDIF
       ENDIF
	   
       DBSELECTAREA("cTMP")
	   cTMP->(Dbskip())

End                    

cTMP->(DbCloseArea()) 

Return                           

User Function ValSAJ1(nTeste)
Local lRet := .T.

if nTeste = 1 .And. Len(Alltrim(MV_PAR01)) > 0
   cQry := "SELECT count(*) as QtdLin FROM SY1010 WHERE D_E_L_E_T_<>'*' AND Y1_USER='"+MV_PAR01+"' "
   cQry := changequery(cQry) 
   TCQUERY cQry ALIAS "cTMP" NEW
   If cTMP->QtdLin > 0
      Aviso('Aviso Rotina',"Usuario ja existe como Comprador", {'OK'}, 1)
      lRet := .F.
   Endif                                
   cTMP->(DbCloseArea()) 
   If lRet
      cQry := "SELECT count(*) as QtdLin FROM SAJ010 WHERE D_E_L_E_T_<>'*' AND AJ_USER='"+MV_PAR01+"' "
      cQry := changequery(cQry) 
      TCQUERY cQry ALIAS "cTMP" NEW
      If cTMP->QtdLin > 0
         Aviso('Aviso Rotina',"Usuario ja existe no Grupo de Compradores", {'OK'}, 1)
         lRet := .F.
      Endif
      cTMP->(DbCloseArea()) 
   Endif                                
Endif

if nTeste = 2.And. Len(Alltrim(MV_PAR02)) > 0
   cQry := "SELECT count(*) as QtdLin FROM SY1010 WHERE D_E_L_E_T_<>'*' AND Y1_USER='"+MV_PAR02+"' "
   cQry := changequery(cQry) 
   TCQUERY cQry ALIAS "cTMP" NEW
   If cTMP->QtdLin = 0
      Aviso('Aviso Rotina',"Usuario nao esta Registrado Como Comprador", {'OK'}, 1)
      lRet := .F.
   Endif
   cTMP->(DbCloseArea()) 
   If lRet
      cQry := "SELECT count(*) as QtdLin FROM SAJ010 WHERE D_E_L_E_T_<>'*' AND AJ_USER='"+MV_PAR02+"' "
      cQry := changequery(cQry) 
      TCQUERY cQry ALIAS "cTMP" NEW
      If cTMP->QtdLin = 0
         Aviso('Aviso Rotina',"Usuario nao esta no Grupo de Compradores", {'OK'}, 1)
         lRet := .F.
      Endif
      cTMP->(DbCloseArea()) 
   Endif
Endif

Return lRet

