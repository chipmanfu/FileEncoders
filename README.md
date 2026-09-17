FileEncoder.ps1 - Powershell file encryptor to be able to move files that EDRs typically delete across protected zones - if your life unfortunately requires such a thing.  
  This is pretty simple, encoding goes - binary ->  base64 -> export to Common Language Infastructure XML 
  Decoding is simply the reverse import Common Language Infastructure XML -> FromBase64 -> binary
