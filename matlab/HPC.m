classdef HPC < handle
    properties (Access = public)
        TotalIterations
        Completed = 0
    end

    methods
        function obj = HPC(total)
            obj.TotalIterations = total;
        end

        function updateProgress(obj, ~)
            obj.Completed = obj.Completed + 1;
            fprintf('Progress: %d / %d\n', obj.Completed, obj.TotalIterations);
        end
    end
end