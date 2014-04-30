function ...
takenTime ...
= EstimateSubDTMex_m ...
(mRows ...                 % �� ����
,nCols ...                 % �� ����
,consideringCellsNo ...    % ��õ�ۿ��� �߻��ϴ� �� ��
,sortedYXElev ...          % �������� ���ĵ� ����
,e1LinearIndicies ...      % ���� �� ����
,e2LinearIndicies ...      % ���� �� ����
,outputFluxRatioToE1 ...   % ���� ������ ���� ����
,outputFluxRatioToE2 ...   % ���� ������ ���� ����
,SDSNbrY ...               % ���� �� ����
,SDSNbrX ...               % ���� �� ����
,floodedRegionCellsNo ...  % flooded region ���� �� ��
,dElev ...                 % �� ��ȭ�� [m/trialTime]
,elev ...                  % �� [m]
,takenTime)                % inf�� �ʱ�ȭ�� ��� ����


% 1. (���� ���� ������ ���� ������ ��簡 0�� �Ǵ� �ð��� ������
for iCell = 1:consideringCellsNo
    
    % (1) i ��° ���� ��ǥ
    y = sortedYXElev(iCell,1);
    x = sortedYXElev(iCell,2);
    
    % A. i ��° ���� ���ⱸ���� Ȯ����
    if floodedRegionCellsNo(y,x) == 0

        % A) ���ⱸ�� �ƴ϶��, i��° ���� �� ��ȭ���� ���� ������ ���� ����
        %    ���� ������ �� ��ȭ���� ����
        % * ����: ���� ����(e1,e2)�� �� ��ȭ���� �� ���� ���, trialTime ����
        %   ����� �Ϸ��� �⺹�� ������. ���� �⺹ ������ �߻��ϱ� ���������� �ð�, 
        %   �� ���� ����(e1,e2)���� ��簡 0�� �Ǵµ� �ɸ��� �ð��� ���ϰ� �̸� ���߿�
        %   ���� �����ð����� ������.
        % * ����: ���� ������ �帧 ������ ��� 0.0000001 ���ٴ� ū ��쿡��
        %   ��쿡�� �ð��� ����. e1 �Ǵ� e2 �� �� ���θ� �帧�� ���޵Ǵ���
        %   ��ȿ���� �Ѱ�� ���� �帧 ������ ��Ȯ�ϰ� 1 �Ǵ� 0�� ���� �ʱ� ������.
        %   �� ��� 0.0000001 ���� Ŭ ��쿡�� �帧�� ������ ���޵ȴٰ� ������.
        %   ���� �̺��� ���� ��쿡�� ������ ���ʿ���

        % �ݺ��� �� ���� �ʱ�ȭ
		takenTimeForE1 = inf; % ���� ��(e1)���� ��簡 0�� �Ǵ� �ð�
		takenTimeForE2 = inf; % ���� ��(e2)���� ��簡 0�� �Ǵ� �ð�

        % (A) i��° ���� �� ��ȭ���� e1�� �� ��ȭ������ ���ٸ�, ���� ������
        %     ��簡 0�� �Ǵµ� �ɸ��� �ð��� ����
        % * ����: takenTimeForEx�� ���ڴ� �׻� ���� ���� ����. ���� if ���ǹ���
        %	���� ��� ���� ���� ���� ���� �����Ƿ� ��ü�� �׻� ���� ���� ����
        [e1Y,e1X] = ind2sub([mRows,nCols],e1LinearIndicies(y,x));
        if (dElev(y,x) < dElev(e1Y,e1X)) ...
            && (outputFluxRatioToE1(y,x) > 0.0000001)

            takenTimeForE1 = (elev(e1Y,e1X) - elev(y,x)) ...
                / (dElev(y,x) - dElev(e1Y,e1X));

        end

        % (B) i��° ���� �� ��ȭ���� e2�� �� ��ȭ������ ���ٸ�, ���� ������
        %     ��簡 0�� �Ǵµ� �ɸ��� �ð��� ����
        [e2Y,e2X] = ind2sub([mRows,nCols],e2LinearIndicies(y,x));
        if (dElev(y,x) < dElev(e2Y,e2X) ) ...
            && (outputFluxRatioToE2(y,x) > 0.0000001)

            takenTimeForE2 = (elev(e2Y,e2X) - elev(y,x))...
                / (dElev(y,x) - dElev(e2Y,e2X));

        end

        % (C) e1�� e2�� �ҿ� �ð��� ���� ���� ���� �ҿ� �ð����� �����
        takenTime(y,x) = min(takenTimeForE1,takenTimeForE2);

    else % floodedRegionCellsNo(y,x) ~= 0

        % B) ���ⱸ�� ��쿡�� i��° ���� �� ��ȭ���� �ִ��Ϻΰ�� ������ ����
        %    ���� ���� �� ��ȭ���� ����

        % (A) ���� ���� ��ǥ
        nextY = SDSNbrY(y,x);
        nextX = SDSNbrX(y,x);

        % (B) i��° ���� �� ��ȭ���� ���� ���� �� ��ȭ������ �۴ٸ� ����
        %     ������ ��簡 0�� �Ǵµ� �ɸ��� �ð��� ����
        if dElev(y,x) < dElev(nextY,nextX)

            takenTime(y,x) = (elev(nextY,nextX) - elev(y,x)) ...
                / (dElev(y,x) - dElev(nextY,nextX));

        end
    end
end % for iCell =

