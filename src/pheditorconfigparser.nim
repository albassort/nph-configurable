import strutils
import streams 

#Stolen from strutils, they should make this *
let whitespace = {' ', '\t', '\v', '\r', '\f'}
type State = enum
  Good, Kill, Skip

proc readVal(a : FileStream, output : var string, error : var string) : State = 
  var readingVal = false
  var quoted = false 
  var over = false
  var notQuoted = false
  var buff = newString(128)
  var i = 0
  while not a.atEnd:
    let read = a.readChar()
    if read in whitespace and not quoted:
      continue
    elif not readingVal and read != '=' and read notin whitespace:
      error = "Failed to parse, value expected."
      return KILL
    elif not readingVal and read == '=':
      readingVal = true
      continue
    elif readingVal and not quoted and read == '"' and i == 0:
      quoted = true 
      continue
    elif readingVal and i == 0 and read == '\n':
      error = "Failed to parse, rest of value expected, but got nothing."
      return KILL
    elif readingVal and quoted and read == '"':
      quoted = false
      over = true
      continue
    elif over and read notin whitespace and read != '\n':
      error = "Failed to parse, spaces are not allowed in values. Put it in quotes, please"
      return KILL
    elif readingVal and read in whitespace and read != '\n' and not quoted:
      over = true
    elif over and read == '\n':
      break;
    elif readingVal:
      buff[i] = read
      i+=1
  output = buff

proc readKey(a : FileStream, output : var string, error : var string) : State = 
  var reading = false
  var buff = newString(128)
  var i = 0
  while not a.atEnd:
    let read = a.readChar()
    if read in whitespace and not reading:
      continue
    elif read == '\n' and not reading:
      #:TODO: RETURN SKIP LINE

      return Skip
    elif reading and read in whitespace:
      output = buff
      return  Good
    elif reading and read == '\n':
      error = "Failed to parse, key expected but got nothing"
      return KIll
    elif read notin whitespace and not reading:
      reading = true
      buff[i] = read
      i+=1
    elif reading:
      buff[i] = read
      i+=1


var error = ""
var buff = ""
let x = newFileStream("testing")
echo readKey(x, buff, error)
echo buff
echo error
echo readVal(x, buff, error)
echo buff
echo error
