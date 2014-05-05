% =========================================================================
%> @section INTRO RapidMassMovement
%>
%> - �Ҿ����� ����� �ľ��ϰ�, �̵鿡 Ȱ���� �߻���Ű�� �Լ�
%>  - ����: Ȱ���� ���� �����̵��� ���� ������� ��Ģ�� �ٰ��ؾ� ��.
%>  - ����:
%>   - 1. Ȱ���� õ��Ȱ��(shallow landslide)�� ��ݾ�Ȱ��(bedrock landslide)��
%>     ������. õ��Ȱ������ �ϼ���(debris flow), �ϼ��ֹ���ġ(debris avalanch),
%>     �ϼ�Ȱ��(debris landslide) ��� ���� ������� �̵��Ǵ� ���� ������
%>   - 2. �Ҿ����� ������ ���� ��鰢�� �̷� ������ŭ�� ��鹰���� ���� ����
%>     �̵��ϸ�, ���� ��鹰���� ��� �Ϻη� ���������� �̵��ϸ�, ���� ���� ��
%>     �̻��� �����̵��� �Ͼ�� �ʴ� ������鿡�� ���� �̵��� ������.
%>  - ����: �ܼ����� ���� ���� ������ �ƴ� D8 �˰����� �̿��Ѵ�.
%>
%> @version 0.1
%> @callgraph
%> @callergraph
%> @see Collapse(), CalcSDSFlow(), CheckOversteepSlopes()
%>
%> @retval dBedrockElev                 : Ȱ���� ���� ��ݾ� �� ��ȭ�� [m/dT]
%> @retval dSedimentThick               : Ȱ���� ���� ������ �β� ��ȭ�� [m/dT]
%> @retval dTAfterLastShallowLandslide  : ���ŵ� ������ õ��Ȱ�� ���� ��� �ð� [year]
%> @retval dTAfterLastBedrockLandslide  : ���ŵ� ������ ��ݾ�Ȱ�� ���� ��� �ð� [year]
%>
%> @param mRows                         : ���� (�ܰ� ��� ����) ���� �� ����
%> @param nCols                         : ���� (�ܰ� ��� ����) ���� �� ����
%> @param Y                             : �ܰ� ��踦 ������ Y�� ũ��
%> @param X                             : �ܰ� ��踦 ������ X�� ũ��
%> @param Y_INI                         : ���� ���� Y ���� ��ǥ��(=2)
%> @param Y_MAX                         : ���� ���� Y ������ ��ǥ��(=Y+1)
%> @param X_INI                         : ���� ���� X ���� ��ǥ��(=2)
%> @param X_MAX                         : ���� ���� X ������ ��ǥ��(=X+1)
%> @param Y_TOP_BND                     : ���� �ܰ� �� ��� Y ��ǥ��
%> @param Y_BOTTOM_BND                  : ���� �ܰ� �Ʒ� ��� Y ��ǥ��
%> @param X_LEFT_BND                    : ���� �ܰ� �� ��� X ��ǥ��
%> @param X_RIGHT_BND                   : ���� �ܰ� �� ��� X ��ǥ��
%> @param dT                            : �������� �����Ⱓ [year]
%> @param ROOT2                         : sqrt(2)
%> @param QUARTER_PI                    : pi * 0.25
%> @param CELL_AREA                     : �� ���� [m^2]
%> @param DISTANCE_RATIO_TO_NBR         : �� ũ�⸦ �������� �̿� ���� �Ÿ��� [m]
%> @param soilCriticalSlopeForFailure   : õ��Ȱ���� �߻��ϴ� �Ӱ� ��鰢 [radian]
%> @param rockCriticalSlopeForFailure   : ��ݾ�Ȱ���� �߻��ϴ� �Ӱ� ��鰢 [radian]
%> @param bedrockElev                   : ��ݾ� �� [m]
%> @param sedimentThick                 : ������ �β� [m]
%> @param dTAfterLastShallowLandslide   : ������ õ��Ȱ�� ���� ��� �ð� [year]
%> @param dTAfterLastBedrockLandslide   : ������ ��ݾ�Ȱ�� ���� ��� �ð� [year]
%> @param dX                            : �� ũ�� [m]
%> @param OUTER_BOUNDARY                : ���� ���� �ܰ� ��� ����ũ
%> @param IS_LEFT_RIGHT_CONNECTED       : �¿� �ܰ� ��� ������ ����
%> @param ithNbrYOffset                 : �߾� ���� ���� 8 ���� �̿� ���� ����Ű�� ���� Y�� �ɼ�
%> @param ithNbrXOffset                 : �߾� ���� ���� 8 ���� �̿� ���� ����Ű�� ���� X�� �ɼ�
%> @param sE0LinearIndicies             : �ܰ� ��踦 ������ �߾� ��
%> @param s3IthNbrLinearIndicies        : 8 ���� �̿� ���� ����Ű�� 3���� ���� �迭
% =========================================================================
function [dBedrockElev,dSedimentThick,dTAfterLastShallowLandslide,dTAfterLastBedrockLandslide] = RapidMassMovement(mRows,nCols,Y,X,Y_INI,Y_MAX,X_INI,X_MAX,Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND,dT,ROOT2,QUARTER_PI,CELL_AREA,DISTANCE_RATIO_TO_NBR,soilCriticalSlopeForFailure,rockCriticalSlopeForFailure,bedrockElev,sedimentThick,dTAfterLastShallowLandslide,dTAfterLastBedrockLandslide,dX,OUTER_BOUNDARY,IS_LEFT_RIGHT_CONNECTED,ithNbrYOffset,ithNbrXOffset,sE0LinearIndicies,s3IthNbrLinearIndicies)
%
% function RapidMassMovement
%

% ��� �� ���� �ʱ�ȭ
SOIL = 1; % õ��Ȱ��
ROCK = 2; % �ϼ��ر�

% RapidMassMovement �� �߻����� �ʵ��� �Ϸ��� 0�� ������ ��
oversteepSlopesNo = 0;

dBedrockElev = zeros(mRows,nCols);
dSedimentThick = zeros(mRows,nCols);
facetFlowSlope = nan(mRows,nCols);

while (oversteepSlopesNo > 0)
    
    % ��ǥ ���� ������
    elev = bedrockElev + sedimentThick;
    
    % ������ ������
    [steepestDescentSlope ...       % ���
    ,slopeAllNbr ...                % 8 �̿� ������ ���
    ,SDSFlowDirection ...           % ����
    ,SDSNbrY ...                    % ���� ���� Y ��ǥ��
    ,SDSNbrX] ...                   % ���� ���� X ��ǥ��
        = CalcSDSFlow(mRows,nCols,Y,X,Y_INI,Y_MAX,X_INI,X_MAX ...
        ,Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND ...
        ,QUARTER_PI,DISTANCE_RATIO_TO_NBR,elev,dX ...
        ,IS_LEFT_RIGHT_CONNECTED ...
        ,ithNbrYOffset,ithNbrXOffset ...
        ,sE0LinearIndicies,s3IthNbrLinearIndicies);
        
    % ������ ���ǵ��� ���� ���� ������ �ο���
    [flood ...                          % flooded region
    ,SDSNbrY ...                        % ������ ���� ���� Y ��ǥ��
    ,SDSNbrX ...                        % ������ ���� ���� X ��ǥ��
    ,SDSFlowDirection ...               % ������ ����
    ,steepestDescentSlope ...           % ������ ���
    ,integratedSlope ...                % ������ ���� ���� ���
    ,floodedRegionIndex ...             % flooded region ����
    ,floodedRegionCellsNo ...           % flooded region ���� �� ��
    ,floodedRegionLocalDepth ...        % flooded region ���� ���ⱸ ������ ����
    ,floodedRegionTotalDepth ...        % �� local depth
    ,floodedRegionStorageVolume] ...    % flooded region �� ���差
        = ProcessSink(mRows,nCols,X_INI,X_MAX ...
        ,Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND,QUARTER_PI,CELL_AREA ...
        ,elev,ithNbrYOffset,ithNbrXOffset ...
        ,OUTER_BOUNDARY,IS_LEFT_RIGHT_CONNECTED ...
        ,slopeAllNbr,steepestDescentSlope ...
        ,facetFlowSlope,SDSNbrY,SDSNbrX,SDSFlowDirection); 

	% 1. õ��Ȱ��
    
    % 1) õ��Ȱ���� �߻��� ������ ����Ǵ� �Ҿ����� ����� �ľ���
	[oversteepSlopes ...                % �Ҿ����� ���
    ,oversteepSlopesIndicies ...        % �Ҿ����� �� ����
    ,dTAfterLastShallowLandslide ...    % ������ õ��Ȱ�� ���� ��� �ð�
    ,dTAfterLastBedrockLandslide] ...   % ������ ��ݾ�Ȱ�� ���� ��� �ð�
        = CheckOversteepSlopes(mRows,nCols,Y,X,Y_INI,Y_MAX,X_INI,X_MAX ...
        ,dT,ROOT2 ...
        ,SOIL,soilCriticalSlopeForFailure ...
        ,bedrockElev,sedimentThick,elev ...
        ,dTAfterLastShallowLandslide,dTAfterLastBedrockLandslide ...        
        ,dX,OUTER_BOUNDARY,SDSNbrY,SDSNbrX,flood);	
	
    
    % 2) õ��Ȱ������ ���� �� ��ȭ���� ����
	oversteepSlopesNo = size(oversteepSlopesIndicies,1);
	
	if oversteepSlopesNo > 0
	
		[dBedrockElevByDebrisFlow ...       % ��ݾ� �� ��ȭ��
        ,dSedimentThickByDebrisFlow ...     % ������ �β� ��ȭ��
        ,SDSNbrY ...                    % õ��Ȱ���� ������ ���� ���� Y ��ǥ��
        ,SDSNbrX ...                    % õ��Ȱ���� ������ ���� ���� X ��ǥ��
        ,flood] ...                     % õ��Ȱ���� ������ flooded region
            = Collapse(mRows,nCols,Y,X,Y_INI,Y_MAX,X_INI,X_MAX ...
            ,Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND,CELL_AREA ...
            ,DISTANCE_RATIO_TO_NBR,ROOT2,QUARTER_PI ...
            ,oversteepSlopes ...
            ,oversteepSlopesIndicies,oversteepSlopesNo ...
            ,SOIL ...
            ,soilCriticalSlopeForFailure,rockCriticalSlopeForFailure ...
            ,bedrockElev,sedimentThick,elev ...
            ,SDSNbrY,SDSNbrX,flood ...
            ,dX,OUTER_BOUNDARY,IS_LEFT_RIGHT_CONNECTED ...
            ,ithNbrYOffset,ithNbrXOffset ...
            ,sE0LinearIndicies,s3IthNbrLinearIndicies);
		
		% 3) ������ �β��� �����ϰ�, ���� ��ȭ���� ����
		dSedimentThick = dSedimentThick + dSedimentThickByDebrisFlow;
		sedimentThick(Y_INI:Y_MAX,X_INI:X_MAX) ...
		    = sedimentThick(Y_INI:Y_MAX,X_INI:X_MAX) ...
		    + dSedimentThickByDebrisFlow(Y_INI:Y_MAX,X_INI:X_MAX);
		elev = bedrockElev + sedimentThick;

	end
	
    % 2. ��ݾ�Ȱ��
    
	% 1) ��ݾ�Ȱ���� �߻��� ������ ����Ǵ� �Ҿ����� ����� �ľ���
	[oversteepSlopes ...                % �Ҿ����� ���
    ,oversteepSlopesIndicies ...        % �Ҿ����� �� ����
    ,dTAfterLastShallowLandslide ...    % ������ õ��Ȱ�� ���� ��� �ð�
    ,dTAfterLastBedrockLandslide] ...   % ������ ��ݾ�Ȱ�� ���� ��� �ð�
        = CheckOversteepSlopes(mRows,nCols,Y,X,Y_INI,Y_MAX,X_INI,X_MAX ...
        ,dT,ROOT2 ...
        ,ROCK,rockCriticalSlopeForFailure ...
        ,bedrockElev,sedimentThick,elev ...
        ,dTAfterLastShallowLandslide,dTAfterLastBedrockLandslide ...   
        ,dX,OUTER_BOUNDARY,SDSNbrY,SDSNbrX,flood);
	
	% 2) ��ݾ�Ȱ������ ���� �� ��ȭ���� ����
	oversteepSlopesNo = size(oversteepSlopesIndicies,1);
	
	if oversteepSlopesNo > 0
	
		[dBedrockElevByRockFailure ...      % ��ݾ� �� ��ȭ��
        ,dSedimentThickByRockFailure ...    % ������ �β� ��ȭ��
        ,SDSNbrY ...                    % ��ݾ�Ȱ���� ������ ���� ���� Y ��ǥ��
        ,SDSNbrX ...                    % ��ݾ�Ȱ���� ������ ���� ���� X ��ǥ��
        ,flood] ...                     % ��ݾ�Ȱ���� ������ flooded region
            = Collapse(mRows,nCols,Y,X,Y_INI,Y_MAX,X_INI,X_MAX ...
            ,Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND,CELL_AREA ...
            ,DISTANCE_RATIO_TO_NBR,ROOT2,QUARTER_PI ...
            ,oversteepSlopes ...
            ,oversteepSlopesIndicies,oversteepSlopesNo ...
            ,ROCK ...
            ,soilCriticalSlopeForFailure,rockCriticalSlopeForFailure ...
            ,bedrockElev,sedimentThick,elev ...
            ,SDSNbrY,SDSNbrX,flood ...
            ,dX,OUTER_BOUNDARY,IS_LEFT_RIGHT_CONNECTED ...
            ,ithNbrYOffset,ithNbrXOffset ...
            ,sE0LinearIndicies,s3IthNbrLinearIndicies);
		
		% 3) ������ �β��� ��ݾ� ���� �����ϰ�, ���� ��ȭ���� ����
		dSedimentThick = dSedimentThick + dSedimentThickByRockFailure;
		dBedrockElev = dBedrockElev + dBedrockElevByRockFailure;
		sedimentThick(Y_INI:Y_MAX,X_INI:X_MAX)...
		    = sedimentThick(Y_INI:Y_MAX,X_INI:X_MAX)...
		    + dSedimentThickByRockFailure(Y_INI:Y_MAX,X_INI:X_MAX);
		bedrockElev(Y_INI:Y_MAX,X_INI:X_MAX)...
		    = bedrockElev(Y_INI:Y_MAX,X_INI:X_MAX)...
		    + dBedrockElevByRockFailure(Y_INI:Y_MAX,X_INI:X_MAX);  

	end
    
end

end % RapidMassMovement end