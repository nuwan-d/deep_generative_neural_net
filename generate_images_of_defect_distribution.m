%% This script extracts the coordinated of deleted atoms by the script "generate_lammps_input_data_files.m" and generates image data for modeling cGAN.


close all;
clear all;
clc;

mkdir('defect_distibution')

for vac_concen=0.14:0.02:0.14
    
    for x_cen = 20:40:180
        
        for y_cen = 30:35:170
    
            for x_2_cen = 30:35:170
                
                for y_2_cen = 20:40:180
                                 
                    directory_name = ['',num2str(vac_concen),'_',num2str(x_cen),'_',num2str(y_cen),'_',num2str(x_2_cen),'_',num2str(y_2_cen)];

                    oldFolder = cd(directory_name); % go to the newly created folder while saving the current location in OldFolder; SHOULD BE CHANGED FOR DIFFRENT WIDTHS

                    fileID = fopen('deleted_atoms.txt');

                    [data,count] = fscanf(fileID, '%f %f %*f ',[2,inf]);

                    fclose(fileID);

                    data = data';

                        %% 
                        cd(oldFolder) % come back to OldFolder
                        cd('defect_distibution');

                        %%

                        figure
                        plot(data(:,1),data(:,2),'ok', 'MarkerSize',3,'MarkerFaceColor','k'); 

                        axis equal  
                        axis off
                        
                        axis([0 200 0 200])

    %                     c = colorbar('southoutside');                

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

                          fig_name = directory_name;

                        %% saving file
                         print(gcf,'-djpeg',fig_name);
                         
                         rgbImage = imread(fig_name);
                         delete(fig_name);
                         rgbImage = imresize(rgbImage,[256, 256]);
                         
%                          figure
%                          imshow(rgbImage)
                         
                        %% write five images for the five strains
                        
                         fig_name = strcat(directory_name,"_0.01.jpeg");
                         imwrite(rgbImage,fig_name)
                         
                         fig_name = strcat(directory_name,"_0.02.jpeg");
                         imwrite(rgbImage,fig_name)
                         
                         fig_name = strcat(directory_name,"_0.03.jpeg");
                         imwrite(rgbImage,fig_name)
                                                  
                         fig_name = strcat(directory_name,"_0.04.jpeg");
                         imwrite(rgbImage,fig_name)
                                                  
                         fig_name = strcat(directory_name,"_0.05.jpeg");
                         imwrite(rgbImage,fig_name)
                         
                         close

                         clear fileID
                         cd(oldFolder) % come back to OldFolder

                end

            end

        end

    end

end
    
