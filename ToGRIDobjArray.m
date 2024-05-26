function [sedThickGRIDobjArray,bedElevGRIDobjArray] = ToGRIDobjArray(majorOutputs)
% GPSS 모의 결과를 TopoToolbox로 분석하기 위해 GRIDobj로 변환하는 함수

finalResultNo = majorOutputs.totalExtractTimesNo + 1;
dX = majorOutputs.dX;
dY = majorOutputs.dX;
X = majorOutputs.X;
X_INI = majorOutputs.X_INI;
Y = majorOutputs.Y;
Y_INI = majorOutputs.Y_INI;

sedThickGRIDobjArray = repmat(GRIDobj([]),finalResultNo,1);
bedElevGRIDobjArray = repmat(GRIDobj([]),finalResultNo,1);

for i=1:finalResultNo

    ithSedThick = majorOutputs.sedimentThick(:,:,i);
    sedThickGRIDobjArray(i) = TransformtoGRIDobj(ithSedThick ...
                    ,dX,dY,X,X_INI,Y,Y_INI);
    
    ithBedElev = majorOutputs.bedrockElev(:,:,i);
    bedElevGRIDobjArray(i) = TransformtoGRIDobj(ithBedElev ...
                    ,dX,dY,X,X_INI,Y,Y_INI);

end

end

function outGRIDobj = TransformtoGRIDobj(ithZ,dX,dY,X,X_INI,Y,Y_INI)
% To convert the GPSS output final result to TopoToolbox grid object
% Default values were chosen referring the "srtm_bigtujunga30m_utm11.tif"

outGRIDobj = GRIDobj([]); % creates an empty instance of GRIDobj

% Z matrix with elevation values
outGRIDobj.Z = ithZ(Y_INI:Y+1,X_INI:X+1);
% NAME optional name (string)
% outGRIDobj.name = 'sedThick401';
% CELLSIZE cellsize of the grid (scalar)
outGRIDobj.cellsize = dX;
% REFMAT 3-by-2 affine transformation matrix
outGRIDobj.refmat = double([0,-dY; dX,0; dX*0.5,dY*Y+dY*0.5]);
% SIZE size of the grid (two element vector)
outGRIDobj.size = [Y,X];
% ZUNIT unit of grid values (string)
outGRIDobj.zunit = [];
% XYUNIT unit of the coordinates (string)
outGRIDobj.xyunit = [];

% GEOREF additional information on spatial referencing (structure array)
% SpatialRef : Map raster reference object (if ModelType is 'ModelTypeProjected')
%    or a geographic raster reference object (if ModelType is 'ModelTypeGeographic') 
outGRIDobj.georef.SpatialRef.RasterInterpretation = 'cells'; % 'cells' means RasterPixelIsArea
outGRIDobj.georef.SpatialRef.XIntrinsicLimits = [0.5,X+0.5]; % CornerCoords structure
outGRIDobj.georef.SpatialRef.YIntrinsicLimits = [0.5,Y+0.5];
outGRIDobj.georef.SpatialRef.CellExtentInWorldX = dX; 
outGRIDobj.georef.SpatialRef.CellExtentInWorldY = dY;
outGRIDobj.georef.SpatialRef.XWorldLimits = [0,dX*X]; % bounding box
outGRIDobj.georef.SpatialRef.YWorldLimits = [0,dY*Y];
outGRIDobj.georef.SpatialRef.RasterSize = [Y,X]; % size for height and width
outGRIDobj.georef.SpatialRef.ColumnsStartFrom = 'north';
outGRIDobj.georef.SpatialRef.RowsStartFrom = 'west';
outGRIDobj.georef.SpatialRef.RasterExtentInWorldX = dX*X;
outGRIDobj.georef.SpatialRef.RasterExtentInWorldY = dY*Y;
outGRIDobj.georef.SpatialRef.TransformationType = 'rectlinear';
outGRIDobj.georef.SpatialRef.CoordinateSystemType = 'planar';
% GEOREF : ProjectedCRS info
outGRIDobj.georef.SpatialRef.ProjectedCRS.Name = "WGS 84 / UTM zone 11N";
% GEOREF : ProjectedCRS info - GeographicCRS
outGRIDobj.georef.SpatialRef.ProjectedCRS.GeographicCRS.Name = "WGS 84";
outGRIDobj.georef.SpatialRef.ProjectedCRS.GeographicCRS.Datum = "World Geodetic System 1984";
outGRIDobj.georef.SpatialRef.ProjectedCRS.GeographicCRS.Spheroid.Code = 7030;
outGRIDobj.georef.SpatialRef.ProjectedCRS.GeographicCRS.Spheroid.Name = 'WGS 84';
outGRIDobj.georef.SpatialRef.ProjectedCRS.GeographicCRS.Spheroid.LengthUnit = 'meter';
outGRIDobj.georef.SpatialRef.ProjectedCRS.GeographicCRS.Spheroid.SemimajorAxis = 6378137;
outGRIDobj.georef.SpatialRef.ProjectedCRS.GeographicCRS.Spheroid.SemiminorAxis = 6.356752314245179e+06;
outGRIDobj.georef.SpatialRef.ProjectedCRS.GeographicCRS.Spheroid.InverseFlattening = 298.2572;
outGRIDobj.georef.SpatialRef.ProjectedCRS.GeographicCRS.Spheroid.Eccentricity = 0.0818;
outGRIDobj.georef.SpatialRef.ProjectedCRS.GeographicCRS.Spheroid.Flattening = 0.0034;
outGRIDobj.georef.SpatialRef.ProjectedCRS.GeographicCRS.Spheroid.ThirdFlattening = 0.0017;
outGRIDobj.georef.SpatialRef.ProjectedCRS.GeographicCRS.Spheroid.MeanRadius = 6.371008771415059e+06;
outGRIDobj.georef.SpatialRef.ProjectedCRS.GeographicCRS.Spheroid.SurfaceArea = 5.100656217240886e+14;
outGRIDobj.georef.SpatialRef.ProjectedCRS.GeographicCRS.Spheroid.Volume = 1.083207319801408e+21;
outGRIDobj.georef.SpatialRef.ProjectedCRS.GeographicCRS.PrimeMeridian = 0;
outGRIDobj.georef.SpatialRef.ProjectedCRS.GeographicCRS.AngleUnit = 'degree';
outGRIDobj.georef.SpatialRef.ProjectedCRS.ProjectionMethod ='Transverse Mercator';
outGRIDobj.georef.SpatialRef.ProjectedCRS.LengthUnit = 'meter';
% GEOREF : ProjectedCRS info - ProjectionParameters
outGRIDobj.georef.SpatialRef.ProjectedCRS.ProjectionParameters.LatitudeOfNaturalOrigin = 0;
outGRIDobj.georef.SpatialRef.ProjectedCRS.ProjectionParameters.LongitudeOfNaturalOrigin = -117;
outGRIDobj.georef.SpatialRef.ProjectedCRS.ProjectionParameters.ScaleFactorAtNaturalOrigin = 0.9996;
outGRIDobj.georef.SpatialRef.ProjectedCRS.ProjectionParameters.FalseEasting = 500000;
outGRIDobj.georef.SpatialRef.ProjectedCRS.ProjectionParameters.FalseNorthing = 0;
% GEOREF : GeoKeyDirectoryTag for GeoTIFF specification
outGRIDobj.georef.GeoKeyDirectoryTag.GTModelTypeGeoKey = 1;
outGRIDobj.georef.GeoKeyDirectoryTag.GTRasterTypeGeoKey = 1;
outGRIDobj.georef.GeoKeyDirectoryTag.GTCitationGeoKey = 'PCS Name = WGS_84_UTM_zone_11N'; % EPSG 32611
outGRIDobj.georef.GeoKeyDirectoryTag.GeogCitationGeoKey = 'GCS_WGS_1984';
outGRIDobj.georef.GeoKeyDirectoryTag.GeogAngularUnitsGeoKey = 9102;
outGRIDobj.georef.GeoKeyDirectoryTag.ProjectedCSTypeGeoKey = 32611;
outGRIDobj.georef.GeoKeyDirectoryTag.ProjLinearUnitsGeoKey = 9001;
% GEOREF : Mapping projection structure that is generated by geotiff2mstruct()
outGRIDobj.georef.mstruct.mapprojection = 'tranmerc';
outGRIDobj.georef.mstruct.zone = [];
outGRIDobj.georef.mstruct.angleunits = 'degrees';
outGRIDobj.georef.mstruct.aspect = 'normal';
outGRIDobj.georef.mstruct.falsenorthing = 0;
outGRIDobj.georef.mstruct.falseeasting = 500000;
outGRIDobj.georef.mstruct.fixedorient = [];
outGRIDobj.georef.mstruct.geoid = [6378137,0.081819190842621];
outGRIDobj.georef.mstruct.maplatlimit = [-80,80];
outGRIDobj.georef.mstruct.maplonlimit = [-137,-97];
outGRIDobj.georef.mstruct.mapparallels = [];
outGRIDobj.georef.mstruct.nparallels = 0;
outGRIDobj.georef.mstruct.origin = [0,-117,0];
outGRIDobj.georef.mstruct.scalefactor = 0.9996;
outGRIDobj.georef.mstruct.trimlat = [-80,80];
outGRIDobj.georef.mstruct.trimlon = [-20,20];
outGRIDobj.georef.mstruct.frame = 'off';
outGRIDobj.georef.mstruct.ffill = 100;
outGRIDobj.georef.mstruct.fedgecolor = [0.15,0.15,0.15];
outGRIDobj.georef.mstruct.ffacecolor = 'none';
outGRIDobj.georef.mstruct.flatlimit = [-80,80];
outGRIDobj.georef.mstruct.flinewidth = 2;
outGRIDobj.georef.mstruct.flonlimit = [-20,20];
outGRIDobj.georef.mstruct.grid = 'off';
outGRIDobj.georef.mstruct.galtitude = Inf;
outGRIDobj.georef.mstruct.gcolor = [0.15,0.15,0.15];
outGRIDobj.georef.mstruct.glinestyle = ':';
outGRIDobj.georef.mstruct.glinewidth = 0.5;
outGRIDobj.georef.mstruct.mlineexception = [];
outGRIDobj.georef.mstruct.mlinefill = 100;
outGRIDobj.georef.mstruct.mlinelimit = [];
outGRIDobj.georef.mstruct.mlinelocation = 30;
outGRIDobj.georef.mstruct.mlinevisible = 'on';
outGRIDobj.georef.mstruct.plineexception = [];
outGRIDobj.georef.mstruct.plinefill = 100;
outGRIDobj.georef.mstruct.plinelimit = [];
outGRIDobj.georef.mstruct.plinelocation = 15;
outGRIDobj.georef.mstruct.plinevisible = 'on';
outGRIDobj.georef.mstruct.fontangle = 'normal';
outGRIDobj.georef.mstruct.fontcolor = [0.15,0.15,0.15];
outGRIDobj.georef.mstruct.fontname = 'Helvetica';
outGRIDobj.georef.mstruct.fontsize = 10;
outGRIDobj.georef.mstruct.fontunits = 'points';
outGRIDobj.georef.mstruct.fontweight = 'normal';
outGRIDobj.georef.mstruct.labelformat = 'compass';
outGRIDobj.georef.mstruct.labelrotation = 'off';
outGRIDobj.georef.mstruct.labelunits = 'degrees';
outGRIDobj.georef.mstruct.meridianlabel = 'off';
outGRIDobj.georef.mstruct.mlabellocation = 30;
outGRIDobj.georef.mstruct.mlabelparallel = 80;
outGRIDobj.georef.mstruct.mlabelround = 0;
outGRIDobj.georef.mstruct.parallellabel = 'off';
outGRIDobj.georef.mstruct.plabellocation = 15;
outGRIDobj.georef.mstruct.plabelmeridian = -137;
outGRIDobj.georef.mstruct.plabelround = 0;

end