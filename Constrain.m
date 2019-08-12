function conNum = Constrain(num,varargin)
    if nargin == 3
        UL = max(varargin{1},varargin{2});
        LL = min(varargin{1},varargin{2});
    end
    if nargin == 2
        UL = max(cell2mat(varargin));
        LL = min(cell2mat(varargin));
    end
    conNum = max(min(num,UL),LL);
end