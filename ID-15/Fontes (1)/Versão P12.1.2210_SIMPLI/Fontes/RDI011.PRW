#include 'protheus.ch'
#include 'parmtype.ch'

user function RDI011()
   Local lRet := Exec()
return lRet


**********************
Static Function Exec()
**********************
   Local lRet       := .F.
   Local aAreaQZ1   := QZ1->(GetArea())
   Local lPreVldEx  := .F.
   Local bPreVldEx  := {|| lPreVldEx := PreVldExec() }
   Local bExec      := {|| lRet := U_SelectImp() }
   
   MsgRun( "Validando os processos..." , "Aguarde..." , bPreVldEx )   

   If ! lPreVldEx
      return .F.
   Endif

   MsgRun( "Executando o processo..." , "Aguarde..." , bExec )   

   If lRet
      MsgInfo("Processo concluído!")
   Endif

   QZ1->(RestArea(aAreaQZ1))
   
Return lRet 

****************************
Static Function PreVldExec()
****************************
   Local lRet      := .T.
   Local aFiles    := {}
   Local cMask     := ""
   Local cPath     := ""
   Local nRetSinc  := 0
   
   lRet := U_RDI002(QZ1->QZ1_CODIGO,.T.,.T.,@nRetSinc) //
   
   If ! lRet .And. ! MsgYesNo('O cadastro do processo não está sincronizado com o dicionário!'+CRLF+CRLF+"Deseja continuar?","Atenção")
      //MsgStop("O cadastro do processo não está sincronizado com o dicionário! Verifique.")
      return lRet
   Endif
   
   If __nLocalLdr == 1
      cPath := AllTrim(GetMv("FS_RDI006")) + AllTrim(QZ1->QZ1_DESTIN) + "\"
   Else
      cPath := U_GetDir(101) + AllTrim(QZ1->QZ1_DESTIN) + "\"
   Endif
   
   cPath := Left(cPath,RAT("\",cPath))
   cMask := AllTrim(QZ1->QZ1_DESTIN)+'*.TXT'
   
   aFiles := Directory(cPath + cMask)
   
   lRet := ! Empty(aFiles)
   
   If ! lRet
      MsgStop("Não há arquivo na origem!"+CRLF+CRLF+cPath)
   Endif
   
return lRet   
