import json
import "source"

type
    JsonThermocouple = ref object of RootObj
        etValue, ptValue : float
        etPriv, ptPriv : float
        etGrad, ptGrad : string
    CalcResult = ref object of RootObj
        epr, esk : float
        tpr, tsk : float
        realTemp : float
        diffM, diffC, diffP : float

proc newJsonThermocouple*(json : JsonNode) : JsonThermocouple =
    to(json, JsonThermocouple)

proc calc*(th : JsonThermocouple) : JsonNode =
    var
        etGrad : Graduation = th.etGrad.grad()
        ptGrad : Graduation = th.ptGrad.grad()
        esk = etGrad.value(th.etPriv)
        epr = esk + th.etValue
        tsk = ptGrad.value(th.ptPriv)
        tpr = tsk + th.ptValue
        realTemp = etGrad.temp(epr)
        diffM = tpr - ptGrad.value(realTemp)
        diffC = ptGrad.temp(abs(diffM))
        diffP = (tpr / ptGrad.value(realTemp) - 1) * 100
    return
        %CalcResult(
            epr: epr, esk: esk,
            tpr: tpr, tsk: tsk,
            realTemp: realTemp,
            diffM: diffM, diffC: diffC, diffP: diffP
        )
