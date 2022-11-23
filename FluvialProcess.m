% =========================================================================
%> @section INTRO FluvialProcess
%>
%> - ��õ�ۿ뿡 ���� ������ �β� �� ��ݾ� �� ��ȭ���� ���ϴ� �Լ�
%>
%> - History
%>  - 2020140426
%>   - EstimateDElveByFluvialProcesss_m.m ���� �ۼ�
%>  - 20110819
%>   - ��� ������ ��ǥ����� ���� �����̵��� �ݿ���
%>  - 201007
%>   - �ϵ� �� �ϻ� �������� ��������� ����
%>  - 20100321
%>   - flooded region �� �� ������ �β� ��ȭ�� ���ϴ� �˰����� ����ȭ��
%>  - 20100313
%>   - ��ݾ� �ϻ� ħ���� �߰���
%>  - 20100224
%>   - flooded region �� ���� ���ⱸ�� �� �� ��ȭ���� ���ϴ� �˰�����
%>     ��ü������ ������. ��Ⱓ�� ���� �ߴ��� ������ ���, ���� �ð���
%>     �ҿ���� �ʴ� ������ �˰����� ������
%>  - 20100209
%>   - EstimateMinTakenTime �Լ��� ������ ��õ�� ���� �� �� ��ȭ���� ���ϴ�
%>     �Լ��� Ưȭ ��Ŵ
%>  - 20100104
%>   - flooded region�� ���� ���ⱸ�� �� �� ��ȭ���� ���ϴ� �˰����� ����
%>     ������. Ư�� ���ⱸ���� ������������ ���� ������ ��ݷ��� ���̴µ�
%>     �־����� �ξ���
%>  - 20091225
%>   - flooded region �� sink �� ������ FluvialProcess �Լ� ���� �� ���ⱸ��
%>     ������ �� �������� ������ �߻��Ͽ�, �̸� �ذ��ϱ� ���� �õ��� ��
%>  - 20091221
%>   - �������� ä���� flooded region�� ���ⱸ ���� ������������ ��������
%>     ������ �ذ��ϰ�, �������� ä������ ���� flooded region������ ���� ����
%>     �������� ���� �̵��� �Ͼ���� ��
%>
%> @version 0.93
%> @callgraph
%> @callergraph
%> @see IsBoundary()
%>
%> @retval dSedimentThick               : ������ �β� ��ȭ�� [m/subDT]
%> @retval dBedrockElev                 : ��ݾ� �� ��ȭ�� [m/subDT]
%> @retval dChanBedSed                  : �ϵ� �� �ϻ� ������ ��ȭ�� [m^3/subDT]

%> @param mRows                         : ���� (�ܰ� ��� ����) ���� �� ����
%> @param nCols                         : ���� (�ܰ� ��� ����) ���� �� ����
%> @param Y_TOP_BND                     : ���� �ܰ� �� ��� Y ��ǥ��
%> @param Y_BOTTOM_BND                  : ���� �ܰ� �Ʒ� ��� Y ��ǥ��
%> @param X_LEFT_BND                    : ���� �ܰ� �� ��� X ��ǥ��
%> @param X_RIGHT_BND                   : ���� �ܰ� �� ��� X ��ǥ��
%> @param CELL_AREA                     : �� ���� [m^2]
%> @param FLUVIALPROCESS_COND           : flooded region�� �� ������ �β� ��ȭ���� �����ϴ� ���
%> @param timeWeight                    : �������� ���ӱⰣ�� ���̱� ���� ħ���� ����ġ
%> @param sortedYXElev                  : ���� �� ������ ������ Y,X ��ǥ��
%> @param consideringCellsNo            : �Լ��� ����� �Ǵ� ������ ��
%> @param channel                       : ��õ ���� �Ӱ�ġ�� ���� ��
%> @param chanBedSed                    : �ϵ� �� �ϻ� ������ ���� [m^3]
%> @param hillslope                     : ��鼿
%> @param sedimentThick                 : ������ �β�
%> @param OUTER_BOUNDARY                : ���� ���� �ܰ� ��� ����ũ
%> @param bankfullDischarge             : �������� [m^3/s]
%> @param bankfullWidth                 : ���������� ���� [m]
%> @param flood                         : SINK�� ���� ���� ���̴� ����(flooded region)
%> @param floodedRegionIndex            : ���� flooded region ����
%> @param floodedRegionCellsNo          : ���� flooded region �� ����
%> @param floodedRegionLocalDepth       : flooded region ���� ���� ���� [m]
%> @param floodedRegionTotalDepth       : flooded region ���� �� ������ ���� [m]
%> @param floodedRegionStorageVolume    : ���� flooded region ���� [m^3]
%> @param e1LinearIndicies              : ���� ������ ����Ű�� ���� �� ����
%> @param e2LinearIndicies              : ���� ������ ����Ű�� ���� �� ����
%> @param outputFluxRatioToE1           : ���� ���⿡ ���� ���� ���� �й�Ǵ� ����
%> @param outputFluxRatioToE2           : ���� ���⿡ ���� ���� ���� �й�Ǵ� ����
%> @param SDSNbrY                       : �ִ��Ϻΰ�� ������ ����Ű�� ���� ���� Y ��ǥ
%> @param SDSNbrX                       : �ִ��Ϻΰ�� ������ ����Ű�� ���� ���� X ��ǥ
%> @param integratedSlope               : ������ facet flow ��� [radian]
%> @param kfa                           : 
%> @param mfa                           : ��õ�� ���� ������ ��� ���Ŀ��� ������ ����
%> @param nfa                           : ��õ�� ���� ������ ��� ���Ŀ��� ����� ����
%> @param kfbre                         : ��ݾ� �ϻ� ���൵
%> @param fSRho                         : ��ݵǴ� �������� ��� �е�
%> @param g                             : �߷°��ӵ�
%> @param nB                            : ��ݾ� �ϻ� �ϵ������� Manning ���� ���
%> @param mfb                           : ��ݾ� �ϻ� ħ�� ���Ŀ��� ������ ����
%> @param nfb                           : ��ݾ� �ϻ� ħ�� ���Ŀ��� ����� ����
%> @param subDT                         : ���� ���� �ð� [s]
%> @param dX                            : �� ũ�� [s]
%> @param bedrockElev                   : ��ݾ� ��[m]
%> @param FLOW_ROUTING                  : Chosen flow routing algorithm
% =========================================================================
function [dSedimentThick,dBedrockElev,dChanBedSed] = FluvialProcess(mRows,nCols,Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND,CELL_AREA,FLUVIALPROCESS_COND,timeWeight,sortedYXElev,consideringCellsNo,channel,chanBedSed,hillslope,sedimentThick,OUTER_BOUNDARY,bankfullDischarge,bankfullWidth,flood,floodedRegionIndex,floodedRegionCellsNo,floodedRegionLocalDepth,floodedRegionTotalDepth,floodedRegionStorageVolume,e1LinearIndicies,e2LinearIndicies,outputFluxRatioToE1,outputFluxRatioToE2,SDSNbrY,SDSNbrX,integratedSlope,kfa,mfa,nfa,kfbre,fSRho,g,nB,mfb,nfb,subDT,dX,bedrockElev,elev,FLOW_ROUTING)
%
% function FluvialProcess
%

% constant
D_INF = 1; % infinitive flow routing algorithm 

%--------------------------------------------------------------------------
% flooded region�� ������ ������ ������ �β� �� ��ݾ� �� ��ȭ�� ����

% ���� �ʱ�ȭ
transportCapacityForShallow ...     % ��ǥ����� ���� �����̵�
    = ( bankfullWidth ...
    .* ( kfa .* ( bankfullDischarge ./ bankfullWidth ) .^ mfa ...
    .* integratedSlope .^ nfa ) ) .* subDT ...
    .* timeWeight;                  % �������� ���ӱⰣ ��Ҹ� ���� ����ġ
% ������: ����δ� ��õ�� ���� ������ ��ݴɷ°� �����ϰ� ������. ���� �Ű�����
% ������ �ʿ���

transportCapacity ...               % ������ ��� �ɷ�[m^3/subDT]
    = ( bankfullWidth ...
    .* ( kfa .* ( bankfullDischarge ./ bankfullWidth ) .^ mfa ...
    .* integratedSlope .^ nfa ) ) .* subDT ...
    .* timeWeight;                  % �������� ���ӱⰣ ��Ҹ� ���� ����ġ

% ��ݾ� �ϻ� ħ����[m^3/subDT]
% * ����: �� ��ü�� �ƴ� �ϵ��� ���� ħ�ĵǴ� ���Ǹ� ���� (Tucker et al.,1994)
bedrockIncision ...
    = ( dX .* bankfullWidth ...
    .* (kfbre * fSRho * g * nB^mfb ...
    .* (bankfullDischarge ./ bankfullWidth).^ mfb ...
    .* integratedSlope .^ nfb ) ) .* subDT ...
    .* timeWeight;                  % �������� ���ӱⰣ ��Ҹ� ���� ����ġ

%--------------------------------------------------------------------------
% EstimateDElevByFluvial.c �κ�

% ���� ���� �غ�
mexSortedIndicies = (sortedYXElev(:,2)-1)*mRows + sortedYXElev(:,1);
mexSDSNbrIndicies = (SDSNbrX-1)*mRows + SDSNbrY;

if FLOW_ROUTING == D_INF

    [dSedimentThick ...      % ������ �β� ��ȭ�� [m^3/m^2 subDT]
    ,dBedrockElev ...        % ��ݾ� �� ��ȭ�� [m^3/m^2 subDT]
    ,dChanBedSed ...         % �ϵ� �� �ϻ� ������ ��ȭ�� [m^3/subDT]
    ,inputFlux ...           % ��� �������� ������ ������ [m^3/subDT]
    ,outputFlux...           % �Ϸ����� ������ [m^3/subDT]
    ,inputFloodedRegion ...  % flooded region������ ������ [m^3/subDT]
    ,isFilled] ...           % ��� �������� ���� flooded region�� ���� ����
    = EstimateDElevByFluvialProcess ...
    (dX ...                              % 0 . �� ũ��
    ,mRows ...                           % 1 . �� ����
    ,nCols ...                           % 2 . �� ����
    ,consideringCellsNo);                % 3 . ��õ�ۿ��� �߻��ϴ� �� ��
    % ------------------------------------% ���ϴ� mexGetVariablePtr�� �θ�
    % mexSortedIndicies ...              % 4 . �������� ���ĵ� ����
    % e1LinearIndicies ...               % 5 . ���� �� ����
    % e2LinearIndicies ...               % 6 . ���� �� ����
    % outputFluxRatioToE1 ...            % 7 . ���� ������ ���� ����
    % outputFluxRatioToE2 ...            % 8 . ���� ������ ���� ����
    % mexSDSNbrIndicies ...              % 9 . ���� �� ����
    % flood ...                          % 10 . flooded region
    % floodedRegionCellsNo ...           % 11 . flooded region ���� �� ��
    % floodedRegionStorageVolume ...     % 12 . flooded region ���差
    % bankfullWidth ...                  % 13 . ���������� ����
    % transportCapacity ...              % 14 . �ִ� ������ ��ݴɷ�
    % bedrockIncision ...                % 15 . ��ݾ� �ϻ� ħ����
    % chanBedSed ...                     % 16 . �ϵ��� �ϻ� ������ ����
    % sedimentThick ...                  % 17 . ������ �β�
    % hillslope ...                      % 18 . ��鼿
    % transportCapacityForShallow ...    % 19 . ��ǥ����� ���� �����̵�
    % bedrockElev ...                    % 20 . ��ݾ� ��

    % %--------------------------------------------------------------------------
    % % EstimateDElevByFluvial_m.m �κ�
    % 
    % [dSedimentThick1 ...      % ������ �β� ��ȭ�� [m^3/m^2 subDT]
    % ,dBedrockElev1 ...        % ��ݾ� �� ��ȭ�� [m^3/m^2 subDT]
    % ,dChanBedSed1 ...         % �ϵ� �� �ϻ� ������ ��ȭ�� [m^3/subDT]
    % ,inputFlux1 ...           % ��� �������� ������ ������ [m^3/subDT]
    % ,outputFlux1...           % �Ϸ����� ������ [m^3/subDT]
    % ,inputFloodedRegion1 ...  % flooded region������ ������ [m^3/subDT]
    % ,isFilled1] ...           % ��� �������� ���� flooded region�� ���� ����
    % = EstimateDElevByFluvialProcess_m ...
    % (dX ...                         % �� ũ��
    % ,mRows ...
    % ,nCols ...
    % ,consideringCellsNo ...         % ��õ�ۿ��� �߻��ϴ� �� ��
    % ,sortedYXElev ... 		        % �������� ���ĵ� Y,X ��ǥ
    % ,e1LinearIndicies ...           % ���� �� ����
    % ,e2LinearIndicies ...           % ���� �� ����
    % ,outputFluxRatioToE1 ...        % ���� ������ ���� ����
    % ,outputFluxRatioToE2 ...        % ���� ������ ���� ����
    % ,SDSNbrY ...                    % ���� �� ����
    % ,SDSNbrX ...                    % ���� �� ����
    % ,flood ...                      % flooded region
    % ,floodedRegionCellsNo ...       % flooded region ���� �� ��
    % ,floodedRegionStorageVolume ... % flooded region ���差
    % ,transportCapacity ...          % �ִ� ������ ��ݴɷ�
    % ,bedrockIncision ...			% ��ݾ� �ϻ� ħ����
    % ,chanBedSed ...                 % �ϵ��� �ϻ� ������ ����
    % ,bedrockElev ...				% ��ݾ� ��
    % ,sedimentThick ...              % ������ �β�
    % ,hillslope ...                  % ��� ��
    % ,transportCapacityForShallow ...% ��ǥ����� ���� �����̵�
    % ,elev);
    % 
    % %for debug
    % if sum(sum(dSedimentThick1-dSedimentThick)) > 1e-6
    %     error('FuvialProcess:notEqual','dSedimentThick');
    % end
    % if sum(sum(dBedrockElev1-dBedrockElev)) > 1e-6
    %     error('FuvialProcess:notEqual','dBedrockElev1');
    % end
    % if sum(sum(dChanBedSed1-dChanBedSed)) > 1e-6
    %     error('FuvialProcess:notEqual','dChanBedSed');
    % end
    % if sum(sum(inputFlux1-inputFlux)) > 1e-6
    %     error('FuvialProcess:notEqual','inputFlux');
    % end
    % if sum(sum(outputFlux1-outputFlux)) > 1e-6
    %     error('FuvialProcess:notEqual','outputFlux');
    % end
    % if sum(sum(inputFloodedRegion1-inputFloodedRegion)) > 1e-6
    %     error('FuvialProcess:notEqual','inputFloodedRegion');
    % end
    % if sum(sum(isFilled1-isFilled)) > 1e-6
    %     error('FuvialProcess:notEqual','isFilled');
    % end
    % %--------------------------------------------------------------------------
    
else
    
    [dSedimentThick ...      % ������ �β� ��ȭ�� [m^3/m^2 subDT]
    ,dBedrockElev ...        % ��ݾ� �� ��ȭ�� [m^3/m^2 subDT]
    ,dChanBedSed ...         % �ϵ� �� �ϻ� ������ ��ȭ�� [m^3/subDT]
    ,inputFlux ...           % ��� �������� ������ ������ [m^3/subDT]
    ,outputFlux...           % �Ϸ����� ������ [m^3/subDT]
    ,inputFloodedRegion ...  % flooded region������ ������ [m^3/subDT]
    ,isFilled] ...           % ��� �������� ���� flooded region�� ���� ����
    = EstimateDElevByFluvialProcessBySDS ...
    (dX ...                              % 0 . �� ũ��
    ,mRows ...                           % 1 . �� ����
    ,nCols ...                           % 2 . �� ����
    ,consideringCellsNo);                % 3 . ��õ�ۿ��� �߻��ϴ� �� ��
    % ------------------------------------% ���ϴ� mexGetVariablePtr�� �θ�
    % mexSortedIndicies ...              % 4 . �������� ���ĵ� ����
    % mexSDSNbrIndicies ...              % 9 . ���� �� ����
    % flood ...                          % 10 . flooded region
    % floodedRegionCellsNo ...           % 11 . flooded region ���� �� ��
    % floodedRegionStorageVolume ...     % 12 . flooded region ���差
    % bankfullWidth ...                  % 13 . ���������� ����
    % transportCapacity ...              % 14 . �ִ� ������ ��ݴɷ�
    % bedrockIncision ...                % 15 . ��ݾ� �ϻ� ħ����
    % chanBedSed ...                     % 16 . �ϵ��� �ϻ� ������ ����
    % sedimentThick ...                  % 17 . ������ �β�
    % hillslope ...                      % 18 . ��鼿
    % transportCapacityForShallow ...    % 19 . ��ǥ����� ���� �����̵�
    % bedrockElev ...                    % 20 . bedrock elevation
    %--------------------------------------------------------------------------

end

%--------------------------------------------------------------------------
% �ռ� flooded region�� ������ ���鿡�� ������ �β� �� ��ݾ� �� ��ȭ����
% ����. ���⼭�� flooded region ������ ������ �β� ��ȭ���� ���ϰ�, flooded
% region ���ⱸ�� ������ �β� ��ȭ���� ������.

% ���

% FLUVIALPROCESS_COND for flooded region �±�
SIMPLE = 1;
% DETAIL = 2;
X_INI = 1;
X_MAX = nCols - 1;
Y_INI = 2;
Y_MAX = mRows - 1;

% ���� �ʱ�ȭ
% flooded region ���ⱸ�� �� ��ȭ��[m/subDT]�� ���� ���� ���� ��, �̸�
% flooded region �� ������ ���� ��
sedimentDepthToBeAdded = zeros(mRows,nCols);
% flooded region�� ���� ����� ���, flooded region�� ���� ���ⱸ�� ����
% ��������� ����ϴ� ����(�Ϲ������� < 1)
outletWeightToBeAdded = 0.5;
% flooded region�� ���� �����ϰ� �����Ǵ� ���� �����ϱ� ���� ���� ����
verySmallRandomValues = rand(mRows,nCols) * 0.001;

% (flooded region �� ��ȭ���� ���ϱ� ����) ���� ��ȭ [m^3 -> m]
inputFlux = inputFlux ./ CELL_AREA;
outputFlux = outputFlux ./ CELL_AREA;
inputFloodedRegion ...
    = inputFloodedRegion ./ (floodedRegionCellsNo * CELL_AREA);

% ��õ�� �������� ���� ������ �������� ������ �β� ��ȭ���� �ݿ���
dSedimentThick(~channel) = dSedimentThick(~channel) + inputFlux(~channel);

% 1. ������ �β��� ��ݾ� �� ��ȭ���� ���Ͽ� �� ��ȭ���� ����
% * flooded region�� ������ �β� ��ȭ���� ������ ������ �ִ� ���� ���ⱸ��
%   �� ��ȭ����
dElev = zeros(mRows,nCols);
dElev(Y_INI:Y_MAX,X_INI:X_MAX) ...
    = dSedimentThick(Y_INI:Y_MAX,X_INI:X_MAX)...
    + dBedrockElev(Y_INI:Y_MAX,X_INI:X_MAX);

% 2. flooded region ���ⱸ�� ��ǥ�� �� ����
[tmpOutletY,tmpOutletX] = find(floodedRegionCellsNo > 0);

floodedRegionsNo = size(tmpOutletY,1);

% 3. ���� flooded region�� ���ⱸ�� ������ �β� ��ȭ���� ����
for ithFloodedRegion = 1:floodedRegionsNo
    
    % 1) ���� ó���� flooded region�� ���ⱸ ��ǥ
    outletY = tmpOutletY(ithFloodedRegion,1);
    outletX = tmpOutletX(ithFloodedRegion,1);
    
    % 2) ���� ó���� flooded region�� ���� ��ȣ
    floodedRegionIndexNo = - floodedRegionIndex(outletY,outletX);
    
    % 3) ���� ó���� flooded region�� ����
    currentFloodedRegion = ...
        (floodedRegionIndex == floodedRegionIndexNo);
    
    % 3) ���ⱸ�� �ܰ� ��迡 ��ġ�ϴ��� Ȯ����
    if IsBoundary(outletY,outletX,Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND)

        % (1) ���ⱸ�� �ܰ� ��迡 ��ġ�Ѵٸ�, 1) ���� �������� ���差 �ʰ� ����,
        %     2) ���ⱸ�� ������ �������� ������, 3) ���ⱸ�� ������ �β�
        %     ��ȭ���� �տ��� ������ �ʾ����Ƿ� ���⼭ �̸� ����
        % * ����: ���� �ǹ��ִ� ���� 1)�� 2)�� ��������. �̴� �ܰ� �����
        %   ������ �β� �� �� ��ȭ���� �ǹ̰� ���� ������

        % a. flooded region������ ������[m/subDT]�� ���差[m^3/m^2]��
        %    �ʰ��ߴ��� Ȯ����
        if inputFloodedRegion(outletY,outletX) > ...
            (floodedRegionTotalDepth(outletY,outletX) / floodedRegionCellsNo(outletY,outletX))

            % a) �������� ���差�� �ʰ��Ѵٸ�,
            % (a) ���ⱸ�� �������� flooded region �ʰ� ��� �������� ����
            inputFlux(outletY,outletX) ...
                = inputFlux(outletY,outletX) ...
                + (inputFloodedRegion(outletY,outletX) ...      % [m/subDT]
                    - floodedRegionTotalDepth(outletY,outletX) ...  % [m/subDT]
                        / floodedRegionCellsNo(outletY,outletX));

            % * ���� �������� �������� �ʰ��ߴٰ� ǥ����
            isFilled(outletY,outletX) = true;

        % else

            % b) �������� ���差�� �ʰ����� �ʴ´ٸ�, ���ⱸ�� �������� 0�� �Է�            

        end

        % b. (�ܰ� ��迡 ��ġ��) ���ⱸ�� ������ ������
        % * ���ⱸ�� ���� ��迡 ��ġ�ϱ� ������, ��õ�ۿ뿡 ���� ������ ���
        %   ������ ����� �� ����. �ܰ� ���� ���Ե� ������ ��� ���ŵǱ�
        %   ������ �ܰ� ��迡���� �������� �� ��������
        % * ����: ������ outputFlux�� ���� ������� �����Ƿ� �ּ� ó��
        % outputFlux(outletY,outletX) = inputFlux(outletY,outletX);

        % c. ���ⱸ�� ������ �β� ��ȭ�� [m/subDT]
        % * ����: 0���� ���ǹ��ϹǷ� �ּ� ó��
        % dSedimentThick(outletY,outletX) ...
        %     = inputFlux(outletY,outletX) - outputFlux(outletY,outletX);
        %     => 0
        
        % d. ���ⱸ�� �� ��ȭ��[m/subDT]�� ����
        % * ����: 0���� ���ǹ��ϹǷ� �ּ� ó��
        % dElev(outletY,outletX) = dSedimentThick(outletY,outletX);
        %     => 0

    end % if IsBoundary(outletY,outletX,Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND)
    
    
    % 6) flooded region���� ������ �������� ���差�� �ʰ��ߴ��� Ȯ����
    if isFilled(outletY,outletX) == true

        % (1) ������ �������� ���差�� �ʰ��ߴٸ�, flooded region ���ⱸ��
        %     ���� ����ߴ��� Ȯ����         
        if dElev(outletY,outletX) > 0

            % A. ���ⱸ�� ���� ����ߴٸ�(���� 1,6) ���ⱸ�� �������� ���Ե�
            %    ���������� ���ٴ� �ǹ�. ���� flooded region�� ���� ���ⱸ
            %    �� �̻����� �����.

            % A) flooded region�� ���ⱸ �� �̻����� ����ϴ� ���� [m/subDT]
            sedimentDepthToBeAdded(outletY,outletX) ...
                = dElev(outletY,outletX) ...
                / ( floodedRegionCellsNo(outletY,outletX) ...
                + outletWeightToBeAdded );

            % B) flooded region�� ������ �β� ��ȭ���� ����ϴ� ���̷� ������Ŵ
            dSedimentThick(currentFloodedRegion) ...
                = floodedRegionLocalDepth(currentFloodedRegion) ...
                + sedimentDepthToBeAdded(outletY,outletX) ...
                + verySmallRandomValues(currentFloodedRegion);

            % C) ���ⱸ�� ������ �β� ��ȭ�� ����
            dSedimentThick(outletY,outletX) ...
                = sedimentDepthToBeAdded(outletY,outletX) ...
                * outletWeightToBeAdded;

        else % dElev(outletY,outletX) <= 0

            % B. ���ⱸ�� ���� �����ϰų�(���� 2,7) ���ٸ�(���� 11,13)
            %    flooded region ���� ���� ���ⱸ�� ����ŭ �����
            % * ���ⱸ�� ������ �β� ��ȭ���� �������� ����

            % A) flooded region�� �� ������ �β� ��ȭ���� ���� ���ⱸ ����ŭ
            %    ��½�Ŵ
            dSedimentThick(currentFloodedRegion) ...
                = floodedRegionLocalDepth(currentFloodedRegion) ...
                + verySmallRandomValues(currentFloodedRegion);

        end % dElev(outletY,outletX) > 0

    else % isFilled(outletY,outletX) == false

        % (2) ������ �������� ���差���� ���� ���
        % * ����: flooded region���� ������ �������� ���� ���� ������ �����Ǵ�
        %   �˰����� flooded region�� �а� ��Ÿ���� ����(Ư�� rand �Լ���
        %   �Լ��� �̿��Ͽ� ���� �ʱ� ����)������ ����� ���� �ð��� �ҿ�Ǳ�
        %   ������, ��Ⱓ�� ���� �ߴ��� ������ ���� ������ �˰����� �̿���

        % A. ������ �˰����� �̿��� �������� Ȯ����
        if FLUVIALPROCESS_COND == SIMPLE

            % A) ������ �˰����� �̿��Ѵٸ�,
            % (A) flooded region������ ������ �������� ����ϴ� ���
            %     ����[m^3/m^2]�� ����
            increasingHeightByInput = inputFloodedRegion(outletY,outletX);
            % * ����: floodedRegionCellsNo(outletY,outletX) ���� �ʿ� ����
            %   �̹� ������ ������.

            % (B) flooded region�� ������ �β� ��ȭ���� ��� ���̸�ŭ ������Ŵ
            dSedimentThick(currentFloodedRegion) ...
              = increasingHeightByInput ...
              + verySmallRandomValues(currentFloodedRegion);
          
            % for debug
            if min(dSedimentThick(currentFloodedRegion)) < 0
                warning('FluvialProcess:negativeFloodedRegionInput', 'negative flooded region input');
            end

        else % FLUVIALPROCESS_COND == DETAIL

            % B) �ڼ��� �˰����� �̿��Ѵٸ�,
            % (A) ������ �������� flooded region�� ���� ���� ������ ä��鼭
            %     ����ϸ�, �̷� ���� �������� ���� ������ flooded region��
            %     �ִ� ���̴� ���� �۾���

            % a. ���� ó���� flooded region�� local depth�� ������
            currentLocalDepth = floodedRegionLocalDepth(currentFloodedRegion);

            % b. flooded region������ ������ �������� ����ϴ� ����[m^3/m^2]
            increasingHeightByInput = inputFloodedRegion(outletY,outletX);
            % * ����: floodedRegionCellsNo(outletY,outletX) ���� �ʿ� ����

            % c. ���� ó���� flooded region�� 2�� �̻��� ���� �����Ǿ����� Ȯ��
            if floodedRegionCellsNo(outletY,outletX) > 1

                % a) ���� ó���� flooded region�� 2�� �̻��� ���� �����Ǿ�
                %    �ִٸ�, ������ �������� ���� ���� �ٴ��� ���� ä��

                % (a) local depth�� ������������ ������
                sortedCurrentLocalDepth = sort(currentLocalDepth,'descend');

                % (b) ������ �������� flooded region�� ���� ���� �ٴ��� ä���
                %     ���� ��[m^3/m^2]�� ������ �������� ����ϴ� ���̷� ����
                remainedInput = increasingHeightByInput;

                % (c) ���� �������� ���� ���� ������ flooded region�� �ٴ��� ä��
                isDone = false;

                while (isDone == false)

                    % 1. ���� ���� ���� ��(local depth�� ���� ū ��)�� ���̸� �ľ���
                    maxLocalDepth = max(sortedCurrentLocalDepth(:));

                    % 2. ���� ���� ���� ��(��)�� �� �������� �ľ���
                    maxLocalDepthCellsNo ...
                      = find(sortedCurrentLocalDepth == maxLocalDepth);
                    maxLocalDepthCellsNo = size(maxLocalDepthCellsNo,1);

                    % 3. ���� ���� ���� ��(��)�� ���� flooded region�� ��
                    %    ���� ���������� Ȯ����
                    if maxLocalDepthCellsNo ...
                            ~= floodedRegionCellsNo(outletY,outletX)

                        % 1) �������� �ʴٸ�, ���� flooded region�� ���̰�
                        %    ���� �ٸ��ٴ� �ǹ�. ���� flooded region��
                        %    ���� ���� �ٴں��� ä��

                        % (1) �������� ���� ���� ���̸� �ľ�
                        secondMaxLocalDepth = sortedCurrentLocalDepth ...
                            (maxLocalDepthCellsNo+1,1);

                        % (2) ���� ���� ���� ���� �������� ���� ������ ����
                        depthDifference ...
                            = maxLocalDepth - secondMaxLocalDepth;

                        % (3) ���� ���� ��(��)�� ������ ��[m^3/m^2]
                        depthToBeDeposited ...
                            = depthDifference * maxLocalDepthCellsNo;

                        % (4) �����ִ� ���� �������� ���� ���� ������ ��� ��
                        if remainedInput > depthToBeDeposited

                            % A. �����ִ� ���� �������� ���� ������ �纸��
                            %    ũ�ٸ�, �����ִ� ���� �������� ���� ����
                            %    ���� ��(��)�� ä��� ���� ���� ��(��)��
                            %    ���̸� �������� ���� ���� ���̷� ������
                            sortedCurrentLocalDepth ...
                                (1:maxLocalDepthCellsNo,1) ...
                                    = secondMaxLocalDepth;

                            remainedInput ...
                                = remainedInput - depthToBeDeposited;

                        else % remainedInput <= depthToBeDeposited

                            % B. �����ִ� ���� �������� ���� ������ �纸��
                            %    �۴ٸ�, ���������� �����ִ� ���� ��������
                            %    ���� ���� ��(��)�� ä��鼭 ����� ���̸�
                            %    ����

                            % A) �����ִ� ���� �������� ���� ���� ����
                            %    ��(��)�� ����ŭ ����
                            finalDepthToBeDeposited ...
                                = remainedInput / maxLocalDepthCellsNo;

                            % B) ���� flooded region�� �ִ� ���̸� ����
                            maxDepth ...
                            = maxLocalDepth - finalDepthToBeDeposited;

                            % C) ���� ���� ���� ���̸� ����
                            sortedCurrentLocalDepth ...
                                (1:maxLocalDepthCellsNo,1) = maxDepth;

                            % D) �ִ� ���̸� �������Ƿ� �ݺ��� ��ħ
                            isDone = true;

                        end % remainedInput > depthToBeDeposited

                    else  % maxLocalDepthCellsNo ...
                          %   ~= floodedRegionCellsNo(outletY,outletX)

                        % 2) �����ϴٸ�, flooded region ��ü ���̰�
                        %    �����ϴٴ� �ǹ�. ���� �����ִ� ���� ��������
                        %    ���� flooded region �� ���� ������ �̸� �ִ�
                        %    ���̿��� ��

                        % (1) �����ִ� ���� �������� ���� ���� ���� ��(��)��
                        %     ����ŭ ����
                        finalDepthToBeDeposited ...
                            = remainedInput / maxLocalDepthCellsNo;

                        % (2) ���� flooded region�� �ִ� ���̸� ����
                        maxDepth ...
                            = maxLocalDepth - finalDepthToBeDeposited;

                        % (3) �ִ� ���̸� �������Ƿ� �ݺ��� ����
                        isDone = true;                            

                    end % if maxLocalDepthCellsNo ...

                end % while (isDone == false)

            else % floodedRegionCellsNo(outletY,outletX) <= 1

                % b) ���� ó���� flooded region�� �ϳ��� ���̶��, ������
                %    ������ �� ��ü�� flooded region�� �����ϴ� ���̰� ��

                % (a) flooded region�� �ִ� ���̴� local depth - flooded
                %     region������ ������ �������� �����ϴ� ����)��
                % * ����: flooded region ���� �ϳ��� ���, ���� local depth��
                %   total depth�� ������
                maxDepth ...
                    = ( floodedRegionTotalDepth(outletY,outletX) ...
                        - increasingHeightByInput );

            end % floodedRegionCellsNo(outletY,outletX) > 1

            % * ���ⱸ�� �� ���� ���θ� Ȯ���� �ʿ���� flooded region �ִ�
            %   ���̱��� �� ������ �β� ��ȭ���� �����ϸ� ��
            % * ����(4,5,9,10/3,8/12,13)
            
            satisfyingCells = ...
                currentFloodedRegion & (floodedRegionLocalDepth > maxDepth);

            dSedimentThick(satisfyingCells) ...
                = floodedRegionLocalDepth(satisfyingCells) - maxDepth ...
                + verySmallRandomValues(satisfyingCells);

        end % if FLUVIALPROCESS_COND 

    end % isFilled(outletY,outletX) == true
        
end % for ithFloodedRegion = 1:floodedRegionsNo

%--------------------------------------------------------------------------
% �ܰ� ������ �������� ������ �β� ��ȭ���� �ݿ��� [m/subDT]
% * ����: inputFlux�� �ܰ� ��谪�� �̿��Ͽ� �� ������ ��� ħ������ ����
%   ��� ���� �� ������ ������� ��

dSedimentThick(OUTER_BOUNDARY) = inputFlux(OUTER_BOUNDARY);

end % FluvialProcess end