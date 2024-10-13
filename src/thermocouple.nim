import json
import "source"

type
  JsonThermocouple = ref object of RootObj
    etValue, ptValue: float
    etPriv, ptPriv: float
    etGrad, ptGrad: string

  CalcResult = ref object of RootObj
    epr, esk: float
    tpr, tsk: float
    realTemp: float
    diffM, diffC, diffP: float

proc newJsonThermocouple*(json: JsonNode): JsonThermocouple =
  to(json, JsonThermocouple)

proc calc*(th: JsonThermocouple): JsonNode =
  var
    etGrad: Graduation = th.etGrad.grad()
    ptGrad: Graduation = th.ptGrad.grad()
    esk: float = etGrad.value(th.etPriv)
    epr: float = esk + th.etValue
    tsk: float = ptGrad.value(th.ptPriv)
    tpr: float = tsk + th.ptValue
    realTemp: float = etGrad.temp(epr)
    diffM: float = tpr - ptGrad.value(realTemp)
    diffC: float = ptGrad.temp(abs(diffM))
    diffP: float = (tpr / ptGrad.value(realTemp) - 1) * 100
  return
    %CalcResult(
      epr: epr,
      esk: esk,
      tpr: tpr,
      tsk: tsk,
      realTemp: realTemp,
      diffM: diffM,
      diffC: diffC,
      diffP: diffP,
    )
