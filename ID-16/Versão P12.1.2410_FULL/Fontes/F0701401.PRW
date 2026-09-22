#include 'protheus.ch'
#include 'apwebsrv.ch'

/*/{Protheus.doc} F0701401
Realiza o Upsert de um Registro Simpro
@author izac.ciszevski
@since 19/01/2017
@param oSimpro, object, Objeto Simpro fornecido pelo WebService W0701401
@Project MAN0000007423041_EF_014
/*/
User Function F0701401(oSimpro)
    Local cRetorno := ""
    Local cChave   := ""
    Local aCampos  := {}

    aCampos := {; 
                    {"P16_FILIAL", oSimpro:cFilReg      },;
                    {"P16_COD"   , oSimpro:cCOD         },;
                    {"P16_DESCR" , oSimpro:cDescr       },;
                    {"P16_DIV"   , Val(oSimpro:cDiv)    },;
                    {"P16_DTVAL" , CToD(oSimpro:cDTVAL) },;
                    {"P16_STUSS" , oSimpro:cSTUSS       },;
                    {"P16_STATUS", oSimpro:cSTATUS      },;
                    {"P16_STISS" , oSimpro:cSTISS       },;
                    {"P16_ID"    , U_GetIntegID()       };
                }

    cRetorno := U_F0700001("P16", {2}, "F0701301", "MASTER", aCampos)//-- chamar função de log

    aCampos := ASize(aCampos, 0)
    aCampos := Nil

Return cRetorno