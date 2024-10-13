import asyncdispatch
import jester
import json
import strformat
import logging
import os
import "source"
import "thermometr", "thermocouple", "secondary"

let args: seq[string] = os.commandLineParams()

var level: Level = lvlInfo
if args.contains("-debug"):
  level = lvlAll

let log: Logger =
  newConsoleLogger(levelThreshold = level, fmtStr = "[$datetime] - $levelname: ")

logging.addHandler(log)
logging.info("Start")

routes:
  get "/":
    resp readFile("public/index.html")

  get "/api/grads/@name/":
    var rsp: JsonNode
    if @"name" == "thermometers":
      rsp = thermometers()
    elif @"name" == "thermocouples":
      rsp = thermocouples()
    else:
      rsp = allGrads()
    resp(Http200, $rsp, contentType = "application/json")

  post "/primary/thermocouple/":
    try:
      var body: JsonNode = parseJson(request.body)
      logging.info(fmt"primaryThermocouple: body = {body}")
      var rsp: JsonNode = newJsonThermocouple(body).calc()
      resp(Http200, $rsp, contentType = "application/json")
    except:
      var rsp: JsonNode = %*{"error": getCurrentExceptionMsg()}
      resp(Http400, $rsp, contentType = "application/json")

  post "/primary/thermometr/":
    try:
      var body: JsonNode = parseJson(request.body)
      logging.info(fmt"primaryThermometr: body = {body}")
      var rsp: JsonNode = newJsonThermometr(body).calc()
      resp(Http200, $rsp, contentType = "application/json")
    except:
      var rsp: JsonNode = %*{"error": getCurrentExceptionMsg()}
      resp(Http400, $rsp, contentType = "application/json")

  post "/secondary/":
    try:
      var body: JsonNode = parseJson(request.body)
      logging.info(fmt"secondary: body = {body}")
      var rsp: JsonNode = newJsonSecondary(body).calc()
      resp(Http200, $rsp, contentType = "application/json")
    except:
      var rsp: JsonNode = %*{"error": getCurrentExceptionMsg()}
      resp(Http400, $rsp, contentType = "application/json")

runForever()
