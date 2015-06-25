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
            
            % separate optional arguments
            optIdx = nd.findoption(varargin{:});
            % number of input variables withouth options
            nVari = optIdx-1;
            
            % Empty the specnd object, 1 axis, no data points.
            D.raw.datcnt.value = zeros(0,1);
            D.raw.datcnt.name  = 'data';
            D.raw.datcnt.label = 'raw data';

            D.raw.errmon.value = zeros(0,1);
            D.raw.errmon.name  = 'error';
            D.raw.errmon.label = 'raw error';

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
            
            if nVari > 0
                % input data matrix and optionally error matrix, plus axis
                % vectors in a cell

                % find the position a cell input argument
                aVarIdx = find(cellfun(@(C)iscell(C),varargin(1:nVari)),1,'first');
                
                if isempty(aVarIdx)
                    % if no axis arguments in cell
                    aVarIdx = nVari+1;
                end
                
                if aVarIdx == 1
                    error('specnd:WrongInput','M data matrix is missing.');
                end
                
                switch nVari
                    case 1
                        D.raw.datcnt.value = varargin{1};
                        D.raw.errmon.value = 0*D.raw.datcnt.value;
                    case 2
                        switch aVarIdx
                            case 2
                                D.raw.datcnt.value = varargin{1};
                                D.raw.errmon.value = 0*D.raw.datcnt.value;
                                D.raw.axis.value   = varargin{2}(:)';
                            case 3
                                D.raw.datcnt.value = varargin{1};
                                D.raw.errmon.value = varargin{2};
                        end
                    case 3
                        switch aVarIdx
                            case 2
                                D.raw.datcnt.value = varargin{1};
                                D.raw.errmon.value = 0*D.raw.datcnt.value;
                                D.raw.axis.value   = varargin{2}(:)';
                            case 3
                                D.raw.datcnt.value = varargin{1};
                                D.raw.errmon.value = varargin{2};
                                D.raw.axis.value  = varargin{3}(:)';
                            case 4
                                D.raw.datcnt.value = varargin{1};
                                D.raw.errmon.value = varargin{2};
                        end
                end
                
                % check for event mode
                if sum(size(D.raw.axis.value{1})>1)>1
                    % axis is 2D matrix or higher dim --> event mode
                    nDim   = size(D.raw.axis.value{1},2);
                    nPoint = size(D.raw.datcnt.value,1);
                    
                    D.raw.channel.value = ones(nPoint,1);
                else
                    % histogram mode
                    nAxis = size(D.raw.datcnt.value);
                    
                    nDim  = numel(D.raw.axis.value);
                    
                    if isempty(D.raw.axis.value{1})
                        for ii = 1:nDim
                            D.raw.axis.value{ii} = (1:nAxis(ii))';
                        end
                    else
                        % transpose axis if necessary
                        for ii = 1:nDim
                            D.raw.axis.value{ii} = D.raw.axis.value{ii}(:);
                        end
                    end
                    
                end
                
                if numel(D.raw.axis.name) < nDim
                    for ii = 1:nDim
                        if nDim<=3
                            D.raw.axis.name{ii}  = char('x'+ii-1);
                            D.raw.axis.label{ii} = [char('x'+ii-1) '-axis'];
                        else
                            D.raw.axis.name{ii}  = ['x' num2str(ii)];
                            D.raw.axis.label{ii} = ['x' num2str(ii) '-axis'];
                        end
                    end
                end

                D.raw.g.value = eye(nDim);
                
            end
            validate(D);
        end
        
    end
    
end