#Include 'Protheus.ch'

/*
{Protheus.doc} SISPAG002
Funções para tratamento do código de barras (E2_CODBAR) no layout do aquivo SISPAG.
@Author     Ramon Teodoro e Silva
@Since      27/10/2016     
@Version    P12.7
@Return
*/

/*
{Protheus.doc} SISPDV
Tratamento do dígito verificador. Posição 022 a 022
@Author     Ramon Teodoro e Silva
@Since      27/10/2016     
@Version    P12.7
@Return
*/
User Function SISPDV()        

Local cRetDV := ""

If Len(Alltrim(SE2->E2_CODBAR)) == 44         
	cRetDV := Substr(SE2->E2_CODBAR,5,1)
ElseIf Len(Alltrim(SE2->E2_CODBAR)) == 47
    cRetDV := Substr(SE2->E2_CODBAR,33,1)
ElseIf Len(Alltrim(SE2->E2_CODBAR)) >= 36 .and. Len(Alltrim(SE2->E2_CODBAR)) <= 43
	cRetDV := Substr(SE2->E2_CODBAR,33,1)
Else
    cRetDV := "0"
Endif

Return cRetDV

/*
{Protheus.doc} SISVENC
Tratamento do fator vencimento. Posição 023 a 026
@Author     Ramon Teodoro e Silva
@Since      27/10/2016     
@Version    P12.7
@Return
*/

User Function SISVENC()

Local cRetVenc := ""

If Len(Alltrim(SE2->E2_CODBAR)) == 44      
	cRetVenc := Substr(SE2->E2_CODBAR,6,4)
ElseIf Len(Alltrim(SE2->E2_CODBAR)) == 47
	cRetVenc := Substr(SE2->E2_CODBAR,34,4)
ElseIf Len(Alltrim(SE2->E2_CODBAR)) >= 36 .and. Len(Alltrim(SE2->E2_CODBAR)) <= 43
  	cRetVenc := "0000"
Else
	cRetVenc := "0000"                         
EndIf	

cRetVenc := Strzero(Val(cRetVenc),4)

Return cRetVenc

/*
{Protheus.doc} SISVLR
Tratamento do campo valor. Posição 027 a 036
@Author     Ramon Teodoro e Silva
@Since      27/10/2016     
@Version    P12.7
@Return
*/

User Function SISVLR()

Local cRetVlr := ""

If Len(Alltrim(SE2->E2_CODBAR)) == 44             
	cRetVlr := Substr(SE2->E2_CODBAR,10,10)
ElseIf Len(Alltrim(SE2->E2_CODBAR)) == 47
    cRetVlr := Substr(SE2->E2_CODBAR,38,10)
ElseIf Len(Alltrim(SE2->E2_CODBAR)) >= 36 .and. Len(Alltrim(SE2->E2_CODBAR)) <= 43
    cRetVlr := Alltrim(Substr(SE2->E2_CODBAR,34,10))
Else
	cRetVlr := "0000000000"                 
EndIf	

cRetVlr := Strzero(Val(cRetVlr),10) 

Return cRetVlr

/*
{Protheus.doc} SISCLIV
Tratamento do campo livre. Posição 037 a 061
@Author     Ramon Teodoro e Silva
@Since      27/10/2016     
@Version    P12.7
@Return
*/

User Function SISCLIV

Local cRetCLiv := ""


If Len(Alltrim(SE2->E2_CODBAR)) == 44            
	cRetCLiv := Substr(SE2->E2_CODBAR,20,25)                                                                   
ElseIF Len(Alltrim(SE2->E2_CODBAR)) == 47
    cRetCLiv := Substr(SE2->E2_CODBAR,5,5)+Substr(SE2->E2_CODBAR,11,10)+Substr(SE2->E2_CODBAR,22,10)
ElseIf Len(Alltrim(SE2->E2_CODBAR)) >= 36 .and. Len(Alltrim(SE2->E2_CODBAR)) <= 40
    cRetCLiv := Substr(SE2->E2_CODBAR,5,5)+Substr(SE2->E2_CODBAR,11,10)+Substr(SE2->E2_CODBAR,22,10)
Else
    cRetCLiv := Replicate("0",25)                                                                   
EndIf

Return cRetCLiv


/*
{Protheus.doc} SISDVC 
Tratamento no dígito verificador da conta, para considerar cadastros antigos com conta e digito no mesmo campo
@Author     Ramon Teodoro e Silva
@Since      23/01/2016     
@Version    P12.7
@Return
*/

User Function SISDVC

Local cRet := ""

If Empty(Alltrim(SA6->A6_DVCTA))            
	cRet := RIGHT(TRIM(SA6->A6_NUMCON),1)                                                                 
Else
    cRet := Alltrim(SA6->A6_DVCTA)                                                                    
EndIf

Return cRet 


/*
{Protheus.doc} VENCBOL 
Tratamento no dígito verificador da conta, para considerar cadastros antigos com conta e digito no mesmo campo
@Author     Ramon Teodoro e Silva
@Since      23/01/2016     
@Version    P12.7
@Return
*/

User Function VENCBOL

Local cRet := ""
                            
If !Empty(SE2->E2_XVENBOL)           
	cRet := GRAVADATA(SE2->E2_XVENBOL,.F.,5)                                                               
Else
    cRet := GRAVADATA(SE2->E2_VENCREA,.F.,5)                                                                                      
EndIf

Return cRet 
