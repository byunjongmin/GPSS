% =========================================================================
%> @section INTRO CalcSDSFlow
%>
%> - 최대 하부 경사를 가지는 이웃 셀을 찾아 이의 방향과 경사를 반환하고, 
%>   이 이웃 셀의 좌표를 SDSNbrX, SDSNbrY에 기록하는 함수.
%>
%>  - 연산은 CalcInfinitiveFlow 함수와 같이 격자(배열) 단위로 수행함.
%>
%> @version 0.1
%>
%> @callgraph
%> @callergraph
%>
%> @retval steepestDescentSlope         : 경사
%> @retval slopeAllNbr                  : 8개 이웃 셀과의 경사
%> @retval SDSFlowDirection             : 유향
%> @retval SDSNbrY                      : 다음 셀 Y 좌표값
%> @retval SDSNbrX                      : 다음 셀 X 좌표값
%>
%> @param mRows                         : 모형 (외곽 경계 포함) 영역 행 개수
%> @param nCols                         : 모형 (외곽 경계 포함) 영역 열 개수
%> @param Y                             : 외곽 경계를 제외한 Y축 크기
%> @param X                             : 외곽 경계를 제외한 X축 크기
%> @param Y_INI                         : 모형 영역 Y 시작 좌표값(=2)
%> @param Y_MAX                         : 모형 영역 Y 마지막 좌표값(=Y+1)
%> @param X_INI                         : 모형 영역 X 시작 좌표값(=2)
%> @param X_MAX                         : 모형 영역 X 마지막 좌표값(=X+1)
%> @param Y_TOP_BND                     : 모형 외곽 위 경계 Y 좌표값
%> @param Y_BOTTOM_BND                  : 모형 외곽 아래 경계 Y 좌표값
%> @param X_LEFT_BND                    : 모형 외곽 좌 경계 X 좌표값
%> @param X_RIGHT_BND                   : 모형 외곽 우 경계 X 좌표값
%> @param QUARTER_PI                    : pi * 0.25
%> @param DISTANCE_RATIO_TO_NBR         : 셀 크기를 기준으로 이웃 셀간 거리비 [m]
%> @param elev                          : 지표 고도 [m]
%> @param dX                            : 셀 크기 [m]
%> @param IS_LEFT_RIGHT_CONNECTED       : 좌우 외곽 경계 연결을 결정
%> @param ithNbrYOffset                 : 중앙 셀로 부터 8 방향 이웃 셀을 가리키기 위한 Y축 옵셋
%> @param ithNbrXOffset                 : 중앙 셀로 부터 8 방향 이웃 셀을 가리키기 위한 X축 옵셋
%> @param sE0LinearIndicies             : 외곽 경계를 제외한 중앙 셀
%> @param s3IthNbrLinearIndicies        : 8 방향 이웃 셀을 가리키는 3차원 색인 배열
% =========================================================================
function [steepestDescentSlope,slopeAllNbr,SDSFlowDirection,SDSNbrY,SDSNbrX] = CalcSDSFlow(mRows,nCols,Y,X,Y_INI,Y_MAX,X_INI,X_MAX,Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND,QUARTER_PI,DISTANCE_RATIO_TO_NBR,elev,dX,IS_LEFT_RIGHT_CONNECTED,ithNbrYOffset,ithNbrXOffset,sE0LinearIndicies,s3IthNbrLinearIndicies)
%
% function CalcSDSFlow
%

% 유향 및 경사 변수 초기화
SDSFlowDirection = nan(mRows,nCols);
steepestDescentSlope = nan(mRows,nCols);
slopeAllNbr = nan(mRows,nCols,8);
% 최대 하부 경사를 가지는 이웃 셀의 좌표를 기록하는 행렬 초기화
[SDSNbrX,SDSNbrY] = meshgrid(X_LEFT_BND:X_RIGHT_BND,Y_TOP_BND:Y_BOTTOM_BND);
% * 주의 : 연산은 격자 단위로 수행되는데 모델 영역 내부만을 대상으로 하기 때문에
%   경계를 제외한 배열을 생성하고 초기화한다. s는 mRows*nCols보다 작은 Y*X
%   크기를 가지는 행렬을 의미한다.
sSteepestDescentSlope = -inf(Y, X);
% 유향이 없을 경우에는 NaN으로 기록된다.
sSDSFlowDirection = nan(Y, X);
[sSDSNbrX,sSDSNbrY] = meshgrid(X_INI:X_MAX,Y_INI:Y_MAX);

% 개별 셀별로 연산을 수행하여 유향과 경사를 구하는 것이 아니라,
% 격자(배열) 단위로 연산을 수행한다.

% 중앙 셀의 (선형 색인이 가리키는) 고도를 저장한다.
sE0Elevation = elev(sE0LinearIndicies);

% 중앙 셀을 기준으로 8개 이웃 셀의 경사를 탐색하여 유향과 경사를 결정한다.

% 최대 하부 경사를 가지는 이웃 셀의 Y,X 좌표값 입력시 기본이 되는 좌표값
initialNbrX = sSDSNbrX;
initialNbrY = sSDSNbrY;

for ithNbr = 1:8

    % 선형 옵셋을 이용한 k 번째 이웃 셀의 고도
    sKthNbrElevation = elev(s3IthNbrLinearIndicies(:,:,ithNbr));

    % 중앙 셀과 k 번째 이웃 셀과의 경사를 구함
    sKthNbrSlope = (sE0Elevation - sKthNbrElevation) ...
    / (DISTANCE_RATIO_TO_NBR(ithNbr) * dX);

    % 차후를 위해 k 번째 이웃 셀과의 경사를 저장함
    slopeAllNbr(Y_INI:Y_MAX,X_INI:X_MAX, ithNbr) = sKthNbrSlope;

    % k 번째 이웃 셀과의 경사가 이전 최대 경사보다 큰 셀들을
    % biggerSlope으로 기록함
    biggerSlope = sKthNbrSlope > sSteepestDescentSlope;

    % biggerSlope에 해당하는 셀들을 대상으로
    % k 번째 이웃 셀의 좌표를 sSDSNbrY, sSDSNbrX에 기록함

    % 좌우가 연결되었는지 확인하고, 연결되었다면 offset 을 재설정한다.
    if IS_LEFT_RIGHT_CONNECTED == true
        
        if ithNbr == 1 || ithNbr == 2 || ithNbr == 8
            
            ithNbrXOffset2 = ones(Y,X);
            ithNbrXOffset2(:,X) = ithNbrXOffset2(:,X) - X;
            
            sSDSNbrY(biggerSlope) = initialNbrY(biggerSlope) ...
                + ithNbrYOffset(ithNbr);
            sSDSNbrX(biggerSlope) = initialNbrX(biggerSlope) ...
                + ithNbrXOffset2(biggerSlope);
            
        elseif ithNbr == 4 || ithNbr == 5 || ithNbr == 6
            
            ithNbrXOffset2 = - ones(Y,X);
            ithNbrXOffset2(:,1) = ithNbrXOffset2(:,1) + X;
            
            sSDSNbrY(biggerSlope) = initialNbrY(biggerSlope) ...
                + ithNbrYOffset(ithNbr);
            sSDSNbrX(biggerSlope) = initialNbrX(biggerSlope) ...
                + ithNbrXOffset2(biggerSlope);
            
        else % ithNbr == 3 || ithNbr == 7
        
            sSDSNbrY(biggerSlope) = initialNbrY(biggerSlope) ...
                + ithNbrYOffset(ithNbr);
            sSDSNbrX(biggerSlope) = initialNbrX(biggerSlope) ...
                + ithNbrXOffset(ithNbr);
        
        end

    
    else
        
        sSDSNbrY(biggerSlope) = initialNbrY(biggerSlope) ...
            + ithNbrYOffset(ithNbr);
        sSDSNbrX(biggerSlope) = initialNbrX(biggerSlope) ...
            + ithNbrXOffset(ithNbr);
        
    end
    
    % k 번째 이웃과의 경사가 양인 셀을 possitiveSlope이라고 기록한다.
    possitiveSlope = sKthNbrSlope > 0;

    % k 번째 이웃 셀과의 경사가 양이면서 동시에 이전 최대 경사보다 큰 셀에는
    % k 번째 이웃 셀의 방향을 유향으로 기록한다.
    sSDSFlowDirection(biggerSlope & possitiveSlope) ...
      = (ithNbr-1) * QUARTER_PI;

    % k 번째 이웃 셀과의 경사를 경사로 기록한다.
    sSteepestDescentSlope(biggerSlope) = sKthNbrSlope(biggerSlope);

end % for ithNbr = 1:8

% 최대 하부 경사 유향과 경사의 경계값을 설정한다.
% 모델 영역 경계의 유향과 경사는 NaN으로 기록된다.
SDSFlowDirection(Y_INI:Y_MAX,X_INI:X_MAX) = sSDSFlowDirection;
steepestDescentSlope(Y_INI:Y_MAX,X_INI:X_MAX) = sSteepestDescentSlope;
SDSNbrX(Y_INI:Y_MAX,X_INI:X_MAX) = sSDSNbrX;
SDSNbrY(Y_INI:Y_MAX,X_INI:X_MAX) = sSDSNbrY;

end % CalcSDSFlow end