#INCLUDE "TOTVS.CH"
#INCLUDE "xmlxfun.ch"


Static oXmlFile := NIL

/*/{Protheus.doc} TPkgExp
(long_description)
@author    rat
@since     22/08/2019
@version   ${version}
@example
(examples) 
@see (links_or_references)
/*/
class TPkgExp 
    /*
    ** Public
    */
    DATA cIdPack    As DEFAULT "" 
    DATA cXmlFile   As DEFAULT "" //Nome qualificado do arquivo PKG (XML)
    DATA cPackage   As DEFAULT ""
    DATA cDesc      As DEFAULT ""
    DATA aPackages  As DEFAULT {}
    DATA aParams    As DEFAULT {}
    DATA aEmpresas  As DEFAULT {}
    DATA cWorkDir   As DEFAULT "" 
    
     
	method new(cFileName) constructor
	method Destroy() /* DESTRUCTOR */
	
	method ClassName()
	method SetFileNm()
	method IsPresent(cIdPack) 
	method GetPkgByID(cIdPack) 


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
method new(cFileName) class TPkgExp
   ::cWorkDir := U_GetDir(0)
   ::SetFileNm(cFileName)
return Self

/**************************
** DESTRUCTOR
***************************/
method Destroy(cFileName) class TPkgExp
   ASize(Self:aPackages,0)
   ::Self := FreeObj(::Self)
return Self

/**************************
** Retorna o nome da classe
***************************/
METHOD ClassName() CLASS TPkgExp
Return "TPkgExp" //GetClassName(Self)


/****************************************
** Carrega a classe com os valores do XML
*****************************************/
METHOD SetFileNm(cFileName) CLASS TPkgExp
   Local cError   := ""
   Local cWarning := ""
   Local nX       := 0
   Local xValue   
   Local aFld     := {}

   Private aNodes   := {}
   
   ::cXmlFile := ::cWorkDir + cFileName
   
   oXmlFile := XmlParserFile( ::cXmlFile ,"", @cError, @cWarning )
   If (oXmlFile == NIL )
      MsgStop(U_FmtStr('Erro ao ler o pacote "{1}"!'+CHR(13)+'{2}'+CHR(13)+cWarning,{FileNoExt(cFileName),cError,cWarning}))
      return
   Endif
   
   ::cIdPack    := Upper(FileName(cFileName,.F.))
   ::cPackage   := Upper(oXmlFile:_Package:_Name:Text)
   ::cDesc      := oXmlFile:_Package:_Description:Text   
   ::aPackages  := {}
   ::aParams    := {}
   ::aEmpresas  := {}

   If ( Type("oXmlFile:_Package:_Packs") == "O" )
      aNodes :=  ClassDataArr(oXmlFile:_Package:_Packs)
      If Type("aNodes[1][2]") == "O"
         For nX := 1 To Len(aNodes)
             If (Type( U_FmtStr("aNodes[{1}][2]",{nX}) ) != "O")
                Loop
             Endif
             
             If File(aNodes[nX][2]:_fileName:Text)
                Aadd(::aPackages,TFileExp():New(aNodes[nX][2]:_fileName:Text))
             Endif
         Next nX
      Endif
   Endif
   
   If ( Type("oXmlFile:_Package:_Params") == "O" )
      aNodes :=  ClassDataArr(oXmlFile:_Package:_Params)
      If Type("aNodes[1][2]") == "O"
         For nX := 1 To Len(aNodes)
             If ( Type( U_FmtStr("aNodes[{1}][2]",{nX}) ) != "O")
                Loop
             Endif      

             xValue := aNodes[nX][2]:_Value:Text

             aFld := TamSx3( aNodes[nX][2]:_Field:Text )
             
             If ! Empty(aFld)
                Do Case
                   Case (aFld[3] == "D")
                        xValue := Ctod(xValue)
                   Case (aFld[3] == "N")
                        xValue := Val(xValue)
                EndCase
             Endif 
             
             Aadd(::aParams,{aNodes[nX][2]:_PackId:Text,aNodes[nX][2]:_Name:Text,aNodes[nX][2]:_Field:Text,xValue})
         Next nX
      Endif
   Endif
   
   If ( Type("oXmlFile:_Package:_Empresas") == "O" )
      aNodes := ClassDataArr(oXmlFile:_Package:_Empresas)
      For nX := 1 To Len(aNodes)
          If ( Type( U_FmtStr("aNodes[{1}][2]",{nX}) ) != "O")
             Loop
          Endif      
          Aadd(::aEmpresas,{aNodes[nX][2]:_Empresa:Text,aNodes[nX][2]:_Filial:Text})
      Next nX
   Endif

   If ValType(oXmlFile) == "O"
      FreeObj(oXmlFile)
   Endif
   
Return

/****************************************
** Pesquisa se um package está presente
*****************************************/
METHOD IsPresent(cIdPack) CLASS TPkgExp
   Local lRet := .F.
   
   If ! Empty( ::aPackages )
      lRet := (AScan(::aPackages,{|p| p:cIdPack == Upper(cIdPack)}) > 0) 
   Endif
   
Return lRet


****************************************
METHOD GetPkgByID(cIdPack) CLASS TPkgExp
****************************************
   Local oRet
   Local nIdx := 0
   
   If ! Empty( ::aPackages ) .And. ( nIdx := AScan(::aPackages,{|p| p:cIdPack == Upper(cIdPack)}) ) > 0
      oRet := ::aPackages[nIdx] 
   Endif

Return oRet
