specnd
======

**specnd** *[spekendi:]* is a multidimensional data analysis toolbox for Matlab® with error and multiple data channel handling


Features:
=======

  * event mode and grid mode
  * count/monitor mode and value/error mode and automatic conversion
  * multiple channels to store different data values for the same coordinates
  * stores measurement parameters
  * can include a metric tensor to represent reciprocal space
  * flexible plotting, import, export functions
  * optimised for speed and flexibility (not for memory - no large datasets)
  * simple internal data structure, easily accessible
  * includes physical units along every axis with automatic conversion
  * syntax is optimized for command line usage

Examples:
=======

**data binning/rebinning/summation:**

**D = D(V1,V2)** rebins a 2 dimensional data, bin points are stored in V1 and V2 vectors

**D = D(:,[ymin ymax])** sums the data along the 2nd dimension between ymin and ymax

**data integration:**

**D = integrate(D,2)** integrates the data along the 2nd dimension (includes dy)

**append/combine data:**

**D = [D1 D2]** combines data

**D = [D1; D2; D3]** creates a higher dimensional data with a new axis

**access channel:**

**D = D{idx}** keeps only a single channel with idx index

**D = {D1 D2}** stores two datasets in one as separate channels

**transformation:**

**D = calc(D,@fun)** calculates data values from the old data values

**D = eval(D,@fun)** simulates data for the given coordinates using @fun

**D = transform(D,@fun,dims)** transforms coordinates of given dimensions using @fun

**D = transform(D,R)** linear transformation of coordinates with R matrix including metric tensor

**import:**

**D=loads(‘data[11:28]’,@fun,’X=H, Y=K, Z=L, D=det1, M=mon2’)** loads 3D data in (h,k,l)

**plot:**

**plot(D,dims)** plots data along selected dimensions, overplots additional dimensions
