Class dc.tts.TTSRESTApp Extends %CSP.REST
{

Parameter CHARSET = "utf-8";

Parameter CONVERTINPUTSTREAM = 1;

Parameter CONTENTTYPE = "application/json";

Parameter Version = "1.0.0";

Parameter HandleCorsRequest = 1;

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
<!-- Server Info -->
<Route Url="/" Method="GET" Call="GetInfo" Cors="true"/>
<!-- Swagger specs -->
<Route Url="/_spec" Method="GET" Call="SwaggerSpec" />

<!-- generate text from audio file -->
<Route Url="/texttoaudio" Method="POST" Call="GenerateAudioFromText" />


</Routes>
}

// Generate audio file from text

ClassMethod GenerateAudioFromText() As %Status
{
    Set tSC = $$$OK 
    
    try {
      // get the sentence to be processed
      Set sentence = $ZCONVERT(%request.Content.Read(),"I","UTF8")

      Set Language = %request.Get("lang")
      Set Domain = %request.Get("domain")

      Set Language = $GET(Language,0)
      If Language = "" {
        Set Language = "en"
      }

      Set Domain = $GET(Domain,0)
      If Domain = "" {
        Set Domain = "com"
      }

      //call embedded python classmethod to get mp3 audio file from text
      Set output = ##class(dc.tts.TTSEngine).GenerateAudioFileFromText(sentence, Language, Domain)

      Set %response.ContentType = "audio/mp3"
      
      Do %response.SetHeader("Content-Disposition","attachment;filename="""_output_"""")
      Set %response.NoCharSetConvert=1
      Set %response.Headers("Access-Control-Allow-Origin")="*"

      Set stream=##class(%Stream.FileBinary).%New()
      Set sc=stream.LinkToFile("/opt/irisbuild/"_output)
      Do stream.OutputToDevice()
        
      Set tSC=$$$OK
  
    //returns error message to the user
    } catch e {
        Set tSC=e.AsStatus()
        Set pOutput = tSC
    }

    Quit tSC
}

/// General information
ClassMethod GetInfo() As %Status
{
  SET version = ..#Version
  SET fmt=##class(%SYS.NLS.Format).%New("ptbw")
  
  SET info = {
    "Service": "TTS Service API",
    "version": (version),
    "Developer": "Yuri Gomes",
    "Status": "Ok",
    "Date": ($ZDATETIME($HOROLOG))
  }
  Set %response.ContentType = ..#CONTENTTYPEJSON
  Set %response.Headers("Access-Control-Allow-Origin")="*"

  Write info.%ToJSON()
  Quit $$$OK
}

ClassMethod %ProcessResult(pStatus As %Status = {$$$OK}, pResult As %DynamicObject = "") As %Status [ Internal ]
{
  #dim %response As %CSP.Response
  SET tSC = $$$OK
  IF $$$ISERR(pStatus) {
    SET %response.Status = 500
    SET tSC = ..StatusToJSON(pStatus, .tJSON)
    IF $isobject(tJSON) {
      SET pResult = tJSON
    } ELSE {
      SET pResult = { "errors": [ { "error": "Unknown error parsing status code" } ] }
    }
  } 
  ELSEIF pStatus=1 {
    IF '$isobject(pResult){
      SET pResult = {
      }
    }
  }
  ELSE {
    SET %response.Status = pStatus
    SET error = $PIECE(pStatus, " ", 2, *)
    SET pResult = {
      "error": (error)
    }
  }
  
  IF pResult.%Extends("%Library.DynamicAbstractObject") {
    WRITE pResult.%ToJSON()
  }
  ELSEIF pResult.%Extends("%JSON.Adaptor") {
    DO pResult.%JSONExport()
  }
  ELSEIF pResult.%Extends("%Stream.Object") {
    DO pResult.OutputToDevice()
  }
  
  QUIT tSC
}

ClassMethod SwaggerSpec() As %Status
{
  Set tSC = ##class(%REST.API).GetWebRESTApplication($NAMESPACE, %request.Application, .swagger)
  Do swagger.info.%Remove("x-ISC_Namespace")
  Set swagger.basePath = "/iris-tts" 
  Set swagger.info.title = "TTS Service API"
  Set swagger.info.version = "1.0"
  Set swagger.host = "localhost:52773"
  Return ..%ProcessResult($$$OK, swagger)
}

}
