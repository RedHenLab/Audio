import subprocess, sys, os
from ..utils.utils import Commandline
import commands

def CallPanako(subapp, arglist, DB_path = None):
    #check if the path for the database exist already, if not, fail
    current_module = sys.modules[__name__]
    jar_path = os.path.join(os.path.dirname(os.path.abspath(current_module.__file__)), "panako1/panako.jar")
    if DB_path is not None:
        _, err = commands.getstatusoutput("cd "+DB_path)
        # _, err, _ = Commandline(["cd", DB_path])
        if err != "":
            raise NameError(err)
            sys.exit(0)
        Place(os.path.join(DB_path, "dbs"))
        return Commandline(["java", "-jar", jar_path, subapp] + arglist, os.path.join(DB_path,"dbs"))
    else :
        Place("dbs")
        return Commandline(["java", "-jar", jar_path, subapp] + arglist, "dbs")
    

def Store(Audio_path, db_path = None):
    subapp = "store"
    Audio_path = os.path.abspath(Audio_path)
    db_path = os.path.abspath(db_path)
    return CallPanako(subapp, [Audio_path], db_path)

def Query(Audio_path, db_path = None):
    subapp = "query"
    Audio_path = os.path.abspath(Audio_path)
    return CallPanako(subapp, [Audio_path], db_path)

def Place(Store_path):
    return Commandline(["mkdir", Store_path])

