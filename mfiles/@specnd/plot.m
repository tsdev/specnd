function plot(D,varargin)
% plot specnd object

if ishistmode(D)
    switch ndim(D)
        case 1
            plot1(D,varargin{:})
        case 2
            % plot 2D 
            plot2(D,varargin{:});
        case 3
    end
else
end

end