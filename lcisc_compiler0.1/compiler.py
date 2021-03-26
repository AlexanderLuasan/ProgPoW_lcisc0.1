


import vivado
import system_verilog

def make_project_file(file_name,included_files):
    with open(file_name,'w') as f:
        for file in included_files:
            f.write(f"sv work {file}\n")
    

def recursive_compile(sv_file,libraries):
    if(isinstance(sv_file,list)):
        compile_files = sv_file
        compile_paths = [i.path for i in sv_file]
    else:
        compile_files = [sv_file]
        compile_paths = [sv_file.path]

    return better_recusive_compile(compile_files,libraries)
    index = 0
    while(index < len(compile_files)):
        print(index,compile_paths)
        for i in compile_files[index].imports:
            to_compile = None
            for l in libraries:
                to_compile=l.find_package(i)
                if(to_compile!=None):
                    break
            
            if(to_compile==None):
                print("missing")
            elif(to_compile.path not in compile_paths):
                compile_files.append(to_compile)
                compile_paths.append(to_compile.path)
            elif(to_compile.path in compile_paths[:index-1]):
                del compile_files[compile_paths.index(to_compile.path )]
                del compile_paths[compile_paths.index(to_compile.path )]
                compile_files.append(to_compile)
                compile_paths.append(to_compile.path)
                index -=1
        index +=1
    return compile_paths

def better_recusive_compile(file_list,libs):
    all_paths = []
    path_to_obj = {

    }
    path_to_dependency = {

    }

    for file in file_list[::-1]:
        path_to_obj[file.path] =  file
        all_paths.append(file.path)
    
    for i in range(len(file_list)-1):
        path_to_dependency[file_list[i].path] = file_list[i+1].path

    index = 0
    while(index < len(all_paths)):
        current_search_file_path = all_paths[index]
        current_search_file_obj = path_to_obj[current_search_file_path]
        path_to_dependency[current_search_file_path] = []
        for i in current_search_file_obj.imports:#find the imports
            new_file = None
            for l in libs:
                new_file=l.find_package(i)
                if(new_file!=None):
                    break
            if(new_file==None):
                print("missing:",i)
            elif(new_file.path not in all_paths):#realy new
                all_paths.append(new_file.path)
                path_to_obj[new_file.path] =  new_file
            #always a dependency
            if(current_search_file_path != new_file.path):#no circle depdency
                path_to_dependency[current_search_file_path] = path_to_dependency.get(current_search_file_path,[]) + [new_file.path]
        index = index + 1
    #now work on solving the best return

    final_compile_order = []

    
    while(len(all_paths)>0):

        for not_added_file in all_paths:
            all_dependencies_meet = True
            for depdendecy in path_to_dependency[not_added_file]:
                if(depdendecy not in final_compile_order):
                    all_dependencies_meet = False
                    break
            if(all_dependencies_meet):
                final_compile_order.append(not_added_file)
                all_paths.remove(not_added_file)
                break
    return final_compile_order



    
    


    



if __name__ == "__main__":
    import lcsic
    a = lcsic.lcsic_design("design.lcisc")

    print(a.lib_folders[1].index.find_package("Adder"))

    files = recursive_compile(system_verilog.system_verilog_file("sv/PipelineStage.sv"),[l.index for l in a.lib_folders])[::-1]

    vivado.compile_sv_batch(files)

