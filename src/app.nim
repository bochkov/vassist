import jester, asyncdispatch
import json
import logging
import os
import "source"
import "thermometr", "thermocouple", "secondary"

let 
  cpars : seq[string] = commandLineParams()

var level = lvlInfo
if cpars.contains("-debug"):
  level = lvlAll
let log : Logger = newConsoleLogger(levelThreshold = level)
addHandler(log)

routes:
    get "/":
        resp readFile("public/index.html")

    get "/api/grads/@name/":
        var rsp : JsonNode
        if @"name" == "thermometers":
            rsp = thermometers()
        elif @"name" == "thermocouples":
            rsp = thermocouples()
        else:
            rsp = allGrads()
        resp(Http200, $rsp, contentType = "application/json")

    post "/primary/thermocouple/":
        try:
            var rsp : JsonNode =
                newJsonThermocouple(
                    parseJson(request.body)
                ).calc()
            resp(Http200, $rsp, contentType = "application/json")
        except:
            var rsp : JsonNode = %* {"error": getCurrentExceptionMsg()}
            resp(Http400, $rsp, contentType = "application/json")

    post "/primary/thermometr/":
        try:
            var rsp : JsonNode = 
                newJsonThermometr(
                    parseJson(request.body)
                ).calc()
            resp(Http200, $rsp, contentType = "application/json")
        except:
            var rsp : JsonNode = %* {"error": getCurrentExceptionMsg()}
            resp(Http400, $rsp, contentType = "application/json")

    post "/secondary/":
        try:
            var rsp : JsonNode =
                newJsonSecondary(
                    parseJson(request.body)
                ).calc()
            resp(Http200, $rsp, contentType = "application/json")
        except:
            var rsp : JsonNode = %* {"error": getCurrentExceptionMsg()}
            resp(Http400, $rsp, contentType = "application/json")

runForever()
