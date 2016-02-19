import subprocess

def Commandline(arglist, cwd_path = None):
    p = subprocess.Popen(arglist,
                         stdout = subprocess.PIPE, stderr = subprocess.PIPE, cwd = cwd_path)
    output, err = p.communicate()
    exitcode = p.returncode
    return output, err, exitcode