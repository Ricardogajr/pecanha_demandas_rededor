///#INCLUDE "PROTHEUS.CH"
///#INCLUDE "RWMAKE.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "xmlxfun.ch"

 
Static oXmlFile := NIL

/*/{Protheus.doc} TFileExp
(long_description)
@author    rat
@since     22/08/2019
@version   ${version}
@example
(examples)
@see (links_or_references)
/*/
class TFileExp 
    
    /*
    ** Private
    */
    
    /*
    ** Public
    */
    DATA cIdPack    As DEFAULT "" 
    DATA cXmlFile   As DEFAULT "" //Nome qualificado do arquivo PKG (XML)
    DATA cPackage   As DEFAULT ""
    DATA cDesc      As DEFAULT ""
    DATA cQuery     As DEFAULT ""
    DATA cAlsName   As DEFAULT ""
    DATA cDelimiter As DEFAULT ";"
    DATA lSetTrim   As DEFAULT .F.
    DATA cFldExcept As DEFAULT ""
    DATA aParams    As DEFAULT {}
    DATA cWorkDir   As DEFAULT "" 
    
     
	method new(cFileName) constructor
	method ClassName()
	method SetFileNm() 

endclass

/*/{Protheus.doc} new
Metodo construtor
@author    rat
@since     22/08/2019
@version   ${version}
@example
(examples)
@see (links_or_references)
/*/
method new(cFileName) class TFileExp
   ::cWorkDir := U_GetDir(0)
   ::SetFileNm(cFileName)
return Self

/**************************
** Retorna o nome da classe
***************************/
METHOD ClassName() CLASS TFileExp
Return "TFileExp" //GetClassName(Self)


/****************************************
** Carrega a classe com os valores do XML
*****************************************/
METHOD SetFileNm(cFileName) CLASS TFileExp
   Local cError   := ""
   Local cWarning := ""
   //Local oXmlFile := NIL
   Local aNodes   := {}
   Local nX       := 0
   
   ::cXmlFile := ::cWorkDir + cFileName
    
   oXmlFile := XmlParserFile( ::cXmlFile ,"", @cError, @cWarning )
   If (oXmlFile == NIL )
      MsgStop(U_FmtStr('Erro ao ler o pacote "{1}"!'+CHR(13)+'{2}'+CHR(13)+cWarning,{FileNoExt(cFileName),cError,cWarning}))
      return
   Endif
   
   ::cIdPack    := Upper(FileName(cFileName,.F.))
   ::cPackage   := oXmlFile:_Package:_Name:Text
   ::cDesc      := oXmlFile:_Package:_Description:Text   
   ::cQuery     := oXmlFile:_Package:_Select:Text
   ::cAlsName   := oXmlFile:_Package:_Alias:Text 
   ::cDelimiter := oXmlFile:_Package:_Delimiter:Text
   ::cFldExcept := AllTrim(oXmlFile:_Package:_FldExcept:Text)
   ::lSetTrim   := (Upper(AllTrim(oXmlFile:_Package:_Trim:Text)) == "TRUE")
   ::aParams    := {}

   If ( Type("oXmlFile:_Package:_Params") == "O" )
      aNodes :=  ClassDataArr(oXmlFile:_Package:_Params)
      For nX := 1 To Len(aNodes)
          If (ValType(aNodes[nX,2]) != "O")
             Loop
          Endif
          
          Aadd(::aParams,{aNodes[nX,2]:RealName,aNodes[nX,2]:_CAMPO:Text,aNodes[nX,2]:_DSPAR:Text,AllTrim(aNodes[nX,2]:_TIPO:Text),;
                          aNodes[nX,2]:_PICTURE:Text,aNodes[nX,2]:_F3:Text,VAL(aNodes[nX,2]:_TAMANHO:Text),VAL(aNodes[nX,2]:_DECIMAL:Text), ,;
                          aNodes[nX,2]:_VALUE:Text})
      Next nX
   Endif

   If ValType(oXmlFile) == "O"
      FreeObj(oXmlFile)
   Endif
   
Return