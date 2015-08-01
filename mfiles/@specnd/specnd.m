classdef specnd < handle
    properties
        % Fields that stores all data of a specnd object
        % Sub fields are:
        %   'sig'       struct, sub fields are name, label, value. The
        %               value subfield is a matrix, stores the signal
        %               values, dimensions are:
        %                   grid mode:
        %                   nAxis(1) x nAxis(2) x ... x nAxis(nDim) x nCh
        %                   event mode:
        %                   1 x nPoint
        %   'err'       struct, sub fields are name, label, value. The
        %               value subfield is a matrix, stores the error values
        %               correspond to the signal, same dimensions as the
        %               signal
        %   'mon'       struct, sub fields are name, label, value. The
        %               value subfield is a matrix, stores the monitor
        %               values, either a single value (if monitor for all
        %               data points are equal) or it has the same dimenions
        %               as the signal
        %   'g'         matrix, g-tensor, dimensions are nDim x nDim
        %   'par'       struct, stores parameter information, sub fields
        %               are name, label, value
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
            
            % create specnd object from struct and store it in the .raw
            % field
            if nargin == 1 && isstruct(varargin{1})
                D.raw = varargin{1};
                validate(D);
                return;
            end
            
            % separate optional arguments
            optIdx = ndext.findoption(varargin{:});
            % number of input arguments without options
            nVari = optIdx-1;
            
            % Create an empty specnd object has an empty data, err and
            % metric tensor and unity monitor.
            D.raw.sig = struct('value',zeros(0,0),'name','signal','label','signal');
            D.raw.err = struct('value',0,'name','error','label','standard deviation');
            D.raw.mon = struct('value',1,'name','monitor','label','monitor');
            D.raw.g   = struct('value',1,'name','g','label','Descartes coordinate system');
            
            % Empty object contains zero number of axis and channel
            D.raw.ax  = struct('value',{},'name',{},'label',{});
            D.raw.ch  = struct('value',{},'name',{},'label',{});
            
            % copy all global settings into the specnd object
            D.raw.par = ndext.getpref;
            
            % unused fields at present, empty struct
            %D.raw.log = struct([]);
            %D.raw.fit = struct([]);
            
            if nVari == 1
                error('specnd:specnd:WrongInput','Missing signal values!')
            end
            
            if nVari > 1
                % input arguments: X, Y, E
                %
                % X     matrix or cell
                % Y     matrix
                % E     matrix, optional
                % M     matrix, optional
                
                if iscell(varargin{1})
                    if ~isempty(varargin{1})
                        % check that the length of the vectors are equal to
                        % the size of the signal matrix
                        nAxis  = cellfun(@(C)numel(C),varargin{1});
                        datDim = size(varargin{2});
                        if numel(nAxis) == 1 && datDim(2) == 1
                            datDim = datDim(1);
                        end
                        if numel(nAxis)>numel(datDim) && all(nAxis(numel(datDim)+1:end)==1)
                            datDim((end+1):numel(nAxis)) = 1;
                        end
                        
                        if any(nAxis-datDim)
                            error('specnd:specnd:WrongInput',['Dimensions of input signal matrix '...
                                'is incompatible with the given coordinate matrices!'])
                        end
                        
                        % create the right size of the struct
                        D.raw.ax(numel(varargin{1}),1).value = [];
                        % fill up the value fields with the input coordinate values
                        [D.raw.ax(:).value] = deal(varargin{1}{:});
                    end
                else
                    % check that the input signal has the right dimensions
                    if size(varargin{2},2)>1
                        varargin{2} = varargin{2}.';
                    end
                    
                    cSize = size(varargin{1})==size(varargin{2},1);
                    if ~any(cSize)
                        error('specnd:specnd:WrongInput','Wrong input data dimensions!');
                    end
                    if sum(cSize)==1 && cSize(2)
                        varargin{1} = varargin{1}.';
                    end
                    
                    % split up the event mode coordinates 
                    % create the right size of the struct
                    D.raw.ax(size(varargin{1}),2).value = [];
                    [D.raw.ax(:).value] = deal(varargin{1});
                    %D.raw.ax(1).value = varargin{1};
                end
                
                switch nVari
                    case 2
                        D.raw.sig.value = varargin{2};
                    case 3
                        D.raw.sig.value = varargin{2};
                        if ~isempty(varargin{3})
                            D.raw.err.value = varargin{3};
                        end
                    case 4
                        D.raw.sig.value = varargin{2};
                        if ~isempty(varargin{3})
                            D.raw.err.value = varargin{3};
                        end
                        if ~isempty(varargin{4})
                            D.raw.mon.value = varargin{4};
                        end
                end
                                
                % number of data points
                nPoint = numel(D.raw.sig.value);
                
                % number of axis
                nAxis = numel(D.raw.ax);
                
                % check for event/histogram mode
                ishistmode = sum(size(D.raw.ax(1).value)>1)==1;
                
                if ~ishistmode
                    % axis is 2D matrix or higher dim --> event mode
                    % auto transpose the coordinate and signal matrix if
                    % necessary
                    if sum(size(D.raw.sig.value)>1)>1
                        error('specnd:specnd:WrongInput','Event mode signal has to be a vector!');
                    end
                    if size(D.raw.sig.value,2)>1
                        D.raw.sig.value = D.raw.sig.value.';
                    end
                    
                    size(D.raw.ax
                    %if size(D.raw.ax(1).value
                    
                    nAxis  = size(D.raw.axis.value{1},2);    
                else
                    % histogram mode
                    sDat    = size(D.raw.sig.value);
                    % get the real number of data dimensions
                    datDim  = ndext.realdim(D.raw.sig.value);
                    % get the number of axes
                    nAxis   = numel(D.raw.axis.value);
                    
                    % create integer coordinate values if not given, only
                    % works for histogram mode
                    if isempty(D.raw.axis.value{1})
                        for ii = 1:datDim
                            D.raw.axis.value{ii} = (1:sDat(ii))';
                        end
                    else
                        % standardize axis data
                        for ii = 1:nAxis
                            % transpose axisc vector if necessary
                            D.raw.axis.value{ii} = D.raw.axis.value{ii}(:);
                            
                            % sort coordinates, signal, error and monitor
                            % along unsorted dimensions
                            if ~issorted(D.raw.axis.value{ii})
                                [D.raw.axis.value{ii},axSort] = sort(D.raw.axis.value{ii},1);
                                % sort data the same way
                                selector = repmat({':'},1,nAxis); selector{ii} = axSort;
                                D.raw.sig.value = D.raw.sig.value(selector{:});
                                % sort error bar as well
                                D.raw.err.value = D.raw.err.value(selector{:});
                                if numel(D.raw.mon.value)>1
                                    % sort monitor as well if not scalar
                                    D.raw.mon.value = D.raw.mon.value(selector{:});
                                end
                            end
                        end
                        
                    end
                end
                
                % take care of the axis labels, etc
                % for up to 3D data, call axes as (x,y,z) for datasets with
                % dimensions higher than 3, call axes as (x1,x2,x3,...)
                for ii = 1:nAxis
                    if nAxis<=3
                        D.raw.axis.name{ii}  = char('x'+ii-1);
                        D.raw.axis.label{ii} = [char('x'+ii-1) '-axis'];
                    else
                        D.raw.axis.name{ii}  = ['x' num2str(ii)];
                        D.raw.axis.label{ii} = ['x' num2str(ii) '-axis'];
                    end
                end

                % take care of the metrix tensor
                D.raw.g.value = eye(nAxis);
                
            end
            validate(D);
        end
        
    end
    
end