import json
import "source"

type
    JsonSecondary = ref object of RootObj
        tbegin, tend, every : float
        grad : string
        kt :  float
        tempNeeded : bool
        temp : float
    Diapason = ref object of RootObj
        tbegin, tend : float
    Result = ref object of RootObj
        temp, value : float
        vis, sig : Diapason
    CalcResult = ref object of RootObj
        ed : string
        deltaVis, deltaSig: float
        result: seq[Result]

proc newJsonSecondary*(json : JsonNode) : JsonSecondary =
    if not json.hasKey("tempNeeded"):
        json["tempNeeded"] = %false
    if not json.hasKey("temp"):
        json["temp"] = %0.0
    to(json, JsonSecondary)

proc value(th : JsonSecondary, temp : float) : float =
    var grad : Graduation = th.grad.grad()
    if th.tempNeeded:
        return grad.value(temp + th.temp)
    else:
        return grad.value(temp)

proc calc*(th : JsonSecondary) : JsonNode =
    var 
        grad : Graduation = th.grad.grad()
        resseq : seq[Result] = @[]
        deltaVis : float = (grad.value(th.tend) - grad.value(th.tbegin)) * th.kt / 100
        deltaSig : float = (grad.value(th.tend) - grad.value(th.tbegin)) * (th.kt + 0.5) / 100
        i : float = th.tbegin
    while i <= th.tend:
        var vis, sig : tuple[tbegin, tend : float]
        var val : float = th.value(i)
        vis = (val - deltaVis, val + deltaVis)
        sig = (val - deltaSig, val + deltaSig)
        resseq.add(
            Result(
                temp : i,
                value : val,
                vis : Diapason(tbegin : vis.tbegin, tend : vis.tend),
                sig : Diapason(tbegin : sig.tbegin, tend : sig.tend)
            )
        )
        i += th.every
    return
        %CalcResult(
            ed: $grad.ed(),
            deltaVis: deltaVis,
            deltaSig: deltaSig,
            result: resseq
        )
