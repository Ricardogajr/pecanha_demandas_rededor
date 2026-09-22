#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "TOPCONN.CH"


/*/{Protheus.doc} xfSendMail
Nova função de envio de E-mail
@type function
@version V 1.00
@author Diego Fraidemberge Mariano
@since 30/08/2024
@param cPara, character, Destinatário de Email
@param cCC, character, Email CC
@param cAssunto, character, Assunto do Email 
@param _cHTML, variant, Corpo do Email 
@param aNota, array, Array com dados para os Anexos
@return array, Informações do envio aRet[1] = 0 (OK), 1 (ERRO) - aRet[2] = Mensagem
/*/
User Function xfSendMail(cPara, cCC, cAssunto, _cHTML)

Local oEmail := Nil
Local nI     := 0
Local aRet   := {}
//Local aSepara    := {}
//Local nZ         := 0

oEmail := Email():New() 
oEmail:SetGetShowErr("OFF")
oEmail:Destino(cPara)
if !Empty(alltrim(cCC))
    oEmail:DestCC(cCC)
Endif
oEmail:Assunto(cAssunto)
oEmail:Mensagem(_cHTML, .F.)

oEmail:MandaMail()
If oEmail:lError 

    aAdd(aRet, -1)
    aAdd(aRet, oEmail:cError)

Else

    aAdd(aRet, 0)
    aAdd(aRet, "E-mail enviado com sucesso!!!")

EndIf

Return aRet
