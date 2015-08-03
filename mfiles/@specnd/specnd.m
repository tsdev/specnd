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
            D.raw.sig = struct('val',[],'err',0,'mon',ndext.getpref('mon').val,'name','','label','');
            D.raw.g   = struct('val',1,'name','g','label','Descartes coordinate system');
            
            % Empty object contains zero number of axis and channel
            D.raw.ax  = struct('val',{},'err',{},'name',{},'label',{});
            D.raw.ch  = struct('val',{},'name',{},'label',{});
            
            % copy all global settings into the specnd object
            D.raw.par = ndext.getpref;
            
            % unused fields at present
            %D.raw.log = struct('',{});
            %D.raw.fit = struct([]);
            
            if nVari == 1
                error('specnd:specnd:WrongInput','Missing signal values!')
            end
            
            if nVari > 1
                % input arguments: axis, signal, {error}, {monitor}
                %
                % axis      matrix or cell
                % signal    matrix
                % error     matrix, optional
                % monitor   matrix, optional
                
                if iscell(varargin{1})
                    if ~isempty(varargin{1})
                        % check that the length of the vectors are equal to
                        % the size of the signal matrix
                        axDim  = cellfun(@(C)numel(C),varargin{1});
                        sigDim = size(varargin{2});
                        if numel(axDim) == 1 && sigDim(2) == 1
                            sigDim = sigDim(1);
                        end
                        if numel(axDim)>numel(sigDim) && all(axDim(numel(sigDim)+1:end)==1)
                            sigDim((end+1):numel(axDim)) = 1;
                        end
                        
                        if numel(axDim)~=numel(sigDim) || any(axDim-sigDim)
                            error('specnd:specnd:WrongInput',['Dimensions of input signal matrix '...
                                'is incompatible with the given coordinate matrices!'])
                        end
                        
                        % create the right size of the struct
                        D.raw.ax(numel(varargin{1}),1).val = [];
                        % fill up the value fields with the input coordinate values
                        [D.raw.ax(:).val] = deal(varargin{1}{:});
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
                    D.raw.ax(size(varargin{1},2)).val = [];
                    [D.raw.ax(:).val] = ndext.mat2list(varargin{1},2);
                end
                
                switch nVari
                    case 2
                        D.raw.sig.val = varargin{2};
                    case 3
                        D.raw.sig.val = varargin{2};
                        if ~isempty(varargin{3})
                            D.raw.sig.err = varargin{3};
                        end
                    case 4
                        D.raw.sig.val = varargin{2};
                        if ~isempty(varargin{3})
                            D.raw.sig.err = varargin{3};
                        end
                        if ~isempty(varargin{4})
                            D.raw.sig.mon = varargin{4};
                        end
                end
                
                % number of axis
                axDim = numel(D.raw.ax);
                
                if ~ishistmode(D)
                    % event mode
                    % auto transpose the coordinate and signal matrix if
                    % necessary
                    if sum(size(D.raw.sig.val)>1)>1
                        error('specnd:specnd:WrongInput','Event mode signal has to be a vector!');
                    end
                    if size(D.raw.sig.val,2)>1
                        D.raw.sig.val = D.raw.sig.val.';
                    end
                else
                    % histogram mode
                    % get the true number of signal dimensions
                    sigDim = ndext.realdim(D.raw.sig.val);
                    % get the number of axes
                    axDim  = numel(D.raw.ax);
                    
                    if sigDim > axDim
                        D.raw.ax((axDim+1):sigDim).val = [];
                        axDim = sigDim;
                    end
                    
                    % create integer coordinate values for missing axes
                    % and standardize axis data
                    for ii = 1:axDim
                        if isempty(D.raw.ax(ii).val)
                            D.raw.ax(ii).val = (1:size(D.raw.sig.val,ii))';
                        end
                        
                        % sort coordinates, signal, error and monitor
                        % along unsorted dimensions
                        if ~issorted(D.raw.ax(ii).val)
                            [D.raw.ax(ii).val,axSort] = sort(D.raw.ax(ii).val,1);
                            % sort data the same way
                            selector = repmat({':'},1,axDim);
                            selector{ii} = axSort;
                            D.raw.sig.val = D.raw.sig.val(selector{:});
                            % sort error bar as well
                            if numel(D.raw.sig.err) > 1
                                D.raw.sig.err = D.raw.sig.err(selector{:});
                            end
                            if numel(D.raw.sig.mon)>1
                                % sort monitor as well if not scalar
                                D.raw.sig.mon = D.raw.sig.mon(selector{:});
                            end
                        end
                    end
                end
                
                % take care of the axis labels, etc
                % for up to 3D data, call axes as (x,y,z) for datasets with
                % dimensions higher than 3, call axes as (x1,x2,x3,...)
                if axDim<=3
                    axName  = num2cell(char('x'+(0:(axDim-1))));
                    axLabel = mat2cell(num2str(('x'+(0:axDim-1))','%s-axis'),ones(1,axDim),6);
                else
                    axName  = mat2cell(num2str(((0:axDim-1))','x%d'),ones(1,axDim),2+double(axDim>10));
                    axLabel = mat2cell(num2str(((0:axDim-1))','x%d-axis'),ones(1,axDim),7+double(axDim>10));
                end
                [D.raw.ax(:).name]  = axName{:};
                [D.raw.ax(:).label] = axLabel{:};
                
                % add zero error to each axis
                zCell = num2cell(zeros(1,axDim));
                [D.raw.ax(:).err] = zCell{:};

            end
            
            validate(D);
        end
        
    end
    
end