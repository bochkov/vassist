import json
import math

type JsonThermometr = ref object of RootObj
  tbegin: float
  tend: float
  tevery: float
  t0: float
  t100: float

proc newJsonThermometr*(json: JsonNode): JsonThermometr =
  to(json, JsonThermometr)

proc next10(num: float): float =
  if num >= 0.01 and num < 0.1:
    return 0.1
  if num >= 0.1 and num < 1:
    return 1
  if num >= 1 and num < 10:
    return 10
  if num >= 10 and num < 100:
    return 100
  if num >= 100 and num < 1000:
    return 1000
  return 1

proc calc*(th: JsonThermometr): JsonNode =
  var
    res: JsonNode = %*{"colHeader": [], "rowHeader": [], "matrix": []}
    chdr: seq[float] = @[]
    rhdr: seq[float] = @[]
    cols: int = pow(th.tevery / next10(th.tevery), -1).toInt()
    rows: int = ((th.tend - th.tbegin) / cols.toFloat() / th.tevery).toInt()

  for i in 0 .. cols - 1:
    chdr.add(i.toFloat() * th.tevery)
  res["colHeader"] = %*chdr

  for i in 0 .. rows:
    rhdr.add(th.tbegin + th.tevery * i.toFloat() * cols.toFloat())
  res["rowHeader"] = %*rhdr

  var mtrx: JsonNode = newJArray()
  for i in 0 .. rows:
    var vval: JsonNode = newJArray()
    for j in 0 .. cols - 1:
      var val: float = rhdr[i] + chdr[j]
      if val > th.tend or val < th.tbegin:
        vval.add(%"NaN")
      else:
        vval.add(%(th.t0 + (th.t100 - th.t0) / 100 * val))

    mtrx.add(vval)
  res["matrix"] = mtrx
  return res
