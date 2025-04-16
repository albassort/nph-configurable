import tables
import sugar
import sequtils
import ./postgresssy
import ./cheaporm
import strformat
import pretty
func groupBy*[A,B,C](a : openArray[A],
                    b : proc(a : A) : B {.closure.},
                    c : proc(a : A) : C {.closure.}) : Table[B, seq[C]] {.inline, effectsOf: b, effectsOf: c.} =
  for x in a:
    let bOfX = b(x)
    let cOfX = c(x)
    if bOfX notin result:
      result[bOfX] = @[cOfX]
    else:
      result[bOfX].add(cOfX)

proc keyVal*[A,B,C](a : openArray[A],
        b : proc(a : A) : B {.closure.},
        c : proc(a : A) : C {.closure.}) : Table[B, C] {.inline, effectsOf: b, effectsOf: c.} =
  for x in a:
    let bOfX = b(x)
    let cOfX = c(x)
    result[bOfX] = cOfX
