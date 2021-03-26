'''
this file contains control methods of the vivado system
compile a file
search for dependencys
start a simulation
'''
import sys
import os


#the basic compile function uses the file path
def compile_sv(file_path):
    os.system(f"xvlog -sv {file_path}")

def compile_sv_batch(file_paths):
    spaced_files  = ' '.join(file_paths)
    os.system(f"xvlog -sv {spaced_files}")


def elab_sim(module,name):
    os.system(f"xelab -debug typical {module} -s {name}")
#xelab -debug typical top -s top_sim

def simulate(name):
    os.system(f"xsim {name} -gui")
    
if __name__ == "__main__":
    compile_sv(sys.argv[1])