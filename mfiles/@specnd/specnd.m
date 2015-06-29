classdef specnd < handle
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
            % input arguments: X, Y, E
            
            % separate optional arguments
            optIdx = ndext.findoption(varargin{:});
            % number of input variables without options
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
            
            D.raw.g.value = ones(0,0);
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
                if iscell(varargin{1})
                    if isempty(varargin{1})
                        D.raw.axis.value = {[]};
                    else
                        D.raw.axis.value = varargin{1};
                    end
                else
                    D.raw.axis.value = {varargin{1}};
                end
                
                switch nVari
                    case 1
                        error('specnd:specnd:WrongInput','Missing necessary input argument!')
                    case 2
                        D.raw.datcnt.value = varargin{2};
                        D.raw.errmon.value = 0*D.raw.datcnt.value;
                    case 3
                        D.raw.datcnt.value = varargin{1};
                        D.raw.errmon.value = varargin{2};
                end
                
                % check for event mode
                if sum(size(D.raw.axis.value{1})>1)>1
                    % axis is 2D matrix or higher dim --> event mode
                    axDim   = size(D.raw.axis.value{1},2);
                    nPoint = size(D.raw.datcnt.value,1);
                    
                    D.raw.channel.value = ones(nPoint,1);
                else
                    % histogram mode
                    nAxis = size(D.raw.datcnt.value);
                    % get the real number of data dimensions
                    datDim  = ndext.realdim(D.raw.datcnt.value);
                    % get the number of axes
                    axDim   = numel(D.raw.axis.value);
                    
                    if isempty(D.raw.axis.value{1})
                        for ii = 1:datDim
                            D.raw.axis.value{ii} = (1:nAxis(ii))';
                        end
                    else
                        % transpose axis if necessary
                        for ii = 1:axDim
                            D.raw.axis.value{ii} = D.raw.axis.value{ii}(:);
                        end
                        % sort data along the pecific dimension for the
                        % first dimension
                        [D.raw.axis.value{1},axSort] = sort(D.raw.axis.value{1},1);
                        % sort data the same way
                        selector = repmat({':'},1,axDim); selector{1} = axSort;
                        D.raw.datcnt.value = D.raw.datcnt.value(selector{:});
                        
                    end
                    
                end
                
                if numel(D.raw.axis.name) < axDim
                    for ii = 1:axDim
                        if axDim<=3
                            D.raw.axis.name{ii}  = char('x'+ii-1);
                            D.raw.axis.label{ii} = [char('x'+ii-1) '-axis'];
                        else
                            D.raw.axis.name{ii}  = ['x' num2str(ii)];
                            D.raw.axis.label{ii} = ['x' num2str(ii) '-axis'];
                        end
                    end
                end

                D.raw.g.value = eye(axDim);
                
            end
            validate(D);
        end
        
    end
    
end