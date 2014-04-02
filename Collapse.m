% =========================================================================
%> @section INTRO Collapse
%>
%> - �Ҿ����� ������ Ȱ���� �߻����� ��� ������ ��� �Ϻη� ����������
%>   �̵���Ű�� �Լ�.
%>  - ����: FluvialProcess �Լ������� �帧�й踦 ���� ���� ���� �˰�����
%>    ���Ͽ�����, �� �Լ������� �ִ��Ϻΰ�� ���� �˰����� �̿���. �̴� ����
%>    ���� �˰����� �̿��� ��� ���� ���� �ð��� �ʿ��ϱ� ������.
%>  - ����: Tucker(1994)�� GOLEM�� �ִ� �˰����� ������.
%>
%> - History
%>  - 2010-09-28
%>   - RapidMassMovement �Լ��� ���� �ӵ��� ����ϱ� ���� CollapseMex.c�� ������.
%>
%> @version 0.1
%>
%> @callgraph
%> @callergraph
%> @see ProcessSink(), IsBoundary(), CalcSDSFlow()
%>
%> @retval dBedrockElev                 : ��ݾ� �� ��ȭ�� [m/dT]
%> @retval dSedimentThick               : ������ �β� ��ȭ�� [m/dT]
%> @retval SDSNbrY                      : Ȱ�� �߻� �� ���ŵ� ���� �� Y ��ǥ��
%> @retval SDSNbrX                      : Ȱ�� �߻� �� ���ŵ� ���� �� X ��ǥ��
%> @retval flood                        : Ȱ�� �߻� �� ���ŵ� flooded region
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
%> @param CELL_AREA                     : �� ���� [m^2]
%> @param DISTANCE_RATIO_TO_NBR         : �� ũ�⸦ �������� �̿� ���� �Ÿ��� [m]
%> @param ROOT2                         : sqrt(2)
%> @param QUARTER_PI                	: pi * 0.25
%> @param oversteepSlopes               : �Ҿ����� ��
%> @param oversteepSlopesIndicies       : (�������� ���ĵ�) �Ҿ����� �� ����
%> @param oversteepSlopesNo             : �Ҿ����� �� ����
%> @param rapidMassMovementType         : Ȱ�� ����
%> @param soilCriticalSlopeForFailure   : õ��Ȱ�� �߻� �Ӱ� ��鰢 [radian]
%> @param rockCriticalSlopeForFailure   : ��ݾ�Ȱ�� �߻� �Ӱ� ��鰢 [radian]
%> @param bedrockElev                   : ��ǥ �� [m]
%> @param sedimentThick                 : ������ �β� [m]
%> @param elev                          : ��ǥ �� [m]
%> @param SDSNbrY                       : �ִ��Ϻΰ�� ������ ����Ű�� ���� ���� Y ��ǥ
%> @param SDSNbrX                       : �ִ��Ϻΰ�� ������ ����Ű�� ���� ���� X ��ǥ
%> @param flood                         : SINK�� ���� ���� ���̴� ����(flooded region)
%> @param dX                            : �� ũ��
%> @param OUTER_BOUNDARY                : ���� ���� �ܰ� ��� ����ũ
%> @param IS_LEFT_RIGHT_CONNECTED       : �¿� �ܰ� ��� ������ ����
%> @param ithNbrYOffset                 : �߾� ���� ���� 8 ���� �̿� ���� ����Ű�� ���� Y�� �ɼ�
%> @param ithNbrXOffset                 : �߾� ���� ���� 8 ���� �̿� ���� ����Ű�� ���� X�� �ɼ�
%> @param sE0LinearIndicies             : �ܰ� ��踦 ������ �߾� ��
%> @param s3IthNbrLinearIndicies        : 8 ���� �̿� ���� ����Ű�� 3���� ���� �迭
% =========================================================================
function [dBedrockElev,dSedimentThick,SDSNbrY,SDSNbrX,flood] = Collapse(mRows,nCols,Y,X,Y_INI,Y_MAX,X_INI,X_MAX,Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND,CELL_AREA,DISTANCE_RATIO_TO_NBR,ROOT2,QUARTER_PI,oversteepSlopes,oversteepSlopesIndicies,oversteepSlopesNo,rapidMassMovementType,soilCriticalSlopeForFailure,rockCriticalSlopeForFailure,bedrockElev,sedimentThick,elev,SDSNbrY,SDSNbrX,flood,dX,OUTER_BOUNDARY,IS_LEFT_RIGHT_CONNECTED,ithNbrYOffset,ithNbrXOffset,sE0LinearIndicies,s3IthNbrLinearIndicies)
%
% function Collapse
%

% ���
SOIL = 1;           % õ��Ȱ��
% ROCK = 2;         % ��ݾ�Ȱ��

FLOODED = 2;                            % flooded region �±�

% ���� �ʱ�ȭ
minDElevByCollapse = - 0.001;           % ���� �ݺ��� �����ϱ� ���� ����. ����: ����
facetFlowSlope = nan(mRows,nCols);      % (���� ���� �˰����� �̿���) ��� ���
dBedrockElev = zeros(mRows,nCols);      % ��ݾ� �� ��ȭ��
dSedimentThick = zeros(mRows,nCols);    % ������ �β� ��ȭ��

% 1. Ȱ�� ������ ���� (�̵����� �����ϱ� ����) ��ȿ ���� Ȱ���� �߻��ϰ� �Ǵ�
% �Ӱ� ������ ������

% * ����: õ��Ȱ���� ��ݾ�Ȱ���� �߻��ϴ� �Ӱ� �����̴� ���� �ٸ�
% * ����: ��ݾ� ���� ������ �β��� ���� ��ǥ ���� ���� ���� ��ǥ ����
%   �̿��Ͽ� ���� ���� õ��Ȱ�� �߻��� ������ �� ������, ��ݾ�Ȱ�� ������
%   �������� ����. ��ݾ�Ȱ���� ���� ��ݾ� ���� ���� ���� ��ǥ������
%   ���̰� ���� ����� ����.

% 1) �߾� ���� ���� �� ���ΰ��� ����
indicies = reshape(1:mRows*nCols,[mRows,nCols]);    % �߾� �� ����
nbrIndicies = (SDSNbrX - 1) * mRows + SDSNbrY;      % ���� �� ����
dIndicies = indicies - nbrIndicies;                 % �߾� �� ���ΰ� ���� �� ���� ����

% 2) ���� ���� ���� ������ ��
orthogonalDownstream = false(mRows,nCols);          % ���� ���� ���� ������ ��
orthogonalDownstream(Y_INI:Y_MAX,X_INI:X_MAX) ...
    = (mod(dIndicies(Y_INI:Y_MAX,X_INI:X_MAX),mRows) == 0) ...
    | (abs(dIndicies(Y_INI:Y_MAX,X_INI:X_MAX)) == 1);

% 3) ���� �� ���⿡ ���� õ��Ȱ���� �߻��ϴ� �Ӱ� ����
% * ����: ��ݾ�Ȱ���� ��쿡�� �Ϸ������� õ��Ȱ��ó�� �������� �̵��ϹǷ�
%   soilCriticalHeight�� �ʿ���. ���� ���ǹ� �ۿ� ��.
soilCriticalHeightForOrtho = soilCriticalSlopeForFailure * dX;
soilCriticalHeightForDiag = soilCriticalSlopeForFailure * dX * ROOT2;
soilCriticalHeight = zeros(mRows,nCols);
soilCriticalHeight(Y_INI:Y_MAX,X_INI:X_MAX) ...
    = ones(Y,X) * soilCriticalHeightForDiag;
soilCriticalHeight(orthogonalDownstream) = soilCriticalHeightForOrtho;

% 4) Ȱ���� �߻��ϴ� �Ӱ� ���� ����
if rapidMassMovementType == SOIL
    
    % õ��Ȱ���� ���    
    effectiveElev = bedrockElev + sedimentThick;    % õ��Ȱ���� ��ȿ ��
    criticalHeight = soilCriticalHeight;            % õ��Ȱ���� �Ӱ� ����
    
else % rapidMassMovementType == ROCK
    
    % ��ݾ�Ȱ���� ���
    % ���� �� ���⿡ ���� �Ӱ� ����
    rockCriticalHeightForOrtho = rockCriticalSlopeForFailure * dX;
    rockCriticalHeightForDiag = rockCriticalSlopeForFailure * dX * ROOT2;
    rockCriticalHeight = zeros(mRows,nCols);
    rockCriticalHeight(Y_INI:Y_MAX,X_INI:X_MAX) ...
        = ones(Y,X) * rockCriticalHeightForDiag;
    rockCriticalHeight(orthogonalDownstream) = rockCriticalHeightForOrtho;
        
	effectiveElev = bedrockElev;                    % ��ݾ�Ȱ���� ��ȿ ��
    criticalHeight = rockCriticalHeight;            % ��ݾ�Ȱ���� �Ӱ� ����
    
end

% 2. �Ҿ����� ���� ���鿡�� Ȱ���� �߻��ϰ� �̷� ���� �� ��ȭ�� �߻���

[oversteepSlopesY,oversteepSlopesX] ...             % �Ҿ��� �� ��ǥ ���
    = ind2sub([mRows nCols],oversteepSlopesIndicies);

for ithCell = 1:oversteepSlopesNo

    % 1) �ݺ��� ���� �ʱ�ȭ
    isBoundary = false;     % ������ ���� ��迡 �����ߴ��� ǥ���ϴ� ����
    dBedrockElevByIthCell = zeros(mRows,nCols); % i��° �Ҿ��� ���� ���� ��ȭ��
    dSedimentThickByIthCell = zeros(mRows,nCols);
    
	% 2) ���� ó���� �Ҿ��� �� ��ǥ
	y = oversteepSlopesY(ithCell);
	x = oversteepSlopesX(ithCell);

	% 3) ���� �� ������ ����
	nextY = SDSNbrY(y,x);
	nextX = SDSNbrX(y,x);
	
	% 4) Ȱ������ ���� �� �������� ħ���� ����
    % * ����: �Ӱ� ������ �ʰ��ϴ� ������ ���� ���� �̵���
	dElev1 = ...
        - ((effectiveElev(y,x) - elev(nextY,nextX)) - criticalHeight(y,x));
    
    % * ����: ħ������ �������� Ȯ���ϰ�, �ƴ� ����� �� �������� �̵��� ������
    if dElev1 < 0
        
        % (1) ���ǿ� ���� ħ���� ����
		% * ����: ���� ���� ���� �� �������� ��鹰�� �̵����� ���� �����.
        %   ���� �� ���� ���� �������� �� ���� ���� �̵��Ǿ�� ��
        % * ����: ���� ���� �ܰ� ����� ������ ������, ���� �̵��� ������.
        % * ����: ���� ���� �Ҿ����� ���� ��쿡�� ���� �������� ���� �̵���
        %   ���� ������ ����ǹǷ� ������ ����
        
        % ������ ħ������ ����
		dElev1 = dElev1 * 0.5;

        if IsBoundary(nextY,nextX,Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND) == true
			
			dElev1 = dElev1 * 2;
            
            % * ����: õ��Ȱ���� ���, �̵����� ������ �β��� ���ѵ�
            if rapidMassMovementType == SOIL && - dElev1 > sedimentThick(y,x)

                dElev1 = - sedimentThick(y,x);
                
            end
            
            dSedimentThickByIthCell(nextY,nextX) ...
                = dSedimentThickByIthCell(nextY,nextX) - dElev1;
            
			isBoundary = true;
			
		elseif oversteepSlopes(nextY,nextX) == true
			
			dElev1 = dElev1 * 2;
			
        end % IsBoundary(nextY,nextX,Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND) == true

        % * ħ������ �ּ� ħ�������� ������ �ּ� ħ������ ��ü��
        % * ����: ħ������ �ְ��� �߻�������, �̸� ���� ������ ���� ���� ����
        %   ���� �����Ͽ� ���� �ݺ��� ������        
        if - dElev1 < - minDElevByCollapse
            
            dElev1 = minDElevByCollapse;
            
        end
        
        % (2) ������ �β� �� ��ݾ� ���� ������
        if rapidMassMovementType == SOIL
            
            % * ����: õ��Ȱ���� ���, �̵����� ������ �β��� ���ѵ�
            if - dElev1 > sedimentThick(y,x)
                dElev1 = - sedimentThick(y,x);                
            end
            
            dSedimentThickByIthCell(y,x) ...
                = dSedimentThickByIthCell(y,x) + dElev1;

        else % rapidMassMovementType == ROCK

            dBedrockElevByIthCell(y,x) ...
                = dBedrockElevByIthCell(y,x) + dElev1;
            
            % * ����: ��ݾ� ����� ������������ ħ������ ������
            dSedimentThickByIthCell(y,x) ...
                = dSedimentThickByIthCell(y,x) - sedimentThick(y,x);
            dElev1 = dElev1 + dSedimentThickByIthCell(y,x);

        end

        isStable = false;
        
    else % dElev1 >= 0       
        
        isStable = true;        
        
    end % dElev1 < 0
	
    % 5) ���� ����� �̷� ������ ���� ���� �������� ���� �̵��� �߻���
    dSedimentThickByIthCell ... % i��° �Ҿ��� ���� ���� ������ �β� ��ȭ�� [m/dT]
        = CollapseMex(mRows,nCols,isStable,isBoundary,nextY,nextX ...
        ,rapidMassMovementType,dElev1);
    %
    % * CollapseMex.c
    %
    % ���� �� ������ Ȱ���� ���� �Ҿ����� ������ ���� ������ ��������
    % ��ݾ� �� �� ������ �β� ��ȭ���� ���ϴ� �Լ� 
    % * ����: Collapse �Լ��� while �ݺ������� MEX ���Ϸ� ������
    % 
    % dSedimentThickByIthCell ...      0 . i��° �Ҿ��� ���� ���� ������ �β� ��ȭ�� [m/dT]
    % = CollapseMex ...
    % (mRows ...                       0 . �� ����
    % ,nCols ...                       1 . �� ����
    % ,isStable ...                    2 . ���� ������ �����̵��� �ʴ� ����ȭ ����
    % ,isBoundary ...                  3 . ������ �̵��� �ܰ� ��� ���� ����
    % ,nextY ...                       4 . ���� ���� Y ��ǥ
    % ,nextX ...                       5 . ���� ���� X ��ǥ
    % ,rapidMassMovementType ...       6 . Ȱ�� ����
    % ,dElev1)                         7 . i��° ���� ħ���� [m/dT]
    %
    %----------------------------- mexGetVariablePtr �Լ��� �����ϴ� ����
    %
    % dSedimentThickByIthCell          8 . i��° �Ҿ��� ���� ���� ������ �β� ��ȭ�� [m/dT]
    % SDSNbrY ...                      9 . ���� �� Y ��ǥ
    % SDSNbrX ...                      10. ���� �� X ��ǥ
    % elev ...                         11. ���ŵ� ��ǥ �� [m]
    % soilCriticalHeight ...           12. õ��Ȱ�� �߻��� �Ӱ� ���� [m]
    % sedimentThick ...                13. ������ �β�
    % oversteepSlopes ...              14. �Ҿ����� ��
    % flood ...                        15. flooded region

    % ���� ��ݾ� �� �� ������ �β� ��ȭ���� ����
    dBedrockElev = dBedrockElev + dBedrockElevByIthCell;
    dSedimentThick = dSedimentThick + dSedimentThickByIthCell;
    
    % ��ݾ� �� �� ������ �β� �׸��� ���� ������
    bedrockElev = bedrockElev + dBedrockElevByIthCell;
    sedimentThick = sedimentThick + dSedimentThickByIthCell;
    elev = bedrockElev + sedimentThick;
    
    % �Ҿ����� ��鿡�� �߿��� ��鹰���� ��� �Ϻη� �̵��ϹǷ�, ��� �Ϻ���
    % ���� ��ȭ�鼭 ������ �޶���. ���� ������ ���� ����
    [steepestDescentSlope ...   % ������ ���
    ,slopeAllNbr ...            % ������ 8�� �̿� ������ ���
    ,SDSFlowDirection ...       % ������ ����
    ,SDSNbrY ...                % ������ ���� ���� Y ��ǥ��
    ,SDSNbrX] ...               % ������ ���� ���� X ��ǥ��
        = CalcSDSFlow(mRows,nCols,Y,X,Y_INI,Y_MAX,X_INI,X_MAX ...
        ,Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND ...
        ,QUARTER_PI,DISTANCE_RATIO_TO_NBR,elev,dX ...
        ,IS_LEFT_RIGHT_CONNECTED ...
        ,ithNbrYOffset,ithNbrXOffset ...
        ,sE0LinearIndicies,s3IthNbrLinearIndicies);
        
    % ������ ���ǵ��� ���� ���� ������ �ο��Ѵ�.
    [flood ...                      % ������ flooded region
    ,SDSNbrY ...                    % ������ ���� ���� Y ��ǥ��
    ,SDSNbrX ...                    % ������ ���� ���� X ��ǥ��
    ,SDSFlowDirection ...           % ������ ����
    ,steepestDescentSlope ...       % ������ ���
    ,integratedSlope ...            % ������ facet flow ���
    ,floodedRegionIndex ...         % ������ flooded region ����
    ,floodedRegionCellsNo ...       % ������ flooded region ���� �� ��
    ,floodedRegionLocalDepth ...    % ������ flooded region ���� ���ⱸ �� ����
    ,floodedRegionTotalDepth ...    % ������ local depth �� ��
    ,floodedRegionStorageVolume] ...% ������ flooded region ������
        = ProcessSink(mRows,nCols,X_INI,X_MAX ...
        ,Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND,QUARTER_PI,CELL_AREA ...
        ,elev,ithNbrYOffset,ithNbrXOffset ...
        ,OUTER_BOUNDARY,IS_LEFT_RIGHT_CONNECTED ...
        ,slopeAllNbr,steepestDescentSlope ...
        ,facetFlowSlope,SDSNbrY,SDSNbrX,SDSFlowDirection);    
    
end % for ithCell

end % Collapse end