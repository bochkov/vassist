import json
import macros

type
    ResException* = object of Exception
    ThRes = ref object of RootObj
    Graduation* = ref object of RootObj
    Thermocouple* = ref object of Graduation
    Thermometr* = ref object of Graduation

proc name*(gr : Graduation) : cstring {. dynlib:"libthermo.so" importc:"th_name" .}
proc desciption*(gr : Graduation) : cstring {. dynlib:"libthermo.so" importc:"th_description" .}

proc value0(gr : Graduation, temp : float) : ThRes {. dynlib:"libthermo.so" importc:"th_value" .}
proc temp0(gr : Graduation, value : float) : ThRes {. dynlib:"libthermo.so" importc:"th_temp" .}

proc success(res : ThRes) : bool {. dynlib:"libthermo.so" importc:"tres_success" .}
proc val(res : ThRes) : float {. dynlib:"libthermo.so" importc:"tres_val" .}
proc err(res : ThRes) : cstring {. dynlib:"libthermo.so" importc:"tres_err" .}

proc value*(gr : Graduation, temp : float) : float =
    var res : ThRes = gr.value0(temp)
    if res.success():
        return res.val()
    else:
        raise newException(ResException, $res.err())

proc temp*(gr : Graduation, value : float) : float =
    var res : ThRes = gr.temp0(value)
    if res.success():
        return res.val()
    else:
        raise newException(ResException, $res.err())

type
    JKJ* = ref object of Thermocouple
    MKM* = ref object of Thermocouple
    MKT* = ref object of Thermocouple
    NNN* = ref object of Thermocouple
    PPR* = ref object of Thermocouple
    PPS* = ref object of Thermocouple
    PRB* = ref object of Thermocouple
    XAK* = ref object of Thermocouple
    XKL* = ref object of Thermocouple
    XKnE* = ref object of Thermocouple
    VRA1* = ref object of Thermocouple
    VRA2* = ref object of Thermocouple
    VRA3* = ref object of Thermocouple

proc newJKJ*() : JKJ {. dynlib:"libthermo.so" importc:"th_new_jkj" .}
proc newMKM*() : MKM {. dynlib:"libthermo.so" importc:"th_new_mkm" .}
proc newMKT*() : MKT {. dynlib:"libthermo.so" importc:"th_new_mkt" .}
proc newNNN*() : NNN {. dynlib:"libthermo.so" importc:"th_new_nnn" .}
proc newPPR*() : PPR {. dynlib:"libthermo.so" importc:"th_new_ppr" .}
proc newPPS*() : PPS {. dynlib:"libthermo.so" importc:"th_new_pps" .}
proc newPRB*() : PRB {. dynlib:"libthermo.so" importc:"th_new_prb" .}
proc newXAK*() : XAK {. dynlib:"libthermo.so" importc:"th_new_xak" .}
proc newXKL*() : XKL {. dynlib:"libthermo.so" importc:"th_new_xkl" .}
proc newXKnE*() : XKnE {. dynlib:"libthermo.so" importc:"th_new_xkne" .}
proc newVRA1*() : VRA1 {. dynlib:"libthermo.so" importc:"th_new_vra1" .}
proc newVRA2*() : VRA2 {. dynlib:"libthermo.so" importc:"th_new_vra2" .}
proc newVRA3*() : VRA3 {. dynlib:"libthermo.so" importc:"th_new_vra3" .}

type
    Pt* = ref object of Thermometr
    TSM* = ref object of Thermometr
    TSN* = ref object of Thermometr
    TSP* = ref object of Thermometr

proc newPt*(r : float) : Pt {. dynlib:"libthermo.so" importc:"th_new_pt" .}
proc newTSM*(r : float) : TSM {. dynlib:"libthermo.so" importc:"th_new_tsm" .}
proc newTSN*(r : float) : TSN {. dynlib:"libthermo.so" importc:"th_new_tsn" .}
proc newTSP*(r : float) : TSP {. dynlib:"libthermo.so" importc:"th_new_tsp" .}

proc `%=`(gr : Graduation) : JsonNode =
    return %* {"name": $gr.name()}

proc thermocouples*() : JsonNode =
    return %* [
        %=newPPS(), %=newPPR(), %=newXAK(), %=newXKL(),
        %=newJKJ(), %=newMKM(), %=newMKT(), %=newNNN(),
        %=newPRB(), %=newXKnE(), %=newVRA1(), 
        %=newVRA2(), %=newVRA3()
    ]

proc thermometers*() : JsonNode =
    return %* [
        %=newPt(100), %=newTSM(50), %=newTSM(100), %=newTSP(50),
        %=newTSP(100), %=newTSN(100)
    ]

proc allGrads*() : JsonNode =
    var res : JsonNode = %[]
    res.add(thermocouples())
    res.add(thermometers())
    return res

proc ed*(th : Graduation) : string =
    if th is Thermocouple:
        return "мВ"
    elif th is Thermometr:
        return "Ом"
    else:
        return ""

proc grad*(name : string) : Graduation =
    case name:
        of "ТПП(S)":
            return newPPS()
        of "ТПП(R)":
            return newPPR()
        of "ТХА(K)":
            return newXAK()
        of "ТХК(L)":
            return newXKL()
        of "ТЖК(J)":
            return newJKJ()
        of "ТМК(M)":
            return newMKM()
        of "ТМК(T)":
            return newMKT()
        of "ТНН(N)":
            return newNNN()
        of "ТПР(B)":
            return newPRB()
        of "ТХКн(E)":
            return newXKnE()
        of "ТВР(A-1)":
            return newVRA1()
        of "ТВР(A-2)":
            return newVRA1()
        of "ТВР(A-3)":
            return newVRA1()
        of "Pt100":
            return newPt(100)
        of "50М":
            return newTSM(50)
        of "100М":
            return newTSM(100)
        of "50П":
            return newTSP(50)
        of "100П":
            return newTSP(100)
        of "100Н":
            return newTSN(100)
        else:
            raise newException(ResException, "Cannot evaluate graduation")
