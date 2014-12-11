import json, sys

from glob import glob
from xml.dom.minidom import *


result = []
print sys.argv
f_len = len(glob("%s/*.xml" % (sys.argv[1],)))


for i, f in enumerate(glob("%s/*.xml" % (sys.argv[1],))):
  print i, "/", f_len, "(", round(float(i) / float(f_len) * 100, 2), ")"

  # try:
  xml = parse(f)
  memberdef = xml.getElementsByTagName('memberdef')
  snippets = []

  for node in memberdef:
    func_name, arg_string = "", ""

    if node.getAttribute("kind") == "function":
      if len(node.getElementsByTagName("name")) and node.getElementsByTagName("name")[0].firstChild:
        func_name = node.getElementsByTagName("name")[0].firstChild.nodeValue

      argsstring = node.getElementsByTagName("argsstring")[0].firstChild.nodeValue
      args = argsstring.split(",")

      for i, arg in enumerate(args):
        args[i] = "${%d:%s}" % (i + 1, arg)

      arg_string = "(%s)" % (", ".join(args).replace("(", "").replace(")", ""),)

    elif node.getAttribute("kind") == "define":
      if len(node.getElementsByTagName("name")) and node.getElementsByTagName("name")[0].firstChild:
        func_name = node.getElementsByTagName("name")[0].firstChild.nodeValue

      for i, param in enumerate(node.getElementsByTagName("param")):
        if len(param.getElementsByTagName("defname")):
          arg_string += "${%d:%s}, " % (i + 1, param.getElementsByTagName("defname")[0].firstChild.nodeValue,)

      if len(arg_string):
        arg_string = "(%s)" % arg_string[0:-2]

    elif node.getAttribute("kind") == "enum":
      for ename in node.getElementsByTagName("enumvalue"):
        func_name = ename.getElementsByTagName("name")[0].firstChild.nodeValue
        result.append({"trigger": func_name, "contents": ("%s %s" % (func_name, arg_string)).strip()})

      func_name = ""

    elif node.getAttribute("kind") == "typedef":
      func_name = node.getElementsByTagName("name")[0].firstChild.nodeValue


    if func_name:
      result.append({"trigger": func_name, "contents": ("%s %s" % (func_name, arg_string)).strip()})
  # except Exception, e:
  #   pass

print "total: ", len(result)

f = open("%s.sublime-completions" % (sys.argv[2],), "wb")

result = {
  "scope": "source.c99",
  "completions": result
}

json.dump(result, f, indent=2)

f.close()

