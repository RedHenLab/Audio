from time import localtime, strftime
import sys, getopt
import commands, os


class Node(object):
    
    def __init__(self, Data_dir, Ext=None):
        self.folder = Data_dir
        self.ext = Ext
        print commands.getstatusoutput("mkdir -p "+Data_dir)
    
    def Flow(self, func, fn, dest_node, args):
        src_file = os.path.join(self.folder, fn+self.ext)
        if type(args) is dict:
            return func(src_file, dest_node.folder, **args)
        else:
            return func(src_file, dest_node.folder, *args)
        
    def Pick(self, fn):
        return os.path.join(self.folder, fn+self.ext)
