classdef specnd
    properties
        % Field that stores all data of a specnd object
        % Sub fields are:
        %   'datcnt'    matrix, stores the data values, dimensions are:
        %                   grid mode:
        %                   nAxis(1) x nAxis(2) x ... x nAxis(nDim) x nCh
        %                   event mode:
        %                   1 x nPoint
        %   'errmon'    matrix, stores the error/monitor values
        %   'g'         matrix, g-tensor, dimensions are nDim x nDim
        %   'param'     struct, stores parameter information, sub fields
        %               are name, label, value
        %                   value: possible data types: string, double
        %                   matrix with arbitrary dimensions, function
        %                   handle
        %   'axis'      struct, stores information on each axis vector, sub
        %               fields are name, label, value
        %                   value: dimensions are:
        %                       grid mode: 1 x nAxis(idx)
        %                       event mode: 1 x nPoint
        %   'channel'   struct, stores information on each data channel,
        %               sub fields are name, label, value
        %
        % See also -.
        raw
    end
    methods
        function D = specnd(varargin)
            % Empty the specnd object, 1 axis, no data points.
            D.raw.datcnt.value = zeros(0,1);
            D.raw.datcnt.name  = 'data';
            D.raw.datcnt.label = 'raw data';
            D.raw.errmon = D.raw.datcnt;
            
            D.raw.axis.value{1} = zeros(1,0);
            D.raw.axis.name{1}  = 'x';
            D.raw.axis.label{1} = 'x-axis';
            
            D.raw.channel.value = ones(1,1);
            D.raw.channel.name  = 'ch1';
            D.raw.channel.label = 'channel 1';
            
            D.raw.g.value = ones(1,1);
            D.raw.g.name  = 'g';
            D.raw.g.label = 'Descartes coordinate system';
            
            D.raw.param.name  = {'fid'};
            D.raw.param.label = {'file identifier for text output'};
            D.raw.param.value = {1};
            
            D.raw.log = struct;
            D.raw.fit = struct;
            
            if nargin == 1
                D.raw.datcnt.value = varargin{1};
                D.raw.errmon.value = 0*D.raw.datcnt.value;
                
                nAxis = size(D.raw.datcnt.value);
                % remove stupid matlab extra dimension
                if nAxis(end) == 1
                    nAxis(end) = [];
                end
                
                nDim  = numel(nAxis);
                for ii = 1:nDim
                    D.raw.axis.value{ii} = 1:nAxis(ii);
                    if nDim<=3
                        D.raw.axis.name{ii} = char('x'+ii-1);
                        D.raw.axis.label{ii} = [char('x'+ii-1) '-axis'];
                    else
                        D.raw.axis.name{ii} = ['x' num2str(ii)];
                        D.raw.axis.label{ii} = ['x' num2str(ii) '-axis'];
                    end
                end
                
                D.raw.g.value = eye(nDim);
            end
            validate(D);
        end
        function n = ndims(D)
            n = numel(D.raw.axis.label);
        end
        function n = naxis(D,idx)
            if nargin == 1
                idx = 1:ndims(D);
            end
            n = [];
            for ii = 1:ndims(D)
                n(ii) = numel(D.raw.axis.value{ii}); %#ok<AGROW>
            end
            n = n(idx);
        end
        
    end
    
end