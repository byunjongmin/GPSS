% =========================================================================
%> @section INTRO EstimateSubDT
%>
%> - �ӽ� ���� �����ð� ���� ��õ�� ���� �� ��ȭ���� �̿��� �Ϸ� ��������
%>   ���� ������ ��簡 0�� �Ǵµ� �ɸ��� �ð�[trialTime]�� ���Ͽ� �̸� ����
%>   �����ð����� �����ϴ� �Լ�
%>
%>  - ����: ���� ������ ��簡 0�� �ȴٴ� �ǹ̴� �Ϸ� ������ �� ����
%>    ���������ٴ� �ǹ���. ���� �����ð��� �� ����� �Ϸ��� �⺹��
%>    �����Ǵ� ������ �ذ��ϱ� ���� �˰���
%>  - ���� : Tucker�� GOLEM���� �� �˰����� �����Ͽ� ������
%>
%>  - History
%>   - 100227 GPSS2D08.m
%>    - FluvialProcess 0.6�� �����Ͽ���, minTakenTime�� ���̴� �����
%>      �����Ͽ���
%>   - 100208 GPSS2d07.m
%>    - ���� ���� �ð����� ���ϴ� �뵵�� ����ϱ� ���� �ܼ��ϰ� ����
%>   - 100124
%>    - ���� ������ ��簡 0�� �Ǵ� �ð��� �ľ��ϴ� �Լ��� ����鼭 �Լ� �̸���
%>      EstimateMinTakenTime���� ������
%>   - 100104
%>    - flooded region�� ���� ���ⱸ�� �� �� ��ȭ���� ���ϴ� �˰����� ����
%>      ������. Ư�� ���ⱸ���� ������������ ���� ������ ��ݷ��� ���̴µ�
%>      �־����� �ξ���
%>   - 091225
%>    - flooded region �� sink �� ������ FluvialProcess �Լ� ���� �� ���ⱸ��
%>      ������ �� �������� ������ �߻��Ͽ�, �̸� �ذ��ϱ� ���� �õ��� ��
%>   - 091221
%>    - �������� ä���� flooded region�� ���ⱸ ���� ������������ ��������
%>      ������ �ذ��ϰ�, �������� ä������ ���� flooded region������ ���� ����
%>      �������� ���� �̵��� �Ͼ���� ��
%>
%>
%> @version 0.1
%> @callgraph
%> @callergraph
%>
%> @retval subDT                    : ���� �����ð� [s]
%> @retval sumSubDT                 : ���� ���� �����ð� [s]
%> @retval nt                       : ���� �����ð� ������ ���� ����
%>
%> @param mRows                     : ���� (�ܰ� ��� ����) ���� �� ����
%> @param nCols                     : ���� (�ܰ� ��� ����) ���� �� ����
%> @param elev                      : ��ǥ �� [m]
%> @param dSedimentThick            : �ӽ� ���� ���� �ð� ������ ������ �β� ��ȭ�� [m/subDT]
%> @param dBedrockElev              : �ӽ� ���� ���� �ð� ������ ��ݾ� �� ��ȭ�� [m/subDT]
%> @param trialTime                 : �ӽ� ���� ���� �ð� [s]
%> @param sumSubDT                  : ���� ���� ���� �ð� [s]
%> @param minSubDT                  : �ּ����� ���� ���� �ð� [s]
%> @param basicManipulationRatio    : �ݺ��� �� �ӽ� ���� �����ð� ������ ���õ� ������ ���
%> @param nt                        : �ݺ��� �� �ӽ� ���� �����ð� ������ ���õ� ������ ����
%> @param bankfullTime              : �������� [s]
%> @param consideringCellsNo        : ��õ�ۿ��� �Ͼ�� ������ ��
%> @param sortedYXElev              : ���� �� ������ ������ Y,X ��ǥ��
%> @param SDSNbrY                   : �ִ��Ϻΰ�� ������ ����Ű�� ���� ���� Y ��ǥ
%> @param SDSNbrX                   : �ִ��Ϻΰ�� ������ ����Ű�� ���� ���� X ��ǥ
%> @param floodedRegionCellsNo      : ���� flooded region �� ����
%> @param e1LinearIndicies          : ���� ������ ����Ű�� ���� �� ����
%> @param outputFluxRatioToE1       : ���� ���⿡ ���� ���� ���� �й�Ǵ� ����
%> @param e2LinearIndicies          : ���� ������ ����Ű�� ���� �� ����
%> @param outputFluxRatioToE2       : ���� ���⿡ ���� ���� ���� �й�Ǵ� ����
% =========================================================================
function [subDT,sumSubDT,nt]= EstimateSubDT(mRows,nCols,elev,dSedimentThick,dBedrockElev,trialTime,sumSubDT,minSubDT,basicManipulationRatio,nt,bankfullTime,consideringCellsNo,sortedYXElev,SDSNbrY,SDSNbrX,floodedRegionCellsNo,e1LinearIndicies,outputFluxRatioToE1,e2LinearIndicies,outputFluxRatioToE2)
%
% function EstimateSubDT
%

% 1. �ݺ��� �� ���� �ʱ�ȭ
takenTime = inf(mRows,nCols);   % ���� �ҿ� �ð�

% 2. �ӽ� ���� �����ð� ������ �� ��ȭ�� ����
dElev = dSedimentThick + dBedrockElev;

%--------------------------------------------------------------------------
% ���� ���� �غ�
mexSortedIndicies ...       % sortedYXElev�� ���� ���� ����
    = (sortedYXElev(:,2)-1)*mRows + sortedYXElev(:,1);
mexSDSNbrIndicies ...       % SDSNbrY,SDSNbrX�� ���� ���� ����
    = (SDSNbrX-1)*mRows + SDSNbrY;

takenTime ...                    0 �Ϸ����� ������ ��簡 0�� �Ǵ� �ð� [s]
    = EstimateSubDTMex ...
 	(mRows ...                   0 . �� ����
 	,nCols ...                   1 . �� ����
 	,consideringCellsNo); ...    2 . ��õ�ۿ��� �߻��ϴ� �� ��
%----------------------------- mexGetVariablePtr �Լ��� �����ϴ� ����
% mexSortedIndicies ...        3 . �������� ���ĵ� ����
% e1LinearIndicies ...         4 . ���� �� ����
% e2LinearIndicies ...         5 . ���� �� ����
% outputFluxRatioToE1 ...      6 . ���� ������ ���� ����
% outputFluxRatioToE2 ...      7 . ���� ������ ���� ����
% mexSDSNbrIndicies ...        8 . ���� �� ����
% floodedRegionCellsNo ...     9 . flooded region ���� �� ��
% dElev ...                    10 . �� ��ȭ�� [m/trialTime]
% elev ...                     11 . �� [m]
%----------------------------- mexGetVariable �Լ��� �����ؿ��� ����
% takenTime ...                0 . inf�� �ʱ�ȭ�� ��� ����

%--------------------------------------------------------------------------

% 4. ���� ���� ��簡 0�� �Ǵµ� �ɸ��� �ð�[trialTime]�� �ּ��� �ð��� ����
% * ����: ���� ���� ���� 2�� �̻��̶��, ��簡 ū ���� ����. ������ �̰ͱ���
%         ��������� ����.
[minTakenTimeToBeFlat,minLocation] = min(takenTime(:));

%--------------------------------------------------------------------------
% minTakenTime�� ���� �ø��� ��� : GPSS2D07.m ����
%-------------------------------------------------------------------------

% 5. ���� �����ð�[s]
subDT = (minTakenTimeToBeFlat * trialTime) ... % ���� ��ȭ: [trialTime] -> [s]
    * 0.95;                                         % * ����: �ּҽð����� �۰���

% 6. ���� �ӽ� ���� �����ð��� ����
% * ����: �� ���� ���, ���� �ʱ⿡�� �ּ� �ð��� ª���� �Ĺݺη� ������ ����
%         �����. ���� �ּ� �ð��� ������� �ӽ� ���� �����ð��� �������Ѽ�
%         ��ü���� �� ���� �ð��� ����. ������ ������ �׽�Ʈ�� �������� �ʾ���

% 1) �ּ� �ð��� �ӽ� ���� �����ð��� ��
if minTakenTimeToBeFlat > trialTime

    % (1) �ּ� �ð��� �ӽ� ���� �����ð����� ũ�ٸ�,
    %     ���� �ӽ� ���� �����ð��� �ø��� ����, ������ 3 ���ҽ�Ŵ
    nt = nt - 3;
    
    % * ����: ���� �����ð��� �ӽ� ���� �����ð����� ������
    subDT = trialTime;

elseif minTakenTimeToBeFlat < trialTime * basicManipulationRatio

    % (2) ���� �ּ� �ð��� �ӽ� ���� �����ð��� ���ݺ��� �۴ٸ�,
    %     ���� �ӽ� ���� �����ð��� ���̱� ���� ������ 1 ������Ŵ
    nt = nt + 1;

end

% 7. ���� ���� �����ð��� ������ ��ݷ� ������ �ּ� �������� �۴ٸ�,
%    �ּ� ������ ������
if subDT < minSubDT

    subDT = minSubDT;

end

% 8. ���� ���� �����ð��� ���� ���� �������� ���� �Ⱓ�� �ʰ��ϸ�
%    �ʰ����� ���� �縸ŭ�� ���� �����ð����� ������
sumSubDT = sumSubDT + subDT;

if sumSubDT > bankfullTime

    exceededTime = sumSubDT - bankfullTime;

    subDT = subDT - exceededTime;

end

end % EstimateSubDT end