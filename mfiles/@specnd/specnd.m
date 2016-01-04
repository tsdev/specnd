classdef specnd < handle
    properties
        % Fields that stores all data of a specnd object
        % Sub fields are:
        %   'sig'       struct, sub fields are value, error, name, label. The
        %        value subfield is a matrix, stores the signal
        %               values, dimensions are:
        %                   grid mode:
        %                   nAxis(1) x nAxis(2) x ... x nAxis(nDim) x nCh
        %                   event mode:
        %                   nPoint x 1
        %         error subfield stores the error of the signal
        %               values in a matrix, the matrix either has the same
        %               dimensions as the value matrix, or a scalar for
        %               uniform error
        %       monitor subfield stores the monitor for each signal value
        %               in a matrix, the matrix either has the same
        %               dimensions as the value matrix, or a scalar for
        %               uniform monitor value
        %   'g'         struc variable, with subfields value, name and
        %               label. The value is a matrix, g-tensor, dimensions
        %               are nDim x nDim or scalar 1 for Descartes
        %               coordinate system.
        %   'par'       struct, stores parameter information, sub fields
        %               are value, error, name and label.
        %                   value: possible data types: string, double
        %                   matrix with arbitrary dimensions, function
        %                   handle
        %   'ax'        struct, stores information on each axis vector, sub
        %               fields are name, label, value
        %                   value: dimensions are:
        %                       grid mode: 1 x nAxis(idx)
        %                       event mode: 1 x nPoint
        %   'ch'        struct, stores information on each data channel,
        %               sub fields are name, label, value
        %
        % See also -.
        raw
    end
    methods
        function D = specnd(varargin)
            D = constructor(varargin{:});
        end
        
    end
    
end