'''
build an index in the lib folder to locate things in the future




'''
from system_verilog import system_verilog_file
import os


def index_sv_files(folder):
    objects = os.listdir(folder)
    nodes = []
    for obj in objects:
        obj_name = folder+"/"+ obj
        if os.path.isdir(obj_name):#directory
            nodes.extend(index_sv_files(obj_name))
        elif os.path.isfile(obj_name):
            if(obj_name[-3::] == ".sv"):
                nodes.append(system_verilog_file(obj_name))
    return nodes

class MISSING_SV_PACKAGE(Exception):
    pass

class library:
    def __init__(self,path):

        self.sv_files = index_sv_files(path)

    def find_package(self,pkg_name):
        for i in self.sv_files:
            if pkg_name in i.packages:
                return i


    def matching(self,func):
        end = []
        for sv_file in self.sv_files:
            if(func(sv_file)):
                end.append(sv_file)
        return end
        

if __name__ == "__main__":
    lib_folder = library("/home/alexander/Documents/lib")

    for i in lib_folder.sv_files:
        print(i.path,i.modules.keys())

    print(lib_folder.matching(lambda x: x.has_module("Scheduler"))[0].path)






