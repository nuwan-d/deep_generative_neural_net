%% Generates LAMMPS data and input files for simulating the interaction between 2 defective regions and the job array submission file 
%% for the Digital Research Alliance of Canada

close all;
clear all;
clc;

delete arr.sh 
delete case_list.txt


%% Generate LAMMPS data and input files

for vac_concen=0.18:0.02:0.18
    
    for x_cen = 20:40:180
        
        for y_cen = 30:35:170
    
            for x_2_cen = 30:35:170
                
                for y_2_cen = 20:40:180


                    %vac_concen = 2; %vacancy percentage
                    %% obtaining coordinates of a pristine graphene sheet

                    load grap_3d_coord.mat

                    no_atom_to_delete = round(size(grap_3d_coord,1)*size(grap_3d_coord,2)*vac_concen);

                    %% get delete atm locations

                    for i = 1:no_atom_to_delete
                        delete_atm_location(i,1) = 1 + round((rand(1))*(size(grap_3d_coord,1)-1));
                        delete_atm_location(i,2) = 1 + round((rand(1))*(size(grap_3d_coord,2)-1));
                    end


                    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %% Delete atoms in circular regions of the sheet 

                    del_atm = 1;

                    for i = size(delete_atm_location,1):-1:1

                        x = delete_atm_location(i,1);
                        y = delete_atm_location(i,2);

                            if (sqrt((grap_3d_coord(x, y, 1)-x_cen)^2 + (grap_3d_coord(x, y, 2)- y_cen)^2) < 20) || sqrt((grap_3d_coord(x, y, 1)-x_2_cen)^2 + (grap_3d_coord(x, y, 2)- y_2_cen)^2) < 20

                                deleted_atoms(del_atm,:) = grap_3d_coord(x, y, 1:3);
                                grap_3d_coord(x, y, 1:3) = 10000;

                                del_atm = del_atm + 1;
                            end

                    end


                    no_atom_to_delete = size(deleted_atoms,1)

                    %% Delete atoms in a circular region

                    grap_1d_coord = reshape(grap_3d_coord,[], 3);

                    grap_1d_coord = sortrows(grap_1d_coord, 1, 'descend');

                    deleted_atoms_1d = reshape(grap_3d_coord,[], 3);

                    grap_1d_coord(1:no_atom_to_delete,:) = [];


                    %% plotting


                    figure(1)
                    plot(deleted_atoms(:,1),deleted_atoms(:,2),'o','MarkerSize',2,'MarkerEdgeColor','k','MarkerFaceColor','r')
                    axis equal
                    axis ([0 200 0 200])
                    


                    %% 

                    directory_name = ['',num2str(vac_concen),'_',num2str(x_cen),'_',num2str(y_cen),'_',num2str(x_2_cen),'_',num2str(y_2_cen)];

                     mkdir(directory_name); % make new folder; 
                     oldFolder = cd(directory_name); % go to the newly created folder while saving the current location in OldFolder;


                    %%
                    save('deleted_atoms.txt', 'deleted_atoms', '-ascii') 

                    %% creating data.file    
                    %% DATA.FILE

                        fid=fopen('grap.data','w');

                        fprintf(fid,'Graphene sheet containing vacancies\n');
                        fprintf(fid,'\n');
                        fprintf(fid,'%d atoms \n',size(grap_1d_coord,1));
                        fprintf(fid,'\n');
                        fprintf(fid,'%d atom types \n',1);
                        fprintf(fid,'\n');
                        fprintf(fid,'#simulation box \n');
                        fprintf(fid,'%f %f xlo xhi\n',min(grap_1d_coord(:,1))-20, max(grap_1d_coord(:,1))+20); % change this in an appropriate way for zig-zag and arm chair
                        fprintf(fid,'%f %f ylo yhi\n',-10, 210);
                        fprintf(fid,'%f %f zlo zhi\n',min(grap_1d_coord(:,3))-20, max(grap_1d_coord(:,3))+20);
                        fprintf(fid,'\n');
                        fprintf(fid,'Masses\n');
                        fprintf(fid,'\n');
                        fprintf(fid,'%d %f \n',1, 12.010000);
                        fprintf(fid,'\n');
                        fprintf(fid,'Atoms\n');
                        fprintf(fid,'\n');

                    %% define atoms

                        for i=1:size(grap_1d_coord,1)

                             fprintf(fid,'%d %d %f %f %f \n',i ,1, grap_1d_coord(i,1), grap_1d_coord(i,2), grap_1d_coord(i,3));

                        end

                    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %% IN.FILE

                    fid=fopen('grap.in','w');

                    fprintf(fid,'# Fracture of defective graphene sheet\n');
                    fprintf(fid,'\n');

                    fprintf(fid,'##---------------INITIALIZATION-------------------------------\n');
                    fprintf(fid,'\n');
                    fprintf(fid,'units          metal\n');
                    fprintf(fid,'dimension 	    3 \n');

                    fprintf(fid,'boundary       p p f\n');

                    fprintf(fid,'atom_style 	atomic\n');
                    fprintf(fid,'newton 		on \n');
                    fprintf(fid,'\n');
                    fprintf(fid,'\n');

                    fprintf(fid,'##---------------ATOM DEFINITION------------------------------\n');
                    fprintf(fid,'\n');
                    fprintf(fid,'read_data 	grap.data \n');
                    fprintf(fid,'\n');
                    fprintf(fid,'\n');

                    fprintf(fid,'region     active_grap block INF INF 3.0 196 INF INF\n');
                    fprintf(fid,'group      active_grap region active_grap\n');
                    fprintf(fid,'\n');
                    fprintf(fid,'\n');


                    fprintf(fid,'##---------------FORCE FIELDS---------------------------------\n');
                    fprintf(fid,'\n');
                    fprintf(fid,'pair_style 	airebo 3.0 \n');
                    fprintf(fid,'pair_coeff     * * /PATH/CH.airebo C\n');
                    fprintf(fid,'\n');
                    fprintf(fid,'\n');

                    fprintf(fid,'##---------------SETTINGS-------------------------------------\n');
                    fprintf(fid,'\n');
                    fprintf(fid,'timestep 	0.0005\n');
                    fprintf(fid,'variable   ts equal 0.0005\n');
                    fprintf(fid,'\n');
                    fprintf(fid,'\n');


                    fprintf(fid,'##---------------COMPUTES-------------------------------------\n');
                    fprintf(fid,'\n');
                    fprintf(fid,'compute 	1 active_grap stress/atom NULL\n');
                    fprintf(fid,'compute 	2 active_grap property/atom x y\n'); 
                    fprintf(fid,'compute 	3 active_grap pe/atom \n'); 
                    fprintf(fid,'\n');


                    fprintf(fid,'fix    2a active_grap ave/atom 1 20000 40000 c_1[1] c_1[2] c_1[4] c_2[*] c_3\n');

                    fprintf(fid,'\n');
                    fprintf(fid,'\n');
                    fprintf(fid,'\n');


                    fprintf(fid,'fix		1a active_grap nve\n');
                    fprintf(fid,'fix        1b active_grap langevin 300 300 0.05 48279 \n');


                    fprintf(fid,'thermo 	1000\n');

                    fprintf(fid,'##---------------RELAXATION--------------------------------------\n');
                    fprintf(fid,'\n');
                    fprintf(fid,'run            40000\n');
                    fprintf(fid,'dump           4b active_grap custom 40000 dump.data.* id f_2a[*]\n');
                    fprintf(fid,'\n');
                    fprintf(fid,'\n');

                    fprintf(fid,'##---------------DEFORMATION--------------------------------------\n');
                    fprintf(fid,'\n');
                    fprintf(fid,'\n');
                    fprintf(fid,'change_box     all y final -10 212.2 remap\n');
                    fprintf(fid,'run            40000\n');
                    fprintf(fid,'\n');
                    fprintf(fid,'\n');
                    fprintf(fid,'change_box     all y final -10 214.4 remap\n');
                    fprintf(fid,'run            40000\n');
                    fprintf(fid,'\n');
                    fprintf(fid,'\n');
                    fprintf(fid,'change_box     all y final -10 216.6 remap\n');
                    fprintf(fid,'run            40000\n');
                    fprintf(fid,'\n');
                    fprintf(fid,'\n');
                    fprintf(fid,'change_box     all y final -10 218.8 remap\n');
                    fprintf(fid,'run            40000\n');
                    fprintf(fid,'\n');
                    fprintf(fid,'\n');
                    fprintf(fid,'change_box     all y final -10 221 remap\n');
                    fprintf(fid,'run            40000\n');

                    fclose(fid);


                    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                    cd(oldFolder) % come back to OldFolder

                    clear grap_1d_coord deleted_atoms

                    
                end
                
                fclose all;

            end
           
        end
        
    end
    
end


%% array job submition file for Compute Canada
    
fid=fopen('arr.sh','w');  %$sbatch file_name.sh

fprintf(fid,'#!/bin/bash\n');
fprintf(fid,'#SBATCH --account=YOUR_ACCOUNT\n');
fprintf(fid,'#SBATCH --nodes=1\n');
fprintf(fid,'#SBATCH --ntasks-per-node=32\n'); 
fprintf(fid,'#SBATCH --mem=0\n');
fprintf(fid,'#SBATCH --time=00-1:58\n'); 
fprintf(fid,'#SBATCH --mail-user=YOUR_EMAIL\n');
fprintf(fid,'#SBATCH --job-name=2_vac_0.18\n');
fprintf(fid,'#SBATCH --output=%%J.log\n');
fprintf(fid,'#SBATCH --array=1-625\n');

fprintf(fid,'\n');
fprintf(fid,'# Load the module:\n');

fprintf(fid,'\n');
fprintf(fid,'module load StdEnv/2020  intel/2020.1.217  openmpi/4.0.3 lammps-omp/20201029\n');

fprintf(fid,'\n');
fprintf(fid,'echo "Starting task $SLURM_ARRAY_TASK_ID"\n');
fprintf(fid,'DIR=$(sed -n "${SLURM_ARRAY_TASK_ID}p" case_list.txt)\n');
fprintf(fid,'cd $DIR\n');

fprintf(fid,'\n');
fprintf(fid,'echo "Starting run at: `date`"\n');

fprintf(fid,'\n');
fprintf(fid,'lmp_exec=lmp_icc_openmpi\n');
fprintf(fid,'lmp_input="grap.in"\n');
fprintf(fid,'lmp_output="lammps_output.txt"\n');

fprintf(fid,'\n');
fprintf(fid,'srun ${lmp_exec} < ${lmp_input} > ${lmp_output}\n');

fprintf(fid,'\n');
fprintf(fid,'echo "Program finished with exit code $? at: `date`"\n');
fprintf(fid,'\n');

fclose(fid);


%% CREATING CASE-LIST FILE

delete case_list.txt

for vac_concen=0.18:0.02:0.18
    
    for x_cen = 20:40:180
        
        for y_cen = 30:35:170
    
            for x_2_cen = 30:35:170
                
                for y_2_cen = 20:40:180
                
                    sub_file_id=fopen('case_list.txt','a');

                    directory_name = ['',num2str(vac_concen),'_',num2str(x_cen),'_',num2str(y_cen),'_',num2str(x_2_cen),'_',num2str(y_2_cen)];

                    fprintf(sub_file_id,'%s\n', directory_name);
                end   

            end

        end

    end
    
end

fclose(sub_file_id);
