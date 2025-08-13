classdef Utils

    methods (Static)

        function saveFigure(fileName, dir)

            if nargin == 1
                saveFolder = fullfile(pwd, "figures");
                if ~exist(saveFolder, 'dir')
                    mkdir(saveFolder);
                end
            elseif nargin == 2
                saveFolder = dir;
            end

            fullPath = fullfile(saveFolder, fileName);
            saveas(gcf, fullPath);
            

        end

    end

end