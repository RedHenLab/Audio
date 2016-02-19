import subprocess, sys, os
from ..utils.utils import Commandline

def CallPanako(subapp, arglist, DB_path = None):
    #check if the path for the database exist already, if not, fail
    current_module = sys.modules[__name__]
    jar_path = os.path.join(os.path.dirname(os.path.abspath(current_module.__file__)), "panako/panako.jar")
    if DB_path is not None:
        _, err, _ = Commandline(["cd", DB_path])
        if err != "":
            raise NameError(err)
            sys.exit(0)
        Place(os.path.join(DB_path, "dbs"))
        return Commandline(["java", "-jar", jar_path, subapp] + arglist, DB_path)
    else :
        Place("dbs")
        return Commandline(["java", "-jar", jar_path, subapp] + arglist)
    

def Store(Audio_path, db_path = None):
    subapp = "store"
    Audio_path = os.path.abspath(Audio_path)
    return CallPanako(subapp, [Audio_path], db_path)

def Query(Audio_path, db_path = None):
    subapp = "query"
    Audio_path = os.path.abspath(Audio_path)
    return CallPanako(subapp, [Audio_path], db_path)

def Place(Store_path):
    return Commandline(["mkdir", Store_path])

