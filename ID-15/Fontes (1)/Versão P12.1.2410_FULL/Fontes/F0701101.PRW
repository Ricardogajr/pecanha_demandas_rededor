#include 'protheus.ch'

/*{Protheus.doc} F0701101
Realiza o Upsert de um Registro BrasIndice
@author izac.ciszevski
@since 19/01/2017
@param oBrasIndice, object, Objeto BrasIndice fornecido pelo WebService W0701101
@Project MAN0000007423041_EF_011
*/
User Function F0701101(oBrasIndice)
    Local cRetorno := ""
    Local cChave   := ""
    Local aCampos  := {}

    aCampos := {;
                    {"P14_FILIAL", oBrasIndice:cFilReg      },;
                    {"P14_COD",    oBrasIndice:cCOD         },;
                    {"P14_CODMED", oBrasIndice:cCODMED      },;
                    {"P14_DESMED", oBrasIndice:cDESMED      },;
                    {"P14_CODLAB", oBrasIndice:cCODLAB      },;
                    {"P14_DESLAB", oBrasIndice:cDESLAB      },;
                    {"P14_CODAPR", oBrasIndice:cCODAPR      },;
                    {"P14_DESAPR", oBrasIndice:cDESAPR      },;
                    {"P14_DTVAL" , CToD(oBrasIndice:cDTVAL) },;
                    {"P14_BRATUS", oBrasIndice:cBRATUS      },;
                    {"P14_BRATIS", oBrasIndice:cBRATIS      },;
                    {"P14_STATUS", oBrasIndice:cSTATUS      },;
                    {"P14_ID",     U_GetIntegID()           }; //-- função pra pegar o ID
                }
    
    cRetorno := U_F0700001("P14", {2}, "F0701001", "MASTER", aCampos) //-- chamar função de log

    aCampos := ASize(aCampos, 0)
    aCampos := Nil

Return cRetorno

