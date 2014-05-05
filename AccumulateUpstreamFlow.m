% =========================================================================
%> @section INTRO AccumulateUpstreamFlow
%>
%> - ��� �������κ����� ������ ���� �� ������ ���ϴ� �Լ�
%>
%>  - ����: ������ ��� flooded region�� �������� ������ ������ �������� ����
%>    ���� 2������ ���� �� ����
%>
%>  - ���� ���� ����� ������ ����. �켱 flooded region�� �������� ��������
%>    ���� ������ �̿��� ���, ���ⱸ�� ������ flooded region�� �ٸ� �������
%>    �ε巯���� ũ�� �̷� ���� ���ⱸ�� ��ݷ��� ���� ũ�� ��Ÿ���� ������
%>    �߻���. �̰��� ���� �������� �ɰ��� ������ �߱��߰� �̸� �����ϱ� ����
%>    �������� ������ ������ ����
%>
%>  - ����: ���� �� ������ ���� ������ �ʿ����� �����Ƿ� �ּ� ó����
%>
%>  - ��� ���� �� ���� ���: upstreamDischarge2, upstreamCellsNo
%>
%> - History
%>
%>  - 2009-12-31
%>   - flooded region�� �ش��ϴ� ������ ������ �� ������ ���� ����ȭ��
%>
%> @version 0.1
%> @callgraph
%> @callergraph
%>
%> @see IsBoundary()
%>
%> @retval upstreamDischarge1           : ���� ���� [m^3/year]
%> @retval isOverflowing                : flooded region ������ �ʰ� ���� �±�
%>
%> @param mRows                         : ���� (�ܰ� ��� ����) ���� �� ����
%> @param nCols                         : ���� (�ܰ� ��� ����) ���� �� ����
%> @param Y_TOP_BND                     : ���� �ܰ� �� ��� Y ��ǥ��
%> @param Y_BOTTOM_BND                  : ���� �ܰ� �Ʒ� ��� Y ��ǥ��
%> @param X_LEFT_BND                    : ���� �ܰ� �� ��� X ��ǥ��
%> @param X_RIGHT_BND                   : ���� �ܰ� �� ��� X ��ǥ��
%> @param CELL_AREA                     : �� ���� [m^2]
%> @param sortedYXElev                  : ���� �� ������ ������ Y,X ��ǥ��
%> @param consideringCellsNo            : �Լ��� ����� �Ǵ� ������ ��
%> @param OUTER_BOUNDARY                : ���� ���� �ܰ� ��� ����ũ
%> @param annualRunoff                  : ���� ��ǥ ���ⷮ [m/year]
%> @param flood                         : SINK�� ���� ���� ���̴� ����(flooded region)
%> @param floodedRegionCellsNo          : ���� flooded region �� ����
%> @param floodedRegionStorageVolume    : ���� flooded region ������(����)
%> @param floodedRegionIndex            : ���� flooded region ����
%> @param facetFlowDirection            : ���� ���� �˰������� ���� ����
%> @param e1LinearIndicies              : ���� ������ ����Ű�� ���� �� ����
%> @param e2LinearIndicies              : ���� ������ ����Ű�� ���� �� ����
%> @param outputFluxRatioToE1           : ���� ���⿡ ���� ���� ���� �й�Ǵ� ����
%> @param outputFluxRatioToE2           : ���� ���⿡ ���� ���� ���� �й�Ǵ� ����
%> @param SDSNbrY                       : �ִ��Ϻΰ�� ������ ����Ű�� ���� ���� Y ��ǥ
%> @param SDSNbrX                       : �ִ��Ϻΰ�� ������ ����Ű�� ���� ���� X ��ǥ
%> @param FLOW_ROUTING                  : Chosen flow routing algorithm
% =========================================================================
function [upstreamDischarge1,isOverflowing] = AccumulateUpstreamFlow(mRows,nCols,Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND,CELL_AREA,sortedYXElev,consideringCellsNo,OUTER_BOUNDARY,annualRunoff,flood,floodedRegionCellsNo,floodedRegionStorageVolume,floodedRegionIndex,facetFlowDirection,e1LinearIndicies,e2LinearIndicies,outputFluxRatioToE1,outputFluxRatioToE2,SDSNbrY,SDSNbrX,FLOW_ROUTING)
%
% function AccumulateUpstreamFlow
%

% constant
D_INF = 1; % infinitive flow routing algorithm

% ���� �ʱ�ȭ
% ��� ���� �ʱ�ȭ
% ��� �������κ����� ����[m^3] (flooded region�� �������� �����)
% * ����: �Ⱓ ��ǥ ���ⷮ���� �ʱ�ȭ
upstreamDischarge1 = ones(mRows,nCols) * annualRunoff * CELL_AREA;
upstreamDischarge1(OUTER_BOUNDARY) = 0;
% ��� ������ ���� �� ����
% * ����: 1�� �ʱ�ȭ
upstreamCellsNo = ones(mRows,nCols);
upstreamCellsNo(OUTER_BOUNDARY) = 0;

%--------------------------------------------------------------------------
% mex ������ ���� ����
mexSortedIndicies = (sortedYXElev(:,2)-1)*mRows + sortedYXElev(:,1);
mexSDSNbrIndicies = (SDSNbrX-1)*mRows + SDSNbrY;

if FLOW_ROUTING == D_INF

    [upstreamDischarge1 ...              0 ��� �������κ����� ���� [m^3]
    ,inputDischarge ...                  1 ��� �������κ����� ���� [m^3]
    ,dischargeInputInFloodedRegion ...   2 flooded region������ ����
    ,isOverflowing] ...                  3 flooded region ���差 �ʰ� �±�
    = EstimateUpstreamFlow ...
    (CELL_AREA ...                       0 �� ����
    ,consideringCellsNo ...              1 ��� ���� ������ �� ������ ���ϴ� �� ��
    ,annualRunoff); ...                  2 ���� ���ⷮ
    %--------------------------------- �Է� �������� ������ �κ�
    %,upstreamCellsNo2 ...                 4 ��� ������ ���� �� ����
    %,inputCellsNo2 ...                    5 ��� ������ ���� �� ����
    % -------------------------------- mexGetVariabelPtr �Լ��� �����ϴ� ������
    % upstreamDischarge1 ...             3 ��� �������κ����� ���ⷮ �ʱⰪ
    % upstreamCellsNo); ...              4 ��� ������ ���� �� ���� �ʱⰪ
    % mexSortedYXElev ...                5 �������� ���ĵ� ����
    % e1LinearIndicies ...               6 ���� �� ����
    % e2LinearIndicies ...               7 ���� �� ���� 
    % outputFluxRatio1 ...               8 ���� ������ ���� ����
    % outputFluxRatio2 ...               9 ���� ������ ���� ����
    % mexSDSNbrLinearIndicies ...        10 ���� �� ����
    % flood ...                          11 flooded region
    % floodedRegionCellsNo ...           12 flooded region ���� �� ����
    % floodedRegionStorageVolume ...     13 flooded region ���差 [m^3]
    
else
    
    [upstreamDischarge1 ...              0 ��� �������κ����� ���� [m^3]
    ,inputDischarge ...                  1 ��� �������κ����� ���� [m^3]
    ,dischargeInputInFloodedRegion ...   2 flooded region������ ����
    ,isOverflowing] ...                  3 flooded region ���差 �ʰ� �±�
    = EstimateUpstreamFlowBySDS ...
    (CELL_AREA ...                       0 �� ����
    ,consideringCellsNo ...              1 ��� ���� ������ �� ������ ���ϴ� �� ��
    ,annualRunoff); ...                  2 ���� ���ⷮ
    %--------------------------------- �Է� �������� ������ �κ�
    %,upstreamCellsNo2 ...               4 ��� ������ ���� �� ����
    %,inputCellsNo2 ...                  5 ��� ������ ���� �� ����
    % -------------------------------- mexGetVariabelPtr �Լ��� �����ϴ� ������
    % upstreamDischarge1 ...             3 ��� �������κ����� ���ⷮ �ʱⰪ
    % upstreamCellsNo); ...              4 ��� ������ ���� �� ���� �ʱⰪ
    % mexSortedYXElev ...                5 �������� ���ĵ� ����
    % e1LinearIndicies ...               6 ���� �� ����
    % e2LinearIndicies ...               7 ���� �� ���� 
    % outputFluxRatio1 ...               8 ���� ������ ���� ����
    % outputFluxRatio2 ...               9 ���� ������ ���� ����
    % mexSDSNbrLinearIndicies ...        10 ���� �� ����
    % flood ...                          11 flooded region
    % floodedRegionCellsNo ...           12 flooded region ���� �� ����
    % floodedRegionStorageVolume ...     13 flooded region ���差 [m^3]

end

%--------------------------------------------------------------------------
% �ռ� flooded region�� ������ ������ ������ �� ������ ���ߴ�. ���⼭��
% flooded region�� �ش��ϴ� ������ ������ �� ������ �����Ѵ�.

% 1. flooded region���� ���ⱸ ��ǥ�� ������ ���Ѵ�.
[tmpOutletY,tmpOutletX] = find(floodedRegionCellsNo > 0);

floodedRegionsNo = size(tmpOutletY,1);

% 2. ���� flooded region ���� ������ ������ �� ������ ���Ѵ�.
for ithFloodedRegion = 1:floodedRegionsNo
    
    % 1) ���� ó���� flooded region�� ���ⱸ ��ǥ�� Ȯ���Ѵ�.
    outletY = tmpOutletY(ithFloodedRegion,1);
    outletX = tmpOutletX(ithFloodedRegion,1);
    
    % 2) ���� ó���� flooded region�� ���� ��ȣ�� �ľ��Ѵ�.
    floodedRegionIndexNo = - floodedRegionIndex(outletY,outletX);
    
    % 3) �ݺ��� ������ �����Ѵ�.
    currentFloodedRegion ...
        = (floodedRegionIndex == floodedRegionIndexNo);
    
    % 4) ���ⱸ�� �� ���� ��迡 ��ġ�ϴ��� Ȯ���Ѵ�.
    if IsBoundary(outletY,outletX,Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND)

        % (1) ���ⱸ�� �� ���� ��迡 ��ġ�Ѵٸ�, 1) flooded
        %    region ������ �ʰ� ����, 2) ���ⱸ�� ���Է��� ���ⷮ�� ������
        %    �ʾҴ�. ���⼭�� �̵��� ���Ѵ�.

        % A. flooded region�� ���Է��� ��ǥ ���ⷮ �հ踦 ���Ѵ�.
        dischargeInputInFloodedRegion(outletY,outletX) ...
            = dischargeInputInFloodedRegion(outletY,outletX)...
            + floodedRegionCellsNo(outletY,outletX) ...
            * annualRunoff * CELL_AREA;

        % B. flooded region�� �������� ���Է��� ���Ѵ�.
        if dischargeInputInFloodedRegion(outletY,outletX) ...
                > floodedRegionStorageVolume(outletY,outletX)

            % A) ���Է��� flooded region�� �������� �ʰ��Ѵٸ�,
            %    ���ⱸ�� ���Է��� flooded region�� �ʰ� ���Է���
            %    ���Ѵ�.
            inputDischarge(outletY,outletX) ...
                = inputDischarge(outletY,outletX) ...
                + ( dischargeInputInFloodedRegion(outletY,outletX) ...
                - floodedRegionStorageVolume(outletY,outletX) );

            % B) ���Է��� �ʰ������� ǥ���Ѵ�.
            isOverflowing(outletY,outletX) = true;

        end

        % C. ���ⱸ�� ������ ��� �������κ��� �����ϴ� ������ ���Ѵ�.
        % * ���� : flooded region�� �ʰ� ���Է��� ������ ���̴�.
        % * ���� ��迡 �ִ� ���̱� ������, ���⼭ ���Ǿ ������ ����.
        upstreamDischarge1(outletY,outletX) ...
            = upstreamDischarge1(outletY,outletX) ...
            + inputDischarge(outletY,outletX);

        % D. ���ⱸ�� ���� �� ������ ��� �������κ��� �����ϴ� ����
        %    ������ ���Ѵ�.
        % * ���� : flooded region�� �� ������ ������ ���̴�.
%         upstreamCellsNo(outletY,outletX) ...
%             = upstreamCellsNo(outletY,outletX) ...
%             + inputUpstreamCellsNo(outletY,outletX) ...
%             + floodedRegionCellsNo(outletY,outletX);

    end % IsBoundary(outletY,outletX,Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND)
    
    % 5) ���� ó���� flooded region�� ������ ���Ѵ�.
    % (1) flooded region������ ���Է��� �������� �ʰ��ߴ��� Ȯ���Ѵ�.
    if isOverflowing(outletY,outletX) == true
        
        % A. ���� �ʰ��ߴٸ�, ���ⱸ���� ���� ���� ������ �����Ѵ�.
        upstreamDischarge1(currentFloodedRegion) ...
            = upstreamDischarge1(outletY,outletX) - annualRunoff * CELL_AREA;
    
    else
        
        % B. �ʰ����� �ʴ´ٸ�, flooded region������ ���Է��� ���� ��ǥ ���ⷮ
        %    ���� �����Ѵ�.
        upstreamDischarge1(currentFloodedRegion) ...
            = dischargeInputInFloodedRegion(outletY,outletX);
        
    end

    % 6) ���� ó���� flooded region�� �� ������ ���Ѵ�. ���ⱸ�� �� ��������
    %    ���� ���� ���� �����Ѵ�.
%     upstreamCellsNo(currentFloodedRegion) ...
%             = upstreamCellsNo(outletY,outletX) - 1;
        
end % ithFloodedRegion = 1:

% upstreamCellsNo�� �̿��Ͽ� �������� ������� ���� ��� �������κ����� ������
% ����
% upstreamDischarge2 = upstreamCellsNo .* annualRunoff .* CELL_AREA;

end % AccumulateUpstreamFlow end