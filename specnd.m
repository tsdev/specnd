classdef    specnd
    properties
        raw
        % Field that stores all data of a specnd object
        % Sub fields are:
        %   'datcnt'    matrix, stores the data values, dimensions are:
        %                   event mode:
        %                   nAxis(1) x nAxis(2) x ... x nAxis(nDim) x nCh
        %                   grid mode:
        %                   nPoint 
        %   'errmon'    matrix, stores the error/monitor values
        %   'g'         matrix, g-tensor
        %   'param'     struct, stores parameter information, sub fields
        %               are name, label, value
        %   'axis'      struct, stores information on each axis vector, sub
        %               fields are name, label, value
        %   'channel'   struct, stores information on each data channel,
        %               sub fields are name, label
        %
        %               3 x nMagExt matrix, where nMagExt = nMagAtom*prod(N_ext)
        %   'k'         magnetic ordering wave vector in a 3x1 vector
        %   'n'         normal vector to the rotation of the moments in
        %               case of non-zero ordering wave vector, dimensions
        %               are 3x1
        %   'N_ext'     Size of the magnetic supercell, default is [1 1 1]
        %               if the magnetic cell is identical to the
        %               crystallographic cell, the 1x3 vector extends the
        %               cell along the a, b and c axis
        %
        % See also SW.GENMAGSTR, SW.OPTMAGSTR, SW.ANNEAL, SW.MOMENT, SW.NMAGEXT, SW.STRUCTFACT.
        
    end
    methods
        function D = specnd(varargin)
        end
    end
    
end