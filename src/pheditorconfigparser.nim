import strutils
import tables
import streams 
import pretty
#Stolen from strutils, they should make this *
let whitespace = {' ', '\t', '\v', '\r', '\f'}
type State = enum
  Good, Skip, End, Blob
 
proc readVal(a : StringStream, output : var string, error : var string) : State = 
  var readingVal = false
  var quoted = false 
  var over = false
  var notQuoted = false
  var buff = newString(2048)
  var i = 0
  while not a.atEnd:
    let read = a.readChar()
    if readingVal and read == '\n':
      break;
    elif not readingVal and read != '=' and read notin whitespace:
      error = "Failed to parse, value expected."
      return Skip
    elif not readingVal and read == '=':
      readingVal = true
      continue
    elif readingVal and not quoted and read == '"' and i == 0:
      quoted = true 
      continue
    elif readingVal and i == 0 and read == '\n':
      error = "Failed to parse, rest of value expected, but got nothing."
      return Skip
    elif readingVal and quoted and read == '"':
      quoted = false
      over = true
      continue
    elif over and read notin whitespace and read != '\n':
      error = "Failed to parse, spaces are not allowed in values. Put it in quotes, please"
      return Skip
    elif readingVal and read in whitespace and read != '\n' and not quoted and i != 0:
      over = true
    elif readingVal and read notin whitespace:
      buff[i] = read
      i+=1
  if i == 0:
    return Skip
  output = buff[0 .. i-1]
  return Good

proc readUntil(a : StringStream, output : var string, until  = '\n') : State = 
  var buff = newString(2048)
  var i = 0
  while not a.atEnd:
    let read = a.readChar() 
    if read == until:
      output = buff[0 .. i-1]
      return Good
    buff[i] = read
    i+=1
  return End

proc readKey(a : StringStream, output : var string, error : var string) : State = 
  var reading = false
  var buff = newString(2048)
  var i = 0
  while not a.atEnd:
    let read = a.readChar()
    if read in whitespace and not reading:
      continue
    elif read == '#' and not reading:
      return Skip
    elif read == '[' and not reading:
      discard readUntil(a, output, ']')
      return Blob
    elif read == '\n' and not reading:
      #:TODO: RETURN SKIP LINE

      return Skip
    elif reading and read in whitespace:

      output = buff[0 .. i-1]
      return  Good
    elif reading and read == '\n':
      error = "Failed to parse, key expected but got nothing"
      return Skip
    elif read notin whitespace and not reading:
      reading = true
      buff[i] = read
      i+=1
    elif reading:
      buff[i] = read
      i+=1




var error = ""
var buff = ""
var result = newTable[(string, string), string]()
let x = newFileStream("testing")

var blob = "root"
var line : string
while x.readLine(line):
  #let start =  readKey(x, buff, error)
  #echo buff
  #var key : string
  #echo start
  var buff : string
  var error : string 
  var stream = newStringStream(line)
  let key = readKey(stream, buff, error)
  if key == Skip:
    continue
  if key == Blob:
    blob = buff
    continue
  echo buff
  let keyData = buff
  let val = readVal(stream, buff, error)
  if val != Good:
    continue
  result[(keyData, blob)] = buff

print result
