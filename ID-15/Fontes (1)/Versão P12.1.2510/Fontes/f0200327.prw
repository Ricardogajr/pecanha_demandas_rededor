#Include 'Protheus.ch'

/*/{Protheus.doc} F0200327
Retorna sub-status da vaga
@type function
@author henrique.toyada
@since 04/11/2016
@project MAN00000463301_EF_003
@version 1.0
@param cSubSt, codigo do sub-status
@return cRet, descrição
/*/
User Function F0200327(cSubSt)

	Local cRet := ""
	
    // Jamer Nunes Pedroso - 20/05/2017
    Local aSQSStatus := ;
    {{'1','Aprovada'            },;
     {'2','Em Recrutamento'     },;
     {'3','Em Movimentacao (RI)'},;
     {'4','Cadastro'            },;
     {'5','Cancelada'           },;
     {'6','Suspensa'            },;
     {'7','Concluida'           },;
     {'8','Exame-Docto'         },;
     {'9','Ass.Contrato'        },;     
     {'A','Pend Lib. Posto'	    }}

	Default cSubSt := ""
	
    aEval(aSQSStatus,{|x| cRet:= if(x[1]==cSubSt,x[2],cRet) })

Return cRet

