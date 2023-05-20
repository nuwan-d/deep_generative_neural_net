%% This script extracts atomic positions from the LAMMPS simulation files and generates image data for modeling cGAN. The LAMMPS input/data files can be generated from the script "generate_lammps_input_data_files.m" in this repository.

close all;
clear all;
clc;

mkdir('disp_distibution_yy')

for vac_concen=0.14:0.02:0.14
    
    for x_cen = 20:40:180
        
        for y_cen = 30:35:170
    
            for x_2_cen = 30:35:170
                
                for y_2_cen = 20:40:180
                                
            
                %% Get initial equilbrated coordinates
                      
 		directory_name = ['',num2str(vac_concen),'_',num2str(x_cen),'_',num2str(y_cen),'_',num2str(x_2_cen),'_',num2str(y_2_cen)];
           
                oldFolder = cd(directory_name); 
                
                if exist('dump.data.40000')

                    fileID_1 = fopen('dump.data.40000');

                    %% read the fist 8 lines, but do nothing
                    for k=1:5
                    tline = fgets(fileID_1);
                    end

                    %% get box-dim
                    formatSpec = '%f %f';
                    sizeA = [2 Inf];

                    box_dim_initial = fscanf(fileID_1,formatSpec,sizeA);

                    %% skip the next line

                    tline = fgets(fileID_1);

                    %% Scan from the line 9

                    [ini_coords,count] = fscanf(fileID_1, '%d %*f %*f %*f %f %f %*f ',[3,inf]);

                    ini_coords = sortrows(ini_coords',1); % get data in columns
                    
                    fclose(fileID_1);

                    cd(oldFolder)
                    
                else
                        
                        cd(oldFolder) 
                end
                
            
            for time_step = 80000:40000:240000
                          

 	      directory_name = ['',num2str(vac_concen),'_',num2str(x_cen),'_',num2str(y_cen),'_',num2str(x_2_cen),'_',num2str(y_2_cen)];

            
            oldFolder = cd(directory_name); % go to the newly created folder while saving the current location in OldFolder;
                
                    s1 = 'dump.data.';
                    s2 = num2str(time_step);
                    dump_file_name = strcat(s1,s2);
                    
                    if exist(dump_file_name)

                        fileID = fopen(dump_file_name);

                        %% read the fist 8 lines, but do nothing
                        for k=1:5
                        tline = fgets(fileID);
                        end

                        %% get box-dim
                        formatSpec = '%f %f';
                        sizeA = [2 Inf];

                        box_dim = fscanf(fileID,formatSpec,sizeA);
                        box_dim = box_dim';
                        box_vol = (box_dim(1,2) - box_dim(1,1))*(box_dim(2,2) - box_dim(2,1))*(box_dim(3,2) - box_dim(3,1));
                        %% skip the next line

                        tline = fgets(fileID);

                        %% Scan from the line 9

                        [data,count] = fscanf(fileID, '%d %*f %*f %*f %f %f %*f ',[3,inf]);

                        data = sortrows(data',1); % get data in columns


                        fclose(fileID);
                        %% 
                        cd(oldFolder) % come back to OldFolder
                        cd('disp_distibution_yy');

                     %% Plotting displacement

                    displacement = (data(:,3) - ini_coords(:,3));% - (min(data(:,3)) - min(ini_coords(:,3))); % the second part remove the displacement component due to rescaling of the box
                    strain = displacement./((ini_coords(:,3)) + 10); % adjusting for the box size, which starts at y coord of -10

                    figure
                    h = scatter(ini_coords(:,2),ini_coords(:,3),3,strain(:,1),'fill');
                    colormap('jet') 
                    caxis([0 0.08])
                    %colormap('hsv') 
                    axis equal  
                    axis off
   

                    %% removing boarders

                    set(gca,'units','pixels'); % set the axes units to pixels
                    x = get(gca,'position'); % get the position of the axes
                    set(gcf,'units','pixels'); % set the figure units to pixels
                    y = get(gcf,'position'); % get the figure position
                    set(gcf,'position',[y(1) y(2) x(3) x(4)])% set the position of the figure to the length and width of the axes
                    set(gca,'units','normalized','position',[0 0 1 1]) % set the axes units to pixels

                    paperWidth = 2;
                    paperHeight = paperWidth;
                    set(gcf, 'paperunits', 'inches');
                    set(gcf, 'papersize', [paperWidth paperHeight]);
                    set(gcf, 'PaperPosition', [0    0   paperWidth paperHeight]);


                    %% getting file name 

                    s1 = 'disp_';
                    s2 = num2str(time_step/(4*10^(6))-0.01);
                    s3 = '.jpeg';
                    fig_name = strcat(directory_name,'_',s1,s2,s3);

                    %% saving file
                     print(gcf,'-djpeg',fig_name);
                
%                  clear fileID
                   cd(oldFolder) % come back to OldFolder
                     
                     
                    else
                        
                        cd(oldFolder) 
                        
                    end

            end

            end
            
        end
        
    end
    
end

end