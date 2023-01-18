% =========================================================================
%> @section INTRO HillslopeProcess
%>
%> - ����ۿ뿡 ���� ������ �β� ��ȭ��[m/dT]�� ���ϴ� �Լ�
%>  - ��ȭ��(��̺� �������� ��)�� finite volume ���ٹ��� �̿��� (Tucker et al., 2001).
%>
%> @version 0.8
%> @callgraph
%> @callergraph
%>
%> @retval dSedimentThick           : ����ۿ����� ���� ������ �β� ��ȭ�� [m/dT]
%>
%> @param mRows                     : ���� (�ܰ� ��� ����) ���� �� ����
%> @param nCols                     : ���� (�ܰ� ��� ����) ���� �� ����
%> @param Y                         : �ܰ� ��踦 ������ Y�� ũ��
%> @param X                         : �ܰ� ��踦 ������ X�� ũ��
%> @param Y_INI                     : ���� ���� Y ���� ��ǥ��(=2)
%> @param Y_MAX                     : ���� ���� Y ������ ��ǥ��(=Y+1)
%> @param X_INI                     : ���� ���� X ���� ��ǥ��(=2)
%> @param X_MAX                     : ���� ���� X ������ ��ǥ��(=X+1)
%> @param dX                        : �� ũ�� [m]
%> @param dT                        : �������� �����Ⱓ [year]
%> @param CELL_AREA                 : �� ���� [m^2]
%> @param sortedYXElev              : ���� �� ������ ������ Y,X ��ǥ��
%> @param consideringCellsNo        : �Լ��� ����� �Ǵ� ������ ��
%> @param s3IthNbrLinearIndicies    : 8 ���� �̿� ���� ����Ű�� 3���� ���� �迭
%> @param sedimentThick             : ������ �β� [m]
%> @param DIFFUSION_MODEL           : Ȯ��� ���� (1: linear, 2: non-linear Roering et al.(1999))
%> @param kmd                       : ����ۿ��� Ȯ�� ��� [m2/m year]
%> @param soilCriticalSlopeForFailure : critical hillslope gradient [m/m]
%> @param flood                     : SINK�� ���� ���� ���̴� ����(flooded region)
%> @param floodedRegionCellsNo      : ���� flooded region �� ����
%> @param floodedRegionIndex        : ���� flooded region ����
%> @param SDSNbrY                   : �ִ��Ϻΰ�� ������ ����Ű�� ���� ���� Y ��ǥ
%> @param SDSNbrX                   : �ִ��Ϻΰ�� ������ ����Ű�� ���� ���� X ��ǥ
%> @param slopeAllNbr               : 8 �̿� ������ ��� [radian]
% =========================================================================
function dSedimentThick = HillslopeProcess(mRows,nCols,Y,X,Y_INI,Y_MAX,X_INI,X_MAX ...
    ,dX,dT,CELL_AREA,sortedYXElev,consideringCellsNo,s3IthNbrLinearIndicies ...
    ,sedimentThick,DIFFUSION_MODEL,kmd,soilCriticalSlopeForFailure ...
    ,flood,floodedRegionCellsNo,floodedRegionIndex,SDSNbrY,SDSNbrX,slopeAllNbr)
% 
% function HillslopePrcess
%

%--------------------------------------------------------------------------
% 1. �� �ܺη��� ����ۿ� (��õ�� �������� �ʴ� �� ���)

% 1) ����ۿ뿡 ���� ���� �̿� ������ ������ ��ݴɷ�
% * ���� : ���� �̿� ������ �ִ� ������ ��ݴɷ� ������ ���� ��� ���꿡 ����
%   ���� �ƴ϶�, ��� �������� ����

% ��� ����
LINEAR = 1;

% ���� �ʱ�ȭ
% ���� �̿� ������ ������ ��ݴɷ� [m^3/m^2 dT]
transportCapacityToNbrs = zeros(mRows,nCols,8);
% ��� �̿� ������ ������ ��ݴɷ� [m^3/m^2 dT]
sumTransportCapacityToNbrs = zeros(mRows,nCols);

% ������ �̿� ���� ���� ������ ��ݴɷ°� ���� �� ��
for ithNbr = 1:8
    
    % 1. (��Ŀ����� �����ϱ� ����) i��° �̿� ������ �ִ� �Ϻ� ��縦
    %    2���� ��ķ� �����Ѵ�.
    sIthNbrSDSSlope = slopeAllNbr(Y_INI:Y_MAX,X_INI:X_MAX,ithNbr);
    
    % 2. i��° �̿� ������ �ִ��Ϻΰ�簡 ���� ��
    satisfyingCells = (sIthNbrSDSSlope > 0);
    
    % 3. i��° �̿� ������ ������ ��� �ɷ�
    % 1) ���� �ʱ�ȭ
    sTransportCapacityToIthNbr = zeros(Y,X);
    
    % 2) ������ ��� �ɷ�

    if DIFFUSION_MODEL == LINEAR

        % * ���� ���� ���
        sTransportCapacityToIthNbr(satisfyingCells) ...
            = dX * ( kmd * sIthNbrSDSSlope(satisfyingCells) ) ...
            .* dT ...                               % ������ȯ [m^3/dT]
            ./ CELL_AREA;                           % ������ȯ [m/dT]

    else
    
        % * ���� ���� Roering et al(1999) ����
        sTransportCapacityToIthNbr(satisfyingCells) ...
            = dX .* ( kmd .* ( sIthNbrSDSSlope(satisfyingCells) ...
            ./ ( 1 - ( sIthNbrSDSSlope(satisfyingCells) ./ soilCriticalSlopeForFailure) .^ 2) ) ) ...
            .* dT ...                             % ������ȯ [m^3/dT]
            ./ CELL_AREA;                         % ������ȯ [m/dT]

    end
    
    transportCapacityToNbrs(Y_INI:Y_MAX,X_INI:X_MAX,ithNbr) ...
        = sTransportCapacityToIthNbr;
    
    % 4. ��� �̿� ������ ������ ��� �ɷ�
    sumTransportCapacityToNbrs(Y_INI:Y_MAX,X_INI:X_MAX) ...
        = sumTransportCapacityToNbrs(Y_INI:Y_MAX,X_INI:X_MAX) ...
        + sTransportCapacityToIthNbr;
    
end

% 2) (���� �� ������) ����ۿ뿡 ���� ������ �β� ��ȭ��

% 8���� �̿� �� ���� (3���� ����)
% * ����: CalcInfinitiveFlow �� CalcSDSFlow �Լ��� �޸� �̿� �� ������ ���
%   ���� ���� mRows�� nCols��. n�� 3������ ��Ÿ���� 3�� ���̱� ���� �׳�'null'
%   ���� ����
n3IthNbrLinearIndicies = nan(mRows,nCols,8);
n3IthNbrLinearIndicies(Y_INI:Y_MAX,X_INI:X_MAX,:) = s3IthNbrLinearIndicies;

%--------------------------------------------------------------------------
% HillslopeProcessMex �Լ� �κ�

% ���� ���� �غ�
mexSortedIndicies = (sortedYXElev(:,2)-1)*mRows + sortedYXElev(:,1);
mexSDSNbrIndicies = (SDSNbrX-1)*mRows + SDSNbrY;

[inputFlux ...                   0 ��� �������κ����� ������ [m/dT]
,outputFlux...                   1 �̿� ������ �� ������ [m/dT]
,inputFloodedRegion ...          2 flooded region������ ������ [m/dT]
    ] = HillslopeProcessMex(mRows,nCols,consideringCellsNo);
% HillslopeProcessMex �Լ��� mexGetVariablePtr �Լ��� �����ϴ� ����
%
% mexSortedIndicies ...            0 . �������� ���ĵ� ����
% mexSDSNbrIndicies ...            1 . ���� �� ����
% n3IthNbrLinearIndicies ...       2 . 3���� 8���� �̿� �� ����
% flood ...                        3 . flooded region
% sedimentThick ...                4 . ������ �β�
% transportCapacityToNbrs ...      5 . �� �̿� ������ ����ۿ� ��ݴɷ�
% sumTransportCapacityToNbrs ...   6 . �� ����ۿ� ��ݴɷ�
%
%--------------------------------------------------------------------------

% 3) flooded region�� ������ �β� ��ȭ��
% �ռ� flooded region�� ������ ������ ������� ��鹰���� �̿� ���� �й���.
% ���⼭�� flooded region���� ������ ��鹰���� ���� flooded region�� ������
% �β� ��ȭ���� ����

% (1) flooded region���� ���ⱸ ��ǥ�� ����
[tmpOutletY,tmpOutletX] = find(floodedRegionCellsNo > 0);

floodedRegionsNo = size(tmpOutletY,1);

% (2) ���� flooded region ���� ������ ������ �β� ��ȭ��
for ithFloodedRegion = 1:floodedRegionsNo
    
    % A. ���� ó���� flooded region�� ���ⱸ ��ǥ
    outletY = tmpOutletY(ithFloodedRegion,1);
    outletX = tmpOutletX(ithFloodedRegion,1);
    
    % B. ���� ó���� flooded region�� ���� ��ȣ
    floodedRegionIndexNo = - floodedRegionIndex(outletY,outletX);
    
    % C. ���� ó���� flooded region�� ����
    currentFloodedRegion ...
        = (floodedRegionIndex == floodedRegionIndexNo);
    
    % D. ������ �������� ���� ����ϴ� ��� ������ �β�
    inputFlux(currentFloodedRegion) ...
        = inputFlux(currentFloodedRegion) ...
        + ( inputFloodedRegion(outletY,outletX) ...
        / floodedRegionCellsNo(outletY,outletX) );
    
end

% 4) (�� �ܺ�) ����ۿ����� ���� ������ �β� ��ȭ�� [m/dT]
% * ����: ���⼭�� ����ۿ��� ��� ���࿡ �����ǹǷ�, ��ݾ� �� ��ȭ�� ����
% * ����: inputFlux �ܰ� ��迡�� ����ۿ����� ���� �𵨿������� ����Ǵ� ����
%   �ݿ��Ǿ� ����.
dSedimentThick = inputFlux - outputFlux;

end % HillslopeProcess end