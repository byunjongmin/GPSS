function ...
takenTime ...
= EstimateSubDTMex_m ...
(mRows ...                 % 행 개수
,nCols ...                 % 열 개수
,consideringCellsNo ...    % 하천작용이 발생하는 셀 수
,sortedYXElev ...          % 고도순으로 정렬된 색인
,e1LinearIndicies ...      % 다음 셀 색인
,e2LinearIndicies ...      % 다음 셀 색인
,outputFluxRatioToE1 ...   % 다음 셀로의 유출 비율
,outputFluxRatioToE2 ...   % 다음 셀로의 유출 비율
,SDSNbrY ...               % 다음 셀 색인
,SDSNbrX ...               % 다음 셀 색인
,floodedRegionCellsNo ...  % flooded region 구성 셀 수
,dElev ...                 % 고도 변화율 [m/trialTime]
,elev ...                  % 고도 [m]
,takenTime)                % inf로 초기화된 출력 변수


% 1. (높은 고도의 셀부터 다음 셀과의 경사가 0이 되는 시간을 추정함
for iCell = 1:consideringCellsNo
    
    % (1) i 번째 셀의 좌표
    y = sortedYXElev(iCell,1);
    x = sortedYXElev(iCell,2);
    
    % A. i 번째 셀이 유출구인지 확인함
    if floodedRegionCellsNo(y,x) == 0

        % A) 유출구가 아니라면, i번째 셀의 고도 변화율을 무한 유향을 따라 다음
        %    다음 셀들의 고도 변화율과 비교함
        % * 원리: 다음 셀들(e1,e2)의 고도 변화율이 더 작은 경우, trialTime 내에
        %   상류와 하류의 기복이 역전됨. 따라서 기복 역전이 발생하기 직전까지의 시간, 
        %   즉 다음 셀들(e1,e2)과의 경사가 0이 되는데 걸리는 시간을 구하고 이를 나중에
        %   세부 단위시간으로 설정함.
        % * 주의: 다음 셀로의 흐름 비율이 적어도 0.0000001 보다는 큰 경우에만
        %   경우에만 시간을 구함. e1 또는 e2 중 한 셀로만 흐름이 전달되더라도
        %   유효숫자 한계로 인해 흐름 비율이 정확하게 1 또는 0이 되지 않기 때문임.
        %   즉 적어도 0.0000001 보다 클 경우에만 흐름이 실제로 전달된다고 가정함.
        %   따라서 이보다 작은 경우에는 연산이 불필요함

        % 반복문 내 변수 초기화
		takenTimeForE1 = inf; % 다음 셀(e1)과의 경사가 0이 되는 시간
		takenTimeForE2 = inf; % 다음 셀(e2)과의 경사가 0이 되는 시간

        % (A) i번째 셀의 고도 변화율이 e1의 고도 변화율보다 적다면, 다음 셀과의
        %     경사가 0이 되는데 걸리는 시간을 구함
        % * 주의: takenTimeForEx의 분자는 항상 음의 값을 가짐. 따라서 if 조건문이
        %	참인 경우 분포 또한 음의 값을 가지므로 전체는 항상 양의 값을 가짐
        [e1Y,e1X] = ind2sub([mRows,nCols],e1LinearIndicies(y,x));
        if (dElev(y,x) < dElev(e1Y,e1X)) ...
            && (outputFluxRatioToE1(y,x) > 0.0000001)

            takenTimeForE1 = (elev(e1Y,e1X) - elev(y,x)) ...
                / (dElev(y,x) - dElev(e1Y,e1X));

        end

        % (B) i번째 셀의 고도 변화율이 e2의 고도 변화율보다 적다면, 다음 셀과의
        %     경사가 0이 되는데 걸리는 시간을 구함
        [e2Y,e2X] = ind2sub([mRows,nCols],e2LinearIndicies(y,x));
        if (dElev(y,x) < dElev(e2Y,e2X) ) ...
            && (outputFluxRatioToE2(y,x) > 0.0000001)

            takenTimeForE2 = (elev(e2Y,e2X) - elev(y,x))...
                / (dElev(y,x) - dElev(e2Y,e2X));

        end

        % (C) e1과 e2중 소요 시간이 적은 것을 최종 소요 시간으로 기록함
        takenTime(y,x) = min(takenTimeForE1,takenTimeForE2);

    else % floodedRegionCellsNo(y,x) ~= 0

        % B) 유출구인 경우에는 i번째 셀의 고도 변화율을 최대하부경사 유향을 따라
        %    다음 셀의 고도 변화율과 비교함

        % (A) 다음 셀의 좌표
        nextY = SDSNbrY(y,x);
        nextX = SDSNbrX(y,x);

        % (B) i번째 셀의 고도 변화율이 다음 셀의 고도 변화율보다 작다면 다음
        %     셀과의 경사가 0이 되는데 걸리는 시간을 구함
        if dElev(y,x) < dElev(nextY,nextX)

            takenTime(y,x) = (elev(nextY,nextX) - elev(y,x)) ...
                / (dElev(y,x) - dElev(nextY,nextX));

        end
    end
end % for iCell =

